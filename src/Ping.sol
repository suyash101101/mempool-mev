// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Tiny on-chain counter so fee-racing txs have something to call.
contract Ping {
    uint256 public hits;
    address public lastCaller;

    event Pinged(address indexed who, uint256 newHits);

    function ping() external {
        unchecked {
            hits += 1;
        }
        lastCaller = msg.sender;
        emit Pinged(msg.sender, hits);
    }
}
