// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Sepolia
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";

interface InftMinter {
    function mintFrom(address account, uint256 sourceId) external;
}

interface ICollection {
    function transferListing(address to, uint256 id, uint256 amount) external;
}

contract CCIPConnector is CCIPReceiver {
    address public owner;
    IRouterClient public _router;
    LinkTokenInterface public linkToken;
    ICollection collection;

    mapping(uint256 => uint64) public chainSelectors; // <chainId> => <chain selector>

    event MessageSent(bytes32 messageId);
    event MessageRecived();
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance to cover the fees.
    error NothingToWithdraw(); // Used when trying to withdraw but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.

    // https://docs.chain.link/ccip/supported-networks/testnet
    constructor(
        address router,
        address linkAddress,
        address collectionAddress
    ) CCIPReceiver(router) {
        owner = msg.sender;
        require(router != address(0), "router address is required");
        require(linkAddress != address(0), "link address is required");
        _router = IRouterClient(router);
        linkToken = LinkTokenInterface(linkAddress);
        linkToken.approve(router, type(uint256).max);
        chainSelectors[80002] = 16281711391670634445; // polygon-amoy
        chainSelectors[43113] = 14767482510784806043; // avalanche-fuji
        collection = ICollection(collectionAddress);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        emit MessageRecived();
        //todo extract collection address from the message and not use hardcoded
        (bool success, ) = address(collection).call(message.data);
        require(success);
    }

    function sendMessage(
        address ccipConnectorTarget,
        uint256 targetChainId,
        address to,
        uint256 id,
        uint256 amount
    ) external {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(ccipConnectorTarget),
            data: abi.encodeWithSignature(
                "transferListing(to, id, amount)",
                to,
                id,
                amount
            ),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(0) // Setting feeToken to zero address, indicating native asset will be used for fees
        });

        uint64 destinationChainSelector = chainSelectors[targetChainId];

        // Get the fee required to send the message
        uint256 fees = _router.getFee(destinationChainSelector, message);

        bytes32 messageId;
        // Send the message through the router and store the returned message ID
        messageId = _router.ccipSend{value: fees}(
            destinationChainSelector,
            message
        );
        emit MessageSent(messageId);
    }

    function linkBalance(address account) external view returns (uint256) {
        return linkToken.balanceOf(account);
    }

    function withdrawLINK() external onlyOwner {
        uint256 amount = linkToken.balanceOf(address(this));
        if (amount == 0) revert NothingToWithdraw();
        linkToken.transfer(owner, amount);
    }

    function updateRouterMappings(
        uint256 chainId,
        uint64 chainSelector
    ) external onlyOwner {
        chainSelectors[chainId] = chainSelector;
    }

    receive() external payable {}

    function withdraw(address beneficiary) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = address(this).balance;

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        // Attempt to send the funds, capturing the success status and discarding any return data
        (bool sent, ) = beneficiary.call{value: amount}("");

        // Revert if the send failed, with information about the attempted transfer
        if (!sent) revert FailedToWithdrawEth(msg.sender, beneficiary, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
