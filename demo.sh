#!/usr/bin/env bash
# Live mempool fee-race demo.
# Requires: anvil --block-time 8 --port 8545
set -euo pipefail

RPC="${RPC_URL:-http://127.0.0.1:8545}"

# Anvil default keys (public test keys only)
LOW_KEY=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
HIGH_KEY=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

echo "==> Deploying Ping.sol..."
forge script script/Deploy.s.sol:DeployScript --broadcast --rpc-url "$RPC" -vv 2>&1 | tee /tmp/mempool-deploy.log

PING=$(grep -oE 'Ping deployed at 0x[a-fA-F0-9]{40}' /tmp/mempool-deploy.log | grep -oE '0x[a-fA-F0-9]{40}' | tail -1)

if [[ -z "${PING:-}" ]]; then
  PING=$(jq -r '.transactions[] | select(.contractName=="Ping") | .contractAddress' \
    broadcast/Deploy.s.sol/31337/run-latest.json 2>/dev/null | head -1)
fi

if [[ -z "${PING:-}" || "$PING" == "null" ]]; then
  echo "Could not resolve Ping address."
  exit 1
fi

echo ""
echo "Ping at $PING"
echo ""
echo "==> Submitting TWO pings without waiting (legacy gasPrice: 1 gwei vs 50 gwei)..."
LOW_HASH=$(cast send "$PING" "ping()" --private-key "$LOW_KEY" --legacy --gas-price 1gwei --async --rpc-url "$RPC")
HIGH_HASH=$(cast send "$PING" "ping()" --private-key "$HIGH_KEY" --legacy --gas-price 50gwei --async --rpc-url "$RPC")

echo "LOW  tip tx: $LOW_HASH"
echo "      from 0x70997970C51812dc3A010C7d01b50e0d17dc79C8  gasPrice=1 gwei"
echo "HIGH tip tx: $HIGH_HASH"
echo "      from 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC  gasPrice=50 gwei"
echo ""
echo "==> NOW (Terminal C, before next block mines):"
echo "    cast rpc txpool_content --rpc-url $RPC"
echo ""
echo "Decode gasPrice in JSON:"
echo "    0x3b9aca00     = 1 gwei"
echo "    0xba43b7400    = 50 gwei"
echo ""
read -r -p "Press Enter after txpool_content (or to continue)..." _

echo "==> Waiting for block (~8s)..."
sleep 9

echo ""
echo "lastCaller:"
cast call "$PING" "lastCaller()(address)" --rpc-url "$RPC"

echo ""
echo "LOW tx gasPrice:"
cast tx "$LOW_HASH" --rpc-url "$RPC" | grep -E 'gasPrice|from|blockNumber'

echo ""
echo "HIGH tx gasPrice:"
cast tx "$HIGH_HASH" --rpc-url "$RPC" | grep -E 'gasPrice|from|blockNumber'
