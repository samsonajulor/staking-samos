// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import {StakingSamos} from "../src/Skaker.sol";

contract TestStakingSamos is Test {
    uint256 _precision = 10**18;
    uint256 _annualAPR = 14; // 14% APR

    function _getRewardForDeposit(uint256 amountInEth) internal view returns (uint256) {
        uint256 annualRewardRate = (_annualAPR * _precision) / 100;

        uint256 annualRewardTokens = (amountInEth * 10 * annualRewardRate) / 365;

        return annualRewardTokens;
    }
    function mkaddr(
        string memory name
    ) public returns (address addr, uint256 privateKey) {
        privateKey = uint256(keccak256(abi.encodePacked(name)));
        // address addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))))
        addr = vm.addr(privateKey);
        vm.label(addr, name);
    }
    
    function switchSigner(address _newSigner) public {
        vm.startPrank(_newSigner);
        vm.deal(_newSigner, 4 ether);
    }

    StakingSamos public stakingSamosContract;

    address _johnDoe;
    address _janeDoe;

    uint256 _privKeyA;
    uint256 _privKeyB;

    StakingSamos.User public userA;

    function setUp() public {
        (_johnDoe, _privKeyA) = mkaddr("JOHN_DOE");
        (_janeDoe, _privKeyB) = mkaddr("JANE_DOE");

        switchSigner(_johnDoe);

        stakingSamosContract = new StakingSamos(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);

        userA = StakingSamos.User({
            addr: _johnDoe,
            wethBalance: 0,
            receiptTokenBalance: 0,
            optedInForAutoCompounding: false,
            lastAutoCompoundingTimestamp: 0,
            isActive: false
        });
    }

    function testConstructor() public {
        stakingSamosContract = new StakingSamos(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
        assertEq(stakingSamosContract.owner(), _johnDoe);


        assertEq(stakingSamosContract.wethTokenAddress(), 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);

        assertEq(stakingSamosContract.autoCompoundingInterval(), 30 days);
    }

    function testDeposit() public {
        stakingSamosContract.deposit{value: 1 ether}();
        (address addr, uint256 wethBalance, uint256 receiptTokenBalance, bool optedInForAutoCompounding,uint256 lastAutoCompoundingTimestamp, bool isActive) = stakingSamosContract.users(_johnDoe);
        assertEq(wethBalance, 1 ether);
        assertEq(optedInForAutoCompounding, false);
        assertEq(lastAutoCompoundingTimestamp, 0);
        assertEq(isActive, true);
        assertEq(addr, _johnDoe);
        assertEq(receiptTokenBalance, _getRewardForDeposit(1 ether));
        assertEq(stakingSamosContract.receiptToken().balanceOf(_johnDoe), _getRewardForDeposit(1 ether));
    }

    function testOptInAutoCompounding() public {
        stakingSamosContract.deposit{value: 1 ether}();
        stakingSamosContract.optInAutoCompounding();
        (,,, bool optedInForAutoCompounding,,) = stakingSamosContract.users(_johnDoe);

        assertEq(optedInForAutoCompounding, true);
    }
}
