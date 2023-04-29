import { describe; it; Suite } = "mo:testing/SuiteSync";
import Ecmult "mo:libsecp256k1/core/ecmult";
import Helper "../../src/transactions/Helper";
import HU "../../src/utils/HashUtils";
import AU "../../src/utils/ArrayUtils";
import Consts "../consts/pre_g";

let context = Ecmult.ECMultContext(?Ecmult.calcPreGFast(Consts.pre_g));

let s = Suite();

s.run([
    describe("getRecoveryId", [
        it("valid", func (): Bool {
            let expected = #ok(0: Nat8);
            let pubkey = AU.fromText("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1");
            let signature = AU.fromText("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
            let message = AU.fromText("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
            let response = Helper.getRecoveryId(message, signature, pubkey, context);
            response == expected
        }),
        it("invalid signature", func (): Bool {
            let expected = #err("Invalid signature");
            let pubkey = AU.fromText("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1");
            let signature = AU.fromText("");
            let message = AU.fromText("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
            let response = Helper.getRecoveryId(message, signature, pubkey, context);
            response == expected
        }),
        it("invalid message", func (): Bool {
            let expected = #err("Invalid message");
            let pubkey = AU.fromText("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1");
            let signature = AU.fromText("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
            let message = AU.fromText("");
            let response = Helper.getRecoveryId(message, signature, pubkey, context);
            response == expected
        }),
        it("invalid public key", func (): Bool {
            let expected = #err("Invalid public key");
            let pubkey = AU.fromText("");
            let signature = AU.fromText("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
            let message = AU.fromText("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
            let response = Helper.getRecoveryId(message, signature, pubkey, context);
            response == expected
        }),
    ]),
]);
