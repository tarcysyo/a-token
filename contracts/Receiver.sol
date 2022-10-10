// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Receiver is Ownable {
    // Constructor  
    constructor() {}

    // Public functions that are view
    function viewBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    } 
}
