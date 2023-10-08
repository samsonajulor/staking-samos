// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import { ReceiptToken } from "./ReceiptToken.sol";

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}