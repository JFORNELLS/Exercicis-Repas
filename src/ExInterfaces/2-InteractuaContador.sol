// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IBlockcoder {
    function increment() external;

    function decrement() external;

    function counter() external view returns (uint256);
}

contract InteractuaContador {

    IBlockcoder public blockcoder;

    constructor(address _blockcoder) {
        blockcoder = IBlockcoder(_blockcoder);
    }

    function incrementaContador() external {
       blockcoder.increment();
    }

    function deccrementContador() external {
        blockcoder.decrement();
    }

    function contador() public view returns (uint256) {
       return  blockcoder.counter();
    }

}