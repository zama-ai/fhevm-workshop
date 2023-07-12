const { Wallet, Contract } = require('ethers');
const { WALLET_PRIVATE_KEY, WALLET_TO_TRANSFER, CONTRACT_ADDRESS } = require('./constants');
const { getInstance, provider } = require('./instance.js');
const abi = require('../../abi.json');

const signer = new Wallet(WALLET_PRIVATE_KEY, provider);
const contract = new Contract(CONTRACT_ADDRESS, abi, signer);

const transfer = async (to, amount) => {
  // Get instance to encrypt amount parameter
  const fhevm = await getInstance();

  // Encrypt amount
  console.log(`Encrypting ${amount}`);
  const encryptedAmount = fhevm.encrypt32(amount);

  console.log('Sending transaction');
  const transaction = await contract['transfer(address,bytes)'](to, encryptedAmount);
  console.log('Waiting for transaction validation...');
  await provider.waitForTransaction(transaction.hash);
};

transfer(process.argv[2], +process.argv[3] || 100)
  .then(() => {
    console.log('Transaction done!');
  })
  .catch(() => console.log('Transaction failed :('));
