import RecoveryId "mo:libsecp256k1/RecoveryId";
import Signature "mo:libsecp256k1/Signature";
import Message "mo:libsecp256k1/Message";
import Ecdsa "mo:libsecp256k1/Ecdsa";
import Ecmult "mo:libsecp256k1/core/ecmult";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Rlp "mo:rlp";
import RlpTypes "mo:rlp/types";
import HU "../utils/HashUtils";
import AU "../utils/ArrayUtils";
import RlpUtils "../utils/RlpUtils";

module {
    public func getRecoveryId(
        message: [Nat8],
        signature: [Nat8],
        publicKey: [Nat8],
        context: Ecmult.ECMultContext,
    ): Result.Result<Nat8, Text> {
        if(signature.size() != 64) {
            return #err("Invalid signature");
        };
        if(message.size() != 32) {
            return #err("Invalid message");
        };
        if(publicKey.size() != 33) {
            return #err("Invalid public key");
        };

        let signature_bytes_64 = switch(Signature.parse_standard(signature)) {
            case (#ok(sig)) {
                sig;
            };
            case (#err(msg)) {
                return #err(debug_show msg);
            };
        };

        label L for(i in Iter.range(0, 2)) {
            let recovery_id = switch(RecoveryId.parse_rpc(Nat8.fromNat(27 + i))) {
                case (#ok(id)) {
                    id;
                };
                case _ {
                    continue L;
                };
            };

            let message_bytes_32 = Message.parse(message);

            switch(Ecdsa.recover_with_context(
                message_bytes_32, signature_bytes_64, recovery_id, context)) {
                case (#ok(key)) {
                    if(key.serialize_compressed() == publicKey) {
                        return #ok(Nat8.fromNat(i));
                    };
                };
                case _ {};
            };
        };

        return #err("Not found");
    };

    public func deserializeAccessList(
        accessList: [(Text, [Text])]
    ): RlpTypes.Input {
        let stream = Buffer.Buffer<RlpTypes.Input>(accessList.size());

        for(list in accessList.vals()) {
            let address = #Uint8Array(Buffer.fromArray<Nat8>(AU.fromText(list.0)));

            let storageKeys = Buffer.Buffer<RlpTypes.Input>(list.1.size());
            for(key in list.1.vals()) {
                storageKeys.add(#Uint8Array(Buffer.fromArray(AU.fromText(key))));
            };

            stream.add(#List(Buffer.fromArray<RlpTypes.Input>([address, #List(storageKeys)])));
        };

        return #List(stream);
    };

    public func encodeAccessList(
        accessList: [(Text, [Text])]
    ): [Nat8] {
        switch(Rlp.encode(deserializeAccessList(accessList))) {
            case (#ok(res)) {
                return Buffer.toArray(res);
            };
            case (#err(_)) {
                return []
            };
        };
    };

    public func serializeAccessList(
        accessList: RlpTypes.Decoded
    ): [(Text, [Text])] {
        switch(accessList) {
            case (#Uint8Array(_)) {
                return [];
            };
            case (#Nested(buf)) {
                let res = Buffer.Buffer<(Text, [Text])>(10);

                for(item in buf.vals()) {
                    switch(item) {
                        case (#Uint8Array(_)) {
                            return [];
                        };
                        case (#Nested(buf)) {
                            let address = RlpUtils.getAsValue(buf.get(0));
                            let storageKeys = RlpUtils.getAsList(buf.get(1));
                            res.add((
                                AU.toText(address), 
                                Array.map<[Nat8], Text>(storageKeys, func k = AU.toText(k))
                            ));
                        };
                    };
                };

                return Buffer.toArray(res);
            };
        };
    };

    public func decodeAccessList(
        accessList: [Nat8]
    ): [(Text, [Text])] {
        switch(Rlp.decode(#Uint8Array(Buffer.fromArray(accessList)))) {
            case (#err(_)) {
                return [];
            };
            case (#ok(dec)) {
                return serializeAccessList(dec);
            };
        };
    };
}