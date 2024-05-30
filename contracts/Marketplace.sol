// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICollection {
    function transferListing(address to, uint256 id, uint256 amount) external;

    function owner() external view returns (address);
}

interface ICCIPConnector {
    function send(
        address receiver,
        uint64 destinationChainSelector,
        address to,
        uint256 id,
        uint256 amount,
        address collection
    ) external returns (bytes32 messageId);
}

contract Marketplace {
    uint256 public fee = 2; //2%
    address public owner;
    address public ccipMapper;
    address public ccipSourceConnector;

    constructor() {
        owner = msg.sender;
    }

    event buyingCrossChainLog(
        address indexed collectionAddress,
        uint256 indexed listingId,
        uint256 amount,
        address indexed to,
        uint256 destinationChainId
    );

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

    function updateCCIPMapperAddress(address mapper) external onlyOwner {
        require(
            mapper != address(0),
            "cross-chain mapper should be a valid address"
        );
        ccipMapper = mapper;
    }

    function updateCCIPSourceConnector(address _ccipSourceConnector) external onlyOwner {
        ccipSourceConnector = _ccipSourceConnector;
    }

    function CCIPBuyListing(
        address to, //buyer
        uint256 destinationChainId, //listed item chain
        address collectionAddress, // collection address could be in other chain
        uint256 listingId,
        uint256 amount // amount that is bought
    ) external payable {
        if (block.chainid == destinationChainId) {
            buyListing(collectionAddress, to, listingId, amount);
        } else {

            payForProducts(collectionAddress, listingId, amount);

            require(
                ccipMapper != address(0),
                "cross chain connector is not initialized"
            );

            (bool success, bytes memory data) = ccipMapper.call{gas: 500000}(
                abi.encodeWithSignature(
                    "getCCIPNavigations(uint256)",
                    destinationChainId
                )
            );
            require(success, "failed to read CCIP mapping ");
            (address destinationCCIPConnector, uint64 chainSelector) = abi.decode(
                data,
                (address, uint64)
            );

            require(ccipSourceConnector != address(0), "ccipSourceConnector is not defined");
            ICCIPConnector(ccipSourceConnector).send(
                destinationCCIPConnector,
                chainSelector,
                to,
                listingId,
                amount,
                collectionAddress
            );
        }
    }

    function chainId() public view returns (uint256) {
        return block.chainid;
    }

    function CCIPtransferListing(
        address collectionAddress,
        address to,
        uint256 listingId,
        uint256 amount
    ) external {
        require(msg.sender == ccipSourceConnector, "only ccipSourceConnector can perform this operation");
        require(amount > 0, "amount of listings should be greater then zero");
        require(collectionAddress != address(0), "Collection does not exist");
        ICollection(collectionAddress).transferListing(
            to,
            listingId,
            amount
        );
    }

    function buyListing(
        address collectionAddress,
        address to,
        uint256 listingId,
        uint256 amount
    ) public payable {
        require(msg.value > 0, "payment should be greater then zero");
        require(amount > 0, "amount of listings should be greater then zero");
        require(collectionAddress != address(0), "Collection does not exist");
        payForProducts(collectionAddress, listingId, amount);
        ICollection(collectionAddress).transferListing(
            to,
            listingId,
            amount
        );

        
    }

    function payForProducts(address collectionAddress, uint256 listingId, uint256 amount) internal {
        uint256 feeAmount = (msg.value * fee) / 100;
        uint256 paymentToOwner = msg.value - feeAmount;
        ICollection collection = ICollection(collectionAddress);

        (bool success, ) = payable(collection.owner()).call{
            value: paymentToOwner
        }("");
        require(success, "Payment to owner failed");

        emit ListingBoughtLog(collectionAddress, listingId, amount, msg.sender);
    }

    function transferOwnership(address account) external onlyOwner {
        owner = account;
        emit TransferOwnershipLog(owner, account);
    }

    function transferTokens(address to, uint256 amount) external onlyOwner {
        require(amount <= address(this).balance);
        payable(to).transfer(amount);

        emit TransferTokensLog(to, amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner of contract");
        _;
    }
}
