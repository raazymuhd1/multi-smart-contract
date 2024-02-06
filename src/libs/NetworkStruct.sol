pragma solidity ^0.8.20;

contract NetworkStruct {

    struct PresaleNetwork {
        address usdc;
        address usdt;
        address token;
        address treasury;
    }

    struct StakingNetwork {
        address stakeToken;
        address rewardToken;
    }

}