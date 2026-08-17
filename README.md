# Lab A — Mempool & Fee Priority

**Web3 Uncovered · Road to Devcon · Session 1**

> What happens between **Confirm** and **Confirmed**? Your transaction sits in a **public waiting room** (the mempool) where anyone can read it and block builders pick by fee.

Pair with **Lab B:** [`sandwich-attack`](https://github.com/suyash101101/sandwich-attack) — shows how bots profit from that visibility.

**Documentation in this repo:**

| File | Who it is for |
|------|---------------|
| [`README.md`](./README.md) | Quick setup + run commands (start here) |
| [`GUIDE.md`](./GUIDE.md) | Full explanation, privacy angle, layperson analogies |
| [`SPEAKER_NOTES.md`](./SPEAKER_NOTES.md) | Presenter script — what to say live, timing, Q&A |

---

## The privacy crux

| Fact | Implication |
|------|-------------|
| Pending txs are **public** | Amount, target contract, and calldata are visible before confirmation |
| Block space is scarce | Higher fee tip → higher inclusion priority |
| RPC nodes expose the txpool | Searchers watch the same feed you will inspect below |

This lab does **not** run an attack. It proves the infrastructure that makes MEV possible.

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

Expected:

```text
[PASS] test_pingIncrements()
```

---

## Run end-to-end

### Terminal A — slow blocks (time to inspect the pool)

```bash
anvil --block-time 8 --port 8545
```

### Terminal B — deploy + submit two competing txs

```bash
forge script script/FeeRace.s.sol:FeeRaceScript \
  --broadcast \
  --rpc-url http://127.0.0.1:8545 \
  -vv
```

### Terminal C (optional) — peek at the public mempool

Run **after** Terminal B submits, **before** the next block mines:

```bash
cast rpc txpool_content --rpc-url http://127.0.0.1:8545
```

### Verify the high-tip tx won

Replace `<PING_ADDR>` with the address printed by the script:

```bash
cast call <PING_ADDR> "lastCaller()(address)" --rpc-url http://127.0.0.1:8545
# Expected: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC  (Anvil account #2, 50 gwei)
```

---

## What the script does

1. Deploys `Ping.sol` (increments a counter)
2. Account #1 calls `ping()` at **1 gwei**
3. Account #2 calls `ping()` at **50 gwei**
4. Both wait in the txpool; the higher tip gets priority in the next block

---

## Layout

```text
src/Ping.sol           # on-chain target
script/FeeRace.s.sol   # fee race demo
test/Ping.t.sol        # unit test
```

---

## Safety

Anvil private keys are **public test keys**. Never fund them on mainnet.
