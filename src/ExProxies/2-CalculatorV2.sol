//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

contract ImplementacionV2 is UUPSUpgradeable {

    error YouAreNotOwner();
    error IsNotNewImplementation();
    error IsNotAContract();

    
    address public immutable owner;
    address public addrThis;
    uint256 public result;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert YouAreNotOwner();
        _;
    }

    modifier oldImplementation(address _address) {
        if (_address == addrThis) revert IsNotNewImplementation();
        _;
    }    
    
    function addition(uint256 a, uint256 b) external returns (uint256) {
        return result = a + b;
        
    }

    function substraction(uint256 a, uint256 b) external returns (uint256) {
        return result = a - b;

    }

    function multiplication(uint256 a, uint256 b) external returns (uint256) {
        return result = a * b;

    }

    function division(uint256 a, uint256 b) external returns (uint256) {
        return result = a / b;
    }

    function _authorizeUpgrade(
        address _newImplementation
    ) internal override onlyOwner oldImplementation(_newImplementation) {
        if (!_isContract(_newImplementation)) revert IsNotAContract();
    }

    function _isContract(address _newImplementation) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_newImplementation)
        }
        return size > 0;

    }  


}
