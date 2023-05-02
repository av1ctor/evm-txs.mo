import { describe; it; Suite } = "mo:testing/Suite";
import HU "../../src/utils/HashUtils";
import AU "../../src/utils/ArrayUtils";
import Transfer "../../src/Transfer";
import Debug "mo:base/Debug";

let s = Suite();

await* s.run([
    describe("nat64ToArray", [
        it("0xdeadbeef=[0xde, 0xad, 0xbe, 0xef]", func (): Bool {
            let expected = [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8];
            let response = AU.fromNat64(0xdeadbeef);
            response == expected
        }),
        it("0xdeadbeefdeadc0de=[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde]", func (): Bool {
            let expected = [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8];
            let response = AU.fromNat64(0xdeadbeefdeadc0de);
            response == expected
        }),
    ]),
    describe("textToArray", [
        it("'deadbeef'=[0xde, 0xad, 0xbe, 0xef]", func (): Bool {
            let expected = [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8];
            let response = AU.fromText("deadbeef");
            response == expected
        }),
        it("'0xdeadbeefdeadc0de'=[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde]", func (): Bool {
            let expected = [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8];
            let response = AU.fromText("0xdeadbeefdeadc0de");
            response == expected
        }),
    ]),
    describe("arrayToNat64", [
        it("[0xde, 0xad, 0xbe, 0xef] = 0xdeadbeef", func (): Bool {
            let expected = 0xdeadbeef: Nat64;
            let response = AU.toNat64([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]);
            response == expected
        }),
        it("[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde] = 0xdeadbeefdeadc0de", func (): Bool {
            let expected = 0xdeadbeefdeadc0de: Nat64;
            let response = AU.toNat64([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]);
            response == expected
        }),
    ]),
    describe("arrayToText", [
        it("[0xde, 0xad, 0xbe, 0xef] = 'deadbeef'", func (): Bool {
            let expected = "deadbeef";
            let response = AU.toText([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]);
            response == expected
        }),
        it("[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde] = 'deadbeefdeadc0de'", func (): Bool {
            let expected = "deadbeefdeadc0de";
            let response = AU.toText([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]);
            response == expected
        }),
    ]),
    describe("getTransferERC20Data", [
        it("valid", func (): Bool {
            let expected = #ok("a9059cbb000000000000000000000000907dc4d0be5d691970cae886fcab34ed65a2cd660000000000000000000000000000000000000000000000000000000000000001");
            let response = Transfer.getTransferERC20Data("0x907dc4d0be5d691970cae886fcab34ed65a2cd66", 1);
            response == expected
        }),
        it("invalid", func (): Bool {
            let expected = #err("Invalid address");
            let response = Transfer.getTransferERC20Data("0x00", 1);
            response == expected
        }),
    ]),
]);
