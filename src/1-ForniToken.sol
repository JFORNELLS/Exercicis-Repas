// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/solmate/src/tokens/ERC20.sol";

contract ForniToken is ERC20 {
    /// @notice Emited when the contrat is deployed.
    event Genesis(address owner);
    /// @notice Emited when he user mints tokens.    
    event Mint(address indexed to, uint amount);
    /// @notice Emited when the user burns tokens.
    event Burn(address indexed user, uint256 amount);


    /// @notice Thrown when the amount is 0.
    error Amount_Cannot_Be_0();
    /// @notice Thrown when the caller is address 0.
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
