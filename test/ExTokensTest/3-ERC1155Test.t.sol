// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {BeansToken} from "src/ExTokens/3-ERC1155.sol";

contract CanReceivedERC1155 {
    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    abi.encodeWithSignature(
                        "onERC1155Received(address,address,uint256,uint256,bytes)"
                    )
                )
            );
    }

    function onERC1155BatchReceived(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    abi.encodeWithSignature(
                        "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                    )
                )
            );
    }
}

contract CannotReceiveERC115Tokens {}

contract BeansTokenTest is Test {
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed _operator,
        bool approved
    );
    event Minted(
        address indexed to,
        uint256 tokenId,
        uint256 amount,
        uint256 amountPaid
    );
    event BatchMinted(
        address[] indexed to,
        uint256 tokenId,
        uint256[] amount,
        uint256 amountPaid
    );
    event Burned(address indexed from, uint256 tokenId, uint256 amount);
    event BatchBurned(address from, uint256[] tokenId, uint256[] amount);

    CanReceivedERC1155 public yes;
    CannotReceiveERC115Tokens public no;
    BeansToken public b;

    address public maria;
    address public alice;
    address public bob;
    address public paco;
    address public anna;
    address public joan;

    // Array with diferents addresses.
    address[] public user = new address[](4);
    // Array with amounts that the length no match with ids array.
    uint256[] public incorrectLength = new uint256[](3);
    // Array with id tokens.
    uint256[] public amounts = new uint256[](4);
    // Array with an address 0.
    address[] public user0 = new address[](4);
    // Array with diffrents tokens id.
    uint256[] public _ids = new uint256[](4);
    // Array witn insuficient balance.
    uint256[] public insuficientBalance = new uint256[](4);
    // Array with amount 0.
    uint256[] public amount0 = new uint256[](4);
    // Array with suficient balance.
    uint256[] public suficientBalance = new uint256[](4);

    uint256[] public maxAmounts = maxAmounts = new uint256[](4);
    uint256[] public ids = new uint256[](4);

    function setUp() public {
        maria = makeAddr("maria");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        paco = makeAddr("paco");
        anna = makeAddr("anna");
        joan = makeAddr("joan");

        vm.prank(maria);
        b = new BeansToken(0.1 ether, 20);
        yes = new CanReceivedERC1155();
        no = new CannotReceiveERC115Tokens();

        user[0] = alice;
        user[1] = bob;
        user[2] = paco;
        user[3] = anna;

        incorrectLength[0] = 6;
        incorrectLength[1] = 8;
        incorrectLength[2] = 2;

        amounts[0] = 3;
        amounts[1] = 5;
        amounts[2] = 2;
        amounts[3] = 2;

        user0[0] = alice;
        user0[1] = bob;
        user0[2] = address(0);
        user0[3] = anna;

        insuficientBalance[0] = 5;
        insuficientBalance[1] = 7;
        insuficientBalance[2] = 2;
        insuficientBalance[3] = 111;

        suficientBalance[0] = 5;
        suficientBalance[1] = 7;
        suficientBalance[2] = 2;
        suficientBalance[3] = 1;

        ids[0] = 24;
        ids[1] = 12;
        ids[2] = 27;
        ids[3] = 4;

        maxAmounts[0] = 7;
        maxAmounts[1] = 5;
        maxAmounts[2] = 8;
        maxAmounts[3] = 3;

        amount0[0] = 7;
        amount0[1] = 3;
        amount0[2] = 0;
        amount0[3] = 3;
    }

    function test_Deploy() public {
        // Check that evemt emited is correct.
        vm.expectEmit();
        emit Minted(maria, 1, 20, 0);
        // The contract is deployed by Maria.
        vm.prank(maria);
        b = new BeansToken(0.1 ether, 20);
        // check that the owner is Maria.
        assertEq(b.owner(), maria);
        // check that maria has 5 tokens.
        assertEq(b.balanceOf(maria, 1), 20);
        // check that the price for minting 1 token is 0.1 ether.
        assertEq(b.PRICE_PER_TOKEN(), 0.1 ether);
        // check that the maximmum amount for mint an id is 20.
        assertEq(b.MAX_TOKENS_PER_ID(), 20);
    }

    function test_Mint() public {
        startHoax(alice);
        // If the _to adderess is address 0, it will revert..
        vm.expectRevert(BeansToken.Invalid_Address.selector);
        b.mint{value: 10 ether}(address(0), 10);
        // If Alice sends a incorrect amount, it will revert.
        vm.expectRevert(BeansToken.Incorrect_Value_Sent.selector);
        b.mint{value: 9 ether}(bob, 10);
        // Save the token id.
        uint256 tokenId = b.tokensCounter() + 1;
        // check that event emoted is correct.
        vm.expectEmit();
        emit Minted(bob, tokenId, 10, 1 ether);
        // alice mints 10 tokens to bob.
        b.mint{value: 1 ether}(bob, 10);
        // check that bob has 10 tokens
        assertEq(b.balanceOf(bob, 2), 10);
        // check that bob is owner of token with id 2.
    }

    function test_BatchMint() public {
        startHoax(alice);
        // If the array are not the same lenfth, it will revert.
        vm.expectRevert(BeansToken.Address_And_Values_Dont_Match.selector);
        b.batchMint(user, incorrectLength);
        // If any of addresses is 0 it will revert.
        vm.expectRevert(BeansToken.Invalid_Address.selector);
        b.batchMint{value: 1.8 ether}(user0, amounts);
        // If the user wants to mint more tokens than allowed it will revert.
        vm.expectRevert(BeansToken.Exceeded_Max_Tokens.selector);
        b.batchMint{value: 1.8 ether}(user, maxAmounts);
        // If Alice sends an incoreect amount of ETH, it will revert
        vm.expectRevert(BeansToken.Incorrect_Value_Sent.selector);
        b.batchMint{value: 1.7 ether}(user, amounts);
        // Save the token id.
        uint256 tokenId = b.tokensCounter() + 1;
        // Chech that event emited is correct.
        vm.expectEmit();
        emit BatchMinted(user, tokenId, amounts, 1.2 ether);
        // Alice mints different amounts of tokens for diferentes addresses..
        b.batchMint{value: 1.2 ether}(user, amounts);
        // Check that different users hava their tokens.
        assertEq(b.balanceOf(alice, 2), 3);
        assertEq(b.balanceOf(bob, 2), 5);
        assertEq(b.balanceOf(paco, 2), 2);
        assertEq(b.balanceOf(anna, 2), 2);
    }

    function test_Burn() public {
        startHoax(alice);
        // Save the token id.
        uint256 tokenId = b.tokensCounter() + 1;
        // Alice mints 5 tokens with id 2.
        b.mint{value: 0.5 ether}(alice, 5);
        // Alice tries to burn 2 tokens with id 0.
        vm.expectRevert(BeansToken.Invalid_Id_Token.selector);
        b.burn(0, 2);
        // Alice tries to burn 2 tokens with an ID greater than the number of minted tokens.
        vm.expectRevert(BeansToken.Invalid_Id_Token.selector);
        b.burn(5, 2);
        // ALice tries to burn an amount more than she has in her balance.
        vm.expectRevert(BeansToken.Insuficient_Tokens_balance.selector);
        b.burn(tokenId, 9);
        // Alice burna 3 tokens.
        uint256 aliceBalance = b.balanceOf(alice, 2);
        vm.expectEmit();
        emit Burned(alice, tokenId, 3);
        b.burn(tokenId, 3);
        // Check that has 3 tokens less.
        assertEq(b.balanceOf(alice, tokenId), aliceBalance - 3);
    }

    function test_BatchBurn() public {
        startHoax(alice);
        uint256 tokenId = b.tokensCounter();
        for (uint256 i; i < 4; i++) {
            tokenId++;
            b.mint{value: 1 ether}(alice, 10);
            _ids[i] = tokenId;
        }
        // If arrays don't have the same length, it will revert.
        vm.expectRevert(BeansToken.Ids_And_Amount_Dont_Match.selector);
        b.batchBurn(_ids, incorrectLength);
        // If the amount is 0. it will revert.
        vm.expectRevert(
            abi.encodeWithSelector(
                BeansToken.The_Amount_Cannot_Be_0.selector,
                2,
                0
            )
        );
        b.batchBurn(_ids, amount0);
        // If Alice tries to burn an amount more than has in her id balance, it will revert.
        vm.expectRevert(
            abi.encodeWithSelector(
                BeansToken.Insuficient_Token_balance.selector,
                3,
                111
            )
        );
        b.batchBurn(_ids, insuficientBalance);
        // Check tha event emited is correct.
        vm.expectEmit();
        emit BatchBurned(alice, _ids, suficientBalance);
        // Alice burns tokens of differents ids.
        b.batchBurn(_ids, suficientBalance);
        // Check that that differnts balnce are correct.
        assertEq(b.balanceOf(alice, 2), 5);
        assertEq(b.balanceOf(alice, 3), 3);
        assertEq(b.balanceOf(alice, 4), 8);
        assertEq(b.balanceOf(alice, 5), 9);
    }

    function test_SafeTransferFrom() public {
        startHoax(alice);
        // ALice mints 300 tokens to herself with differents ids
        for (uint256 i; i < 30; i++) {
            b.mint{value: 1 ether}(alice, 10);
        }
        // If Alice tries to send tokens an address 0, it will revert.
        vm.expectRevert(BeansToken.Invalid_Address.selector);
        b.safeTransferFrom(alice, address(0), 25, 9, "");
        // If Alice tries to send more tokens than she has, it will revert.
        vm.expectRevert(BeansToken.Insuficient_Tokens_balance.selector);
        b.safeTransferFrom(alice, joan, 22, 13, "");
        // ALice sends to joan 5 tokens with id 22.
        b.safeTransferFrom(alice, joan, 22, 5, "");
        // Check that Joan has 5 tokens.
        assertEq(b.balanceOf(joan, 22), 5);
        // Check that Alice has 5 tokens less.
        assertEq(b.balanceOf(alice, 22), 5);
        vm.stopPrank();
        // Bob tries to move all Alice's tokens, if it is not approved, it will revert
        vm.prank(bob);
        vm.expectRevert(BeansToken.You_Are_Not_Approved.selector);
        b.safeTransferFrom(alice, joan, 13, 10, "");
        // Alice approves of Bob moving his tokens.
        vm.prank(alice);
        b.setApprovalFotAll(bob, true);
        vm.startPrank(bob);
        // If Bob tries to move tokens from Alice to a contract that cannot receive ERC1155 tokens, it will revert.
        vm.expectRevert(
            BeansToken.Contract_Cannot_Receive_ERC1155_Tokens.selector
        );
        b.safeTransferFrom(alice, address(no), 13, 10, "");
        vm.expectEmit();
        emit TransferSingle(bob, alice, address(yes), 13, 10);
        // Bob moves tokens from Alice to a contract can receive ERC1155 tokens.
        b.safeTransferFrom(alice, address(yes), 13, 10, "");
        // Check balances.
        assertEq(b.balanceOf(address(yes), 13), 10);
        assertEq(b.balanceOf(alice, 13), 0);
    }

    function test_SafeBatchTranferFrom() public {
        startHoax(alice);
        // ALice mints 300 tokens to herself with differents ids
        for (uint256 i; i < 30; i++) {
            b.mint{value: 1 ether}(alice, 10);
        }
        // If arrays don't have the same length, it will revert.
        vm.expectRevert(BeansToken.Ids_And_Amount_Dont_Match.selector);
        b.safeBatchTransferFrom(alice, anna, ids, incorrectLength, "");
        // check that the _to adderess is a valid address.
        vm.expectRevert(BeansToken.Invalid_Address.selector);
        b.safeBatchTransferFrom(alice, address(0), ids, amounts, "");
        // Check that event emited is correct.
        vm.expectEmit();
        emit TransferBatch(alice, alice, anna, ids, amounts);
        // If the caller is the owner, there is no need to check the approve.
        // Alice sends his token to Anna.
        b.safeBatchTransferFrom(alice, anna, ids, amounts, "hola caracola");
        // Check balnces.
        assertEq(b.balanceOf(anna, 24), 3);
        assertEq(b.balanceOf(anna, 12), 5);
        assertEq(b.balanceOf(anna, 27), 2);
        assertEq(b.balanceOf(anna, 4), 2);
        assertEq(b.balanceOf(alice, 24), 7);
        assertEq(b.balanceOf(alice, 12), 5);
        assertEq(b.balanceOf(alice, 27), 8);
        assertEq(b.balanceOf(alice, 4), 8);
        vm.stopPrank();
        vm.prank(anna);
        //Anna returns the tokens to Alice.
        b.safeBatchTransferFrom(anna, alice, ids, amounts, "");
        vm.startPrank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(
                BeansToken.The_Amount_Cannot_Be_0.selector,
                2,
                0
            )
        );
        b.safeBatchTransferFrom(alice, anna, ids, amount0, "");
        // If Alice tries to send an amount more than has in her id balance, it will revert.
        vm.expectRevert(
            abi.encodeWithSelector(
                BeansToken.Insuficient_Token_balance.selector,
                3,
                111
            )
        );
        b.safeBatchTransferFrom(alice, joan, ids, insuficientBalance, "");
        // Alice approves of Joan for moving her tokens.
        b.setApprovalFotAll(joan, true);
        vm.stopPrank();
        vm.startPrank(joan);
        // Joan tries to move the tokens a contract cannot receice ERC1155 tokens.
        vm.expectRevert(
            BeansToken.Contract_Cannot_Receive_ERC1155_Tokens.selector
        );
        b.safeBatchTransferFrom(alice, address(no), ids, amounts, "");
        // Check that thr envent enoted is correct.
        vm.expectEmit();
        emit TransferBatch(joan, alice, address(yes), ids, amounts);
        // Joan moves alice's tokens to a contract that can receive ERC1155 tokens.
        b.safeBatchTransferFrom(alice, address(yes), ids, amounts, "");
        // Check balances.
        assertEq(b.balanceOf(address(yes), 24), 3);
        assertEq(b.balanceOf(address(yes), 12), 5);
        assertEq(b.balanceOf(address(yes), 27), 2);
        assertEq(b.balanceOf(address(yes), 4), 2);
        assertEq(b.balanceOf(alice, 24), 7);
        assertEq(b.balanceOf(alice, 12), 5);
        assertEq(b.balanceOf(alice, 27), 8);
        assertEq(b.balanceOf(alice, 4), 8);
    }

    function test_SetApproval() public {
        // If the address to approve is 0 it will revert
        vm.expectRevert(BeansToken.Invalid_Address.selector);
        b.setApprovalFotAll(address(0), true);
    }

    function test_BalanceBatch() public {
        // If address is 0 it will revert.
        vm.expectRevert(BeansToken.Invalid_Address.selector);
        b.balanceOfBatch(user0, _ids);
    }

    function test_CheckERC1155Receiver() public {
        // If contract cannot receive ERC1155 token it will revert.
        vm.expectRevert(
            BeansToken.Contract_Cannot_Receive_ERC1155_Tokens.selector
        );
        b._checkERC1155Receiver(alice, address(no), 2, 7, "");
    }

    function test_CheckERC115Batch5Receiver() public {
        // If contract cannot receive ERC1155 token it will revert.
        vm.expectRevert(
            BeansToken.Contract_Cannot_Receive_ERC1155_Tokens.selector
        );
        b._checkERC1155BatchReceiver(alice, address(no), ids, amounts, "");
    }

    function test_IsContract() public {
        // If the address is a contract returns true.
        assertTrue(b._isContract(address(this)));
        // If the address is not a contract returns false.
        assertFalse(b._isContract(alice));
    }
}
