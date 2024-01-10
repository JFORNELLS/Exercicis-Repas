// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {InteractuaContador} from "src/ExInterfaces/2-InteractuaContador.sol";

contract InteractuaContadorTest is Test {
    string SEPOLIA_RPC_URL = vm.envString("SEPOLIA_RPC_URL");

    address public contadorBlockcoder = 0xe29686E156E52c429D47d44653316563e2708076;

    InteractuaContador public inter;
    uint256 sepolia;

    function setUp() public {
        vm.createSelectFork(SEPOLIA_RPC_URL);
        
        inter = new InteractuaContador(contadorBlockcoder);
    }

    function test_InteractuaContador() public {
        inter.incrementaContador();
        assertEq(inter.contador(), 1);
        inter.incrementaContador();
        assertEq(inter.contador(), 2);
        inter.deccrementContador();
        assertEq(inter.contador(), 1);
    }


}