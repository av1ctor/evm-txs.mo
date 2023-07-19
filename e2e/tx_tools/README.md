### tx_tools - Motoko backend example

## Deploying
dfx deploy backend --argument="(variant { Localhost })"

## Testing
1. dfx canister call backend create_address "()"
2. dfx canister call backend sign_raw_evm_tx "(vec {2; 248; 58; 130; 122; 105; 1; 131; 1; 134; 160; 131; 1; 134; 160; 131; 1; 134; 160; 148; 99; 136; 160; 15; 216; 78; 147; 83; 163; 60; 17; 153; 27; 23; 239; 23; 149; 66; 64; 230; 139; 102; 30; 253; 241; 45; 22; 83; 207; 52; 0; 0; 132; 18; 73; 197; 139; 192; 128; 128; 128}, 31337)"
3. npx hardhat node
4. curl http://127.0.0.1:8545/ \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_sendRawTransaction","params": ["___the_tx_text_field_from_result_returned_by_step_2___"],"id":1}'

## See the /e2e/hardhat/scripts folder for scripts to
1. Deploy a solidity contract
2. Send ether to address created at step 1
3. Create a transaction to be signed by step 2
