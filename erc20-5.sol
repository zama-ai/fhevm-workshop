// SPDX-License-Identifier: BSD-3-Clause-Clear

contract EncryptedERC20 is EIP712 {

constructor() EIP712("Authorization token", "1") {
    contractOwner = msg.sender;
}

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
