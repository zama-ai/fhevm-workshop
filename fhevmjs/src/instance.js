const { createInstance } = require('fhevmjs');
const { JsonRpcProvider } = require('ethers');
const { DEVNET_URL } = require('./constants');

let _instance;
const provider = new JsonRpcProvider(DEVNET_URL);

const getInstance = async () => {
  if (_instance) return _instance;
  // 1. Get chain id
  const network = await provider.getNetwork();
  const chainId = +network.chainId.toString();
  // Get blockchain public key
  const publicKey = await provider.call({ to: '0x0000000000000000000000000000000000000044' });
  // Create instance
  _instance = createInstance({ chainId, publicKey });
  return _instance;
};

module.exports = {
  getInstance,
  provider,
};
