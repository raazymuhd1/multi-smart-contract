// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test, console} from "forge-std/Test.sol";
import { WETH } from "../../src/WETH.sol";
import { DeployWeth } from "../../script/DeployWeth.s.sol";

contract WethTest is Test {
    DeployWeth deployer;
    WETH weth;

    address USER = makeAddr("USER");
    uint256 DEPOSIT_AMOUNT = 3 ether;
    uint256 INITIAL_BALANCE = 10 ether;

    function setUp() public {
        deployer  = new DeployWeth();
        weth = deployer.run();

        vm.deal(USER, INITIAL_BALANCE);
    }


    function test_depositAndMintWeth() public {
        uint256 currBalance = weth.balanceOf(USER);

        vm.startPrank(USER);
        weth.deposit{value: DEPOSIT_AMOUNT}();
        uint256 afterDepositBalance = weth.balanceOf(USER);
        (, bytes memory data) = address(weth).staticcall(abi.encodeWithSignature("name()"));
        string memory name_ = abi.decode(data, (string));

        vm.stopPrank();
        console.log(afterDepositBalance, name_);
        console.log(address(weth).balance);

        assert(afterDepositBalance > currBalance);
        assert(address(weth).balance == DEPOSIT_AMOUNT);
        assertEq(afterDepositBalance, DEPOSIT_AMOUNT);

    }

    function test_withdrawEthAndBurnWeth() public {
        vm.startPrank(USER);
        weth.deposit{value: DEPOSIT_AMOUNT}();
        uint256 currentEthBalance = address(weth).balance;

        weth.withdraw(currentEthBalance);
        uint256 afterBurnBalance = weth.balanceOf(USER);
        uint256 afterWithdrawEthBalance = address(weth).balance;

        vm.stopPrank();

        console.log(address(weth).balance);
        console.log(currentEthBalance, afterWithdrawEthBalance);

        assert(afterBurnBalance == 0);
        assert(afterWithdrawEthBalance == 0);
        assertEq(USER.balance, INITIAL_BALANCE);
    }
}