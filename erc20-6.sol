// SPDX-License-Identifier: BSD-3-Clause-Clear

function transfer(address to, bytes calldata amountCiphertext) public {
    euint32 amount = TFHE.asEuint32(amountCiphertext);

    ebool sufficient = TFHE.le(amount, balances[msg.sender]);
    TFHE.req(sufficient);

    balances[to] = TFHE.add(balances[to], amount);
    balances[msg.sender] = TFHE.sub(balances[msg.sender], amount);
}
