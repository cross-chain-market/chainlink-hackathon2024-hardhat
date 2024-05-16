const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("Collection factory uint tests", () => {
    const deployCollectionFactoryFixture = async () => {
        const [collectionOwner] = await ethers.getSigners();
        const CollectionFactory = await ethers.getContractFactory("CollectionFactory");
        // Specify the gas limit in the deployment options
        const options = { gasLimit: 30000000 }; // Set the gas limit as needed
        const collectionFactoryContract = await CollectionFactory.deploy(options);

        return {
            collectionOwner,
            collectionFactoryContract,
        };
    };

    it("deploy", async () => {
        const { collectionOwner, collectionFactoryContract } = await loadFixture(
            deployCollectionFactoryFixture
        );
        assert.equal(await collectionFactoryContract.owner(), collectionOwner.address);
    });

    it("deploy collection instance from factory", async () => {
        const { collectionOwner, collectionFactoryContract } = await loadFixture(
            deployCollectionFactoryFixture
        );
        const transaction = await collectionFactoryContract.deployCollection(
            "collection name",
            [1, 2, 3],
            [100, 200, 300],
            "this-is-the-hash/",
            "0xFfB60f298947C468A088dAC442cD14bc2b0B6235"
        );
        const receipt = await transaction.wait();
        const event = receipt.events.find(event => event.event === "CollectionDeployedLog");
        if (event) {
            const newCollectionAddress = event.args.collectionAddress;
            console.log("New Collection deployed at:", newCollectionAddress);
          } else {
            console.log("Event not found in receipt");
          }
        expect(event.args.owner).to.equal(collectionOwner.address);
    });
});
