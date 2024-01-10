// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract RecibirEtherReceive {
    event Deposited(address indexed depositer, uint256 amount);
    event Withdrawn(address to, uint256 amount);

    error FailSendingETHWihCall();
    error FailSendingETHWithSend();
    error AmountExceedsYourBalance();

    mapping(address account => uint256 amount) public balances;

    function withdrawWithCall(uint256 _amount) external {
        if (_amount > balances[msg.sender]) revert AmountExceedsYourBalance();
        balances[msg.sender] -= _amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if (!success) revert FailSendingETHWihCall();
        emit Withdrawn(msg.sender, _amount);
    }

    function withdrawWithTransfer(uint256 _amount) external {
        if (_amount > balances[msg.sender]) revert AmountExceedsYourBalance();
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function withdrawWithSend(uint256 _amount) external {
        if (_amount > balances[msg.sender]) revert AmountExceedsYourBalance();
        balances[msg.sender] -= _amount;
        bool success = payable(msg.sender).send(_amount);
        if (!success) revert FailSendingETHWithSend();
        emit Withdrawn(msg.sender, _amount);
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
}
