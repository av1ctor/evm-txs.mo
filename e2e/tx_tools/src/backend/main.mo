import Address "../../../../src/Address";
import Contract "../../../../src/Contract";
import Transaction "../../../../src/Transaction";
import Context "../../../../src/Context";

import Principal "mo:base/Principal";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";

import IcEcdsaApi "IcEcdsaApi";
import Types "Types";

shared({caller = owner}) actor class TxTools(
    network: IcEcdsaApi.Network
) = this {
    let keyName: Text = switch network {
        case (#Localhost) "dfx_test_key";
        case _ "test_key_1"
    };

    type User = {
        nonce: Nat64;
        address: Text;
        publicKey: [Nat8];
    };

    let icEcdsaApi = IcEcdsaApi.IcEcdsaApi();
    let ecCtx = Context.allocECMultContext(null);
    let users = HashMap.HashMap<Principal, User>(10, Principal.equal, Principal.hash);

    public shared(msg) func create_address(
    ): async Result.Result<Types.CreateAddressResponse, Text> {
        let principalId = msg.caller;
        let derivationPath = [Principal.toBlob(principalId)];

        switch(users.get(principalId)) {
            case (?_) return #err("Address already created for user");
            case null ();
        };

        switch(await* Address.create(keyName, derivationPath, icEcdsaApi)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(res)) {
                users.put(principalId, {
                    nonce = 0;
                    address = res.0;
                    publicKey = res.1;
                });

                return #ok({
                    address = res.0;
                });
            };
        };
    };

    public shared(msg) func sign_evm_tx(
        hex_raw_tx: [Nat8],
        chain_id: Nat64
    ): async Result.Result<Types.SignTransactionResponse, Text> {
        let principalId = msg.caller;
        let derivationPath = [Principal.toBlob(principalId)];

        let user = switch(users.get(principalId)) {
            case null return #err("Unknown user");
            case (?key) key;
        };

        switch(await* Transaction.signRawTx(
            hex_raw_tx, chain_id, 
            keyName, derivationPath, user.publicKey, 
            ecCtx, icEcdsaApi)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(tx)) {
                return #ok({
                    sign_tx = tx.1;
                });
            };
        };
    };

    public shared(msg) func deploy_evm_contract(
        bytecode: [Nat8],
        chain_id: Nat64,
        max_priority_fee_per_gas: Nat64,
        gas_limit: Nat64,
        max_fee_per_gas: Nat64
    ): async Result.Result<Types.DeployEVMContractResponse, Text> {
        let principalId = msg.caller;
        let derivationPath = [Principal.toBlob(principalId)];

        let user = switch(users.get(principalId)) {
            case null return #err("Unknown user");
            case (?key) key;
        };

        switch(await* Contract.signDeployment(
            bytecode, 
            max_priority_fee_per_gas, gas_limit, max_fee_per_gas, chain_id, 
            keyName, derivationPath, user.publicKey, user.nonce, 
            ecCtx, icEcdsaApi)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(res)) {
                ignore users.replace(principalId, {
                    user
                    with
                    nonce = user.nonce + 1;
                });

                return #ok({
                    tx = res.1;
                });
            };
        };
    };
};
