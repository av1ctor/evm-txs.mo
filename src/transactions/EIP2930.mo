import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Int64 "mo:base/Int64";
import Rlp "mo:rlp";
import RlpTypes "mo:rlp/types";
import Recover "mo:libsecp256k1/Recover";
import Types "../Types";
import Utils "../Utils";
import ArrayUtils "../ArrayUtils";
import TextUtils "../TextUtils";
import Helper "Helper";

module EIP2930 {
    public func from(
        data: [Nat8]
    ): ?Types.Transaction2930 {
        switch(Rlp.decode(#Uint8Array(Buffer.fromArray(ArrayUtils.right(data, 1))))) {
            case (#err(_)) {
                return null;
            };
            case (#ok(dec)) {
                switch(dec) {
                    case (#Nested(list)) {
                        let chain_id_hex = Utils.rlpGetAsValue(list.get(0));
                        let chain_id = Utils.nat8ArrayToNat64(chain_id_hex);

                        let nonce_hex = Utils.rlpGetAsValue(list.get(1));
                        let nonce = Utils.nat8ArrayToNat64(nonce_hex);

                        let gas_price_hex = Utils.rlpGetAsValue(list.get(2));
                        let gas_price = Utils.nat8ArrayToNat64(gas_price_hex);

                        let gas_limit_hex = Utils.rlpGetAsValue(list.get(3));
                        let gas_limit = Utils.nat8ArrayToNat64(gas_limit_hex);

                        let to_hex = Utils.rlpGetAsValue(list.get(4));
                        let to = Utils.nat8ArrayToHexText(to_hex);

                        let value_hex = Utils.rlpGetAsValue(list.get(5));
                        let value = Utils.nat8ArrayToNat64(value_hex);

                        let data_tx_hex = Utils.rlpGetAsValue(list.get(6));
                        let data_tx = Utils.nat8ArrayToHexText(data_tx_hex);

                        let access_list = Helper.serializeAccessList(list.get(7));

                        let v_hex = Utils.rlpGetAsValue(list.get(8));
                        let v = Utils.nat8ArrayToHexText(v_hex);

                        let r_hex = Utils.rlpGetAsValue(list.get(9));
                        let r = Utils.nat8ArrayToHexText(r_hex);

                        let s_hex = Utils.rlpGetAsValue(list.get(10));
                        let s = Utils.nat8ArrayToHexText(s_hex);

                        return ?{
                            chainId = chain_id;
                            nonce = nonce;
                            gasPrice = gas_price;
                            gasLimit = gas_limit;
                            to = to;
                            value = value;
                            data = data_tx;
                            accessList = access_list;
                            v = v;
                            r = r;
                            s = s;
                        };
                    };
                    case _ {
                        return null;
                    };
                };
            };
        };
    };

    public func getMessageToSign(
        tx: Types.Transaction2930
    ): Result.Result<[Nat8], Text> {
        
        let items: [[Nat8]] = [
            Utils.nat64ToNat8Array(tx.chainId),
            Utils.nat64ToNat8Array(tx.nonce),
            Utils.nat64ToNat8Array(tx.gasPrice),
            Utils.nat64ToNat8Array(tx.gasLimit),
            Utils.hexTextToNat8Array(tx.to),
            Utils.nat64ToNat8Array(tx.value),
            Utils.hexTextToNat8Array(tx.data),
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
                let hash = Utils.calcKeccak(Buffer.toArray(msg), 256);
                return #ok(hash);
            };
        };
    };

    public func sign(
        tx: Types.Transaction2930,
        signature: [Nat8],
        publicKey: [Nat8],
        ctx: Recover.Context,
    ): Result.Result<Types.Transaction2930, Text> {
        let chain_id = tx.chainId;

        let r_remove_leading_zeros = ArrayUtils.stripLeft(ArrayUtils.left(signature, 31), func(e: Nat8): Bool = e == 0);
        let s_remove_leading_zeros = ArrayUtils.stripLeft(ArrayUtils.right<Nat8>(signature, 32), func(e: Nat8): Bool = e == 0);

        let r = Utils.nat8ArrayToHexText(r_remove_leading_zeros);
        let s = Utils.nat8ArrayToHexText(s_remove_leading_zeros);

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
        ctx: Recover.Context,
    ): Result.Result<[Nat8], Text> {
        switch(sign(tx, signature, publicKey, ctx)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(signedTx)) {
                return serialize(signedTx);
            };
        };
    };

    public func isSigned(
        tx: Types.Transaction2930
    ): Bool {
        let r = if(Text.startsWith(tx.r, #text("0x"))) {
            TextUtils.right(tx.r, 2);
        } else {
            tx.r;
        };

        let s = if(Text.startsWith(tx.s, #text("0x"))) {
            TextUtils.right(tx.s, 2);
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

        let r = Buffer.fromArray<Nat8>(Utils.hexTextToNat8Array(tx.r));
        let s = Buffer.fromArray<Nat8>(Utils.hexTextToNat8Array(tx.s));
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
        
        let v = Utils.hexTextToNat8Array(tx.v);

        return if(v.size() == 0) #ok(0) else #ok(1);
    };

    public func serialize(
        tx: Types.Transaction2930
    ): Result.Result<[Nat8], Text> {
        let stream = Buffer.Buffer<RlpTypes.Input>(11);

        let chain_id = Buffer.fromArray<Nat8>(Utils.nat64ToNat8Array(tx.chainId));
        stream.add(#Uint8Array(chain_id));

        let nonce = Buffer.fromArray<Nat8>(Utils.nat64ToNat8Array(tx.nonce));
        stream.add(#Uint8Array(nonce));

        let gas_price = Buffer.fromArray<Nat8>(Utils.nat64ToNat8Array(tx.gasPrice));
        stream.add(#Uint8Array(gas_price));

        let gas_limit = Buffer.fromArray<Nat8>(Utils.nat64ToNat8Array(tx.gasLimit));
        stream.add(#Uint8Array(gas_limit));

        let to = Buffer.fromArray<Nat8>(Utils.hexTextToNat8Array(tx.to));
        stream.add(#Uint8Array(to));

        let value = Buffer.fromArray<Nat8>(Utils.nat64ToNat8Array(tx.value));
        stream.add(#Uint8Array(value));

        let data = Buffer.fromArray<Nat8>(Utils.hexTextToNat8Array(tx.data));
        stream.add(#Uint8Array(data));

        let access_list = Buffer.fromArray<Nat8>(Helper.encodeAccessList(tx.accessList));
        stream.add(#Uint8Array(access_list));

        let v = Buffer.fromArray<Nat8>(Utils.hexTextToNat8Array(tx.v));
        stream.add(#Uint8Array(v));

        let r = Buffer.fromArray<Nat8>(Utils.hexTextToNat8Array(tx.r));
        stream.add(#Uint8Array(r));

        let s = Buffer.fromArray<Nat8>(Utils.hexTextToNat8Array(tx.s));
        stream.add(#Uint8Array(s));

        switch(Rlp.encode(#List(stream))) {
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