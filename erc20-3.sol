// SPDX-License-Identifier: BSD-3-Clause-Clear

function mint(bytes calldata amountCiphertext) public {
    require(msg.sender == contractOwner);
    euint32 amount = TFHE.asEuint32(amountCiphertext);
    balances[contractOwner] = TFHE.add(balances[contractOwner], amount);
}
