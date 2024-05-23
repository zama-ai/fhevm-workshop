const { Wallet, Contract } = require('ethers');
const { WALLET_PRIVATE_KEY, CONTRACT_ADDRESS } = require('./constants');
const { getInstance, provider } = require('./instance.js');
const abi = require('../../abi.json');

const signer = new Wallet(WALLET_PRIVATE_KEY, provider);
const contract = new Contract(CONTRACT_ADDRESS, abi, signer);

const mint = async (amount) => {
  console.log('Sending transaction');
  const transaction = await contract.mint(amount);

  console.log('Waiting for transaction validation...');
  await provider.waitForTransaction(transaction.hash);
};

mint(+process.argv[2] || 1000)
  .then(() => {
    console.log('Transaction done!');
  })
  .catch((err) => console.log('Transaction failed :(', err));
