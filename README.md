# fhEVM Workshop

Welcome to this workshop on building an encrypted ERC20 token!

See more of our examples at https://dapps.zama.ai.

## Getting started

Install Zama Devnet in MetaMask:

- Network name: Zama Devnet
- RPC URL: https://devnet.zama.ai
- Chain ID: 8009
- Currency symbol: ZAMA
- Block explorer: https://main.explorer.zama.ai/

## Encrypted ERC20

Set env variable `ETHCC23_PRIVATE_KEY` to private key that was used to deploy the contract (as copied from MetaMask, i.e. without `0x` prefix):

```
export ETHCC23_PRIVATE_KEY=<private key>
```

When a contract have been deployed to the devnet, the Python files can be used to interact with it by set env variable `CONTRACT` to the address (as copied from Remix) and saving the ABI to `abi.json`.

### Nodejs with fhevmjs

Go in `fhevmjs` directory and `npm install`. Be sure you set `ETHCC23_PRIVATE_KEY` and `CONTRACT`

Mint new tokens:

```bash
CONTRACT=<address> npm run mint 100
```

Get your current balance:

```bash
CONTRACT=<address> npm run balanceOf
```

Make a transfer:

```bash
CONTRACT=<address> npm run transfer 0x56c836D1d7c9f64b9654B433dCa16f1014429DC5 100
```

### Python

Use Python3.10 or earlier:

```
python3.10 -m venv venv
. ./venv/bin/activate
pip install -r requirements.txt
```

For now we also need to installed the fhEVM cli:

```
git clone https://github.com/zama-ai/fhevm-tfhe-cli
cd fhevm-tfhe-cli
cargo install --path .
```

Mint new tokens:

```
python mint.py --amount 100 --contract <address>
```

Get your current balance:

```
python get_balance.py --contract <address>
```

Make a transfer:

```
python transfer.py --amount 5 --to <address> --contract <address>
```
