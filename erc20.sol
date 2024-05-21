// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity ^0.8.20;

import "fhevm/lib/TFHE.sol";

import "./eip712-modifier.sol";

contract EncryptedERC20 is EIP712Reencrypt {
    address public contractOwner;

    constructor() {
        contractOwner = msg.sender;
    }

    mapping(address => euint32) internal balances;

    function balanceOf(
        address wallet,
        bytes32 publicKey,
        bytes calldata signature
    )
        public
        view
        signedBySender(publicKey, signature)
        returns (bytes memory)
    {
        require(wallet == msg.sender);
        return TFHE.reencrypt(balances[msg.sender], publicKey, 0);
    }

    function mint(uint64 amount) public {
        require(msg.sender == contractOwner);
        balances[contractOwner] = TFHE.add(balances[contractOwner], amount);
    }

        euint32 amount = TFHE.asEuint32(amountCiphertext);
        TFHE.req(TFHE.le(amount, balances[msg.sender]));

        balances[to] = TFHE.add(balances[to], amount);
        balances[msg.sender] = TFHE.sub(balances[msg.sender], amount);
    function transfer(address to, bytes calldata amountCiphertext) public returns (bool) {
    }

    }

}
