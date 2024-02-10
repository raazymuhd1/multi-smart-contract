pragma solidity ^0.8.10;

import { WETH } from "../src/WETH.sol";
import { Script, console } from "forge-std/Script.sol";

contract DeployWeth is Script {
    WETH weth;

    function run() public returns(WETH) {
        vm.startBroadcast();
        weth = new WETH();
        vm.stopBroadcast();

        console.log(address(weth));
        return weth;
    }
}