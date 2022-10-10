// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CustomERC20 is ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit {
    // Structs
    struct Receipt {
        uint256 id;
        address addr;
        uint256 unit;
        uint256 amount;
        uint256 date;
    }

    // State variables
    address public immutable receiver = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    uint256 public beganAt;
    uint256 public receiptCount;    
    uint8 public gain;
    uint256 private _validity = 180 seconds;
    uint256 internal constant UNITY = 1e18;
    
    // Mappings
    mapping (uint256 => Receipt) public receipts;

    // Events
    event ReceiptIssued(address indexed addr, uint256 indexed unit, uint256 indexed amount);

    // Constructor
    constructor(
        string memory name,
        string memory symbol,        
        uint8 gain_,
        address payable[] memory receivers,
        uint256[] memory amounts,
        address owner
    ) ERC20(name, symbol) ERC20Permit(name) {
        require(receivers.length == amounts.length, "CustomERC20: Amount of addresses or transfer values are wrong");

        gain = gain_;        
        uint256 grossValue = 0;
        uint256 netValue = 0;
        beganAt = block.timestamp;

        for (uint256 i=0; i < receivers.length; i++) {
            uint256 grossValue_ = (amounts[i] * UNITY);
            uint256 netValue_ = ((amounts[i] - ((amounts[i] / 100) * gain)) * UNITY);
            _mint(receivers[i], netValue_);
            netValue += netValue_;
            grossValue += grossValue_;
        }
        
        _mint(owner, (grossValue - netValue));
        transferOwnership(owner);
    }

    // Public functions
    function pause() public onlyOwner {
        _pause();
    }

    function spend(uint256 unit, uint256 amount) public returns (bool){
        require(checkValidity() == true,"spend(): Expired token");

        address owner = _msgSender();
        _transfer(owner, receiver, (amount * UNITY));
        receipts[receiptCount] = Receipt(receiptCount, owner, unit, amount, block.timestamp);
        receiptCount++;

        emit ReceiptIssued(owner, unit, amount);
            
        return true;     
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(checkValidity() == true,"transfer(): Expired token");

        address owner = _msgSender();
        _transfer(owner, to, (amount * UNITY));

        return true;
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Public functions that are view
    function checkValidity() public view returns (bool VALID) {
        return beganAt + _validity > block.timestamp ? true : false;
    }

    function getReceipt() public view returns (
        uint256[] memory IDs,
        address[] memory ADDRESSES,
        uint256[] memory UNITS,
        uint256[] memory AMOUNTS,
        uint256[] memory DATES
    )
    {
        uint256[] memory id = new uint256[](receiptCount);
        address[] memory addr = new address[](receiptCount);
        uint256[] memory unit = new uint256[](receiptCount);
        uint256[] memory amount = new uint256[](receiptCount);
        uint256[] memory date = new uint256[](receiptCount);

        for (uint256 i = 0; i < receiptCount; i++) {
            Receipt storage receipt = receipts[i];
            id[i] = receipt.id;
            addr[i] = receipt.addr;
            unit[i] = receipt.unit;
            amount[i] = receipt.amount;
            date[i] = receipt.date;
        }

        return (id, addr, unit, amount, date);
    }

    // Internal functions
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }
}
