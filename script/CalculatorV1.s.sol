// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ImplementacionV1} from "../src/ExProxies/2-CalculatorV1.sol";

contract ImplementacionV1Script is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address key = vm.addr(privateKey);
        console.log("Key", key);

        vm.startBroadcast(privateKey);
        //Deply new implementation.
        ImplementacionV1 implementacionV1 = new ImplementacionV1();

        vm.stopBroadcast();
    }
}