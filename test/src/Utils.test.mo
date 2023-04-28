import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Utils "../../src/utils/Utils";
import Debug "mo:base/Debug";

//
// nat64ToArray
//
let nat64ToArray = S.suite("nat64ToArray", [
    S.test("0xdeadbeef=[0xde, 0xad, 0xbe, 0xef]",
      Utils.nat64ToArray(0xdeadbeef),
      M.equals(T.array(T.nat8(0), [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]))
    ),
    S.test("0xdeadbeefdeadc0de=[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde]",
      Utils.nat64ToArray(0xdeadbeefdeadc0de),
      M.equals(T.array(T.nat8(0), [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]))
    ),
]);

S.run(nat64ToArray);

//
// textToArray
//
let textToArray = S.suite("textToArray", [
    S.test("'deadbeef'=[0xde, 0xad, 0xbe, 0xef]",
      Utils.textToArray("deadbeef"),
      M.equals(T.array(T.nat8(0), [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]))
    ),
    S.test("'0xdeadbeefdeadc0de'=[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde]",
      Utils.textToArray("0xdeadbeefdeadc0de"),
      M.equals(T.array(T.nat8(0), [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]))
    ),
]);

S.run(textToArray);

//
// arrayToNat64
//
let arrayToNat64 = S.suite("arrayToNat64", [
    S.test("[0xde, 0xad, 0xbe, 0xef] = 0xdeadbeef",
      Utils.arrayToNat64([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]),
      M.equals(T.nat64(0xdeadbeef))
    ),
    S.test("[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde] = 0xdeadbeefdeadc0de",
      Utils.arrayToNat64([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]),
      M.equals(T.nat64(0xdeadbeefdeadc0de))
    ),
]);

S.run(arrayToNat64);

//
// arrayToText
//
let arrayToText = S.suite("arrayToText", [
    S.test("[0xde, 0xad, 0xbe, 0xef] = 'deadbeef'",
      Utils.arrayToText([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]),
      M.equals(T.text("deadbeef"))
    ),
    S.test("[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde] = 'deadbeefdeadc0de'",
      Utils.arrayToText([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]),
      M.equals(T.text("deadbeefdeadc0de"))
    ),
]);

S.run(arrayToText);


//
// getAddressFromPublicKey
//
let getAddressFromPublicKey = S.suite("getAddressFromPublicKey", [
    S.test("is valid",
      Utils.getAddressFromPublicKey(Utils.textToArray("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1")),
      M.equals(T.result<Text, Text>(T.text(""), T.text(""), #ok("0x907dc4d0be5d691970cae886fcab34ed65a2cd66")))
    ),
    S.test("is invalid (all zeros)",
      Utils.getAddressFromPublicKey(Utils.textToArray("000000000000000000000000000000000000000000000000000000000000000000")),
      M.equals(T.result<Text, Text>(T.text(""), T.text(""), #err("Invalid public key")))
    ),
    S.test("is invalid (empty)",
      Utils.getAddressFromPublicKey(Utils.textToArray("")),
      M.equals(T.result<Text, Text>(T.text(""), T.text(""), #err("Invalid length of public key")))
    ),
]);

S.run(getAddressFromPublicKey);


//
// getTransferData
//
let getTransferData = S.suite("getTransferData", [
    S.test("is valid",
      Utils.getTransferData("0x907dc4d0be5d691970cae886fcab34ed65a2cd66", 1),
      M.equals(T.result<Text, Text>(T.text(""), T.text(""), #ok("a9059cbb000000000000000000000000907dc4d0be5d691970cae886fcab34ed65a2cd660000000000000000000000000000000000000000000000000000000000000001")))
    ),
    S.test("is invalid",
      Utils.getTransferData("0x00", 1),
      M.equals(T.result<Text, Text>(T.text(""), T.text(""), #err("Invalid address")))
    ),
]);

S.run(getTransferData);
