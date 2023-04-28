import RecoveryId "mo:libsecp256k1/RecoveryId";
import Signature "mo:libsecp256k1/Signature";
import Message "mo:libsecp256k1/Message";
import Recover "mo:libsecp256k1/Recover";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Rlp "mo:rlp";
import RlpTypes "mo:rlp/types";
import Utils "../utils/Utils";

module {
    public type Context = Recover.Context;

    public let allocContext = Recover.alloc_context;

    public func getRecoveryId(
        message: [Nat8],
        signature: [Nat8],
        public_key: [Nat8],
        context: Context,
    ): Result.Result<Nat8, Text> {
        if(signature.size() != 64) {
            return #err("Invalid signature");
        };
        if(message.size() != 32) {
            return #err("Invalid message");
        };
        if(public_key.size() != 33) {
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

            switch(Recover.recover_with_context(
                message_bytes_32, signature_bytes_64, recovery_id, context)) {
                case (#ok(key)) {
                    if(key.serialize_compressed() == public_key) {
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
            let address = #Uint8Array(Buffer.fromArray<Nat8>(Utils.textToArray(list.0)));

            let storageKeys = Buffer.Buffer<RlpTypes.Input>(list.1.size());
            for(key in list.1.vals()) {
                storageKeys.add(#Uint8Array(Buffer.fromArray(Utils.textToArray(key))));
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
                            let address = Utils.rlpGetAsValue(buf.get(0));
                            let storageKeys = Utils.rlpGetAsList(buf.get(1));
                            res.add((
                                Utils.arrayToText(address), 
                                Array.map<[Nat8], Text>(storageKeys, func k = Utils.arrayToText(k))
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
            case (#err(msg)) {
                return [];
            };
            case (#ok(dec)) {
                return serializeAccessList(dec);
            };
        };
    };
}