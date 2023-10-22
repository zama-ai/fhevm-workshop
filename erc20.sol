// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity 0.8.19;

import "fhevm/lib/TFHE.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract EncryptedERC20 is EIP712 {
    address public contractOwner;

    constructor() EIP712("Authorization token", "1") {
        contractOwner = msg.sender;
    }

    mapping(address => euint32) internal balances;

    function balanceOf(
        bytes32 publicKey,
        bytes calldata signature
    )
        public
        view
        signedBySender(publicKey, signature)
        returns (bytes memory)
    {
        return TFHE.reencrypt(balances[msg.sender], publicKey, 0);
    }

    function mint(bytes calldata amountCiphertext) public {
        require(msg.sender == contractOwner);
        euint32 amount = TFHE.asEuint32(amountCiphertext);
        balances[contractOwner] = balances[contractOwner] + amount;
    }

    function transfer(address to, bytes calldata amountCiphertext) public {
        euint32 amount = TFHE.asEuint32(amountCiphertext);
        require(TFHE.decrypt(TFHE.le(amount, balances[msg.sender])));

        balances[to] = balances[to] + amount;
        balances[msg.sender] = balances[msg.sender] - amount;
    }

    modifier signedBySender(bytes32 publicKey, bytes memory signature) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(keccak256("Reencrypt(bytes32 publicKey)"), publicKey)
            )
        );
        address signer = ECDSA.recover(digest, signature);
        require(
            signer == msg.sender,
            "EIP712 signer and transaction signer do not match"
        );
        _;
    }

}
