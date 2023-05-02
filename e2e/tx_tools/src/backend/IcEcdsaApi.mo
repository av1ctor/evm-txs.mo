import ExperimentalCycles "mo:base/ExperimentalCycles";

module {
    public type Network = {
        #Mainnet;
        #Testnet;
        #Localhost;
    };
    
    public type ECDSAPublicKeyReply = {
        public_key : Blob;
        chain_code : Blob;
    };

    public type EcdsaKeyId = {
        curve : EcdsaCurve;
        name : Text;
    };

    public type EcdsaCurve = {
        #secp256k1;
    };

    public type SignWithECDSAReply = {
        signature : Blob;
    };

    public type ECDSAPublicKey = {
        canister_id : ?Principal;
        derivation_path : [Blob];
        key_id : EcdsaKeyId;
    };

    public type SignWithECDSA = {
        message_hash : Blob;
        derivation_path : [Blob];
        key_id : EcdsaKeyId;
    };
    
    public type EcdsaCanisterActor = actor {
        ecdsa_public_key : ECDSAPublicKey -> async ECDSAPublicKeyReply;
        sign_with_ecdsa : SignWithECDSA -> async SignWithECDSAReply;
    };

    public class IcEcdsaApi() {
        let ecdsa_canister_actor : EcdsaCanisterActor = actor("aaaaa-aa");

        public let create = func(
            keyName: Text, 
            derivationPath: [Blob]
        ): async* Blob {
            let res = await ecdsa_canister_actor.ecdsa_public_key({
                canister_id = null;
                derivation_path = derivationPath;
                key_id = {
                    curve = #secp256k1;
                    name = keyName;
                };
            });
            
            res.public_key
        };

        public let sign = func(
            keyName: Text, 
            derivationPath: [Blob], 
            messageHash: Blob
        ): async* Blob {
            ExperimentalCycles.add(10_000_000_000);
            let res = await ecdsa_canister_actor.sign_with_ecdsa({
                message_hash = messageHash;
                derivation_path = derivationPath;
                key_id = {
                    curve = #secp256k1;
                    name = keyName;
                };
            });
                
            res.signature
        };
    };
}