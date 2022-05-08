const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const DEPLOYER = process.env.DEPLOYER;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard BSC port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    rinkeby : {
      provider: () => new HDWalletProvider(DEPLOYER, `https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`),
      network_id: 4,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      from: '0x0026456aFFFB9270de56FEb80B3374a832e774A7',
    },
    testnet: {
      networkCheckTimeout: 10000,
      provider: () => new HDWalletProvider(DEPLOYER, `https://speedy-nodes-nyc.moralis.io/8acb30de87a17584b4446d0f/bsc/testnet`),
      network_id: 97,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      from: '0x0026456aFFFB9270de56FEb80B3374a832e774A7',
      gasPrice : 10000010000
    },
    bsc: {
      networkCheckTimeout: 10000,
      deploymentPollingInterval: 8000,
      provider: () => new HDWalletProvider(DEPLOYER, `https://bsc-dataseed1.defibit.io/`),
      network_id: 56,
      confirmations: 5,
      timeoutBlocks: 2000,
      skipDryRun: true,
      from: '0x0026456aFFFB9270de56FEb80B3374a832e774A7', // deployer address ytazılacak,
      gasPrice : 5000010000
    },
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    // Add BSCSCAN_API_KEY in .env file to verify contracts deployed through truffle
    bscscan: "1FI9HME6SVJW41VHFH5RQR55CV8E24BGK2"
  },
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      //https://forum.openzeppelin.com/t/how-to-deploy-uniswapv2-on-ganache/3885
      version: "0.8.11",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
      optimizer: {
        enabled: true,
        runs: 999999
      },
      evmVersion: "istanbul", 
      outputSelection: {
        "*": {
          "": [
            "ast"
          ],
          "*": [
            "evm.bytecode.object",
            "evm.deployedBytecode.object",
            "abi",
            "evm.bytecode.sourceMap",
            "evm.deployedBytecode.sourceMap",
            "metadata"
          ]
        },
      }
      }
    },
  }
}