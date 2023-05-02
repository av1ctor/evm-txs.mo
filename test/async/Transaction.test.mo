import { describe; it; its; Suite } = "mo:testing/Suite";
import Helper "../../src/transactions/Helper";
import HU "../../src/utils/HashUtils";
import AU "../../src/utils/ArrayUtils";

let s = Suite();

await* s.run([
    describe("encodeAccessList", [
        it("valid", func (): Bool {
            let expected = "f872f85994de0b295669a9fd93d5f28d9ec85e40f4cb697baef842a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000007d694bb9bc244d798123fde783fcc1c72d3bb8c189413c0";
            let address_1 = "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae";
            let storage_keys_1 = [
                "0x0000000000000000000000000000000000000000000000000000000000000003",
                "0x0000000000000000000000000000000000000000000000000000000000000007",
            ];

            let address_2 = "0xbb9bc244d798123fde783fcc1c72d3bb8c189413";
            let storage_keys_2 = [];

            let access_list = [(address_1, storage_keys_1), (address_2, storage_keys_2)];
            let response = AU.toText(Helper.encodeAccessList(access_list));
            response == expected
        }),
    ]),
    describe("decodeAccessList", [
        it("valid", func (): Bool {
            let expected = [
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
            ];
            let access_list = "f872f85994de0b295669a9fd93d5f28d9ec85e40f4cb697baef842a00000000000000000000000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000007d694bb9bc244d798123fde783fcc1c72d3bb8c189413c0";
            let response = Helper.decodeAccessList(AU.fromText(access_list));
            response == expected
        }),
    ]),
]);
