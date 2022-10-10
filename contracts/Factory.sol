// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CustomERC20.sol";

contract Factory is Ownable {
    // Events
    event ERC20TokenCreated(address tokenAddress);

    // Constructor
    constructor(){}

    // Public functions
    function deployNewERC20Token (
        string calldata name,
        string calldata symbol,
        uint8 gain,
        address payable[] calldata receivers,
        uint256[] calldata amounts
    ) public onlyOwner returns (address) {
        ERC20 t = new CustomERC20(
            name,
            symbol,
            gain,
            receivers,
            amounts,
            owner()
        );
        emit ERC20TokenCreated(address(t));

        return address(t);
    }
}
