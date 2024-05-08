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
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external;

    function owner() external view returns (address);
}

contract Marketplace {
    mapping(uint256 => address) public marketCollection; //collectionId => Collection
    uint256 public fee = 2; //2%
    address public owner;

    event CollectionAdded(
        address indexed collectionAddress,
        uint256 indexed collectionId
    );

    constructor() {
        owner = msg.sender;
    }

    event ListingBought(
        uint256 indexed collectionId,
        uint256 indexed listingId,
        uint256 amount,
        address indexed to
    );
    event FeeUpdated(uint256 _fee);

    function addCollection(
        address collectionAddress,
        uint256 collectionId
    ) external {
        marketCollection[collectionId] = collectionAddress;

        emit CollectionAdded(collectionAddress, collectionId);
    }

    function updateFee(uint256 _fee) external onlyOwner {
        require((_fee > 0 && _fee <= 100), "fee is not in range");
        fee = _fee;
        emit FeeUpdated(_fee);
    }

    function buyListing(
        uint256 collectionId,
        uint256 listingId,
        uint256 amount,
        address to
    ) external payable {
        require(msg.value > 0, "payment should be greater then zero");
        require(amount > 0, "amount of listings should be greater then zero");
        require(marketCollection[collectionId] != address(0), "Collection does not exist");
        ICollection collection = ICollection(marketCollection[collectionId]);
        collection.transferListing(collection.owner(), to, listingId, amount);
        payable(address(this)).transfer(msg.value * (fee / 100));
        payable(collection.owner()).transfer((msg.value * (100 - fee)) / 100);
        emit ListingBought(collectionId, listingId, amount, to);
    }

    function transferOwnership(address account) onlyOwner external {
        owner = account;
    }

    function transferTokens(address to, uint256 amount) onlyOwner external {
        require(amount <= address(this).balance);
        payable(to).transfer(amount);
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
