//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "src/Proxies/1-Proxy.sol";
import {ImplementacionV1} from "src/Proxies/1-CalculatorV1.sol";
import {ImplementacionV2} from "src/Proxies/1-CalculatorV2.sol";

contract ProxyTest is Test {
    ImplementacionV1 public implementacionV1;
    Proxy public proxy;
    address public owner;
    ImplementacionV2 public implementacionV2;

    function setUp() public {
        owner = makeAddr("owner");
        implementacionV1 = new ImplementacionV1();
        vm.prank(owner);
        proxy = new Proxy(address(implementacionV1));
        implementacionV2 = new ImplementacionV2();
    }

    function test_Upgrade() public {
        // If the caller is not the owner it will revert.
        vm.expectRevert(Proxy.YouAreNotOwner.selector);
        proxy.upgrade(address(implementacionV2));
        
        vm.startPrank(owner);
        // If the new implementation isn't a contract, it will revert
        vm.expectRevert(Proxy.IsNotAContract.selector);
        proxy.upgrade(address(owner));

        // If by mistake, the new implementation is the old address, it will revert.
        vm.expectRevert(Proxy.IsNotNewImplementation.selector);
        proxy.upgrade(address(implementacionV1));  

        // The owner calls the function upgrade, and changes the new implentation.   
        proxy.upgrade(address(implementacionV2));   

        // I call the addition function, and the proxy redirects it to implementationV2, 
        // updates the proxy's storage, and checks the variable in the proxy
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("addition(uint256,uint256)", 2, 2)
        );
        uint256 result = uint256(vm.load(address(proxy), bytes32(uint256(1))));
        assertEq(result, 4);

        (bool success1, ) = address(proxy).call(
            abi.encodeWithSignature("substraction(uint256,uint256)", 555, 333)
        );
        uint256 result1 = uint256(vm.load(address(proxy), bytes32(uint256(1))));
        assertEq(result1, 222);

        (bool success2, ) = address(proxy).call(
            abi.encodeWithSignature("multiplication(uint256,uint256)", 10, 787)
        );
        uint256 result2 = uint256(vm.load(address(proxy), bytes32(uint256(1))));
        assertEq(result2, 7870);

        (bool success3, ) = address(proxy).call(
            abi.encodeWithSignature("division(uint256,uint256)", 200, 4)
        );
        uint256 result3 = uint256(vm.load(address(proxy), bytes32(uint256(1))));
        assertEq(result3, 50);
    }
}
