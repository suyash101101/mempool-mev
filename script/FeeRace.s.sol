// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {Ping} from "../src/Ping.sol";

/// @notice Deploy Ping, then submit two competing calls with different priority fees.
/// With `anvil --block-time 8`, both sit in the txpool — inspect with:
///   cast rpc txpool_content --rpc-url http://127.0.0.1:8545
///
/// Higher tip should be preferred when the next block is built.
contract FeeRaceScript is Script {
    uint256 internal constant DEPLOYER =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 internal constant LOW_TIP_KEY =
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 internal constant HIGH_TIP_KEY =
        0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    function run() external {
        vm.startBroadcast(DEPLOYER);
        Ping ping = new Ping();
        console2.log("Ping deployed at", address(ping));
        vm.stopBroadcast();

        // Low tip first (enters pool earlier, but weaker bid)
        vm.txGasPrice(1 gwei);
        vm.startBroadcast(LOW_TIP_KEY);
        ping.ping();
        console2.log("Submitted LOW tip ping from", vm.addr(LOW_TIP_KEY));
        vm.stopBroadcast();

        // High tip second — should win inclusion priority
        vm.txGasPrice(50 gwei);
        vm.startBroadcast(HIGH_TIP_KEY);
        ping.ping();
        console2.log("Submitted HIGH tip ping from", vm.addr(HIGH_TIP_KEY));
        vm.stopBroadcast();

        console2.log("=== NEXT ===");
        console2.log("1) While Anvil is slow: cast rpc txpool_content");
        console2.log("2) After block mines: cast call", address(ping), "lastCaller()(address)");
        console2.log("   High-tip address should usually be lastCaller if it landed last in block");
        console2.log("   or check tx order in the mined block with cast block latest");
    }
}
