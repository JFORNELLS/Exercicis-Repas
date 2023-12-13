// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {ForniToken} from "src/ExTokens/1-ERC20.sol";

contract ForniTokenTest is Test {

    event Mint(address indexed to, uint amount);
    event Burn(address indexed user, uint256 amount);
    
    ForniToken public forni;
    address public owner;
    address public alice;
    

    function setUp() public {
        alice = makeAddr("alice");

        owner = makeAddr("owner");

        // contract deployed by the owner.
        vm.prank(owner);
        forni = new ForniToken();

    }

    function testDeploy() public {
        // check that the owner has received 1 million tokens.
        assertEq(forni.balanceOf(owner), 1_000_000 ether);
    }

    function testMint() public {
        // check that the address is not address 0.
        vm.expectRevert(ForniToken.Invalid_Address.selector);
        forni.mint(address(0), 100 ether);
        // check that the amount is not 0.
        vm.expectRevert(ForniToken.Amount_Cannot_Be_0.selector);
        forni.mint(alice, 0);

        // the function will be called by Alice.
        vm.startPrank(alice);

        // check that the event emited is correct.
        vm.expectEmit();
        emit Mint(address(alice), 10 ether); 
        // Alice calls mint function and mints 10 tokens to herself.
        forni.mint(address(alice), 10 ether);
        // check that Alice has received 10 tokens.
        assertEq(forni.balanceOf(alice), 10 ether);

    }

    function testBurn() public {
        // the functions will be called by Alice.
        vm.startPrank(alice);   
        // Alice mints 10 tokens to herself.     
        forni.mint(alice, 10 ether);
        // check that the amount is not 0.
        vm.expectRevert(ForniToken.Amount_Cannot_Be_0.selector);   
        forni.burn(0);
        // check that the event emited is correct.
        vm.expectEmit();
        emit Burn(address(alice), 5 ether);
        // Alice burns 5 tokens.
        forni.burn(5 ether);
        // check that Alice has 5 less tokens.
        assertEq(forni.balanceOf(alice), 5 ether);

    }
}
