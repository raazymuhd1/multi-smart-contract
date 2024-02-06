include .env

build :; forge build
compile :; forge compile

# gas cover
cover-gas :; forge coverage

deploy-presale-anvil:; forge script script/DeployPresale.s.sol:DeployPresale --broadcast -vvvv
deploy-presale-sepolia:; forge script script/DeployPresale.s.sol:DeployPresale --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --verify $(ETHERSCAN_API_KEY) --broadcast -vvvv

deploy-staking-anvil:; forge script script/DeployStaking.s.sol:DeployStaking --broadcast -vvvv
deploy-staking-sepolia:; forge script script/DeployStaking.s.sol:DeployStaking --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --verify $(ETHERSCAN_API_KEY) --broadcast -vvvv