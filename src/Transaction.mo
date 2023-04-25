import RecoveryId "mo:libsecp256k1/RecoveryId";
import Signature "mo:libsecp256k1/Signature";
import Message "mo:libsecp256k1/Message";
import Recover "mo:libsecp256k1/Recover";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Debug "mo:base/Debug";

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

            switch(Recover.recover_with_context(message_bytes_32, signature_bytes_64, recovery_id, context)) {
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

};