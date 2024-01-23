//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC1967Proxy} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Proxy2 is ERC1967Proxy {

    constructor(address imple, bytes memory _data) ERC1967Proxy(imple, _data) {

    }


}