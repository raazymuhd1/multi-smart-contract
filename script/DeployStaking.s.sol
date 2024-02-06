// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Staking } from "../src/Staking.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployStaking is Script {
     Staking staking;
     HelperConfig networkConfig;

     function run() public returns(address staking_) {
         
         vm.startBroadcast();
         networkConfig = new HelperConfig();
         (address stakeToken, address rewardToken) = networkConfig.activeStakingNetwork();
         staking = new Staking(stakeToken, rewardToken);
         vm.stopBroadcast();

         console.log(address(staking));
         return address(staking);
     }
}