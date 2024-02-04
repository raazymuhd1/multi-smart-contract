include .env

build :; forge build
compile :; forge compile

# gas cover
cover-gas :; forge coverage

deploy-anvil:; forge script script/DeployPresale.s.sol:DeployPresale --broadcast -vvvv
deploy-sepolia:; forge script script/DeployPresale.s.sol:DeployPresale --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --verify $(ETHERSCAN_API_KEY) --broadcast -vvvv