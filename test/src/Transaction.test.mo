import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Helper "../../src/transactions/Helper";
import Utils "../../src/utils/Utils";

let context = Helper.allocContext();

//
// getRecoveryId
//
let getRecoveryId = S.suite("getRecoveryId", [
    S.test("valid",
      do {
        let pubkey = Utils.textToArray("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1");
        let signature = Utils.textToArray("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
        let message = Utils.textToArray("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
        Helper.getRecoveryId(message, signature, pubkey, context)
      },
      M.equals(T.result<Nat8, Text>(T.nat8(0), T.text(""), #ok(0: Nat8)))
    ),
    S.test("invalid signature",
      do {
        let pubkey = Utils.textToArray("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1");
        let signature = Utils.textToArray("");
        let message = Utils.textToArray("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
        Helper.getRecoveryId(message, signature, pubkey, context)
      },
      M.equals(T.result<Nat8, Text>(T.nat8(0), T.text(""), #err("Invalid signature")))
    ),
    S.test("invalid message",
      do {
        let pubkey = Utils.textToArray("02c397f23149d3464517d57b7cdc8e287428407f9beabfac731e7c24d536266cd1");
        let signature = Utils.textToArray("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
        let message = Utils.textToArray("");
        Helper.getRecoveryId(message, signature, pubkey, context)
      },
      M.equals(T.result<Nat8, Text>(T.nat8(0), T.text(""), #err("Invalid message")))
    ),
    S.test("invalid public key",
      do {
        let pubkey = Utils.textToArray("");
        let signature = Utils.textToArray("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
        let message = Utils.textToArray("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
        Helper.getRecoveryId(message, signature, pubkey, context)
      },
      M.equals(T.result<Nat8, Text>(T.nat8(0), T.text(""), #err("Invalid public key")))
    ),
]);

S.run(getRecoveryId);

//
// encodeAccessList
//
let encodeAccessList = S.suite("encodeAccessList", [
    S.test("valid",
      do {
        let address_1 = "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae";
        let storage_keys_1 = [
            "0x0000000000000000000000000000000000000000000000000000000000000003",
            "0x0000000000000000000000000000000000000000000000000000000000000007",
        ];

        let address_2 = "0xbb9bc244d798123fde783fcc1c72d3bb8c189413";
        let storage_keys_2 = [];

        let access_list = [(address_1, storage_keys_1), (address_2, storage_keys_2)];
        Utils.arrayToText(Helper.encodeAccessList(access_list))
      },
      M.equals(T.text("f872f85994de0b295669a9fd93d5f28d9ec85e40f4cb697baef842a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000007d694bb9bc244d798123fde783fcc1c72d3bb8c189413c0"))
    ),
]);

S.run(encodeAccessList);

//
// decodeAccessList
//
let decodeAccessList = S.suite("decodeAccessList", [
    S.test("valid",
      do {
        let access_list = "f872f85994de0b295669a9fd93d5f28d9ec85e40f4cb697baef842a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000007d694bb9bc244d798123fde783fcc1c72d3bb8c189413c0";
        Helper.decodeAccessList(Utils.textToArray(access_list))
      },
      M.equals(T.array<(Text, [Text])>(T.tuple2<Text, [Text]>(T.text(""), T.array<Text>(T.text(""), []), ("", [])), [
        (
          "de0b295669a9fd93d5f28d9ec85e40f4cb697bae",
          [
            "0000000000000000000000000000000000000000000000000000000000000003",
            "0000000000000000000000000000000000000000000000000000000000000007",
          ],
        ),
        (
          "bb9bc244d798123fde783fcc1c72d3bb8c189413",
          [],
        ),
      ]))
    ),
]);

S.run(decodeAccessList);