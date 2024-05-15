const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("Marketplace & collection uint tests", () => {
    const deployMarketplaceFixture = async () => {
        // Contracts are deployed using the first signer/account by default
        const [collectionOwner, marketplaceOwner, backendAccount, buyerAccount] =
            await ethers.getSigners();

        const MarketplaceFactory = await ethers.getContractFactory("Marketplace");
        const CollectionFactory = await ethers.getContractFactory("Collection");
        // Specify the gas limit in the deployment options
        const options = { gasLimit: 30000000 }; // Set the gas limit as needed
        const marketplaceFactoryWithNewSigner = await MarketplaceFactory.connect(marketplaceOwner);
        const marketplaceContract = await marketplaceFactoryWithNewSigner.deploy(options);
        const collectionName = "My Collection";
        const collectionImageUrl = "https://example.com/collection-image.jpg";
        const ids = [10, 20, 30];
        const totalAmounts = [100, 200, 300];
        const baseImagePath = "https://example.com/images/";
        const collectionContract = await CollectionFactory.deploy(
            collectionName,
            ids,
            totalAmounts,
            baseImagePath,
            marketplaceContract.address
        );
        return {
            marketplaceContract,
            collectionContract,
            marketplaceOwner,
            collectionOwner,
            buyerAccount,
        };
    };

    describe("Marketplace", () => {
        it("deploy", async () => {
            const {
                marketplaceContract,
                collectionContract,
                marketplaceOwner,
                collectionOwner,
                buyerAccount,
            } = await loadFixture(deployMarketplaceFixture);
            assert.equal(await marketplaceContract.owner(), marketplaceOwner.address);
        });

        it("buyListing (marketplace is not approved to transfer)", async () => {
            const {
                marketplaceContract,
                collectionContract,
                marketplaceOwner,
                collectionOwner,
                buyerAccount,
            } = await loadFixture(deployMarketplaceFixture);
            expect(await marketplaceContract.owner()).to.equal(marketplaceOwner.address);
            await collectionContract.setApprovalForAll(marketplaceContract.address, false);
            try {
                await marketplaceContract.buyListing(
                    await collectionContract.address,
                    10,
                    5,
                    { value: 30 }
                );
                expect.fail("Expected function call to revert, but it did not");
            } catch (err) {
                expect(err.message).to.contain("operator is not approved to do this operation");
            }
        });

        it("check transfer of tokens from OTA & to OTA", async () => {
            const {
                marketplaceContract,
                collectionContract,
                marketplaceOwner,
                collectionOwner,
                buyerAccount,
            } = await loadFixture(deployMarketplaceFixture);

            // Get initial and final balances of marketplaceContract
            const initialBalance = await ethers.provider.getBalance(marketplaceContract.address);

            // Send 10 ETH from marketplaceOwner to marketplaceContract
            await marketplaceOwner.sendTransaction({
                to: marketplaceContract.address,
                value: ethers.utils.parseEther("10"), // Sending 10 ETH
            });

            // Assert that the balance increased by 10 ETH
            expect(await marketplaceContract.getBalance()).to.be.greaterThan(initialBalance);

            // Assert that the balance decreased by 3 ETH
            const marketplaceOwnerInitialBalance = await ethers.provider.getBalance(
                marketplaceOwner.address
            );
            await marketplaceContract.transferTokens(
                marketplaceOwner.address,
                ethers.utils.parseEther("3")
            );
            const marketplaceOwnerFinalBalance = await ethers.provider.getBalance(
                marketplaceOwner.address
            );
            expect(marketplaceOwnerFinalBalance).to.be.greaterThan(marketplaceOwnerInitialBalance);
        });

        describe("buyListing (marketplace is approved to transfer)", () => {
            let marketplaceContract;
            let collectionContract;
            let marketplaceOwner;
            let collectionOwner;
            let buyerAccount;

            let collectionOwnerInitialBalance;
            let fee;
            let totalTransfered;
            let feeAmount;
            let transferredValue;
            let marketplaceInitialBalance;

            beforeEach(async () => {
                const {
                    marketplaceContract: _marketplaceContract,
                    collectionContract: _collectionContract,
                    marketplaceOwner: _marketplaceOwner,
                    collectionOwner: _collectionOwner,
                    buyerAccount: _buyerAccount,
                } = await loadFixture(deployMarketplaceFixture);

                marketplaceContract = _marketplaceContract;
                collectionContract = _collectionContract;
                marketplaceOwner = _marketplaceOwner;
                collectionOwner = _collectionOwner;
                buyerAccount = _buyerAccount;

                collectionOwnerInitialBalance = await ethers.provider.getBalance(
                    collectionOwner.address
                );

                fee = 2;
                totalTransfered = ethers.utils.parseEther("30");
                feeAmount = totalTransfered.mul(fee).div(100);
                transferredValue = totalTransfered.sub(feeAmount); // value sent in the purchase transaction
                marketplaceInitialBalance = await marketplaceContract.getBalance();
            });

            it("check owner of deployed contract", async () => {
                expect(await marketplaceContract.owner()).to.equal(marketplaceOwner.address);
            });

            it("check buyListing & updated balanced", async () => {
                // Connect to the marketplace contract with the buyerAccount
                const marketplaceContractWithBuyer = marketplaceContract.connect(buyerAccount);

                const tx = await marketplaceContractWithBuyer.buyListing(
                    await collectionContract.address,
                    10,
                    5,
                    { value: transferredValue }
                );

                // Get final balance of the collectionOwner after the purchase
                const collectionOwnerFinalBalance = await ethers.provider.getBalance(
                    collectionOwner.address
                );

                // Retrieve gas used from the transaction response
                const gasUsed = (await tx.wait()).gasUsed;

                // Calculate expected balance after deducting gas fees and transferred value
                const gasPrice = await ethers.provider.getGasPrice();
                const gasCost = gasUsed.mul(gasPrice);
                const expectedBalance = collectionOwnerInitialBalance
                    .add(transferredValue)
                    .sub(gasCost);

                const marginOfError = totalTransfered.mul(2).div(100); // 1% ETH

                // Check that the owner of the collection got payed for the transaction
                expect(collectionOwnerFinalBalance).to.be.greaterThan(
                    expectedBalance.sub(marginOfError)
                );

                // check that the marketplace contract got 2% of the payment
                const marketplaceFinalBalance = await marketplaceContract.getBalance();
                expect(marketplaceFinalBalance).to.be.greaterThan(marketplaceInitialBalance);
                const calculatedFee = ethers.utils.formatEther(
                    marketplaceFinalBalance.sub(marketplaceInitialBalance)
                );
                const feePercentage =
                    (calculatedFee * 100) / ethers.utils.formatEther(transferredValue);
                // console.log("transferredValue:", ethers.utils.formatEther(transferredValue));
                // console.log("fee: ", calculatedFee);
                // console.log("fee percentage: ", feePercentage);
                expect(feePercentage).to.equal(fee);
            });
        });
    });

    describe("Collection", async () => {
        it("deploy", async () => {
            const {
                marketplaceContract,
                collectionContract,
                marketplaceOwner,
                collectionOwner,
                buyerAccount,
            } = await loadFixture(deployMarketplaceFixture);
            assert.equal(await collectionContract.owner(), collectionOwner.address);
            assert.equal(await collectionContract.name(), "My Collection");
            assert.equal(await collectionContract.balanceOf(collectionOwner.address, 10), 100);
        });

        it("global variables", async () => {
            const {
                marketplaceContract,
                collectionContract,
                marketplaceOwner,
                collectionOwner,
                buyerAccount,
            } = await loadFixture(deployMarketplaceFixture);
            assert.equal(await collectionContract.name(), "My Collection");
        });

        it("balance of items in collection", async () => {
            const {
                marketplaceContract,
                collectionContract,
                marketplaceOwner,
                collectionOwner,
                buyerAccount,
            } = await loadFixture(deployMarketplaceFixture);
            assert.equal(await collectionContract.balanceOf(collectionOwner.address, 10), 100);
            assert.equal(await collectionContract.balanceOf(collectionOwner.address, 20), 200);
            assert.equal(await collectionContract.balanceOf(collectionOwner.address, 30), 300);
        });

        it("transferListing", async () => {
            const {
                marketplaceContract,
                collectionContract,
                marketplaceOwner,
                collectionOwner,
                buyerAccount,
            } = await loadFixture(deployMarketplaceFixture);
            assert.equal(await collectionContract.owner(), collectionOwner.address);
            await collectionContract.transferListing(buyerAccount.address, 10, 5);
            assert.equal(await collectionContract.balanceOf(collectionOwner.address, 10), 95);
            assert.equal(await collectionContract.balanceOf(buyerAccount.address, 10), 5);
        });
    });
});
