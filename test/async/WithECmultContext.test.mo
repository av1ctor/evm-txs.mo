import { describe; it; its; Suite } = "mo:testing/Suite";
import Principal "mo:base/Principal";
import Address "../../src/Address";
import Helper "../../src/transactions/Helper";
import Legacy "../../src/transactions/Legacy";
import EIP2930 "../../src/transactions/EIP2930";
import EIP1559 "../../src/transactions/EIP1559";
import HU "../../src/utils/HashUtils";
import AU "../../src/utils/ArrayUtils";
import TestContext "../TestContext";
import IcEcdsaApi "../mocks/IcEcdsaApi";
import Random "../mocks/Random";
import Types "../../src/Types";
import Transaction "../../src/Transaction";
import Debug "mo:base/Debug";

let testContext = TestContext.Context();
let icEcdsaApi = IcEcdsaApi.IcEcdsaApiMock(testContext.ecGenCtx, Random.RandomMock());

let s = Suite();

await* s.run([
    describe("Address.create", [
        its("valid", func (): async* Bool {
            let principal_id = Principal.toBlob(Principal.fromText("aaaaa-aa"));
            switch(await* Address.create("", [principal_id], icEcdsaApi)) {
                case (#ok(res)) {
                    res.0.size() == 42
                };
                case _ {
                    false
                };
            };
        }),
    ]),
    describe("Transaction.Legacy", [
        its("valid", func(): async* Bool {
            let expected_get_signature_before = #err("This is not a signed transaction");
            let expected_get_signature_after ="6d6caac248af96f6afa7f904f550253a0f3ef3f5aa2fe6838a95b216691468e232a67dc633abe18faaa655f07724d662f14bc160943ac3b9538be5b23aac4670";
            let expected_get_recovery_id_before = #err("This is not a signed transaction");
            let expected_get_recovery_id_after = 0: Nat8;
            let expected_get_message_to_sign_after = "eb86127620fbc047c6b6c2fcedea010143538e452dc7cb67a7fb1f8a00abdbd9";
            let expected_address = "0x907dc4d0be5d691970cae886fcab34ed65a2cd66";

            let tx: Types.TransactionLegacy = {
                nonce = 0;
                gasPrice = 0;
                gasLimit = 0;
                to = "0x0000000000000000000000000000000000000000";
                value = 0;
                data = "0x00";
                chainId = 1;
                v = "0x00";
                r = "0x00";
                s = "0x00";
            };
            
            if(not (Legacy.isSigned(tx) == false)) {
                Debug.print("Legacy.isSigned 1");
                return false;
            };

            if(not (Legacy.getSignature(tx) == expected_get_signature_before)) {
                Debug.print("Legacy.getSignature 1");
                return false;
            };

            if(not (Legacy.getRecoveryId(tx) == expected_get_recovery_id_before)) {
                Debug.print("Legacy.getRecoveryId 1");
                return false;
            };

            let text = "aaaaa-aa";
            let principal_id = Principal.toBlob(Principal.fromText("aaaaa-aa"));

            let (res_create, publicKey) = switch(await* Address.create("", [principal_id], icEcdsaApi)) {
                case (#ok(res)) {
                    (AU.fromText(res.0), res.1)
                };
                case (#err(msg)) {
                    Debug.print("Address.create: " # msg);
                    return false;
                };
            };

            switch(Legacy.serialize(tx)) {
                case (#err(msg)) {
                    Debug.print("Legacy.serialize: " # msg);
                    return false;
                };
                case (#ok(raw_tx)) {
                    let chain_id: Nat64 = 1;
                    switch(await* Transaction.signRawTx(
                        raw_tx, chain_id, "", [principal_id], publicKey, testContext.ecCtx, icEcdsaApi)) {
                        case (#err(msg)) {
                            Debug.print("Transaction.signRawTx: " # msg);
                            return false;
                        };
                        case (#ok(res_sign_)) {
                            let res_sign = switch(res_sign_.0) {
                                case (#Legacy(?sign)) {
                                    switch(Transaction.serialize(#Legacy(?sign))) {
                                        case (#ok(ser)) {
                                            ser;
                                        };
                                        case _ {
                                            Debug.print("Transaction.serialize");
                                            return false;
                                        };
                                    };
                                };
                                case _ {
                                    Debug.print("Not legacy");
                                    return false;
                                };
                            };

                            switch(Legacy.from(res_sign, chain_id)) {
                                case (#err(_)) {
                                    Debug.print("Legacy.from");
                                    return false;
                                };
                                case (#ok(tx_signed)) {
                                    if(not (Legacy.isSigned(tx_signed) == true)) {
                                        Debug.print("Legacy.isSigned 2");
                                        return false;
                                    };

                                    switch(Legacy.getSignature(tx_signed)) {
                                        case (#err(_)) {
                                            Debug.print("Legacy.getSignature");
                                            return false;
                                        };
                                        case (#ok(signature)) {
                                            if(not (AU.toText(signature) == expected_get_signature_after)) {
                                                Debug.print("signature != expected_get_signature_after");
                                                return false;
                                            };

                                            switch(Legacy.getMessageToSign(tx_signed)) {
                                                case (#err(_)) {
                                                    Debug.print("Legacy.getMessageToSign");
                                                    return false;
                                                };
                                                case (#ok(msg)) {
                                                    if(not (AU.toText(msg) == expected_get_message_to_sign_after)) {
                                                        Debug.print("msg != expected_get_message_to_sign_after");
                                                        return false;
                                                    };

                                                    switch(Legacy.getRecoveryId(tx_signed)) {
                                                        case (#err(_)) {
                                                            Debug.print("Legacy.getRecoveryId");
                                                            return false;
                                                        };
                                                        case (#ok(recovery_id)) {
                                                            if(not (recovery_id == expected_get_recovery_id_after)) {
                                                                Debug.print("recovery_id != expected_get_recovery_id_after");
                                                                return false;
                                                            };

                                                            switch(Address.recover(signature, recovery_id, msg, testContext.ecCtx)) {
                                                                case (#err(_)) {
                                                                    Debug.print("Address.recover");
                                                                    return false;
                                                                };
                                                                case (#ok(address)) {
                                                                    assert(address == expected_address);
                                                                    res_create == AU.fromText(address)
                                                                };
                                                            };
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }),
    ]),
    describe("Transaction.EIP2930", [
        its("valid", func(): async* Bool {
            let expected_get_signature_before = #err("This is not a signed transaction");
            let expected_get_signature_after ="6d6caac248af96f6afa7f904f550253a0f3ef3f5aa2fe6838a95b216691468e25eb9c820ac0061ba3afb6bda2fbee923f1cc638a8f35ffa141565d2445a4e7da";
            let expected_get_recovery_id_before = #err("This is not a signed transaction");
            let expected_get_recovery_id_after = 0: Nat8;
            let expected_get_message_to_sign_after = "1db9b0174e2b28a2073c88acbc792a5445407c5a8bf7bc5c65a047d45885eb89";
            let expected_address = "0x907dc4d0be5d691970cae886fcab34ed65a2cd66";

            let tx: Types.Transaction2930 = {
                chainId = 1;
                nonce = 0;
                gasPrice = 0;
                gasLimit = 0;
                to = "0x0000000000000000000000000000000000000000";
                value = 0;
                data = "0x00";
                accessList = [];
                v = "0x00";
                r = "0x00";
                s = "0x00";
            };
            
            if(not (EIP2930.isSigned(tx) == false)) {
                Debug.print("EIP2930.isSigned 1");
                return false;
            };

            if(not (EIP2930.getSignature(tx) == expected_get_signature_before)) {
                Debug.print("EIP2930.getSignature 1");
                return false;
            };

            if(not (EIP2930.getRecoveryId(tx) == expected_get_recovery_id_before)) {
                Debug.print("EIP2930.getRecoveryId 1");
                return false;
            };

            let text = "aaaaa-aa";
            let principal_id = Principal.toBlob(Principal.fromText("aaaaa-aa"));

            let (res_create, publicKey) = switch(await* Address.create("", [principal_id], icEcdsaApi)) {
                case (#ok(res)) {
                    (AU.fromText(res.0), res.1)
                };
                case (#err(msg)) {
                    Debug.print("Address.create: " # msg);
                    return false;
                };
            };

            switch(EIP2930.serialize(tx)) {
                case (#err(msg)) {
                    Debug.print("EIP2930.serialize: " # msg);
                    return false;
                };
                case (#ok(raw_tx)) {
                    let chain_id: Nat64 = 1;
                    switch(await* Transaction.signRawTx(
                        raw_tx, chain_id, "", [principal_id], publicKey, testContext.ecCtx, icEcdsaApi)) {
                        case (#err(msg)) {
                            Debug.print("Transaction.signRawTx: " # msg);
                            return false;
                        };
                        case (#ok(res_sign_)) {
                            let res_sign = switch(res_sign_.0) {
                                case (#EIP2930(?sign)) {
                                    switch(Transaction.serialize(#EIP2930(?sign))) {
                                        case (#ok(ser)) {
                                            ser;
                                        };
                                        case _ {
                                            Debug.print("Transaction.serialize");
                                            return false;
                                        };
                                    };
                                };
                                case _ {
                                    Debug.print("Not EIP2930");
                                    return false;
                                };
                            };

                            switch(EIP2930.from(res_sign)) {
                                case (#err(_)) {
                                    Debug.print("EIP2930.from");
                                    return false;
                                };
                                case (#ok(tx_signed)) {
                                    if(not (EIP2930.isSigned(tx_signed) == true)) {
                                        Debug.print("EIP2930.isSigned 2");
                                        return false;
                                    };

                                    switch(EIP2930.getSignature(tx_signed)) {
                                        case (#err(_)) {
                                            Debug.print("EIP2930.getSignature");
                                            return false;
                                        };
                                        case (#ok(signature)) {
                                            if(not (AU.toText(signature) == expected_get_signature_after)) {
                                                Debug.print("signature != expected_get_signature_after");
                                                return false;
                                            };

                                            switch(EIP2930.getMessageToSign(tx_signed)) {
                                                case (#err(_)) {
                                                    Debug.print("EIP2930.getMessageToSign");
                                                    return false;
                                                };
                                                case (#ok(msg)) {
                                                    if(not (AU.toText(msg) == expected_get_message_to_sign_after)) {
                                                        Debug.print("msg != expected_get_message_to_sign_after");
                                                        return false;
                                                    };

                                                    switch(EIP2930.getRecoveryId(tx_signed)) {
                                                        case (#err(_)) {
                                                            Debug.print("EIP2930.getRecoveryId");
                                                            return false;
                                                        };
                                                        case (#ok(recovery_id)) {
                                                            if(not (recovery_id == expected_get_recovery_id_after)) {
                                                                Debug.print("recovery_id != expected_get_recovery_id_after");
                                                                return false;
                                                            };

                                                            switch(Address.recover(signature, recovery_id, msg, testContext.ecCtx)) {
                                                                case (#err(_)) {
                                                                    Debug.print("Address.recover");
                                                                    return false;
                                                                };
                                                                case (#ok(address)) {
                                                                    assert(address == expected_address);
                                                                    res_create == AU.fromText(address)
                                                                };
                                                            };
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }),
    ]),
    describe("Transaction.EIP1559", [
        its("valid", func(): async* Bool {
            let expected_get_signature_before = #err("This is not a signed transaction");
            let expected_get_signature_after ="6d6caac248af96f6afa7f904f550253a0f3ef3f5aa2fe6838a95b216691468e2225999ff0631028ab5231372637c7b44efa01c0c96db73f68606a0484cd9502b";
            let expected_get_recovery_id_before = #err("This is not a signed transaction");
            let expected_get_recovery_id_after = 0: Nat8;
            let expected_get_message_to_sign_after = "79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1";
            let expected_address = "0x907dc4d0be5d691970cae886fcab34ed65a2cd66";

            let tx: Types.Transaction1559 = {
                chainId = 1;
                nonce = 0;
                maxPriorityFeePerGas = 0;
                gasLimit = 0;
                maxFeePerGas = 0;
                to = "0x0000000000000000000000000000000000000000";
                value = 0;
                data = "0x00";
                accessList = [];
                v = "0x00";
                r = "0x00";
                s = "0x00";
            };
            
            if(not (EIP1559.isSigned(tx) == false)) {
                Debug.print("EIP1559.isSigned 1");
                return false;
            };

            if(not (EIP1559.getSignature(tx) == expected_get_signature_before)) {
                Debug.print("EIP1559.getSignature 1");
                return false;
            };

            if(not (EIP1559.getRecoveryId(tx) == expected_get_recovery_id_before)) {
                Debug.print("EIP1559.getRecoveryId 1");
                return false;
            };

            let text = "aaaaa-aa";
            let principal_id = Principal.toBlob(Principal.fromText("aaaaa-aa"));

            let (res_create, publicKey) = switch(await* Address.create("", [principal_id], icEcdsaApi)) {
                case (#ok(res)) {
                    (AU.fromText(res.0), res.1)
                };
                case (#err(msg)) {
                    Debug.print("Address.create: " # msg);
                    return false;
                };
            };

            switch(EIP1559.serialize(tx)) {
                case (#err(msg)) {
                    Debug.print("EIP1559.serialize: " # msg);
                    return false;
                };
                case (#ok(raw_tx)) {
                    let chain_id: Nat64 = 1;
                    switch(await* Transaction.signRawTx(
                        raw_tx, chain_id, "", [principal_id], publicKey, testContext.ecCtx, icEcdsaApi)) {
                        case (#err(msg)) {
                            Debug.print("Transaction.signRawTx: " # msg);
                            return false;
                        };
                        case (#ok(res_sign_)) {
                            let res_sign = switch(res_sign_.0) {
                                case (#EIP1559(?sign)) {
                                    switch(Transaction.serialize(#EIP1559(?sign))) {
                                        case (#ok(ser)) {
                                            ser;
                                        };
                                        case _ {
                                            Debug.print("Transaction.serialize");
                                            return false;
                                        };
                                    };
                                };
                                case _ {
                                    Debug.print("Not EIP1559");
                                    return false;
                                };
                            };

                            switch(EIP1559.from(res_sign)) {
                                case (#err(_)) {
                                    Debug.print("v.from");
                                    return false;
                                };
                                case (#ok(tx_signed)) {
                                    if(not (EIP1559.isSigned(tx_signed) == true)) {
                                        Debug.print("EIP1559.isSigned 2");
                                        return false;
                                    };

                                    switch(EIP1559.getSignature(tx_signed)) {
                                        case (#err(_)) {
                                            Debug.print("EIP1559.getSignature");
                                            return false;
                                        };
                                        case (#ok(signature)) {
                                            if(not (AU.toText(signature) == expected_get_signature_after)) {
                                                Debug.print("signature != expected_get_signature_after");
                                                return false;
                                            };

                                            switch(EIP1559.getMessageToSign(tx_signed)) {
                                                case (#err(_)) {
                                                    Debug.print("EIP1559.getMessageToSign");
                                                    return false;
                                                };
                                                case (#ok(msg)) {
                                                    if(not (AU.toText(msg) == expected_get_message_to_sign_after)) {
                                                        Debug.print("msg != expected_get_message_to_sign_after");
                                                        return false;
                                                    };

                                                    switch(EIP1559.getRecoveryId(tx_signed)) {
                                                        case (#err(_)) {
                                                            Debug.print("EIP1559.getRecoveryId");
                                                            return false;
                                                        };
                                                        case (#ok(recovery_id)) {
                                                            if(not (recovery_id == expected_get_recovery_id_after)) {
                                                                Debug.print("recovery_id != expected_get_recovery_id_after");
                                                                return false;
                                                            };

                                                            switch(Address.recover(signature, recovery_id, msg, testContext.ecCtx)) {
                                                                case (#err(_)) {
                                                                    Debug.print("Address.recover");
                                                                    return false;
                                                                };
                                                                case (#ok(address)) {
                                                                    assert(address == expected_address);
                                                                    res_create == AU.fromText(address)
                                                                };
                                                            };
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }),
    ]),
    describe("Address.recover", [
        it("valid", func (): Bool {
            let expected = #ok("0x907dc4d0be5d691970cae886fcab34ed65a2cd66");
            let signature = AU.fromText("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
            let recovery_id = 0: Nat8;
            let message = AU.fromText("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
            let response = Address.recover(signature, recovery_id, message, testContext.ecCtx);
            response == expected
        }),
        it("invalid signature", func (): Bool {
            let expected = #err("Invalid signature");
            let signature = AU.fromText("");
            let recovery_id = 0: Nat8;
            let message = AU.fromText("79965df63d7d9364f4bc8ed54ffd1c267042d4db673e129e3c459afbcb73a6f1");
            let response = Address.recover(signature, recovery_id, message, testContext.ecCtx);
            response == expected
        }),
        it("invalid message", func (): Bool {
            let expected = #err("Invalid message");
            let signature = AU.fromText("29edd4e1d65e1b778b464112d2febc6e97bb677aba5034408fd27b49921beca94c4e5b904d58553bcd9c788360e0bd55c513922cf1f33a6386033e886cd4f77f");
            let recovery_id = 0: Nat8;
            let message = AU.fromText("");
            let response = Address.recover(signature, recovery_id, message, testContext.ecCtx);
            response == expected
        }),
    ]),
]);