// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Proxy2} from "../src/ExProxies/2-Proxy.sol";

contract Proxy2Script is Script {

    function setUp() public {
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address key = vm.addr(privateKey);
        console.log("Key", key);
        // Address from implementation.
        address implementation1 = 0xF7E9A8aCA4E1ECa083098B6b8B2cf3Fa56B3d721;

        vm.startBroadcast(privateKey);
        // Deploy proxy and pass the implementation to the constructor.
        bytes memory data = abi.encodeWithSignature("initialize()");
        Proxy2 proxy = new Proxy2(implementation1, data);

        vm.stopBroadcast();
    }
}