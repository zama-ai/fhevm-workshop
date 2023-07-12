import argparse

from fhevm import FHEVM
from utils import load_contract, setup_w3, setup_wallet

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--contract")
    args = parser.parse_args()

    w3 = setup_w3()
    my_account = setup_wallet(w3)
    fhevm = FHEVM(w3, my_account)
    erc20 = load_contract(w3, args.contract)

    # call balanceOf
    public_key, signature = fhevm.generate_auth_token(erc20.address)
    encrypted_balance = erc20.functions.balanceOf(public_key, signature).call(
        {"from": my_account.address}
    )
    balance = fhevm.open(encrypted_balance)
    print(f"Balance: {balance}")
