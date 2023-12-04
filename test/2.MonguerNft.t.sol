// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {MonguerNft} from "../src/2-MonguerNft.sol";

contract CannotReceiveNFT {}

contract CanReceiveNFT {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public virtual returns (bytes4) {
        return
            bytes4(
                keccak256(
                    abi.encodeWithSignature(
                        "onERC721Received(address,address,uint256,bytes)"
                    )
                )
            );
    }
}

contract MonguerNftTest is Test {
    event Transfer(address indexed from, address to, uint256 tokenId);
    event Approval(address indexed from, address spender, uint256 tokenId);
    event ApprovalForAll(address indexed owner, address spender, bool approved);
    event Minted(address indexed to, uint256 tokenId);
    event Burned(address indexed from, uint256 tokenId);

    MonguerNft public m;
    CannotReceiveNFT public noNft;
    CanReceiveNFT public yesNft;

    address public owner;
    address public alice;
    address public bob;

    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        vm.deal(alice, 1 ether);
        vm.deal(bob, 10 ether);
        noNft = new CannotReceiveNFT();
        yesNft = new CanReceiveNFT();

        vm.prank(owner);
        m = new MonguerNft();
    }

    function test_Deploy() public {
        assertEq(m.owner(), owner);
        assertEq(m.balanceOf(owner), 1);
        assertEq(m.ownerOf(1), owner);
    }

    function test_Mint() public {
        vm.deal(address(0), 1 ether);
        // check that the caller is a valid address.
        vm.prank(address(0));
        vm.expectRevert(MonguerNft.Invalid_Address.selector);
        m.mint{value: 1 ether}(alice);
        // the functions will be called by alice.
        vm.startPrank(alice);
        // check if the amount sent is insuficient.
        vm.expectRevert(MonguerNft.Incorrect_Amount_Sent.selector);
        m.mint{value: 0.5 ether}(alice);
        // check if the receptor address is valid.
        vm.expectRevert(MonguerNft.Invalid_Address.selector);
        m.mint{value: 1 ether}(address(0));
        // check that the event emited is correct.
        vm.expectEmit();
        emit Minted(bob, 2);
        // alice mints 1 nft with the correct amount sent.
        m.mint{value: 1 ether}(bob);
        // check if bob haas 1 nft in his balance.
        assertEq(m.balanceOf(bob), 1);
        // check if the owner of the nft with id 2 is bob
        assertEq(m.ownerOf(2), bob);
    }

    function test_Burn() public {
        // bob mints 1 nft.
        vm.prank(bob);
        m.mint{value: 1 ether}(bob);
        vm.startPrank(alice);
        // alice mints 1 nft for herself.
        m.mint{value: 1 ether}(alice);
        // alice tries to burn 1 nft that not hers.
        vm.expectRevert(MonguerNft.You_Are_Not_The_owner.selector);
        m.burn(2);
        // check that the event emited is correct.
        vm.expectEmit();
        emit Burned(alice, 3);
        // alice burns a correct nft.
        m.burn(3);
        // check that alice has not a nft.
        assertEq(m.balanceOf(alice), 0);
        // check that the nft doesn't exist.
        vm.expectRevert(MonguerNft.Nft_Doesnt_Exist.selector);
        m.ownerOf(3);
    }

    function test_TransferFrom() public {
        vm.startPrank(bob);
        // bob mints 1 nft for himself.
        m.mint{value: 1 ether}(bob);
        // bob tries to transfer a nft that does not exist.
        vm.expectRevert(MonguerNft.Nft_Doesnt_Exist.selector);
        m.transferFrom(bob, alice, 3);
        // bob tries to transfer a nft to an invalid address.
        vm.expectRevert(MonguerNft.Invalid_Address.selector);
        m.transferFrom(bob, address(0), 2);
        // check that the event emited is correct.
        vm.expectEmit();
        emit Transfer(bob, alice, 2);
        // if the caller is the owner, there is no need to check the approve.
        // bob transfers his nft to alice.
        m.transferFrom(bob, alice, 2);
        // check that alice has 1 nft.
        assertEq(m.balanceOf(alice), 1);
        // check that alice is the new owner of nft.
        assertEq(m.ownerOf(2), alice);
        // check that bob doesn't have any nft in his balance.
        assertEq(m.balanceOf(bob), 0);
        // if the caller is not the owner.
        vm.stopPrank();
        vm.startPrank(address(m));
        // check that address _from is the owner of the nft.
        vm.expectRevert(MonguerNft.You_Are_Not_The_owner.selector);
        m.transferFrom(bob, address(m), 2);
        // check that msg.sender is approved to move a nft.
        vm.expectRevert(MonguerNft.You_Are_Not_Approved.selector);
        m.transferFrom(alice, address(m), 2);
        vm.stopPrank();
        // alice approve to address MonguerNft
        vm.prank(alice);
        m.approve(address(m), 2);
        // check that the event emited is correct.
        vm.expectEmit();
        emit Transfer(alice, address(m), 2);
        // MongerNft calls transferFrom.
        vm.startPrank(address(m));
        m.transferFrom(alice, address(m), 2);
        // check that MonguerNft has 1 nft.
        assertEq(m.balanceOf(address(m)), 1);
        // check that MongerNft is the new owner.
        assertEq(m.ownerOf(2), address(m));
        // check that alice doesn't have any nft in his balance.
        assertEq(m.balanceOf(alice), 0);
        // MonguerNft sends nft with id 2 to alice.
        m.transferFrom(address(m), alice, 2);
        // MonguerNft tries to move the nft but the approval is deleted.
        vm.expectRevert(MonguerNft.You_Are_Not_Approved.selector);
        m.transferFrom(alice, address(m), 2);
    }

    function test_TransferFromForAll() public {
        vm.startPrank(bob);
        m.mint{value: 1 ether}(bob);
        m.mint{value: 1 ether}(bob);
        m.mint{value: 1 ether}(bob);
        m.mint{value: 1 ether}(bob);
        m.mint{value: 1 ether}(bob);
        // check that address _to is not a invalid address.
        vm.expectRevert(MonguerNft.Invalid_Address.selector);
        m.transferFromForAll(bob, address(0));
        // if the caller is the owner, there is no need to check the approve.
        m.transferFromForAll(bob, alice);
        // check that alice has 5 nfts.
        assertEq(m.balanceOf(alice), 5);
        // check that bob doesn't have any nft.
        m.balanceOf(bob);
        // check that alice is the owner.
        assertEq(m.ownerOf(2), alice);
        assertEq(m.ownerOf(3), alice);
        assertEq(m.ownerOf(4), alice);
        assertEq(m.ownerOf(5), alice);
        assertEq(m.ownerOf(6), alice);

        vm.stopPrank();
        // check that the caller is approved.
        vm.prank(address(m));
        vm.expectRevert(MonguerNft.You_Are_Not_Approved.selector);
        m.transferFromForAll(bob, alice);
        // alice approves to MongerNft.
        vm.prank(alice);
        m.setApprovalForAll(address(m), true);
        // MonguerNft calls the function and tranfer the nfts.
        vm.startPrank(address(m));
        vm.expectEmit();
        emit Transfer(alice, bob, 2);
        emit Transfer(alice, bob, 3);
        emit Transfer(alice, bob, 4);
        emit Transfer(alice, bob, 5);
        emit Transfer(alice, bob, 6);
        m.transferFromForAll(alice, bob);
        // check that alice has 5 nfts.
        assertEq(m.balanceOf(bob), 5);
        // check that bob doesn't have any nft.
        assertEq(m.balanceOf(alice), 0);
        // check that bob is the new owner.
        assertEq(m.ownerOf(2), bob);
        assertEq(m.ownerOf(3), bob);
        assertEq(m.ownerOf(4), bob);
        assertEq(m.ownerOf(5), bob);
        assertEq(m.ownerOf(6), bob);
        vm.stopPrank();
        // bob sends all his nfts to alice.
        vm.prank(bob);
        m.transferFromForAll(bob, alice);
        // MonguerNft tries to move the nfts but the approval is deleted.
        vm.prank(address(m));
        vm.expectRevert(MonguerNft.You_Are_Not_Approved.selector);
        m.transferFromForAll(alice, address(m));
    }

    /// @dev SafeTransFerFrom has the same logic as transferFrom.
    function test_SafeTransferFrom() public {
        vm.startPrank(bob);
        m.mint{value: 1 ether}(bob);
        // bob tries to transfer an nft to an address that is not a contract.
        vm.expectRevert(MonguerNft.It_Is_Not_A_Contract.selector);
        m.safeTransferFrom(bob, alice, 2, "");
        // bob tries to transfer an nft to a contract that cannot receive nfts.
        vm.expectRevert(MonguerNft.Contract_Cannot_Receive_NFTS.selector);
        m.safeTransferFrom(bob, address(noNft), 2, "");
        // bob transfers a nft to a contract that can receive nfts.
        m.safeTransferFrom(bob, address(yesNft), 2, "");
    }

    function test_Approved() public {
        vm.startPrank(bob);
        m.mint{value: 1 ether}(bob);
        // bob tries to approve an nft that is not his.
        vm.expectRevert(MonguerNft.You_Are_Not_The_owner.selector);
        m.approve(alice, 1);
        // bob tries to approva a invalid address.
        vm.expectRevert(MonguerNft.Invalid_Address.selector);
        m.approve(address(0), 2);
        vm.expectEmit();
        // check that the event emited is correct.
        emit Approval(bob, alice, 2);
        // bob approves to a alice.
        m.approve(alice, 2);
    }

    function test_SetApprovalForAll() public {
        vm.startPrank(bob);
        m.mint{value: 1 ether}(bob);
        // bob trie to approve to an invalid address.
        vm.expectRevert(MonguerNft.Invalid_Address.selector);
        m.setApprovalForAll(address(0), true);
        vm.expectEmit();
        emit ApprovalForAll(bob, alice, true);
        // bob approves to alice.
        m.setApprovalForAll(alice, true);
    }
}
