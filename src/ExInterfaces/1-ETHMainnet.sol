// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IDAI {
    function name() external view returns (string memory); 
}

contract InteractuaDai {

    
    address public token;

    constructor(address _dai) {
        token = _dai;
    }

    function consultaNombreDai() public view returns (string memory) {
        return IDAI(token).name();
    }
}