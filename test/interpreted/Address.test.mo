import { describe; it; Suite } = "mo:testing/Suite";
import RecoveryId "mo:libsecp256k1/RecoveryId";
import Recover "mo:libsecp256k1/Recover";
import Ecmult "mo:libsecp256k1/core/ecmult";
import Address "../../src/Address";
import AU "../../src/utils/ArrayUtils";
import Result "mo:base/Result";
import Error "mo:base/Error";
import Consts "../consts/pre_g";

let context = Ecmult.ECMultContext(?Ecmult.calcPreGFast(Consts.pre_g));

let s = Suite();

await* s.run([
    describe("getAddressFromPublicKey", [
        it("valid", func (): Bool {
            let expected = #ok("0x907dc4d0be5d691970cae886fcab34ed65a2cd66");
            let response = Address.fromPublicKey(AU.fromText("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1"));
            response == expected
        }),
        it("invalid (all zeros)", func (): Bool {
            let expected = #err("Invalid public key");
            let response = Address.fromPublicKey(AU.fromText("000000000000000000000000000000000000000000000000000000000000000000"));
            response == expected
        }),
        it("invalid (empby)", func (): Bool {
            let expected = #err("Invalid length of public key");
            let response = Address.fromPublicKey(AU.fromText(""));
            response == expected
        }),
    ]),
    describe("recover", [
        it("valid", func (): Bool {
            let expected = #ok("0x907dc4d0be5d691970cae886fcab34ed65a2cd66");
            let signature = AU.fromText("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
            let recovery_id = 0: Nat8;
            let message = AU.fromText("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
            let response = Address.recover(signature, recovery_id, message, context);
            response == expected
        }),
    ]),
]);

