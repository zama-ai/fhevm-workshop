import argparse

from fhevm import FHEVM
from utils import load_contract, send_transaction, setup_w3, setup_wallet

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--contract")
    parser.add_argument("-a", "--amount", default=100)
    args = parser.parse_args()

    w3 = setup_w3()
    my_account = setup_wallet(w3)
    fhevm = FHEVM(w3, my_account)
    erc20 = load_contract(w3, args.contract)

    # call mint
    amount = fhevm.encrypt32(args.amount)
    mint = erc20.functions.mint(amount)
    send_transaction(w3, mint, my_account.address)
