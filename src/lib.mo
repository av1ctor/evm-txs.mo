import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import IC "mo:base/ExperimentalInternetComputer";
import IcEcdsaApi "utils/IcEcdsaApi";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Utils "utils/Utils";
import Transaction "transactions";
import Types "Types";
import Recover "mo:libsecp256k1/Recover";

module {
    
    public func createAddress(
        keyName: Text,
        principal: Principal
    ): async* Result.Result<Text, Text> {
        let caller = Principal.toBlob(principal);

        try {
            let publicKey = await* IcEcdsaApi.ecdsaPublicKey(keyName, [caller]);
            return Utils.getAddressFromPublicKey(Blob.toArray(publicKey));
        }
        catch(e: Error.Error) {
            return #err("ecdsa_public_key failed: " # Error.message(e));
        };
    };

    public func signTransaction(
        rawTx: [Nat8],
        chainId: Nat64,
        keyName: Text,
        principal: Principal,
        publicKey: [Nat8],
        ctx: Recover.Context
    ): async* Result.Result<(Types.TransactionType, [Nat8]), Text> {
        let caller = Principal.toBlob(principal);

        switch(Transaction.getTransaction(rawTx, chainId)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(tx)) {
                switch(Transaction.getMessageToSign(tx)) {
                    case (#err(msg)) {
                        return #err(msg);
                    };
                    case (#ok(msg)) {
                        try {
                            assert(msg.size() == 32);
                            let signature = await* IcEcdsaApi.signWithEcdsa(keyName, [caller], Blob.fromArray(msg));

                            return Transaction.sign(tx, Blob.toArray(signature), publicKey, ctx);
                        }
                        catch(e: Error.Error) {
                            return #err("sign_with_ecdsa failed: " # Error.message(e));
                        };
                    };
                };
            };
        };
    };

}