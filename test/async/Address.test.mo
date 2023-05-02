import { describe; it; Suite } = "mo:testing/Suite";
import RecoveryId "mo:libsecp256k1/RecoveryId";
import Address "../../src/Address";
import AU "../../src/utils/ArrayUtils";
import Result "mo:base/Result";
import Error "mo:base/Error";
import Consts "../consts/pre_g";

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
        it("invalid (empty)", func (): Bool {
            let expected = #err("Invalid length of public key");
            let response = Address.fromPublicKey(AU.fromText(""));
            response == expected
        }),
    ]),
]);

