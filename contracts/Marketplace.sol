// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICollection {
    function addItem(address to, uint256 id, uint256 amount) external;

    function addItems(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;

    function setURI(string memory newuri) external;

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) external;

    function transferListing(
        address to,
        uint256 id,
        uint256 amount
    ) external;

    function owner() external view returns (address);
}

contract Marketplace {
    uint256 public fee = 2; //2%
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    event ListingBoughtLog(
        address indexed collectionAddress,
        uint256 indexed listingId,
        uint256 amount,
        address indexed to
    );

    event TransferTokensLog(address indexed to, uint256 amount);
    event FeeUpdatedLog(uint256 _fee);
    event TransferOwnershipLog(address indexed from, address indexed to);

    function updateFee(uint256 _fee) external onlyOwner {
        require((_fee > 0 && _fee <= 100), "fee is not in range");
        fee = _fee;
        emit FeeUpdatedLog(_fee);
    }

    function buyListing(
        address collectionAddress,
        uint256 listingId,
        uint256 amount,
        address to
    ) external payable {
        require(msg.value > 0, "payment should be greater then zero");
        require(amount > 0, "amount of listings should be greater then zero");
        require(collectionAddress != address(0), "Collection does not exist");
        ICollection collection = ICollection(collectionAddress);
        ICollection(collectionAddress).transferListing(to, listingId, amount);

        uint256 feeAmount = (msg.value * fee) / 100;
        uint256 paymentToOwner = msg.value - feeAmount;

        (bool success, ) = payable(collection.owner()).call{value: paymentToOwner}("");
        require(success, "Payment to owner failed");

        emit ListingBoughtLog(collectionAddress, listingId, amount, to);
    }

    function transferOwnership(address account) onlyOwner external {
        owner = account;
        emit TransferOwnershipLog(owner, account);
    }

    function transferTokens(address to, uint256 amount) onlyOwner external {
        require(amount <= address(this).balance);
        payable(to).transfer(amount);
        
        emit TransferTokensLog(to, amount);
    }

    function getBalance() view external returns(uint256){
        return address(this).balance;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner of contract");
        _;
    }
}
