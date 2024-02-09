// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./interfaces/IWETH10.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * the way flashmint works is, we create our own weth, mint any amount of it.
 * then buy some token on exchange A, the exchange A will own that amount of our WETH.
 * then using the token that we trade on exchange A with our WETH, to trade for ETH on another exchange that has higher value on exchange A
 * after making profit, we mint another amount of WETH equal with previous amount first time we minted (10 WETH for example). 
 * deposit 10 ETH back to WETH contract, so later the exchange A can withdraw those 10 ETH back
 * by the end of transaction, those 10 WETH that we minted will be destroye or burn it.
 * 
 * exchange A can later withdraw
 */

contract TestWethFlashMint {
  // WETH 10
  address private WETH = 0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9F;
  bytes32 public immutable CALLBACK_SUCCESS =
    keccak256("ERC3156FlashBorrower.onFlashLoan");

  address public sender;
  address public token;

  event Log(string name, uint val);

  function flash() external {
    uint total = IERC20(WETH).totalSupply();
    // borrow more than available
    uint amount = total + 1;

    emit Log("total supply", total);

    IERC20(WETH).approve(WETH, amount);

    bytes memory data = "";
    WETH10(WETH).flashLoan(address(this), WETH, amount, data);
  }

  // called by WETH10
  function onFlashLoan(
    address _sender,
    address _token,
    uint amount,
    uint fee,
    bytes calldata data
  ) external returns (bytes32) {
    uint bal = IERC20(WETH).balanceOf(address(this));

    sender = _sender;
    token = _token;

    // perform an arbitrage here

    emit Log("amount", amount);
    emit Log("fee", fee);
    emit Log("balance", bal);

    return CALLBACK_SUCCESS;
  }
}