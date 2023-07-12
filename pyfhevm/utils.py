import json
import os

from eth_account import Account
from web3 import Web3
from web3.middleware import construct_sign_and_send_raw_middleware

SIGNATURE_KEY_VAR = "ETHCC23_PRIVATE_KEY"
DEVNET_VAR = "ETHCC23_DEVNET"
DEFAULT_DEVNET = "https://devnet.zama.ai"


def setup_w3():
    devnet = os.environ.get(DEVNET_VAR, DEFAULT_DEVNET)
    return Web3(Web3.HTTPProvider(devnet, request_kwargs={"timeout": 600}))


def setup_wallet(w3):
    signature_key = os.environ.get(SIGNATURE_KEY_VAR)
    assert signature_key != None, f"Please specify env variable '{SIGNATURE_KEY_VAR}'"
    if not signature_key.startswith("0x"):
        signature_key = "0x" + signature_key
    account = Account.from_key(signature_key)
    w3.middleware_onion.add(construct_sign_and_send_raw_middleware(account))
    w3.eth.default_account = account.address
    print(f"Account address: {account.address}")
    return account


def send_transaction(w3, tx, from_address):
    # # estimate gas
    # gas = tx.estimate_gas({"value": 0, "from": from_address})
    # print(f"Gas estimation: {gas}")

    # send transaction
    tx_hash = tx.transact({"value": 0, "from": from_address}).hex()
    print(f"Transaction hash: {tx_hash}")

    # wait for transaction to go through
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    assert tx_receipt["status"] == 1


def load_contract(w3, address):
    print(f"Contract address: {address}")

    with open("../abi.json", "rt") as f:
        abi = json.load(f)

    return w3.eth.contract(
        address=address,
        abi=abi,
    )
