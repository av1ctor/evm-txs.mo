import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Utils "../../src/Utils";
import Debug "mo:base/Debug";

//
// nat64ToNat8Array
//
let nat64ToNat8Array = S.suite("nat64ToNat8Array", [
    S.test("0xdeadbeef=[0xde, 0xad, 0xbe, 0xef]",
      Utils.nat64ToNat8Array(0xdeadbeef),
      M.equals(T.array(T.nat8(0), [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]))
    ),
    S.test("0xdeadbeefdeadc0de=[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde]",
      Utils.nat64ToNat8Array(0xdeadbeefdeadc0de),
      M.equals(T.array(T.nat8(0), [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]))
    ),
]);

S.run(nat64ToNat8Array);

//
// hexTextToNat8Array
//
let hexTextToNat8Array = S.suite("hexTextToNat8Array", [
    S.test("'deadbeef'=[0xde, 0xad, 0xbe, 0xef]",
      Utils.hexTextToNat8Array("deadbeef"),
      M.equals(T.array(T.nat8(0), [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]))
    ),
    S.test("'0xdeadbeefdeadc0de'=[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde]",
      Utils.hexTextToNat8Array("0xdeadbeefdeadc0de"),
      M.equals(T.array(T.nat8(0), [0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]))
    ),
]);

S.run(hexTextToNat8Array);

//
// nat8ArrayToNat64
//
let nat8ArrayToNat64 = S.suite("nat8ArrayToNat64", [
    S.test("[0xde, 0xad, 0xbe, 0xef] = 0xdeadbeef",
      Utils.nat8ArrayToNat64([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]),
      M.equals(T.nat64(0xdeadbeef))
    ),
    S.test("[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde] = 0xdeadbeefdeadc0de",
      Utils.nat8ArrayToNat64([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]),
      M.equals(T.nat64(0xdeadbeefdeadc0de))
    ),
]);

S.run(nat8ArrayToNat64);

//
// nat8ArrayToHexText
//
let nat8ArrayToHexText = S.suite("nat8ArrayToHexText", [
    S.test("[0xde, 0xad, 0xbe, 0xef] = 'deadbeef'",
      Utils.nat8ArrayToHexText([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8]),
      M.equals(T.text("deadbeef"))
    ),
    S.test("[0xde, 0xad, 0xbe, 0xef, 0xde, 0xad, 0xc0, 0xde] = 'deadbeefdeadc0de'",
      Utils.nat8ArrayToHexText([0xde: Nat8, 0xad: Nat8, 0xbe: Nat8, 0xef: Nat8, 0xde: Nat8, 0xad: Nat8, 0xc0: Nat8, 0xde: Nat8]),
      M.equals(T.text("deadbeefdeadc0de"))
    ),
]);

S.run(nat8ArrayToHexText);


//
// getAddressFromPublicKey
//
let getAddressFromPublicKey = S.suite("getAddressFromPublicKey", [
    S.test("is valid",
      Utils.getAddressFromPublicKey(Utils.hexTextToNat8Array("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1")),
      M.equals(T.result<Text, Text>(T.text(""), T.text(""), #ok("0x907dc4d0be5d691970cae886fcab34ed65a2cd66")))
    ),
    S.test("is invalid (all zeros)",
      Utils.getAddressFromPublicKey(Utils.hexTextToNat8Array("000000000000000000000000000000000000000000000000000000000000000000")),
      M.equals(T.result<Text, Text>(T.text(""), T.text(""), #err("Invalid public key")))
    ),
    S.test("is invalid (empty)",
      Utils.getAddressFromPublicKey(Utils.hexTextToNat8Array("")),
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
