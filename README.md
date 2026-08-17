# Mempool Fee-Race Lab (`mempool-mev`)

**Web3 Uncovered · Road to Devcon · Session 1**

> What happens between **Confirm** and **Confirmed**? Your transaction sits in a **public waiting room** (the mempool) where anyone can read it and block builders pick by fee.

Pair with **sandwich lab:** [`sandwich-attack`](https://github.com/suyash101101/sandwich-attack) — shows how bots profit from that visibility.

---

## Base fee vs priority tip (EIP-1559)

| Part | Who sets it | Where it goes | What it means |
|------|-------------|---------------|---------------|
| **Base fee** | Network (per block) | **Burned** | Minimum price for block space. Rises when blocks are full. |
| **Priority fee (tip)** | **You** | Validator / builder | Your bid to jump the queue. Higher tip → included sooner & ordered first. |

**You pay roughly:** `gas used × (base fee + tip)`

MetaMask labels these as **max fee** and **priority fee**.

### Why this lab uses plain `gasPrice`

On mainnet, txs are usually **EIP-1559** (`maxFeePerGas` + `maxPriorityFeePerGas`).  
For teaching, `demo.sh` sends **legacy** txs with a single `gasPrice` so you can read **1 gwei vs 50 gwei** directly in `txpool_content`.

| Hex in txpool | Decimal | Meaning |
|---------------|---------|---------|
| `0x3b9aca00` | 1,000,000,000 | **1 gwei** (low bid) |
| `0xba43b7400` | 50,000,000,000 | **50 gwei** (high bid) |

Decode yourself:
```bash
cast --to-wei 1 gwei
cast --to-wei 50 gwei
```

---

## Prerequisites (once)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup

forge --version
anvil --version
```

---

## Setup

```bash
git clone https://github.com/suyash101101/mempool-mev.git
cd mempool-mev

forge install foundry-rs/forge-std
forge build
forge test -vv
```

Expected: `[PASS] test_pingIncrements()`

---

## Run end-to-end (recommended)

### Terminal A — slow blocks (time to inspect the pool)

```bash
anvil --block-time 8 --port 8545
```

### Terminal B — deploy + fee race

```bash
chmod +x demo.sh
./demo.sh
```

### Terminal C — when `demo.sh` pauses (before next block mines)

```bash
cast rpc txpool_content --rpc-url http://127.0.0.1:8545
```

**You should see two pending txs:**

- `from` `0x7099...` → `gasPrice` `0x3b9aca00` (1 gwei)
- `from` `0x3C44...` → `gasPrice` `0xba43b7400` (50 gwei)
- same `to` (Ping contract address printed by demo)

Press Enter in Terminal B to finish.

---

## Verification checklist

Run through this to confirm everything works before the workshop:

| # | Check | Command | Pass if |
|---|-------|---------|---------|
| 1 | Tests green | `forge test -vv` | `[PASS] test_pingIncrements()` |
| 2 | Anvil up | `cast block-number --rpc-url http://127.0.0.1:8545` | returns a number |
| 3 | Two pending txs | `cast rpc txpool_content ...` (during pause) | 2 entries, different `gasPrice` |
| 4 | Gas on mined txs | `cast tx <HASH> \| grep gasPrice` | `1000000000` and `50000000000` |
| 5 | Block order | high-tip tx **before** low-tip in same block | 50 gwei tx first |

**Note on `lastCaller`:** Ping stores whoever called **last** in the block. If both txs fit, high tip runs first, low tip runs second → `lastCaller` may be the **low-tip** account. That is correct. The lesson is **ordering by tip**, not `lastCaller`.

Check block order:
```bash
cast tx <HIGH_HASH> --rpc-url http://127.0.0.1:8545 | grep blockNumber
cast tx <LOW_HASH>  --rpc-url http://127.0.0.1:8545 | grep blockNumber
# Same block → compare transactionIndex or run demo.sh output
```

---

## Alternative (forge only — not ideal for live txpool demo)

`forge script --broadcast` sends txs **one-by-one** and waits for each to mine, so you usually **won't** see both pending at once:

```bash
forge script script/FeeRace.s.sol:FeeRaceScript \
  --broadcast --legacy \
  --rpc-url http://127.0.0.1:8545 -vv
```

Use **`./demo.sh`** for the live audience moment.

---

## What each file does

```text
src/Ping.sol           # on-chain target (ping() updates lastCaller)
script/Deploy.s.sol    # deploy only (used by demo.sh)
script/FeeRace.s.sol   # forge-only alternative
demo.sh                # live demo — async cast send, clear gas prices
test/Ping.t.sol        # unit test
```

---

## Safety

Anvil private keys are **public test keys**. Never fund them on mainnet.
