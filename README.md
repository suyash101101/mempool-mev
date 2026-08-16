# Mempool & MEV Lab (Lab A)

Road to Devcon · Session 1 · NITK Surathkal

See how **pending transactions compete on fees** inside a local mempool (Anvil txpool). This is the conceptual lab. The attack simulation is in the sibling repo [`sandwich-attack`](https://github.com/suyash101101/sandwich-attack).

---

## What you'll learn

1. Pending txs sit in a **public waiting room** (mempool / txpool)
2. **Higher tip ≈ higher priority** for inclusion
3. Anyone with RPC access can **inspect** that waiting room

---

## Prerequisites

```bash
# Install Foundry (once)
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

forge install foundry-rs/forge-std --no-commit
forge build
forge test -vv
```

---

## Run the fee race (e2e)

**Terminal A** — slow blocks so you can peek at the pool:

```bash
anvil --block-time 8
```

**Terminal B** — deploy + submit competing pings:

```bash
forge script script/FeeRace.s.sol:FeeRaceScript \
  --broadcast \
  --rpc-url http://127.0.0.1:8545 \
  -vv
```

**Optional — inspect the mempool while waiting:**

```bash
cast rpc txpool_content --rpc-url http://127.0.0.1:8545
```

**After a block mines:**

```bash
cast block latest --rpc-url http://127.0.0.1:8545
```

Look at transaction order / gas prices in that block.

---

## Mental model

| You do | Real network |
|--------|----------------|
| `anvil` txpool | Public mempool |
| `cast rpc txpool_content` | Explorers / searcher bots watching pending txs |
| High tip vs low tip | Priority fee auction (same idea as gas wars) |

MEV searchers watch this feed continuously. Lab B (`sandwich-attack`) shows how they monetize it.

---

## Layout

```text
src/Ping.sol              # callable target
script/FeeRace.s.sol      # deploy + two competing txs
test/Ping.t.sol
```

---

## Safety

Anvil keys in the script are **public test keys**. Never fund them on mainnet.
