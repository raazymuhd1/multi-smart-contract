pragma solidity ^0.8.20;

import { Presale } from "../src/Presale.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { Script, console } from "forge-std/Script.sol";

contract DeployPresale is Script {
    Presale presale;
    HelperConfig networkConfig;

    address usdc;
    address usdt;
    address token;
    address treasury;

    function run() public returns(address, address, address, address){

        vm.startBroadcast();
        networkConfig = new HelperConfig();
        (usdc, usdt, token, treasury) = networkConfig.activePresaleNetwork();

        /**
         * @param usdt
         * @param usdc
         * @param treasury - treasury address
         * @param tokenAddr - token address
         */
        presale = new Presale(usdt, usdc, treasury, token);
        vm.stopBroadcast();

        console.log(address(presale));
        return (address(presale), usdc, usdt, token);
    }
}