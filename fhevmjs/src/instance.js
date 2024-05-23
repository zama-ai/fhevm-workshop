const { createInstance, getPublicKeyCallParams } = require('fhevmjs');
const { ethers, JsonRpcProvider } = require('ethers');
const { DEVNET_URL } = require('./constants');

let _instance;
const provider = new JsonRpcProvider(DEVNET_URL);

const getInstance = async () => {
  if (_instance) return _instance;
  // 1. Get chain id
  const network = await provider.getNetwork();
  const chainId = +network.chainId.toString();
  // Get blockchain public key
  const rawPublicKeyParams = await provider.call(getPublicKeyCallParams());
  const publicKeyParams = ethers.AbiCoder.defaultAbiCoder().decode(["bytes"], rawPublicKeyParams);
  const publicKey = publicKeyParams[0];
  // Create instance
  _instance = createInstance({ chainId, publicKey });
  return _instance;
};

module.exports = {
  getInstance,
  provider,
};
