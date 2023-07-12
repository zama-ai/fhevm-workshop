const { Wallet, Contract } = require('ethers');
const { WALLET_PRIVATE_KEY, CONTRACT_ADDRESS } = require('./constants');
const { getInstance, provider } = require('./instance.js');
const abi = require('../../abi.json');

const signer = new Wallet(WALLET_PRIVATE_KEY, provider);
const contract = new Contract(CONTRACT_ADDRESS, abi, signer);

const balanceOf = async () => {
  // Get instance to generate token
  const fhevm = await getInstance();

  // Generate token to decrypt
  console.log('Generating auth token');
  const generatedToken = fhevm.generateToken({
    verifyingContract: CONTRACT_ADDRESS,
  });

  // Sign the public key
  const signature = await signer.signTypedData(
    generatedToken.token.domain,
    { Reencrypt: generatedToken.token.types.Reencrypt }, // Need to remove EIP712Domain from types
    generatedToken.token.message
  );

  // Save signed token
  fhevm.setTokenSignature(CONTRACT_ADDRESS, signature);

  // Call the method with public key + signature
  const encryptedBalance = await contract.balanceOf(generatedToken.publicKey, signature);

  // Decrypt the balance
  const balance = fhevm.decrypt(CONTRACT_ADDRESS, encryptedBalance);
  return balance;
};

balanceOf().then((balance) => {
  console.log(`Balance: ${balance}`);
});
