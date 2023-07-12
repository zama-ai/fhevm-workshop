// SPDX-License-Identifier: BSD-3-Clause-Clear

contract EncryptedERC20 {
    address public contractOwner;

    constructor() {
        contractOwner = msg.sender;
    }

    mapping(address => uint32) balances;
}
