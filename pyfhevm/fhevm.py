import os

import sha3
from eip712_structs import Bytes, EIP712Struct, make_domain
from nacl.public import PrivateKey, SealedBox

PUBLIC_KEY_CONTRACT = "0x0000000000000000000000000000000000000044"


class Reencrypt(EIP712Struct):
    publicKey = Bytes(32)


class FHEVM:
    def __init__(self, w3, account):
        self.network_encryption_key = None
        self.my_decryption_key = PrivateKey.generate()
        self.w3 = w3
        self.my_account = account

    def encrypt32(self, plaintext):
        if self.network_encryption_key is None:
            print("Fetching global public key")
            self.network_encryption_key = self.w3.eth.call({"to": PUBLIC_KEY_CONTRACT})

        with open("/tmp/zama_network_public_key", mode="wb") as f:
            f.write(self.network_encryption_key)
        res = os.system(
            f"fhevm-tfhe-cli public-encrypt-integer32 -v {plaintext} -c /tmp/zama_ciphertext -p /tmp/zama_network_public_key"
        )
        assert res == 0, "fail to execute fhe-tool"
        with open("/tmp/zama_ciphertext", mode="rb") as file:
            ciphertext = file.read()
        assert len(ciphertext) == 8404

        return ciphertext

    def generate_auth_token(self, contract_address):
        domain = make_domain(
            name="Authorization token",
            version="1",
            chainId=self.w3.eth.chain_id,
            verifyingContract=contract_address,
        )

        msg = Reencrypt()
        msg["publicKey"] = self.my_decryption_key.public_key._public_key
        assert len(self.my_decryption_key.public_key._public_key) == 32

        signable_bytes = msg.signable_bytes(domain)
        msg_hash = sha3.keccak_256(signable_bytes).digest()
        msg_sig = self.my_account.signHash(msg_hash)

        sig = bytes.fromhex(msg_sig.signature.hex()[2:])
        public_key = self.my_decryption_key.public_key._public_key
        return public_key, sig

    def open(self, ciphertext):
        unseal_box = SealedBox(self.my_decryption_key)
        plaintext_bytes = unseal_box.decrypt(ciphertext)
        plaintext = int.from_bytes(plaintext_bytes, "big")
        return plaintext
