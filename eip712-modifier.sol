// SPDX-License-Identifier: BSD-3-Clause-Clear

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

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
