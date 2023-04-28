import Result "mo:base/Result";
import Types "../Types";
import Eip2930 "EIP2930";
import Legacy "Legacy";
import Eip1559 "EIP1559";
import Recover "mo:libsecp256k1/Recover";

module {
    public func getTransactionType(
        rawTx: [Nat8]
    ): Result.Result<Types.TransactionType, Text> {
        if(rawTx[0] >= 0xc0) {
            return #ok(#Legacy(null));
        }
        else if(rawTx[0] == 0x01) {
            return #ok(#EIP2930(null));
        }
        else if(rawTx[0] == 0x02) {
            return #ok(#EIP1559(null));
        }
        else {
            return #err("Invalid type");
        };
    };

    public func getTransaction(
        rawTx: [Nat8],
        chainId: Nat64
    ): Result.Result<Types.TransactionType, Text> {
        switch(getTransactionType(rawTx)) {
            case (#ok(#Legacy(_))) {
                switch(Legacy.from(rawTx, chainId)) {
                    case (#err(msg)) {
                        return #err(msg);
                    };
                    case (#ok(tx)) {
                        return #ok(#Legacy(?tx));
                    };
                };
            };
            case (#ok(#EIP2930(_))) {
                switch(Eip2930.from(rawTx)) {
                    case (#err(msg)) {
                        return #err(msg);
                    };
                    case (#ok(tx)) {
                        return #ok(#EIP2930(?tx));
                    };
                };
            };
            case (#ok(#EIP1559(_))) {
                switch(Eip1559.from(rawTx)) {
                    case (#err(msg)) {
                        return #err(msg);
                    };
                    case (#ok(tx)) {
                        return #ok(#EIP1559(?tx));
                    };
                };
            };
            case (#err(msg)) {
                return #err("");
            };
        };
    };

    public func getMessageToSign(
        tx: Types.TransactionType
    ): Result.Result<[Nat8], Text> {
        switch(tx) {
            case (#Legacy(tx)) {
                switch(tx) {
                    case null {
                        return #err("Null transaction");
                    };
                    case (?tx) {
                        return Legacy.getMessageToSign(tx);
                    };
                };
            };
            case (#EIP2930(tx)) {
                switch(tx) {
                    case null {
                        return #err("Null transaction");
                    };
                    case (?tx) {
                        return Eip2930.getMessageToSign(tx);
                    };
                };
            };
            case (#EIP1559(tx)) {
                switch(tx) {
                    case null {
                        return #err("Null transaction");
                    };
                    case (?tx) {
                        return Eip1559.getMessageToSign(tx);
                    };
                };
            };
        };
    };

    public func sign(
        tx: Types.TransactionType,
        signature: [Nat8],
        publicKey: [Nat8],
        ctx: Recover.Context
    ): Result.Result<(Types.TransactionType, [Nat8]), Text> {
        switch(tx) {
            case (#Legacy(tx)) {
                switch(tx) {
                    case null {
                        return #err("Null transaction");
                    };
                    case (?tx) {
                        switch(Legacy.signAndSerialize(tx, signature, publicKey, ctx)) {
                            case (#err(msg)) {
                                return #err(msg);
                            };
                            case (#ok(res)) {
                                return #ok((#Legacy(?res.0), res.1));
                            };
                        };
                    };
                };
            };
            case (#EIP2930(tx)) {
                switch(tx) {
                    case null {
                        return #err("Null transaction");
                    };
                    case (?tx) {
                        switch(Eip2930.signAndSerialize(tx, signature, publicKey, ctx)) {
                            case (#err(msg)) {
                                return #err(msg);
                            };
                            case (#ok(res)) {
                                return #ok((#EIP2930(?res.0), res.1));
                            };
                        };
                    };
                };
            };
            case (#EIP1559(tx)) {
                switch(tx) {
                    case null {
                        return #err("Null transaction");
                    };
                    case (?tx) {
                        switch(Eip1559.signAndSerialize(tx, signature, publicKey, ctx)) {
                            case (#err(msg)) {
                                return #err(msg);
                            };
                            case (#ok(res)) {
                                return #ok((#EIP1559(?res.0), res.1));
                            };
                        };
                    };
                };
            };
        };
    };
};