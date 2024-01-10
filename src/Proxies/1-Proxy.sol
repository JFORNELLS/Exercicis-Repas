//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract Proxy {

    event Upgraded(address indexed newImplentation);

    error YouAreNotOwner();
    error DelegatecallFailed();
    error IsNotNewImplementation();
    error IsNotAContract();

    address public immutable owner;
    address public implementation;
    

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert YouAreNotOwner();
        _;
    }

    function upgrade(address _newImplementation) external onlyOwner {
        if (_newImplementation == implementation) revert IsNotNewImplementation();
        if (!_isContract(_newImplementation)) revert IsNotAContract();
        implementation = _newImplementation;
        emit Upgraded(_newImplementation);
    }

    fallback() external {
        (bool success, ) = implementation.delegatecall(msg.data);
        if (!success) revert DelegatecallFailed();
    }

    function _isContract(address _newImplementation) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_newImplementation)
        }
        return size > 0;

    }    

}