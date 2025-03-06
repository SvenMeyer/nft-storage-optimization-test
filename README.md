# Solidity Storage Patterns

This project demonstrates various storage patterns in Solidity and their gas cost implications. It provides benchmarks for different approaches to storing NFT properties on-chain.

## Overview

Storage in Ethereum and other EVM-based blockchains is one of the most expensive operations in terms of gas costs. This project provides a practical comparison of different storage approaches for NFT properties:

1. Packed bytes32 in a mapping
2. Struct with packed uint16 fields
3. Array in a mapping
4. Struct with uint32 + uint16[14] array
5. Struct with uint16[16] array
6. Individual mappings for each property

## Getting Started

```bash
# Install dependencies
npm install

# Run the tests
npx hardhat test
```

## Documentation

For detailed analysis and findings, see [Storage-Optimization.md](./docs/Storage-Optimization.md)

## License

MIT
