// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "./IWETH.sol";
import { ReceiptToken } from "./ReceiptToken.sol";


contract StakingSamos {
    using SafeMath for uint256;

    struct User {
        address addr;
        uint256 wethBalance;
        uint256 receiptTokenBalance;
        bool optedInForAutoCompounding;
        uint256 lastAutoCompoundingTimestamp;
        bool isActive;
    }
    address public owner;

    address public wethTokenAddress;
    ReceiptToken public receiptToken;

    uint256 public annualAPR = 14; // 14% APR
    uint256 public autoCompoundingFeePercentage = 1; // 1% fee
    uint256 public totalAutoCompoundingFee;

    mapping(address => User) public users;

    uint256 public autoCompoundingInterval;
    uint256 public precision = 10**18;

    error InsufficientETH();
    error NoReceiptTokensToCompound();
    error AlreadyOptedInForAutoCompounding();
    error AmountMustBeGreaterThanZero();
    error OnlyContractOwnerCanCallThisFunction();
    error AutoCompoundingNotDueYet();
    error InvalidTokenAddress();
    error TokenTransferFailed();
    error InactiveUser();
    error NotOptedIn();

    event Deposited(address indexed user, uint256 wethAmount, uint256 receiptTokens);
    event AutoCompoundingOptIn(address indexed user);
    event AutoCompound(address indexed user, uint256 wethAmount, uint256 receiptTokens);
    event Withdrawn(address indexed user, uint256 amount);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyContractOwnerCanCallThisFunction();
        }
        _;
    }

    constructor(address _wethTokenAddress) {
        owner = msg.sender;

        if (_wethTokenAddress == address(0)) {
            revert InvalidTokenAddress();
        }

        wethTokenAddress = _wethTokenAddress;
        receiptToken = new ReceiptToken();

        autoCompoundingInterval = 30 days; // Set the default auto-compounding interval to 30 days
    }

    /** Deposit ETH to receive receipt tokens */
    function deposit() external payable {
        if (msg.value <= 0) {
            revert AmountMustBeGreaterThanZero();
        }

        uint256 wethAmount = msg.value; // for real life use please convert to weth

        // IWETH(wethTokenAddress).deposit{ value: wethAmount }();
        uint256 receiptTokens = _getRewardForDeposit(wethAmount);

        User storage currentUser = users[msg.sender];

        currentUser.addr = msg.sender;
        currentUser.wethBalance += wethAmount;
        currentUser.receiptTokenBalance += receiptTokens;
        currentUser.isActive = true;

        receiptToken.mint(msg.sender, receiptTokens);

        emit Deposited(msg.sender, wethAmount, receiptTokens);
    }

    function _getRewardForDeposit(uint256 amountInEth) internal view returns (uint256) {
        uint256 annualRewardRate = (annualAPR * precision) / 100;

        uint256 annualRewardTokens = (amountInEth * 10 * annualRewardRate) / 365;

        return annualRewardTokens;
    }

    function optInAutoCompounding() external {
        User storage currentUser = users[msg.sender];

        if (!currentUser.isActive) {
            revert InactiveUser();
        }

        if (currentUser.optedInForAutoCompounding) {
            revert AlreadyOptedInForAutoCompounding();
        }
        if (currentUser.receiptTokenBalance <= 0) {
            revert NoReceiptTokensToCompound();
        }
        if (block.timestamp < currentUser.lastAutoCompoundingTimestamp + autoCompoundingInterval) {
            revert AutoCompoundingNotDueYet();
        }

        currentUser.optedInForAutoCompounding = true;
        currentUser.lastAutoCompoundingTimestamp = block.timestamp;

        emit AutoCompoundingOptIn(msg.sender);
    }

    function autoCompound(address addr) external onlyOwner {
        User storage currentUser = users[addr];

        if (!currentUser.isActive) {
            revert InactiveUser();
        }

        if (!currentUser.optedInForAutoCompounding) {
            revert NotOptedIn();
        }
        if (block.timestamp < currentUser.lastAutoCompoundingTimestamp + autoCompoundingInterval) {
            revert AutoCompoundingNotDueYet();
        }

        uint256 wethBalance = currentUser.wethBalance;
        uint256 autoCompoundingFee = (wethBalance * autoCompoundingFeePercentage) / 100;

        if (autoCompoundingFee > wethBalance) {
            revert InsufficientETH();
        }

        currentUser.wethBalance -= autoCompoundingFee;
        totalAutoCompoundingFee += autoCompoundingFee;

        uint256 tokensToConvert = currentUser.receiptTokenBalance / 10;

        currentUser.receiptTokenBalance -= tokensToConvert * 10;
        currentUser.wethBalance += tokensToConvert;

        currentUser.lastAutoCompoundingTimestamp = block.timestamp;

        emit AutoCompound(addr, wethBalance, tokensToConvert);
    }

    function withdrawWeth(uint256 amount) external {
        User storage currentUser = users[msg.sender];

        if (!currentUser.isActive) {
            revert InactiveUser();
        }

        if (amount <= 0) {
            revert AmountMustBeGreaterThanZero();
        }
        if (amount > currentUser.wethBalance) {
            revert InsufficientETH();
        }

        currentUser.wethBalance -= amount;

        (bool success, ) = msg.sender.call{ value: amount }(""); /// assume one weth to be one eth
        if (!success) {
            revert TokenTransferFailed();
        }

        emit Withdrawn(msg.sender, amount);
    }

}
