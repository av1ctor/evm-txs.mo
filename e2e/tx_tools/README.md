### tx_tools - Motoko backend example

## Deploying
dfx deploy backend --argument="(variant { Localhost })"

## Testing
- dfx canister call backend create_address "()"
- dfx canister call backend sign_evm_tx "(vec {2; 225; 1; 128; 128; 128; 128; 148; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 128; 0; 129; 192; 0; 0; 0}, 1)"