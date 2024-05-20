// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Collection is ERC1155 {
    string public name;
    string public collectionBaseHash;
    address public owner;

    constructor(
        string memory collectionName,
        uint256[] memory ids,
        uint256[] memory totalAmounts,
        string memory baseHash
    ) ERC1155(baseHash) {
        owner = tx.origin;
        name = collectionName;
        collectionBaseHash = baseHash;
        _mintBatch(tx.origin, ids, totalAmounts, "");
    }

    function addItem(uint256 id, uint256 amount) external onlyOwner {
        _mint(msg.sender, id, amount, "");
    }

    function addItems(
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyOwner {
        _mintBatch(msg.sender, ids, amounts, "");
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    // URI for specific item
    function uri (uint256 imageHash) public view override returns (string memory) {
        return string(abi.encodePacked(
            "https://ipfs.io/ipfs/",
            collectionBaseHash,
            "/",
            Strings.toString(imageHash),
            ".json"
        ));
    }

    // URI for collection
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked("https://ipfs.io/ipfs/", collectionBaseHash, "/collection.json"));
    }

    function transferListing(
        address to,
        uint256 id,
        uint256 amount
    ) external {
        require(
            getBalance(id) > amount,
            "amount greater then available amount"
        );
        require(
            msg.sender == owner ||
            isApprovedForAll(owner, msg.sender),
            "operator is not approved to do this operation"
        );
        super._safeTransferFrom(owner, to, id, amount, bytes(""));
    }

    function getBalance(uint256 id) internal view returns (uint256) {
        return balanceOf(owner, id);
    }

    function transferOwnership(address account) onlyOwner external {
        owner = account;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner of contract");
        _;
    }
}
