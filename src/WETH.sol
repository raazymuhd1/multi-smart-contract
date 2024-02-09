// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title WETH Contract
 * @author mohammed raazy
 * @notice when u deposited ETH, an ERC20 token will be mint it.
 * @notice when u withdraw ETH, an ERC20 token will be burn it.
 * @dev so basically the WETH price will equal to ETH (pegged to ETH price)
 */

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {

    event Deposited(address indexed sender, uint256 indexed amount);

    constructor() ERC20("Wrapped Ether", "WETH") {}

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        uint256 depositValue_ = msg.value;
        _mint(msg.sender, depositValue_); // mint an ERC20 token of WETH after depositing ETH
        emit Deposited(msg.sender, depositValue_);
    }

    function withdraw(uint256 amount_) external payable {
        address payable sender = payable(msg.sender);
        _burn(msg.sender, amount_);
        sender.call{value: amount_}("");
    }
}