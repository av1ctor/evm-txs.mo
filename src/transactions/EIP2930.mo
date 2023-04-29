import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Int64 "mo:base/Int64";
import Rlp "mo:rlp";
import RlpTypes "mo:rlp/types";
import Recover "mo:libsecp256k1/Recover";
import Ecmult "mo:libsecp256k1/core/ecmult";
import Types "../Types";
import HU "../utils/HashUtils";
import AU "../utils/ArrayUtils";
import TU "../utils/TextUtils";
import RlpUtils "../utils/RlpUtils";
import Helper "Helper";

module EIP2930 {
    public func from(
        data: [Nat8]
    ): Result.Result<Types.Transaction2930, Text> {
        switch(Rlp.decode(#Uint8Array(Buffer.fromArray(AU.right(data, 1))))) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(dec)) {
                switch(dec) {
                    case (#Nested(list)) {
                        let chainId = RlpUtils.getAsNat64(list.get(0));
                        let nonce = RlpUtils.getAsNat64(list.get(1));
                        let gasPrice = RlpUtils.getAsNat64(list.get(2));
                        let gasLimit = RlpUtils.getAsNat64(list.get(3));
                        let to = RlpUtils.getAsText(list.get(4));
                        let value = RlpUtils.getAsNat64(list.get(5));
                        let dataTx = RlpUtils.getAsText(list.get(6));
                        let accessList = Helper.serializeAccessList(list.get(7));
                        let v = RlpUtils.getAsText(list.get(8));
                        let r = RlpUtils.getAsText(list.get(9));
                        let s = RlpUtils.getAsText(list.get(10));

                        return #ok({
                            chainId = chainId;
                            nonce = nonce;
                            gasPrice = gasPrice;
                            gasLimit = gasLimit;
                            to = to;
                            value = value;
                            data = dataTx;
                            accessList = accessList;
                            v = v;
                            r = r;
                            s = s;
                        });
                    };
                    case _ {
                        return #err("Invalid raw transaction");
                    };
                };
            };
        };
    };

    public func getMessageToSign(
        tx: Types.Transaction2930
    ): Result.Result<[Nat8], Text> {
        
        let items: [[Nat8]] = [
            AU.fromNat64(tx.chainId),
            AU.fromNat64(tx.nonce),
            AU.fromNat64(tx.gasPrice),
            AU.fromNat64(tx.gasLimit),
            AU.fromText(tx.to),
            AU.fromNat64(tx.value),
            AU.fromText(tx.data),
        ];

        let buf = Buffer.Buffer<RlpTypes.Input>(items.size() + 1);
        for(item in items.vals()) {
            buf.add(#Uint8Array(Buffer.fromArray(item)));
        };

        buf.add(Helper.deserializeAccessList(tx.accessList));

        switch(Rlp.encode(#List(buf))) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(enc)) {
                let msg = Buffer.fromArray<Nat8>([0x01]);
                msg.append(enc);
                let hash = HU.keccak(Buffer.toArray(msg), 256);
                return #ok(hash);
            };
        };
    };

    public func sign(
        tx: Types.Transaction2930,
        signature: [Nat8],
        publicKey: [Nat8],
        ctx: Ecmult.ECMultContext
    ): Result.Result<Types.Transaction2930, Text> {
        let chain_id = tx.chainId;

        let r_remove_leading_zeros = AU.stripLeft(
            AU.left(signature, 31), func(e: Nat8): Bool = e == 0);
        let s_remove_leading_zeros = AU.stripLeft(
            AU.right<Nat8>(signature, 32), func(e: Nat8): Bool = e == 0);

        let r = AU.toText(r_remove_leading_zeros);
        let s = AU.toText(s_remove_leading_zeros);

        switch(getMessageToSign(tx)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(message)) {
                switch(Helper.getRecoveryId(message, signature, publicKey, ctx)) {
                    case (#err(msg)) {
                        return #err(msg);
                    };
                    case (#ok(recovery_id)) {
                        let v = if(recovery_id == 0) "" else "01";

                        return #ok({
                            tx
                            with
                            v = v;
                            r = r;
                            s = s;
                        });
                    };
                };
            };
        };
    };

    public func signAndSerialize(
        tx: Types.Transaction2930,
        signature: [Nat8],
        publicKey: [Nat8],
        ctx: Ecmult.ECMultContext
    ): Result.Result<(Types.Transaction2930, [Nat8]), Text> {
        switch(sign(tx, signature, publicKey, ctx)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(signedTx)) {
                switch(serialize(signedTx)) {
                    case (#err(msg)) {
                        return #err(msg);
                    };
                    case (#ok(serTx)) {
                        return #ok((signedTx, serTx));
                    };
                };
            };
        };
    };

    public func isSigned(
        tx: Types.Transaction2930
    ): Bool {
        let r = if(Text.startsWith(tx.r, #text("0x"))) {
            TU.right(tx.r, 2);
        } else {
            tx.r;
        };

        let s = if(Text.startsWith(tx.s, #text("0x"))) {
            TU.right(tx.s, 2);
        } else {
            tx.s;
        };

        return r != "00" or s != "00";
    };

    public func getSignature(
        tx: Types.Transaction2930
    ): Result.Result<[Nat8], Text> {
        if(not isSigned(tx)) {
            return #err("This is not a signed transaction");
        };

        let r = Buffer.fromArray<Nat8>(AU.fromText(tx.r));
        let s = Buffer.fromArray<Nat8>(AU.fromText(tx.s));
        let res = Buffer.Buffer<Nat8>(r.size() + s.size());
        res.append(r);
        res.append(s);

        return #ok(Buffer.toArray(res));
    };

    public func getRecoveryId(
        tx: Types.Transaction2930
    ): Result.Result<Nat8, Text> {
        if(not isSigned(tx)) {
            return #err("This is not a signed transaction");
        };
        
        let v = AU.fromText(tx.v);

        return if(v.size() == 0) #ok(0) else #ok(1);
    };

    public func serialize(
        tx: Types.Transaction2930
    ): Result.Result<[Nat8], Text> {

        let items: [[Nat8]] = [
            AU.fromNat64(tx.chainId),
            AU.fromNat64(tx.nonce),
            AU.fromNat64(tx.gasPrice),
            AU.fromNat64(tx.gasLimit),
            AU.fromText(tx.to),
            AU.fromNat64(tx.value),
            AU.fromText(tx.data),
            Helper.encodeAccessList(tx.accessList),
            AU.fromText(tx.v),
            AU.fromText(tx.r),
            AU.fromText(tx.s),
        ];

        let buf = Buffer.Buffer<RlpTypes.Input>(items.size());
        for(item in items.vals()) {
            buf.add(#Uint8Array(Buffer.fromArray(item)));
        };

        switch(Rlp.encode(#List(buf))) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(enc)) {
                let msg = Buffer.fromArray<Nat8>([0x01]);
                msg.append(enc);
                return #ok(Buffer.toArray<Nat8>(msg));
            };
        };
    };
};