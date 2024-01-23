// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ImplementacionV2} from "../src/ExProxies/2-CalculatorV2.sol";

contract ImplementacionV2Script is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address key = vm.addr(privateKey);
        console.log("Key", key);
        address proxy = 0xB2A08735bE2B8bbA3579c9B17E63C0641Af8E635;

        vm.startBroadcast(privateKey);
        //Deply new implementation.
        ImplementacionV2 implementacionV2 = new ImplementacionV2();
        // Call the proxy and change the implemmentation.
        bytes memory data = abi.encodeWithSignature("setAddrThis(address)", address(implementacionV2));
        (bool ok, ) = proxy.call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(implementacionV2), data)
        );
        require(ok, "Fail");

        vm.stopBroadcast();

    }
}