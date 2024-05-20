// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './Collection.sol';

contract CollectionFactory {
    address public owner;
    mapping(address => address) public collections;

    constructor() {
        owner = msg.sender;
    }

    event CollectionDeployedLog(address indexed collectionAddress, address indexed owner, string collectionName);

    function deployCollection(string memory collectionName,
        uint256[] memory ids,
        uint256[] memory totalAmounts,
        string memory baseHash,
        address marketplaceAccount) external returns(address) {
        require(bytes(collectionName).length > 0, "Collection name is required");
        require(ids.length > 0, "IDs array must not be empty");
        require(ids.length == totalAmounts.length, "IDs and totalAmounts arrays must have the same length");
        require(marketplaceAccount != address(0), "Marketplace account is required");
        Collection newCollection = new Collection(collectionName, ids, totalAmounts, baseHash);
        emit CollectionDeployedLog(address(newCollection), msg.sender, collectionName);
        collections[address(newCollection)] = msg.sender;
        return address(newCollection);
    }
}
