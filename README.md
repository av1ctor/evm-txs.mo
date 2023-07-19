# evm-txs.mo
EVM transactions creation, encoding, and decoding library in pure Motoko.    
ICDevs.org bounty #32, see: https://forum.dfinity.org/t/open-icdevs-org-bounty-32-evm-transactions-motoko-8-000/17884

## References
- Ported from https://github.com/nikolas-con/ic-evm-sign

## Dependencies
- libsecp256k1.mo: https://github.com/av1ctor/libsecp256k1.mo
- rlp-motoko: https://github.com/relaxed04/rlp-motoko
- motoko-sha3: https://github.com/hanbu97/motoko-sha3

## Features
- Supports legacy, EIP2930 and EIP1559 transactions
- The chain id is user-defined
- Can be set up to work with vessel or MOPS

## Examples
See e2e/tx_tools for a complete example

## Todo

## Licensing
Distributed under the terms of the Apache License (Version 2.0).

See LICENSE for details.
