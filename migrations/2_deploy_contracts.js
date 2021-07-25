var itemManager = artifacts.require("./ItemManager.sol");

module.exports = function(deployer) {
  deployer.deploy(itemManager);
};
