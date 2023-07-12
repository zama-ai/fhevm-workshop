// SPDX-License-Identifier: BSD-3-Clause-Clear

mapping(address => euint32) internal balances;

function balanceOf(bytes32 publicKey)
    public
    view
    returns (bytes memory)
{
    return TFHE.reencrypt(balances[msg.sender], publicKey, 0);
}
