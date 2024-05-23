const { Wallet, Contract } = require('ethers');
const { WALLET_PRIVATE_KEY, CONTRACT_ADDRESS } = require('./constants');
const { getInstance, provider } = require('./instance.js');
const abi = require('../../abi.json');

const signer = new Wallet(WALLET_PRIVATE_KEY, provider);
const contract = new Contract(CONTRACT_ADDRESS, abi, signer);

const balanceOf = async () => {
  const fhevm = await getInstance();

  console.log('Generating public key for reencryption');
  const clientPublicKey = fhevm.generatePublicKey({
    verifyingContract: CONTRACT_ADDRESS,
  });

  console.log('Signing public key');
  const signature = await signer.signTypedData(
    clientPublicKey.eip712.domain,
    { Reencrypt: clientPublicKey.eip712.types.Reencrypt },
    clientPublicKey.eip712.message
  );

  console.log('Calling contract');
  const userAddress = await signer.getAddress();
  const encryptedBalance = await contract.balanceOf(
    userAddress,
    clientPublicKey.publicKey,
    signature
  );

  console.log('Decrypting result using private key');
  const balance = fhevm.decrypt(CONTRACT_ADDRESS, encryptedBalance);
  return balance;
};

balanceOf().then((balance) => {
  console.log(`Balance: ${balance}`);
});
