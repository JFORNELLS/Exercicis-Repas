//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Proxy2} from "src/ExProxies/2-Proxy.sol";
import {ImplementacionV1} from "src/ExProxies/2-CalculatorV1.sol";
import {ImplementacionV2} from "src/ExProxies/2-CalculatorV2.sol";

contract Proxy2Test is Test {
    ImplementacionV1 public implementacionV1;
    Proxy2 public proxy;
    address public owner;
    ImplementacionV2 public implementacionV2;
    
    

    function setUp() public {
        owner = makeAddr("owner");
        vm.startPrank(owner);
        implementacionV1 = new ImplementacionV1();
        
        bytes memory data = abi.encodeWithSignature("initialize()");
        proxy = new Proxy2(address(implementacionV1), data);
        (bool okis, ) = address(proxy).call(abi.encodeWithSignature("setAddrThis(address)", address(implementacionV1)));
        require(okis, "");

     
        implementacionV2 = new ImplementacionV2();
        vm.stopPrank();
    }

    function test_A() public {

        // If the caller is not the owner it will revert.
        vm.expectRevert(ImplementacionV1.YouAreNotOwner.selector);
        (bool ok, ) = address(proxy).call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(implementacionV2), "")
        );     
        require(ok, "");
        
        vm.startPrank(owner);

        // If the new implementation isn't a contract, it will revert
        vm.expectRevert(ImplementacionV1.IsNotAContract.selector);
        (bool ok1, ) = address(proxy).call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)", owner, "")
        );     
        require(ok1, ""); 
                       
        // If by mistake, the new implementation is the old address, it will revert.
        vm.expectRevert(ImplementacionV1.IsNotNewImplementation.selector);
        (bool ok2, ) = address(proxy).call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(implementacionV1), "")
        );     
        require(ok2, "");

        //If the caller of the "upgradeToAndCall" function is not the proxy, it will revert.
        vm.expectRevert();
        (bool okis, ) = address(implementacionV1).call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(implementacionV1), "")
        );     
        require(okis, "");

        bytes memory dates = abi.encodeWithSignature("setAddrThis(address)", address(implementacionV2));
        // The owner calls the function "upgradeToAndCall", and changes the new implentation.   
        (bool ok3, ) = address(proxy).call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(implementacionV2), dates)
        );     
        require(ok3, "");

        // I call the  functions, and the proxy redirects it to implementationV2, 
        // updates the proxy's storage, and checks the variable in the proxy.
        (bool success, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("addition(uint256,uint256)", 10, 21)
        );     
        require(success, "");
        uint256 result = uint256(bytes32(data));
        assertEq(result, 31);

        (bool success1, bytes memory data1) = address(proxy).call(
            abi.encodeWithSignature("substraction(uint256,uint256)", 550, 220)
        );     
        require(success1, "");
        uint256 result1 = uint256(bytes32(data1));
        assertEq(result1, 330);        

        (bool success2, bytes memory data2) = address(proxy).call(
            abi.encodeWithSignature("multiplication(uint256,uint256)", 333, 3)
        );     
        require(success2, "");
        uint256 result2 = uint256(bytes32(data2));
        assertEq(result2, 999);

        (bool success3, bytes memory data3) = address(proxy).call(
            abi.encodeWithSignature("division(uint256,uint256)", 333, 3)
        );     
        require(success3, "");
        uint256 result3 = uint256(bytes32(data3));
        assertEq(result3, 111);

    }
}


