import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import IC "mo:base/ExperimentalInternetComputer";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Recover "mo:libsecp256k1/Recover";
import IcEcdsaApi "utils/IcEcdsaApi";
import Utils "utils/Utils";
import Transaction "transactions";
import Types "Types";

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
                            let signature = await* IcEcdsaApi.signWithEcdsa(
                                keyName, [caller], Blob.fromArray(msg));

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

    public func deployContract(
        bytecode: [Nat8],
        maxPriorityFeePerGas: Nat64,
        gasLimit: Nat64,
        maxFeePerGas: Nat64,
        chainId: Nat64,
        keyName: Text,
        principal: Principal,
        publicKey: [Nat8],
        nonce: Nat64,
        ctx: Recover.Context
    ): async* Result.Result<(Types.TransactionType, [Nat8]), Text> {
        let tx: Types.Transaction1559 = {
            nonce;
            chainId;
            maxPriorityFeePerGas;
            maxFeePerGas;
            gasLimit;
            to = "0x";
            value = 0;
            data = "0x" # Utils.arrayToText(bytecode);
            accessList = [];
            v = "0x00";
            r = "0x00";
            s = "0x00";
        };
        switch(Transaction.serialize(#EIP1559(?tx))) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(rawTx)) {
                return await* signTransaction(rawTx, chainId, keyName, principal, publicKey, ctx);
            };
        };
    };

    public func transferERC20(
        address: Text,
        value: Nat64,
        contractAddress: Text,
        maxPriorityFeePerGas: Nat64,
        gasLimit: Nat64,
        maxFeePerGas: Nat64,
        chainId: Nat64,
        keyName: Text,
        principal: Principal,
        publicKey: [Nat8],
        nonce: Nat64,
        ctx: Recover.Context
    ): async* Result.Result<(Types.TransactionType, [Nat8]), Text> {
        switch(Utils.getTransferData(address, value)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(data)) {
                let tx: Types.Transaction1559 = {
                    nonce;
                    chainId;
                    maxPriorityFeePerGas;
                    maxFeePerGas;
                    gasLimit;
                    to = contractAddress;
                    value = 0;
                    data = "0x" # data;
                    accessList = [];
                    v = "0x00";
                    r = "0x00";
                    s = "0x00";
                };
                switch(Transaction.serialize(#EIP1559(?tx))) {
                    case (#err(msg)) {
                        return #err(msg);
                    };
                    case (#ok(rawTx)) {
                        return await* signTransaction(rawTx, chainId, keyName, principal, publicKey, ctx);
                    };
                };
            };
        };
    };

}