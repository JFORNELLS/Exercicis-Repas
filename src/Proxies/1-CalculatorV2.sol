//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ImplementacionV2  {


    address public implementation;
    uint256 public result;
    
    function addition(uint256 a, uint256 b) external  {
        result = a + b;
    }

    function substraction(uint256 a, uint256 b) external  {
        result = a - b;
    }

    function multiplication(uint256 a, uint256 b) external  {
        result = a * b;
    }

    function division(uint256 a, uint256 b) external  {
        result = a / b;
    }

}