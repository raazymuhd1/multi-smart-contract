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
    uint256 public USDT_PRICE = 0.01 ether;
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
        usdcContract.mint(USER, 1000_000 * DECIMALS);
        vm.stopPrank();
        _;
    }

    function test_selectedCurrency() public {
        vm.prank(USER);
        address expectedPaymentToken = presale.getSelectedTokenPay("usdt");
        
        console.log(expectedPaymentToken);
        assert(expectedPaymentToken == usdt);
    }

    function test_buyTokenWithUsdt() public Minted {
        uint tokenAmount = 200;
        uint256 payAmount = USDT_PRICE * tokenAmount;

        vm.startPrank(USER);
        uint256 userBalanceBfore = tokenContract.balanceOf(USER);

        usdtContract.approve(address(presale), payAmount); // this approve should be call on the frontend later 
        presale.buyToken{value: 0}(tokenAmount, "usdt");
        uint256 expectedBalance = tokenContract.balanceOf(USER);

        vm.stopPrank();

        console.log(payAmount);
        assert(expectedBalance > userBalanceBfore);
    }
    

     function test_buyTokenWithBnb() public Minted {
        uint tokenAmount = 200;
        uint256 payAmount = BNB_PRICE * tokenAmount;

        vm.startPrank(USER);
        uint256 userBalanceBfore = tokenContract.balanceOf(USER);

        presale.buyToken{value: payAmount}(tokenAmount, "bnb");
        uint256 expectedBalance = tokenContract.balanceOf(USER);

        console.log(payAmount);
        console.log(address(this).balance);

        vm.stopPrank();

        assert(expectedBalance > userBalanceBfore);
    }

     function test_buyTokenWithUsdc() public Minted {
        uint tokenAmount = 200;
        uint256 payAmount = BNB_PRICE * tokenAmount;

        vm.startPrank(USER);
        uint256 userBalanceBfore = tokenContract.balanceOf(USER);
        usdcContract.approve(address(presale), payAmount); // this approve should be call on the frontend later 
        presale.buyToken{value: payAmount}(tokenAmount, "usdc");
        uint256 expectedBalance = tokenContract.balanceOf(USER);

        console.log(payAmount);
        console.log(address(this).balance);

        vm.stopPrank();

        assert(expectedBalance > userBalanceBfore);
    }

    function test_emitBuySuccessfullEvent() public Minted {
        uint tokenAmount = 200;
        uint256 payAmount = BNB_PRICE * tokenAmount;

        vm.startPrank(USER);
        usdtContract.approve(address(presale), payAmount); // this approve should be call on the frontend later 
        vm.expectEmit(address(presale)); // event emitter
        emit Presale.BuyTokenSuccessull(USER, tokenAmount);
        presale.buyToken{value: 0}(tokenAmount, "usdt");

        vm.stopPrank();

        assert(tokenContract.balanceOf(USER) > 0);
    }
}

