// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {Ping} from "../src/Ping.sol";

/// @notice Deploy only. Use demo.sh for the live fee-race (async cast sends).
contract DeployScript is Script {
    function run() external returns (address pingAddr) {
        uint256 deployerKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(deployerKey);
        Ping ping = new Ping();
        vm.stopBroadcast();
        pingAddr = address(ping);
        console2.log("Ping deployed at", pingAddr);
    }
}
