// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {Ping} from "../src/Ping.sol";

contract PingTest is Test {
    function test_pingIncrements() public {
        Ping ping = new Ping();
        ping.ping();
        ping.ping();
        assertEq(ping.hits(), 2);
        assertEq(ping.lastCaller(), address(this));
        console2.log("hits", ping.hits());
    }
}
