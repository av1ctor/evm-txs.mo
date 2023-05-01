import SecretKey "mo:libsecp256k1/SecretKey";
import PublicKey "mo:libsecp256k1/PublicKey";
import Message "mo:libsecp256k1/Message";
import Signature "mo:libsecp256k1/Signature";
import Ecdsa "mo:libsecp256k1/Ecdsa";
import ECMult "mo:libsecp256k1/core/ecmult";
import AU "../../src/utils/ArrayUtils";
import Blob "mo:base/Blob";
import Prelude "mo:base/Prelude";
import Error "mo:base/Error";
import Random "mo:libsecp256k1/interfaces/Random";

module {
     public class IcEcdsaApiMock(
        context: ECMult.ECMultGenContext,
        random: Random.Random
     ) {
        let privateKey = "5c86d3784f39013aa50aada6d97f9bad733636d57bf6bb18b0bca1ffcff374b4";
        
        public let create = func(
            keyName : Text, 
            derivationPath : [Blob]
        ): async* Blob {
            switch(SecretKey.parse(AU.fromText(privateKey))) {
                case (#err(msg)) {
                    throw Error.reject(debug_show msg);
                };
                case (#ok(privateKey)) {
                    let publicKey = PublicKey.from_secret_key_with_context(
                        privateKey, context).serialize_compressed();
                    return Blob.fromArray(publicKey);
                };
            };
        };   

        public let sign = func(
            keyName : Text, 
            derivationPath : [Blob], 
            messageHash : Blob
        ): async* Blob {
            switch(SecretKey.parse(AU.fromText(privateKey))) {
                case (#err(msg)) {
                    throw Error.reject(debug_show msg);
                };
                case (#ok(privateKey)) {
                    let message_parsed = Message.parse(Blob.toArray(messageHash));
                    switch(Ecdsa.sign_with_context(message_parsed, privateKey, context, random)) {
                        case (#err(msg)) {
                            throw Error.reject(debug_show msg);
                        };
                        case (#ok(signature)) {
                            return Blob.fromArray(signature.0.serialize());
                        };
                    };
                };
            };
        };
    };
}