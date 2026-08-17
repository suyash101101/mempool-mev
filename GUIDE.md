# Lab A — Full Guide (Mempool & Fee Priority)

**Audience:** Workshop participants and organizers  
**Presenter version:** see [`SPEAKER_NOTES.md`](./SPEAKER_NOTES.md)  
**Quick run commands:** see [`README.md`](./README.md)

---

## What is this lab about? (plain English)

When you tap **Confirm** in a crypto wallet, your transaction does **not** instantly land on the blockchain. It first enters a **waiting room** called the **mempool** (memory pool).

Think of it like:

> **Posting a letter at the post office.**  
> Everyone in the queue can see your envelope size. The clerk picks which letters go in the next truck. If you pay extra for express, yours goes first.

On Ethereum:

- The "waiting room" is **public** — bots, explorers, and anyone running a node can see pending transactions.
- Block builders pick which txs to include based largely on **fees** (tips).
- This lab **proves** that visibility. It does not run an attack.

**Privacy angle:** Your intent (what you are about to do, how much, to which contract) is **leaked before it is final**. That is the root problem Lab B exploits.

---

## How this connects to Lab B

| Lab A (this repo) | Lab B (`sandwich-attack`) |
|-------------------|---------------------------|
| Shows the **waiting room** | Shows **what bots do** with what they see |
| Two people racing with different tips | Bot reads a swap, trades around it |
| "Pending = public" | "Public intent = profit for someone else" |

**Run Lab A first.** Lab B assumes the audience understands that pending txs are visible.

---

## The one-sentence crux

> **Between Confirm and Confirmed, your transaction is public. That is not a bug in this demo — it is how most blockchains work today.**

---

## What happens technically (step by step)

### 1. You start a local blockchain (`anvil`)

Anvil is a fake Ethereum on your laptop. Same rules (mempool, blocks, gas) but fake money.

```bash
anvil --block-time 8 --port 8545
```

`--block-time 8` = new block every 8 seconds. Slow on purpose so you can peek at the pool.

### 2. The script deploys `Ping.sol`

A tiny contract with a counter. Each `ping()` call increments `hits` and records `lastCaller`.

Why a counter? We need something harmless to call. Real bots watch the same pool for Uniswap swaps, NFT mints, etc.

### 3. Two accounts submit competing `ping()` calls

| Account | Gas price | Role |
|---------|-----------|------|
| Anvil #1 (`0x7099...`) | 1 gwei | Low tip — submitted first |
| Anvil #2 (`0x3C44...`) | 50 gwei | High tip — submitted second |

Both txs sit in the **txpool** (Anvil's mempool).

### 4. Next block mines

The builder includes txs. Higher tip usually gets **better priority**.

### 5. You verify who "won"

```bash
cast call <PING_ADDR> "lastCaller()(address)" --rpc-url http://127.0.0.1:8545
```

Expected: `0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC` (high-tip account).

---

## Optional: inspect the mempool live

After Terminal B submits, **before** the 8-second block:

```bash
cast rpc txpool_content --rpc-url http://127.0.0.1:8545
```

You will see **both pending transactions** with their gas prices. That JSON is what searchers scrape 24/7 on mainnet.

**Say to the audience:** "This is the leak. Nothing is secret here."

---

## File-by-file breakdown

### `src/Ping.sol`

```solidity
function ping() external {
    hits += 1;
    lastCaller = msg.sender;
    emit Pinged(msg.sender, hits);
}
```

- `hits` — how many times pinged (on-chain state)
- `lastCaller` — who called last (proves ordering)
- `Pinged` event — log for indexers (like Etherscan)

### `script/FeeRace.s.sol`

- Deploys `Ping`
- Submits low-tip tx, then high-tip tx
- Prints privacy reminder logs

### `test/Ping.t.sol`

Sanity check: calling `ping()` twice sets `hits = 2`.

---

## Expected output (verified)

```text
Ping deployed at 0x5FbDB2315678afecb367f032d93F642f64180aa3
Submitted LOW tip ping from 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
Submitted HIGH tip ping from 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
=== WHY THIS MATTERS FOR PRIVACY ===
Both txs sat in the PUBLIC txpool before a block was mined.
Anyone with RPC access can read pending txs - same as mainnet searchers.
```

---

## Mapping to real life (for non-experts)

| Real world | This lab |
|------------|----------|
| Waiting in line at a government office | Mempool |
| Paying extra for faster service | Gas tip |
| Someone reading your form while you wait | Searcher / bot watching pending txs |
| Your form getting processed | Transaction confirmed in a block |
| A CCTV camera on the queue | Public RPC / txpool API |

**Analogy for privacy:**

> Imagine if every text message you typed sat in a **public draft folder** for 12 seconds before sending — and anyone could read it and act on it first. That is roughly what a public mempool is like for blockchain transactions.

---

## Common questions from beginners

**Q: Is the mempool a single server?**  
No. Every full node has its own copy. They sync via gossip (like rumors spreading). No one central inbox.

**Q: Can I hide my transaction?**  
Not by default. Some wallets offer "private RPC" or Flashbots Protect — that routes around the public pool. This lab shows the **default** behavior.

**Q: Why does higher fee win?**  
Block space is limited. Validators/builders earn fees. They prefer txs that pay more.

**Q: Is this an attack?**  
No. This lab only shows **visibility and ordering**. Lab B shows the attack.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Connection refused` on 8545 | Start `anvil` first in Terminal A |
| `forge install` fails | Use `forge install foundry-rs/forge-std` (no `--no-commit`) |
| Empty txpool when you check | Submit script again; you have 8 seconds before block |
| Wrong `lastCaller` | Run `cast block latest --full` and check tx order + gas prices |

---

## After this lab

Tell the audience:

1. Every swap, transfer, or NFT buy they make on mainnet **passes through this same public stage** (unless they use private routing).
2. Lab B shows a bot **monetizing** that visibility.
3. Session 2 (ZK / privacy) asks: *how do we prove something without revealing the intent early?*
