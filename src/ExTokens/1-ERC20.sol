// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/solmate/src/tokens/ERC20.sol";

contract ForniToken is ERC20 {

    event Genesis(address owner);
    event Mint(address indexed to, uint amount);
    event Burn(address indexed user, uint256 amount);


    error Amount_Cannot_Be_0();
    error Invalid_Address();

    address public immutable owner;


    constructor() ERC20("Forni Token", "Forni" ,18) {
        owner = msg.sender;
        _mint(owner, 1_000_000 ether);
        emit Genesis(owner);
    }

    function mint(address _to, uint256 _amount) public {
        if (_amount == 0) revert Amount_Cannot_Be_0();
        if (_to == address(0)) revert Invalid_Address();
        _mint(_to, _amount);
        emit Mint(_to, _amount);
    }

    function burn(uint256 _amount) public {
        if (_amount == 0) revert Amount_Cannot_Be_0();
        _burn(msg.sender, _amount);
        emit Burn(msg.sender, _amount);
    }
}
