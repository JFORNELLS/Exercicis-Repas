//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract ImplementacionV1 is UUPSUpgradeable, Initializable{

    error YouAreNotOwner();
    error IsNotNewImplementation();
    error IsNotAContract();

    address public owner;
    address public addrThis;

    modifier onlyOwner() {
        if (msg.sender != owner) revert YouAreNotOwner();
        _;
    }

    modifier oldImplementation(address _address) {
        if (_address == addrThis) revert IsNotNewImplementation();
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize() external onlyProxy initializer {
        owner = msg.sender;
    }

    function addition(uint256 a, uint256 b) external pure returns(uint256 result) {
        result = a / b;
    }

    function substraction(uint256 a, uint256 b) external pure returns(uint256 result) {
        result = a * b;
    }

    function multiplication(uint256 a, uint256 b) external pure returns(uint256 result) {
        result = a + b;
    }

    function division(uint256 a, uint256 b) external pure returns(uint256 result) {
        result = a - b;
    }

    function getImplementation() external view returns (address) {
        return addrThis;
    }

    function setAddrThis(address _addrThis) external onlyOwner {
        addrThis = _addrThis;
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
