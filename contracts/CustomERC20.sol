// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomERC20 is ERC20 {
    // State variables
    uint8 public gain;
    uint256 internal constant UNITY = 1e18;
    uint256 public beginAt;
    uint256 private _validity = 60 seconds;

    constructor(
        string memory name,
        string memory symbol,        
        uint8 gain_,
        address payable[] memory receivers,
        uint256[] memory amounts,
        address owner
    ) ERC20(name, symbol) {
        require(receivers.length == amounts.length, "CustomERC20: Amount of addresses or transfer values are wrong");
        gain = gain_;        
        uint256 grossValue = 0;
        uint256 netValue = 0;
        beginAt = block.timestamp;
        for (uint256 i=0; i < receivers.length; i++) {
            uint256 grossValue_ = (amounts[i] * UNITY);
            uint256 netValue_ = ((amounts[i] - ((amounts[i] / 100) * gain)) * UNITY);
            _mint(receivers[i], netValue_);
            netValue += netValue_;
            grossValue += grossValue_;
        }
        _mint(owner, (grossValue - netValue));
    }

    function checkValidity() public view returns (bool) {
        return beginAt + _validity > block.timestamp ? true : false;
    }
}
