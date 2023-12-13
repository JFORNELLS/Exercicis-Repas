// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract RecibirEtherPayable {

    event Deposited(address indexed depositor, uint256 amount);

    error MinAmountNotReached();
    error MaxAmountReached();
    error MaxBalanceReached();

    uint256 public balance;

    function recibirEther() external payable {
        if (msg.value < 1 ether) revert MinAmountNotReached();
        if (msg.value > 10 ether) revert MaxAmountReached();
        balance += msg.value;
        if (balance > 50 ether) revert MaxBalanceReached();
        emit Deposited(msg.sender, msg.value);
    }
}