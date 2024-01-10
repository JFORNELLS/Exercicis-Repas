// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {InteractuaDai} from "src/ExInterfaces/1-ETHMainnet.sol";

contract InteractuaDaiTest is Test {
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    InteractuaDai public inter;
    address public dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {
        vm.createSelectFork(MAINNET_RPC_URL);

        inter = new InteractuaDai(address(dai));
    }

    function test_Name() public {
        assertEq(inter.consultaNombreDai(), "Dai Stablecoin");
    }
}