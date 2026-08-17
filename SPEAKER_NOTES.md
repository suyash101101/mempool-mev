# Lab A — Speaker Notes (Presenter Script)

**Duration:** 10–15 minutes  
**Goal:** Audience understands pending txs are **public** and **fee-ordered** — the setup for MEV/privacy.  
**Run order:** Lab A **before** Lab B.

---

## Before you start (2 min)

**Say:**

> "When you tap Confirm in MetaMask, what happens in those 10–30 seconds before Confirmed? Today we open the hood. Your transaction sits in a public waiting room. Everyone can see it. We will prove that on your laptop."

**Layperson hook:**

> "It is like sending a WhatsApp message that sits in a **group-visible draft** for a few seconds before it sends — and strangers can read it and act on it first."

**Check room:**

- [ ] Foundry installed (`forge --version`)
- [ ] Terminal A: `anvil --block-time 8 --port 8545` running
- [ ] Terminal B ready for script
- [ ] Terminal C optional for `cast rpc txpool_content`

---

## Act 1 — Explain the waiting room (3 min)

**Say:**

> "The mempool is not magic. It is just a list of transactions that are signed but not yet in a block. Nodes gossip them to each other. Block builders pick which ones to include. They prefer higher fees because that is their income."

**On screen:** Show README "privacy crux" table or draw on whiteboard:

```
You tap Confirm
    → wallet signs tx
    → tx sent to a node
    → node gossips it
    → tx enters MEMPOOL (PUBLIC)
    → block builder picks txs by fee
    → block mined → Confirmed
```

**Key line (repeat twice):**

> "**Pending usually means public.** That is the leak."

---

## Act 2 — Run the demo (5 min)

**Terminal B:**

```bash
forge script script/FeeRace.s.sol:FeeRaceScript \
  --broadcast --rpc-url http://127.0.0.1:8545 -vv
```

**While waiting for block (Terminal C — this is the money moment):**

```bash
cast rpc txpool_content --rpc-url http://127.0.0.1:8545
```

**Say while JSON scrolls:**

> "This is the same data a sandwich bot sees. Two pending pings. Different gas prices. Account one bid 1 gwei. Account two bid 50 gwei. Nothing is encrypted. This is the default."

**After block mines:**

```bash
cast call <PING_ADDR> "lastCaller()(address)" --rpc-url http://127.0.0.1:8545
```

**Say:**

> "High tip won. Same game on mainnet — just faster blocks and real money."

---

## Act 3 — Bridge to privacy and Lab B (3 min)

**Say:**

> "We did not attack anyone. We only proved infrastructure. But now you see the problem: **intent is visible early.** Amount, target contract, function being called — all readable."

**Privacy framing:**

> "If you would not shout your bank transfer details in a crowded room before the transfer clears, you should know that default Ethereum behavior is closer to that than to a private bank app."

**Tease Lab B:**

> "Lab B asks: what if that pending transaction is a $50,000 token swap? A bot reads it, trades before you, trades after you, and keeps the difference. You still get your swap — just worse."

---

## Lines to avoid / correct misconceptions

| Audience might think | You clarify |
|---------------------|-------------|
| "Blockchain is anonymous" | Pseudonymous addresses; activity is public, especially pending txs |
| "Mempool is one database" | Copies on many nodes, synced by gossip |
| "Higher fee = faster internet" | Higher fee = higher priority in **limited block space** |
| "This only happens on testnets" | Same mechanism on mainnet; we use Anvil for safety |

---

## If something breaks live

1. **Anvil not running** → `anvil --block-time 8 --port 8545`
2. **Script fails** → `forge build && forge test -vv` first
3. **Missed txpool window** → re-run script; you have 8 seconds
4. **Fallback** → show `test/Ping.t.sol` passing; explain concept verbally

---

## Closing line for Lab A

> "Remember three words: **pending is public.** Lab B shows who profits from that."

---

## Transition to Lab B

```bash
cd ../sandwich-attack
# new anvil without --block-time is fine
anvil --port 8545
```

Open `sandwich-attack/SPEAKER_NOTES.md` and continue.
