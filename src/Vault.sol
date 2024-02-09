// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title VAULT CONTRACT 
 * @author 
 * @notice vault contract is like a bank, where user can deposit any token to vault contract, then the VAULT contract owner will try to invest to any defi protocol to make profit.
 * @notice when user deposited any amount of token, they will mint a shares, and their deposited token will be locked inside vault 
 * @notice when user withdrawing the token, their will get their token amount + profit or amount - loss, and their shares will be burn
 */

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {

    IERC20 private immutable token;

    uint256 private totalShares;
    mapping(address user => uint256 shares) public shareOf; 
}