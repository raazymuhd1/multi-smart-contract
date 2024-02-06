// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { NetworkStruct } from "../src/libs/NetworkStruct.sol";
import { Script } from "forge-std/Script.sol";

contract HelperConfig is Script {

    ERC20Mock usdt_;
    ERC20Mock usdc_;
    ERC20Mock token_;

    NetworkStruct.PresaleNetwork public activePresaleNetwork;
    NetworkStruct.StakingNetwork public activeStakingNetwork;

    constructor() {
        if(block.chainid == 11155111) {
            (activePresaleNetwork, activeStakingNetwork) = getSepoliaConfig();
        } else {
           (activePresaleNetwork, activeStakingNetwork) = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public returns( NetworkStruct.PresaleNetwork memory,  NetworkStruct.StakingNetwork memory) {
        NetworkStruct.PresaleNetwork memory presaleNetwork =  NetworkStruct.PresaleNetwork({  
            usdc: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 
            usdt: 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0,
            token: 0x0000000000000000000000000000000000000000,
            treasury: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        });

        NetworkStruct.StakingNetwork memory stakingNetwork = NetworkStruct.StakingNetwork({
            stakeToken: activePresaleNetwork.token,
            rewardToken: activePresaleNetwork.usdt
        });

        return (presaleNetwork, stakingNetwork);
    }

    function getAnvilConfig() public returns( NetworkStruct.PresaleNetwork memory,  NetworkStruct.StakingNetwork memory) {

        if(activePresaleNetwork.usdc == address(0) && activePresaleNetwork.usdt == address(0) && activePresaleNetwork.token == address(0)) {
             usdc_ = new ERC20Mock();
             usdt_ = new ERC20Mock();
             token_ = new ERC20Mock();
        }

        NetworkStruct.PresaleNetwork memory presaleNetwork = NetworkStruct.PresaleNetwork({  
            usdc: address(usdc_), 
            usdt: address(usdt_), 
            token: address(token_),
            treasury: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        });

        NetworkStruct.StakingNetwork memory stakingNetwork = NetworkStruct.StakingNetwork({
            stakeToken: address(token_),
            rewardToken: address(usdt_)
        });

        return (presaleNetwork, stakingNetwork);
    }
}
