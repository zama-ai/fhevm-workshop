// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity ^0.8.20;

import "fhevm/lib/TFHE.sol";

import "./eip712-modifier.sol";

contract EncryptedERC20 is EIP712Reencrypt {
    address public contractOwner;

    constructor() {
        contractOwner = msg.sender;
    }

    mapping(address => euint64) internal balances;

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

    function transfer(address to, bytes calldata amountCiphertext) public returns (bool) {
        return transfer_leaking(to, amountCiphertext);
        // return transfer_nonleaking(to, amountCiphertext);
    }

    function transfer_leaking(address to, bytes calldata amountCiphertext) internal returns (bool) {
        euint64 amount = TFHE.asEuint64(amountCiphertext);

        bool sufficient = TFHE.decrypt(TFHE.le(amount, balances[msg.sender]));
        if (sufficient) {
            balances[to] = balances[to] + amount;
            balances[msg.sender] = balances[msg.sender] - amount;
        }

        return sufficient;
    }

    function transfer_nonleaking(address to, bytes calldata amountCiphertext) internal returns (bool) {
        euint64 amount = TFHE.asEuint64(amountCiphertext);

        ebool sufficient = TFHE.le(amount, balances[msg.sender]);
        balances[to] = TFHE.select(sufficient, balances[to] + amount, balances[to]);
        balances[msg.sender] = TFHE.select(sufficient, balances[msg.sender] - amount, balances[msg.sender]);
        
        return true;
    }
}
