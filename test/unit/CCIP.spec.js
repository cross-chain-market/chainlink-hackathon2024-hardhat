const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { assert } = require("chai");
const { ethers } = require("hardhat");

//TODO fix test
describe.skip("CCIP cross chain buying", () => {
    const checkUserBalance = async (address) => {
        const provider = ethers.provider;
        const balance = await provider.getBalance(address);
        console.log("user balance: ", ethers.utils.formatEther(balance));
    };

    const deployMarketplaceFixture = async () => {
        //  --- CCIP configurations --- //
        const localSimulatorFactory = await ethers.getContractFactory("CCIPLocalSimulator");
        const localSimulator = await localSimulatorFactory.deploy();

        /**
         * const config: {
            chainSelector_: bigint;
            sourceRouter_: string;
            destinationRouter_: string;
            wrappedNative_: string;
            linkToken_: string;
            ccipBnM_: string;
            ccipLnM_: string;
        } = await localSimulator.configuration();
         */
        const config = await localSimulator.configuration();
        // ---------------------------- //
        // Contracts are deployed using the first signer/account by default
        const [collectionOwner, marketplaceOwner, backendAccount, buyerAccount] =
            await ethers.getSigners();

        const MarketplaceFactory = await ethers.getContractFactory("Marketplace");
        const CollectionFactory = await ethers.getContractFactory("Collection");

        const options = { gasLimit: 30000000 }; // Set the gas limit as needed
        const marketplaceFactoryWithNewSigner = await MarketplaceFactory.connect(marketplaceOwner);
        const marketplaceContract = await marketplaceFactoryWithNewSigner.deploy(options);
        const collectionName = "My Collection";
        const ids = [10, 20, 30];
        const totalAmounts = [100, 200, 300];
        const baseImagePath = "https://example.com/images/";

        const collectionContract = await CollectionFactory.deploy(
            collectionName,
            ids,
            totalAmounts,
            baseImagePath
        );

        const CCIPMappingFactory = await ethers.getContractFactory("CCIPMapping");
        const CCIPMapping = await CCIPMappingFactory.deploy();
        await marketplaceContract.updateCCIPMapperAddress(CCIPMapping.address);

        const CCIPConnectorFactory = await ethers.getContractFactory("CCIPPing");

        const ccipPingContractSender = await CCIPConnectorFactory.deploy(
            config.linkToken_,
            config.sourceRouter_
        );
        await marketplaceContract.updateCCIPSourceConnector(ccipPingContractSender.address);

        network = await ethers.getDefaultProvider().getNetwork();
        console.log("chain id is:", network.chainId);
        await CCIPMapping.updateConnector(network.chainId, ccipPingContractSender.address);

        const ccipPingContractReciver = await CCIPConnectorFactory.deploy(
            config.linkToken_,
            config.destinationRouter_
        );

        await CCIPMapping.updateConnector(network.chainId, ccipPingContractReciver.address);

        const ccipBnMFactory = await ethers.getContractFactory("BurnMintERC677Helper");
        const ccipBnM = ccipBnMFactory.attach(config.ccipBnM_);

        await ccipBnM.drip(ccipPingContractSender.address);

        await localSimulator.requestLinkFromFaucet(
            ccipPingContractSender.address,
            BigInt(5_000_000_000_000_000)
        );

        return {
            marketplaceContract,
            collectionContract,
            ccipPingContractReciver,
            ccipPingContractSender,
            localSimulator,
            ccipBnM,
            config,
            marketplaceOwner,
            collectionOwner,
            buyerAccount,
        };
    };

    it("general test", async () => {
        const {
            marketplaceContract,
            collectionContract,
            marketplaceOwner,
            collectionOwner,
            buyerAccount,
            ccipBnM,
            ccipPingContractReciver,
            ccipPingContractSender,
            config,
        } = await loadFixture(deployMarketplaceFixture);
        console.log(await ccipBnM.balanceOf(ccipPingContractSender.address));
        console.log(await ccipBnM.balanceOf(ccipPingContractReciver.address));

        assert.equal(await collectionContract.owner(), collectionOwner.address);
        assert.equal(await collectionContract.name(), "My Collection");
        assert.equal(await collectionContract.balanceOf(collectionOwner.address, 10), 100);

        await collectionContract.setApprovalForAll(ccipPingContractReciver.address, true);
        const initialBalance = await collectionContract.balanceOf(collectionOwner.address, 10);

        // TODO call CCIP function
        
        const finalBalance = await collectionContract.balanceOf(collectionOwner.address, 10);
        assert.equal(Number(initialBalance), Number(finalBalance) + 20);
        assert.equal(Number(initialBalance), Number(finalBalance) + 20);
    });
});
