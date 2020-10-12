module.exports = {
	networks: {
		coverage: {
			host: 'localhost',
			network_id: '*',
			port: 8555,
			gas: 0x6691b7,
			gasPrice: 0x01
		},
	},
	solc: {
		optimizer: {
			enabled: true,
			runs: 200
		}
	},
	plugins: ["solidity-coverage"],
	compilers: {
		solc: {
			version: '0.6.8'
		}
	}
};
