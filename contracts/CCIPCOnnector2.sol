// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

contract Ping is CCIPReceiver {
    address link;
    address router;

    string public PONG;

    event MessageSent(bytes32 messageId);
    event MessageRecived();
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance to cover the fees.
    error NothingToWithdraw(); // Used when trying to withdraw but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.


    constructor(address _link, address _router) CCIPReceiver(_router) {
        link = _link;
        router = _router;
    }

    function send(
        address receiver,
        uint64 destinationChainSelector
    ) external returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode("Ping"),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                // Additional arguments, setting gas limit
                Client.EVMExtraArgsV1({gasLimit: 500_000})
            ),
            feeToken: link
        });

        uint256 fee = IRouterClient(router).getFee(
            destinationChainSelector,
            message
        );

        IERC20(link).approve(address(router), fee);

        messageId = IRouterClient(router).ccipSend(
            destinationChainSelector,
            message
        );
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        PONG = abi.decode(message.data, (string));
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
