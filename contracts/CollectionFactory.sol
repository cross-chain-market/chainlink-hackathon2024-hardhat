// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './Collection.sol';

contract CollectionFactory {
    address public owner;
    mapping(address => address) collections;

    constructor() {
        owner = msg.sender;
    }

    event CollectionDeployedLog(address indexed collectionAddress, address indexed owner, string collectionName);

    function deployCollection(string memory collectionName,
        uint256[] memory ids,
        uint256[] memory totalAmounts,
        string memory baseHash,
        address marketplaceAccount) external returns(address) {
        // TODO: add checks for inputs
        Collection newCollection = new Collection(collectionName, ids, totalAmounts, baseHash, marketplaceAccount);
        collections[address(newCollection)] = msg.sender;
        emit CollectionDeployedLog(address(newCollection), msg.sender, collectionName);
        return address(newCollection);
    }
}