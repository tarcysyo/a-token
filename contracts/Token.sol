// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract Token is ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit {
    // State variables
    uint8 public gain;
    uint256 private _grossValue;
    uint256 private _netValue;
    uint256 internal constant UNITY = 1e18;

    // Events
    event BatchSubmit(uint256 indexed grossValue, uint256 indexed netValue, uint256 indexed gainValue);
    event BurnExpenses(address indexed selfAddress, uint256 indexed balance);
    event GainChanged(uint8 indexed previousGain, uint8 indexed newGain);
    event Spend(uint256 indexed destination, uint256 indexed amount);

    // Constructor
    constructor(uint8 gain_) ERC20("A-Token", "ATK") ERC20Permit("A-Token") {
        gain = gain_;
    }

    // Public functions
    function changeGain (uint8 newGain) public virtual onlyOwner {
        require(newGain != 0, "changeGain: New gain must be greater than 0");
        _changeGain(newGain);
    }

    function spend(uint256 destination, uint256 amount) public {
        uint256 amount_ = (amount * UNITY);
        _transfer(msg.sender, address(this), amount_);
        emit Spend(destination, amount_);       
    }

    function contractBalance() public view returns (uint256 balance) {
        return balanceOf(address(this));
    }

    function mint(uint256 amount) public onlyOwner {
        uint256 amount_ = amount * UNITY;
        _mint(address(this), amount_);
        _grossValue = amount_;
    }

    function burnExpenses() public onlyOwner {
        uint256 balance = contractBalance();
        _burn(address(this), balance);
        emit BurnExpenses(address(this), balance);
    }

    function batchSubmit(address payable[] memory receivers, uint256[] memory amounts) public onlyOwner {
        require(receivers.length == amounts.length, "batchSubmit: Amount of addresses or transfer values are wrong");
        _netValue = 0;
        for (uint256 i=0; i < receivers.length; i++) {
            uint256 _netValue_ = ((amounts[i] - ((amounts[i] / 100) * gain)) * UNITY);
            _transfer(address(this), receivers[i], _netValue_);
            _netValue += _netValue_;
        }
        _transfer(address(this), msg.sender, (_grossValue - _netValue));
        emit BatchSubmit(_grossValue, _netValue, (_grossValue - _netValue));
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Internal functions
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _changeGain(uint8 newGain) internal virtual {
        uint8 oldGain = gain;
        gain = (newGain);
        emit GainChanged(oldGain, newGain);
    }
}
