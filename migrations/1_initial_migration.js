const ArbitrageAnalyzer = artifacts.require("ArbitrageAnalyzer");

module.exports = function(deployer) {
  deployer.deploy(ArbitrageAnalyzer);
};
