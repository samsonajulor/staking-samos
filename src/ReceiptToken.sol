// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// create erc 720 contract and mint 
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ReceiptToken is ERC20 {
    constructor() ERC20("ReceiptToken", "RPT") {
        _mint(msg.sender, 1000000000000000000000000000);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}