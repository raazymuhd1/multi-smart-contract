// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

/**
 * @title MULTISIG Wallet version 2
 */

contract MultiSigV2 {

    error MultiSigV2_valuIsZero();
    error MultiSigV2_NotEnoughBalance();
    error MultiSigV2_DepositedFailed();

    uint256 private numOfConfirmations = 0;
    mapping(uint256 numOf => address owner) private ownerOf;
    mapping(bytes hash => Transaction) private transaction;

    event Deposited(address indexed depositor, uint256 indexed amount);
    event Submitted(address indexed sender, uint256 indexed value);
    event Cancelled(address indexed cancelledBy);

    struct Transaction {
        address sender;
        uint256 amount;
        bool executed;
        bytes txHash;
    }

    struct Owner {
        address wallet;
    }

    constructor() {
        // initial owner
        ownerOf[0] = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == ownerOf[0] || msg.sender == ownerOf[1] || msg.sender == ownerOf[2], "your not an owner");
        _;
    }

    // modifier NotExecuted(bytes memory txHash) {
    //     require(transaction[txHash]);
    //     _;
    // }

    modifier ValueNotZero() {
         if(msg.value == 0) {
            revert MultiSigV2_valuIsZero();
        }
        _;
    }

    receive() external payable {
        depositEth();
    }

    function depositEth() public payable OnlyOwner ValueNotZero {
        if(msg.sender.balance < msg.value)  revert MultiSigV2_NotEnoughBalance();

        (bool success, ) = payable(address(this)).call{value: msg.value}("");
        if(!success) revert MultiSigV2_DepositedFailed();
    }

    function AddOwner(address newOwner) external OnlyOwner returns(address newOwner_) {
        // require(ownerOf)
    }

    function submitTx() external OnlyOwner {

    }

    function executeTx() external OnlyOwner {

    }

    function cancelTx() external OnlyOwner {

    }
}