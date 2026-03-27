# ArcPay 💸

> USDC Payroll & Bulk Payments on Arc Testnet

ArcPay is a minimal, friendly payment tool built on [Arc](https://arc.network) — a stablecoin-native L1 blockchain by Circle. Send USDC to individuals or run full payroll to your entire team in one click.

**Live Demo:** https://arcpay.vercel.app

---

## What it does

| Feature | Description |
|---|---|
| **Send Payment** | Pay anyone a USDC amount instantly on Arc |
| **Bulk Payroll** | Upload a CSV or manually add recipients — pay everyone in one click |
| **Payment History** | Every payment saved locally with explorer links |
| **Live Balance** | See your USDC balance on Arc Testnet in real time |

---

## Why Arc?

Arc is purpose-built for real-world payments:

- **USDC as gas** — fees are ~0.006 USDC per transaction. No ETH, no volatile gas tokens
- **Sub-second finality** — payments confirm instantly, no waiting
- **Circle-native** — direct integration with Circle's USDC, CCTP, and developer tools
- **EVM compatible** — deploy with standard Solidity + ethers.js tooling

ArcPay uses Arc's native USDC contract (`0x3600000000000000000000000000000000000000`) directly — no custom smart contract needed for basic payments.

---

## Getting Started

### Prerequisites

- [MetaMask](https://metamask.io) or [Rabby](https://rabby.io) wallet
- Arc Testnet added to your wallet
- Testnet USDC from [faucet.circle.com](https://faucet.circle.com)

### Add Arc Testnet to MetaMask

| Field | Value |
|---|---|
| Network Name | Arc Testnet |
| RPC URL | https://rpc.testnet.arc.network |
| Chain ID | 5042002 |
| Currency Symbol | USDC |
| Explorer | https://testnet.arcscan.app |

### Run Locally

```bash
# Clone the repo
git clone https://github.com/Investorquab/arcpay.git
cd arcpay

# Serve locally (no build step needed!)
npx serve .
```

Open `http://localhost:3000` in your browser.

---

## Bulk Payroll CSV Format

ArcPay accepts a simple CSV file for bulk payments:

```csv
name, wallet_address, amount
John Doe, 0x1234...abcd, 150.00
Jane Smith, 0x5678...efgh, 200.00
Alice, 0x9abc...ijkl, 75.50
```

- **name** — recipient name (optional)
- **wallet_address** — Arc Testnet wallet address (required)
- **amount** — USDC amount to send (required)

Drop the CSV on the upload zone or click to browse. ArcPay will preview all recipients before you confirm.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Blockchain | Arc Testnet (Chain ID: 5042002) |
| Token | USDC (`0x3600...0000`) |
| Wallet | MetaMask / Rabby via ethers.js v6 |
| Frontend | Vanilla HTML + CSS + JS (no framework) |
| Font | Bricolage Grotesque + DM Mono |
| Deployment | Vercel |

No build step. No framework. No node_modules. Just one HTML file.

---

## Contract Addresses (Arc Testnet)

```
USDC:        0x3600000000000000000000000000000000000000
EURC:        0x89B50855Aa3bE2F677cD6303Cec089B5F319D72a
Explorer:    https://testnet.arcscan.app
Faucet:      https://faucet.circle.com
RPC:         https://rpc.testnet.arc.network
```

---

## Roadmap

- [ ] EURC support (Euro stablecoin)
- [ ] Crosschain bridge via Circle CCTP
- [ ] Payment links (share a link, get paid)
- [ ] Scheduled/recurring payments
- [ ] CSV export of payment history
- [ ] Email receipts

---

## Built By

Built by [@Investorquab](https://github.com/Investorquab) as a contribution to the Arc ecosystem.

Part of the **Arc Builder** community — [community.arc.network](https://community.arc.network)

---

## License

MIT — free to use, fork, and build on.
