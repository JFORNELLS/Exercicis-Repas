// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {RecibirEtherReceive} from "src/ExTransferencies/2-RecibirEtherReceive.sol";

contract RecibirEtherReceiveTest is Test {

    event Deposited(address indexed depositer, uint256 amount);
    event Withdrawn(address to, uint256 amount);

    RecibirEtherReceive recibir;
    address public alice;

    function setUp() public {
        recibir = new RecibirEtherReceive();
        alice = makeAddr("alice");
    }

    function test_withdrawWithCall() public {
        // The functions will be called by Alice.
        startHoax(alice);
        // I saved Alice's balance to check after the transaction
        uint256 aliceBalanceBefore = alice.balance;
        // I saved RecibirEtherReceive's balancve to check after the transaction.
        uint256 recibirBalance = address(recibir).balance;
        // I saved Alice's balance mapping.
        uint256 aliceMapping = recibir.balances(alice);
        // Check that the emitted event is correct.
        vm.expectEmit();
        emit Deposited(alice, 10 ether);
        // Alice sends 10 ether to RecibirEtherReceive's contract.
        (bool ok, ) = payable(recibir).call{value: 10 ether}("");
        require(ok, "fail Sending ETH");
        // Check that Alice has 10 ether less.
        assertEq(alice.balance, aliceBalanceBefore - 10 ether);
        // Check that RecibirEtherReceive's contract has more 10 ether.
        assertEq(address(recibir).balance, recibirBalance + 10 ether);
        // Check that Alice's balance in the mapping has 10 more ethers.
        assertEq(recibir.balances(alice), aliceMapping + 10 ether);
        // If Alice tries to withdraw an amount greater than what she has in the balance, it will revert.
        vm.expectRevert(RecibirEtherReceive.AmountExceedsYourBalance.selector);
        recibir.withdrawWithCall(11 ether);
        // I saved Alice's balance to check after the withdrawal.
        uint256 aliceBalanceBeforeW = alice.balance;
        // I saved RecibirEtherReceive's balancve to check after the withdrawal.
        uint256 recibirBalanceW = address(recibir).balance;
        // I saved Alice's balance mapping to check after the withdrawal.
        uint256 aliceMappingW = recibir.balances(alice);        
        vm.expectEmit();
        // Check that the emitted event is correct.
        emit Withdrawn(alice, 6 ether);
        // Alice withdraws 6 ethers.
        recibir.withdrawWithCall(6 ether);
        // Check that Alice has more 6 ether.
        assertEq(alice.balance, aliceBalanceBeforeW + 6 ether);
        // Check that RecibirEtherReceive's contract has 10 ethers less.
        assertEq(address(recibir).balance, recibirBalanceW -6 ether);
        // Check that Alice's balance in the mapping has 6 ethers less.
        assertEq(recibir.balances(alice), aliceMappingW - 6 ether);   
        vm.stopPrank();
        // This contract sens 1 ether to RecibirEtherReceive contract.
        (bool success ,) = payable(recibir).call{value: 1 ether}("");   
        require(success, "");        
        // If a contract is the recipient but does not have the receive function, the transaction will revert.
        vm.expectRevert(RecibirEtherReceive.FailSendingETHWihCall.selector);
        recibir.withdrawWithCall(1 ether);      

    }

    function test_withdrawWithTransfer() public {
        // The functions will be called by Alice.
        startHoax(alice);
        // I saved Alice's balance to check after the transaction
        uint256 aliceBalanceBefore = alice.balance;
        // I saved RecibirEtherReceive's balancve to check after the transaction.
        uint256 recibirBalance = address(recibir).balance;
        // I saved Alice's balance mapping.
        uint256 aliceMapping = recibir.balances(alice);
        // Check that the emitted event is correct.
        vm.expectEmit();
        emit Deposited(alice, 18 ether);
        // Alice sends 18 ether to RecibirEtherReceive's contract.
        (bool ok, ) = payable(recibir).call{value: 18 ether}("");
        require(ok, "fail Sending ETH");
        // Check that Alice has 18 ether less.
        assertEq(alice.balance, aliceBalanceBefore - 18 ether);
        // Check that RecibirEtherReceive's contract has more 18 ether.
        assertEq(address(recibir).balance, recibirBalance + 18 ether);
        // Check that Alice's balance in the mapping has 18 more ethers.
        assertEq(recibir.balances(alice), aliceMapping + 18 ether);
        // If Alice tries to withdraw an amount greater than what she has in the balance, it will revert.
        vm.expectRevert(RecibirEtherReceive.AmountExceedsYourBalance.selector);
        recibir.withdrawWithTransfer(20 ether);
        // I saved Alice's balance to check after the withdrawal.
        uint256 aliceBalanceBeforeW = alice.balance;
        // I saved RecibirEtherReceive's balancve to check after the withdrawal.
        uint256 recibirBalanceW = address(recibir).balance;
        // I saved Alice's balance mapping to check after the withdrawal.
        uint256 aliceMappingW = recibir.balances(alice);        
        vm.expectEmit();
        // Check that the emitted event is correct.
        emit Withdrawn(alice, 10 ether);
        // Alice withdraws 10 ethers.
        recibir.withdrawWithTransfer(10 ether);
        // Check that Alice has more 10 ether.
        assertEq(alice.balance, aliceBalanceBeforeW + 10 ether);
        // Check that RecibirEtherReceive's contract has 10 ethers less.
        assertEq(address(recibir).balance, recibirBalanceW - 10 ether);
        // Check that Alice's balance in the mapping has 10 ethers less.
        assertEq(recibir.balances(alice), aliceMappingW - 10 ether);  
        vm.stopPrank();   
        // This contract sens 1 ether to RecibirEtherReceive contract.
        (bool success ,) = payable(recibir).call{value: 1 ether}("");    
        require(success, "");
        // If a contract is the recipient but does not have the receive function, the transaction will revert.
        vm.expectRevert();
        recibir.withdrawWithTransfer(1 ether); 
    }

    function test_withdrawWithSend() public {
        // The functions will be called by Alice.
        startHoax(alice);
        // I saved Alice's balance to check after the transaction
        uint256 aliceBalanceBefore = alice.balance;
        // I saved RecibirEtherReceive's balancve to check after the transaction.
        uint256 recibirBalance = address(recibir).balance;
        // I saved Alice's balance mapping.
        uint256 aliceMapping = recibir.balances(alice);
        // Check that the emitted event is correct.
        vm.expectEmit();
        emit Deposited(alice, 250 ether);
        // Alice sends 250 ether to RecibirEtherReceive's contract.
        (bool ok, ) = payable(recibir).call{value: 250 ether}("");
        require(ok, "fail Sending ETH");
        // Check that Alice has 250 ether less.
        assertEq(alice.balance, aliceBalanceBefore - 250 ether);
        // Check that RecibirEtherReceive's contract has more 250 ether.
        assertEq(address(recibir).balance, recibirBalance + 250 ether);
        // Check that Alice's balance in the mapping has 18 more ethers.
        assertEq(recibir.balances(alice), aliceMapping + 250 ether);
        // If Alice tries to withdraw an amount greater than what she has in the balance, it will revert.
        vm.expectRevert(RecibirEtherReceive.AmountExceedsYourBalance.selector);
        recibir.withdrawWithSend(567 ether);
        // I saved Alice's balance to check after the withdrawal.
        uint256 aliceBalanceBeforeW = alice.balance;
        // I saved RecibirEtherReceive's balancve to check after the withdrawal.
        uint256 recibirBalanceW = address(recibir).balance;
        // I saved Alice's balance mapping to check after the withdrawal.
        uint256 aliceMappingW = recibir.balances(alice);        
        vm.expectEmit();
        // Check that the emitted event is correct.
        emit Withdrawn(alice, 158 ether);
        // Alice withdraws 158 ethers.
        recibir.withdrawWithSend(158 ether);
        // Check that Alice has more 158 ether.
        assertEq(alice.balance, aliceBalanceBeforeW + 158 ether);
        // Check that RecibirEtherReceive's contract has 158 ethers less.
        assertEq(address(recibir).balance, recibirBalanceW - 158 ether);
        // Check that Alice's balance in the mapping has 158 ethers less.
        assertEq(recibir.balances(alice), aliceMappingW - 158 ether);    
        vm.stopPrank();
        // This contract sens 1 ether to RecibirEtherReceive contract.
        (bool success ,) = payable(recibir).call{value: 1 ether}("");    
        require(success, "");
        // If a contract is the recipient but does not have the receive function, the transaction will revert.
        vm.expectRevert(RecibirEtherReceive.FailSendingETHWithSend.selector);
        recibir.withdrawWithSend(1 ether);


    }    

}