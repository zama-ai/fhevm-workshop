import argparse

from fhevm import FHEVM
from utils import load_contract, send_transaction, setup_w3, setup_wallet

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--contract")
    parser.add_argument("-t", "--to", default=None)
    parser.add_argument("-a", "--amount", default=10)
    args = parser.parse_args()

    w3 = setup_w3()
    my_account = setup_wallet(w3)
    fhevm = FHEVM(w3, my_account)
    erc20 = load_contract(w3, args.contract)

    # call transfer
    amount = fhevm.encrypt32(args.amount)
    to = args.to or my_account.address
    transfer = erc20.functions.transfer(to, amount)
    send_transaction(w3, transfer, my_account.address)
