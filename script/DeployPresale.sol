// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/library/Ownable.sol";

contract Presale is Ownable {
    error Presale_AddressCannotBeZero();
    error Presale_valueShouldMoreThanZero();
    error Presale_PaymentFailed();
    error Presale_BnbBalanceIsZero();
    error Presale_UsdtBalanceIsZero();
    error Presale_WithdrawFailed();

    uint256 private constant TOKEN_RATE = 100;
    uint256 private constant PRESALE_PRICE =  0.1;
    uint256 private constant USDT_DECIMALS = 6;
    uint256 private constant USDC_DECIMALS = 6;
    uint256 private constant BNB_DECIMALS = 18;

    address private s_treasuryWallet;
    IERC20 private s_tokenToSell;
    Currency private s_currency;
    SaleState private s_saleState;


    // EVENTS
    event BuyTokenSuccessull(address indexed buyer, uint256 indexed amount);
    event WithdrawSuccessfull(address indexed withdrawTo, uint256 indexed amount);


    // --------------------STRUCTS------------------------
    struct Currency {
        address usdt;
        address usdc;
        address bnb;
    } 

    // ------------------ ENUM -------------------------
    enum SaleState {
        START,
        PAUSE
    }

    // ------------------ MODIFIER ----------------------------

    modifier NotZeroAddress() {
        if(msg.sender != address(0)) {
            revert Presale_AddressCannotBeZero();
        }
        _;
    }

    constructor(address usdt_, address usdc_, address bnb_, address treasury_, address tokenAddr) {
        s_treasuryWallet = treasury_;
        s_tokenToSell = IERC20(tokenAddr);
        s_currency = Currency({ usdt: usdt_, usdc: usdc_, bnb: bnb_ });
    }   


    // INTERNAL & PRIVATE FUNCTIONS -----------------------------
     function _selectedCurrencyToPay(address selectedCurrency_) internal returns(address currency) {
        if(selectedCurrency_ == s_currency.usdt) {
            currency = s_currency.usdt;
        }

         if(selectedCurrency_ == s_currency.usdc) {
            currency = s_currency.usdc;
        }

         if(selectedCurrency_ == s_currency.bnb) {
            currency = s_currency.bnb;
        }
    }

     function _selectedCurrencyToWithdraw(address selectedCurrency_) internal returns(address currency) {
        if(selectedCurrency_ == s_currency.usdt) {
            currency = s_currency.usdt;
        }

         if(selectedCurrency_ == s_currency.usdc) {
            currency = s_currency.usdc;
        }

         if(selectedCurrency_ == s_currency.bnb) {
            currency = s_currency.bnb;
        }
    }


    // -------------------- EXTERNAL & PUBLIC FUNCTIONS ----------------------------
    function buyToken(uint256 amount, address currency) external payable NotZeroAddress {
         uint256 balanceOfToken = IERC20(_selectedCurrencyToWithdraw(currency)).balanceOf(msg.sender);

        if(_selectedCurrencyToPay(currency) == s_currency.bnb && msg.value <= 0) {
            revert Presale_valueShouldMoreThanZero();
        }

        if(_selectedCurrencyToPay(currency) == s_currency.usdt || _selectedCurrencyToPay(currency) == s_currency.usdc && balanceOfToken <= 0) {
            revert Presale_valueShouldMoreThanZero();
        }

        bool success;

        if(_selectedCurrencyToPay(currency) == s_currency.bnb) {
             (success, ) = payable(address(this)).call{value: _amountToPay(amount, currency)}("");
        }

        if(_selectedCurrencyToPay(currency) == s_currency.usdt || _selectedCurrencyToPay(currency) == s_currency.usdc) {
           success = IERC20(_selectedCurrencyToPay(currency)).transferFrom(msg.sender, s_treasuryWallet, _amountToPay(amount, currency));
        }

        if(!success) {
            revert Presale_PaymentFailed();
        }

        s_tokenToSell.transfer(address(this), msg.sender);
        emit BuyTokenSuccessull(msg.sender, amount);
       
    }

    function _amountToPay(uint256 amount, address currency) internal returns(uint amountTopay_) {
          if(selectedCurrency_ == s_currency.usdt) {
             amountTopay_ = (amount * PRESALE_PRICE) * USDT_DECIMALS;
          }

          if(selectedCurrency_ == s_currency.usdc) {
             amountTopay_ = (amount * PRESALE_PRICE) * USDC_DECIMALS;
          }

          if(selectedCurrency_ == s_currency.bnb) {
             amountTopay_ = (amount * PRESALE_PRICE) * BNB_DECIMALS;
          }
          
    }

    function withdraw(address currency) external payable NotZeroAddress OnlyOwner {
         bool success;
         uint256 balanceOfToken = IERC20(_selectedCurrencyToWithdraw(currency)).balanceOf(address(this));

        if(_selectedCurrencyToWithdraw(currency) == s_currency.bnb && address(this).balance <= 0) {
            revert Presale_BnbBalanceIsZero();
        }

        (success, ) = s_treasuryWallet.call{value: address(this).balance}("");

        if(_selectedCurrencyToWithdraw(currency) == s_currency.usdt || _selectedCurrencyToWithdraw(currency) == s_currency.usdc && balanceOfToken <= 0) {
           revert Presale_UsdtBalanceIsZero();
        }

        success = s_tokenToSell.transfer(s_treasuryWallet, balanceOfToken);

        if(!success) {
            revert Presale_WithdrawFailed();
        }

        emit WithdrawSuccessfull();
    }

    function startPrivateSale() external view OnlyOwner returns(SaleState state) {
        require(s_saleState != SaleState.START, "presale is has been started");
        s_saleState = SaleState.START;
        state = s_saleState;
    }

    function pausePresale() external OnlyOwner returns(SaleState state) {
        require(s_saleState == SaleState.START, "presale is not started yet");
        s_saleState = SaleState.PAUSE;
        state = s_saleState;
    }

    function getTokenSellBalance() external view returns(uint256 balance) {
        balance = s_tokenToSell.balanceOf(address(this));
    }
}
