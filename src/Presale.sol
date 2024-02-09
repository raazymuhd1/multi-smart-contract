// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Presale is Ownable {
    error Presale_AddressCannotBeZero();
    error Presale_valueShouldMoreThanZero();
    error Presale_PaymentFailed(string reason);
    error Presale_BnbBalanceIsZero();
    error Presale_UsdtBalanceIsZero();
    error Presale_WithdrawFailed();

    uint256 private constant TOKEN_RATE = 100;
    uint256 private constant PRICE_IN_BNB =  0.01 ether;
    uint256 private PRICE_IN_USDT = 0.01 ether ;
    uint256 private constant DECIMALS = 1e18;
    

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
        string bnb;
    } 

    // ------------------ ENUM -------------------------
    enum SaleState {
        START,
        PAUSE
    }

    // ------------------ MODIFIER ----------------------------

    modifier NotZeroAddress() {
        if(msg.sender == address(0)) {
            revert Presale_AddressCannotBeZero();
        }
        _;
    }

    constructor(address usdt_, address usdc_, address treasury_, address tokenAddr) Ownable(msg.sender) {
        s_treasuryWallet = treasury_;
        s_tokenToSell = IERC20(tokenAddr);
        s_currency = Currency({ usdt: usdt_, usdc: usdc_, bnb: 'bnb'});
    }   

    receive() external payable {}

    fallback() external payable {}

    // INTERNAL & PRIVATE FUNCTIONS -----------------------------

    /**
     * @dev check the currency use to pay
     * @param selectedCurrency_ => selected currency use to pay
     * @return USDT => return a USDT true if its a usdt
     * @return USDC => return a USDC true if its a usdt
     * @return BNB => return a BNB true if its a usdt
     */
     function _currencyCheck(string memory selectedCurrency_) internal pure returns(bool USDT, bool USDC, bool BNB) {
        USDT = keccak256(abi.encodePacked(selectedCurrency_)) == keccak256(abi.encodePacked("usdt"));
        USDC = keccak256(abi.encodePacked(selectedCurrency_)) == keccak256(abi.encodePacked("usdc"));
        BNB = keccak256(abi.encodePacked(selectedCurrency_)) == keccak256(abi.encodePacked("bnb"));

        return (USDT, USDC, BNB);
     }


    /**
     * @dev handle a selected currency to pay the token
     * @param selectedCurrency_ => selected currency to pay the token
     * @return currency => return a selected currency
     * @return isBnb => return whether selected currency isBnb or not
     */
     function _selectedCurrencyToPay(string memory selectedCurrency_) internal returns(address currency, bool isBnb) {
         (bool USDT, bool USDC, bool BNB) = _currencyCheck(selectedCurrency_);

        if(USDT) {
            return (s_currency.usdt, false);
        }

        if(USDC) {
            return (s_currency.usdc, false);
        }

        if(BNB) {
            return (address(0), true);
        }

    }

     /**
     * @dev handle a selected currency to withdraw
     * @param selectedCurrency_ => selected currency withdraw
     * @return currency => return a selected currency
     * @return isBnb => return whether selected currency isBnb or not
     */
     function _selectedCurrencyToWithdraw(string memory selectedCurrency_) internal returns(address currency, bool isBnb) {
        (bool USDT, bool USDC, bool BNB) = _currencyCheck(selectedCurrency_);

        if(USDT) {
            return (s_currency.usdt, false);
        }

         if(USDC) {
            return (s_currency.usdc, false);
        }

         if(BNB) {
            return (address(0), true);
        }

    }


    // function approve(address spender, uint256 amount) public returns(bool isApproved) {
        
    //     _approve(owner, spender, value);
    // }


    // -------------------- EXTERNAL & PUBLIC FUNCTIONS ----------------------------
    /**
     * @dev handle buy token with 3 types of token payment
     * @param amount => amount token to buy
     * @param currency => currency to pay
     */
    function buyToken(uint256 amount, string memory currency) external payable NotZeroAddress returns(bool, uint) {
         ( address token, bool isBnb ) = _selectedCurrencyToPay(currency);
         uint256 balanceOfToken = IERC20(token).balanceOf(msg.sender);
         bool isBnb_ = isBnb;
         uint256 payAmount_ = _amountToPay(amount, currency);

        require(isBnb_ && (msg.value >= payAmount_), "insufficient BNB balance") ;

        bool success;

        if(isBnb_) {
             (success, ) = payable(address(this)).call{value: msg.value}("");
        }

        if((token == s_currency.usdt || token == s_currency.usdc) && (balanceOfToken > payAmount_ && !isBnb)) {
            success = IERC20(token).transferFrom(msg.sender, s_treasuryWallet, payAmount_);
        }

        if(!success) {
            revert Presale_PaymentFailed("payment failed");
        }

        s_tokenToSell.transfer(msg.sender, amount);
        emit BuyTokenSuccessull(msg.sender, amount);
        return (true, payAmount_);
    }

    /**
     * @dev handle a calculation for total amount to pay for buying token
     * @param amount => token amount
     * @param selectedCurrency_ => selected currency to pay
     */
    function _amountToPay(uint256 amount, string memory selectedCurrency_) internal view returns(uint amountTopay_) {
         (bool USDT, bool USDC, bool BNB) = _currencyCheck(selectedCurrency_);

          if(USDT) {
             amountTopay_ = amount * PRICE_IN_USDT;
          }

          if(USDC) {
             amountTopay_ = amount * PRICE_IN_USDT;
          }

          if(BNB) {
             amountTopay_ = amount * PRICE_IN_BNB;
          }
          
    }

    function withdraw(uint256 amount, string memory currency) external payable NotZeroAddress onlyOwner {
         bool success;
         ( address token, bool isBnb ) = _selectedCurrencyToWithdraw(currency);
         uint256 balanceOfToken = IERC20(token).balanceOf(address(this));
         (bool USDT, bool USDC, bool BNB) = _currencyCheck(currency);

        if(isBnb && address(this).balance <= 0) {
            revert Presale_BnbBalanceIsZero();
        }

        (success, ) = s_treasuryWallet.call{value: address(this).balance}("");

        if(token == s_currency.usdt || token == s_currency.usdc && balanceOfToken <= 0) {
           revert Presale_UsdtBalanceIsZero();
        }

        success = IERC20(token).transfer(s_treasuryWallet, balanceOfToken);

        if(!success) {
            revert Presale_WithdrawFailed();
        }

        emit WithdrawSuccessfull(s_treasuryWallet, amount | address(this).balance);
    }

    /**
     * @dev execute this function will start the presale 
     * @return state => the state whether presale is open or paused
     */
    function startPresale() external onlyOwner returns(SaleState state) {
        require(s_saleState != SaleState.START, "presale is has been started");
        s_saleState = SaleState.START;
        state = s_saleState;
    }

    function pausePresale() external onlyOwner returns(SaleState state) {
        require(s_saleState == SaleState.START, "presale is not started yet");
        s_saleState = SaleState.PAUSE;
        state = s_saleState;
    }

    function getTokenSellBalance() external view returns(uint256 balance) {
        balance = s_tokenToSell.balanceOf(address(this));
    }

    function getSelectedTokenPay(string memory currency) external returns(address) {
        (address token, ) = _selectedCurrencyToPay(currency);
        return token;
    }
}
