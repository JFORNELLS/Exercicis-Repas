// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {RecibirEtherPayable} from "src/ExTransferencies/1-RecibirEtherPayable.sol";

contract RecibirEtherPayableTest is Test {

    event Deposited(address indexed depositor, uint256 amount);

    RecibirEtherPayable public recibir;
    address public alice;

    function setUp() public {
        recibir = new RecibirEtherPayable();
        alice = makeAddr("alice");
    }

    function test_RecibirEtherPayable() public {
        // The Funcion will be called by Alice.
        startHoax(alice);
        // If Alice tries to send an amount less tnan 1 ether, the transaction will revert.
        vm.expectRevert(RecibirEtherPayable.MinAmountNotReached.selector);
        recibir.recibirEther{value: 0.5 ether}();
        // If Alice tries to send an amount gretaer than 10 ether, the trasaction will revert.
        vm.expectRevert(RecibirEtherPayable.MaxAmountReached.selector);
        recibir.recibirEther{value: 11 ether}();
        // I saved RecibirEtherPayable's balance to check after the transaction.
        uint256 RecibirEtherPayableBalance = recibir.balance();
        // I saved Alice's balance to check after the transaction.
        uint256 aliceBalance = alice.balance;
        // Check that the emitted event is correct.
        vm.expectEmit();
        emit Deposited(alice, 5 ether);
        // Alice sends a correct amount of ether.
        recibir.recibirEther{value: 5 ether}();
        // Check that the 'RecibirEtherPayable' contract has 5 more ether
        assertEq(recibir.balance(), RecibirEtherPayableBalance + 5 ether);
        // Check that Alice has 5 less ether.
        assertEq(alice.balance, aliceBalance - 5 ether);
        // Alice makes multiple transactions to verify the RecibirEtherPayable's balance.
        recibir.recibirEther{value: 10 ether}();
        recibir.recibirEther{value: 10 ether}();
        recibir.recibirEther{value: 10 ether}();
        recibir.recibirEther{value: 10 ether}();

        // Check that if the RecibirEtherPayable's balance exceeds 50 ether, the transaction will revert
        vm.expectRevert(RecibirEtherPayable.MaxBalanceReached.selector);
        recibir.recibirEther{value: 10 ether}();
    }
}    