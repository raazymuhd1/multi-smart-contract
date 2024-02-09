// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { CErc20, Comptroller, PriceFeed } from "./interfaces/ICompound.sol";

contract CompoundPool {

    IERC20 token;
    CErc20 cToken;

    Comptroller private comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    PriceFeed private priceFeed = PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1);

    constructor(address token_, address cToken_) {
        token = IERC20(token_);
        cToken = CErc20(cToken_);
    }

    function supply(uint256 amount_) external {
        token.transferFrom(msg.sender, address(this), amount_);
        token.approve(address(cToken), amount_);
        require(cToken.mint(amount_) == 0, "mint failed");
    }

    function getCTokenBalance() external view returns(uint256 balance) {
        balance = cToken.balanceOf(address(this));
    } 

    function getInfo() external returns(uint256 exchangeRate, uint256 supplyRate) {
        // exchange rate supply token with cToken
        exchangeRate = cToken.exchangeRateCurrent();
        // interest of supply rate 
        supplyRate = cToken.supplyRatePerBlock();
    }

    // estimate the balance of the supply token
    function estimateBalanceOfUnderlying() external returns(uint256) {
        uint256 cTokenBal = cToken.balanceOf(address(this));
        uint256 exchangeRate = cToken.exchangeRateCurrent();
        uint256 decimals = 8; // WBTC decimals
        uint256 cTokenDecimals = 8;

        return (cTokenBal * exchangeRate) / 10**(18 + decimals - cTokenDecimals); 
    }

    // get an amount of supplied token to the compound pool
    function balanceOfUnderlying() external returns(uint256) {
        return cToken.balanceOfUnderlying(address(this));
    }

    function redeem(uint256 cTokenAmount) external {
        // bcoz redeem function return uint256, if return 0 means successfull
        require(cToken.redeem(cTokenAmount) == 0, "redeem failed");
    }

    // BORROW AND REPAY
    function getCollateralFactor() external view returns(uint256) {
        (bool isListed, uint256 colFactor, bool isComped) = comptroller.markets(address(cToken));
        return colFactor;
    }

    // calculate how much i can borrow
    function getAccountLiquidity() external view returns(uint256, uint256) {
        (uint256 error_, uint256 liquidity_, uint256 shortFall_) = comptroller.getAccountLiquidity(address(this));

        require(error_ == 0, "error"); // if error == 0 means false (no error), if error == 1 means true (error);

        // in normal circumstances - liquidity > 0 and shortfall  == 0
        // liquidity above 0 means account can borrow up to "liquidity"
        // shortfall above 0 subject to liquidation, you borrowed over limit
        return (liquidity_, shortFall_);
    }

    // USD price token to borrow
    function getPriceFeed(address cToken_) external view returns(uint256) {
        uint256 priceFeed_ = priceFeed.getUnderlyingPrice(cToken_);

        return priceFeed_;
    }

      // enter market and borrow
  function borrow(address _cTokenToBorrow, uint _decimals) external {
    // enter market
    // enter the supply market so you can borrow another type of asset
    address[] memory cTokens = new address[](1);
    cTokens[0] = address(cToken);
    uint[] memory errors = comptroller.enterMarkets(cTokens);
    require(errors[0] == 0, "Comptroller.enterMarkets failed.");

    // check liquidity
    (uint error, uint liquidity, uint shortfall) = comptroller.getAccountLiquidity(
      address(this)
    );
    require(error == 0, "error");
    require(shortfall == 0, "shortfall > 0");
    require(liquidity > 0, "liquidity = 0");

    // calculate max borrow
    uint price = priceFeed.getUnderlyingPrice(_cTokenToBorrow);

    // liquidity - USD scaled up by 1e18
    // price - USD scaled up by 1e18
    // decimals - decimals of token to borrow
    uint maxBorrow = (liquidity * (10**_decimals)) / price;
    require(maxBorrow > 0, "max borrow = 0");

    // borrow 50% of max borrow
    uint amount = (maxBorrow * 50) / 100;
    require(CErc20(_cTokenToBorrow).borrow(amount) == 0, "borrow failed");
  }

    // borrowed balance (includes interest)
  // not view function
  function getBorrowedBalance(address _cTokenBorrowed) public returns (uint) {
    return CErc20(_cTokenBorrowed).borrowBalanceCurrent(address(this));
  }

  // borrow rate
  function getBorrowRatePerBlock(address _cTokenBorrowed) external view returns (uint) {
    // scaled up by 1e18
    return CErc20(_cTokenBorrowed).borrowRatePerBlock();
  }

  // repay borrow
  function repay(
    address _tokenBorrowed,
    address _cTokenBorrowed,
    uint _amount
  ) external {
    IERC20(_tokenBorrowed).approve(_cTokenBorrowed, _amount);
    // _amount = 2 ** 256 - 1 means repay all
    require(CErc20(_cTokenBorrowed).repayBorrow(_amount) == 0, "repay failed");
  }

}