// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Presale} from "../../src/Presale.sol";
import { DeployPresale } from "../../script/DeployPresale.s.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract PresaleTest is Test {
    Presale public presale;
    DeployPresale public deployer;
    ERC20Mock public usdtContract;
    ERC20Mock public usdcContract;
    ERC20Mock public tokenContract;

    address usdc;
    address usdt;
    address token;
    address presaleAddr;

    address public USER = makeAddr("USER");
    address public ZERO_ADDR = address(0);
    uint256 public INITIAL_BALANCE = 10 ether;
    uint256 public BNB_PRICE = 0.01 ether;
    uint256 public DECIMALS = 1e18;

    function setUp() public {
        deployer = new DeployPresale();
        ( presaleAddr, usdc, usdt, token) = deployer.run();

        presale = Presale(presaleAddr);
        usdtContract = ERC20Mock(usdt);
        usdcContract = ERC20Mock(usdc);
        tokenContract = ERC20Mock(token);

        vm.deal(ZERO_ADDR, INITIAL_BALANCE);
        vm.deal(USER, INITIAL_BALANCE);

    }

    modifier Minted() {
        vm.startPrank(USER);
        tokenContract.mint(address(presale), 200_000_000 * DECIMALS);
        usdtContract.mint(USER, 1000_000 * DECIMALS);
        vm.stopPrank();
        _;
    }

    function test_selectedCurrency() public {
        vm.prank(USER);
        address expectedPaymentToken = presale.getSelectedTokenPay("usdt");
        
        console.log(expectedPaymentToken);
        assert(expectedPaymentToken == usdt);
    }

    function test_buyWithZeroAddress() public Minted {
        uint tokenAmount = 100;
        uint256 payAmount = (BNB_PRICE * tokenAmount) / DECIMALS;

        vm.expectRevert();
        presale.buyToken{value: payAmount}(100, "usdt");

        vm.stopPrank();

        assert(msg.sender == address(0));
    }

    function test_buyTokenWithUsdt() public Minted {
        uint tokenAmount = 200;
        uint256 payAmount = (BNB_PRICE * tokenAmount) / DECIMALS;

        vm.startPrank(USER);
        uint256 userBalanceBfore = tokenContract.balanceOf(USER);

        tokenContract.approve(address(presale), payAmount);
        presale.buyToken{value: 0}(tokenAmount, "usdt");
        uint256 expectedBalance = tokenContract.balanceOf(USER);

        console.log(tokenContract.balanceOf(address(presale)));
        console.log(usdtContract.balanceOf(address(USER)));
        console.log(USER, address(presale));

        vm.stopPrank();

        console.log(address(presale).balance);
        assert(expectedBalance > userBalanceBfore);
    }
    
}
