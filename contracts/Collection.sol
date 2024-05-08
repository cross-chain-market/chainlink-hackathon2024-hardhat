// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract Collection is ERC1155, Ownable, ERC1155Burnable {
    uint256 public collectionId;
    string public collectionName;
    string public collectionImageUrl;

    constructor(
        uint256 _collectionId,
        string memory _collectionName,
        string memory _collectionImageUrl,
        uint256[] memory ids,
        uint256[] memory totalAmounts,
        string memory baseImagePath,
        address marketplaceAccount
    ) ERC1155("Collection") {
        setURI(baseImagePath);
        collectionId = _collectionId;
        collectionName = _collectionName;
        collectionImageUrl = _collectionImageUrl;
        _mintBatch(msg.sender, ids, totalAmounts, "");
        setApprovalForAll(marketplaceAccount, true);
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

    function transferListing(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external {
        require(
            getBalance(id) > amount,
            "amount greater then available amount"
        );
        require(
            msg.sender == owner() ||
            isApprovedForAll(owner(), msg.sender),
            "operator is not approved to do this operation"
        );
        super._safeTransferFrom(from, to, id, amount, bytes(""));
    }

    function getBalance(uint256 id) internal view returns (uint256) {
        return balanceOf(owner(), id);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
