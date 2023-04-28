import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Char "mo:base/Char";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Error "mo:base/Error";
import PublicKey "mo:libsecp256k1/PublicKey";
import SHA3 "mo:sha3";
import RlpTypes "mo:rlp/types";
import TU "./TextUtils";
import AU "./ArrayUtils";

module {
    public func getAddressFromPublicKey(
        publicKey: [Nat8]
    ): Result.Result<Text, Text> {
        if(publicKey.size() != 33) {
            return #err("Invalid length of public key");
        };

        let p = switch(PublicKey.parse_compressed(publicKey)) {
            case (#err(e)) {
                return #err("Invalid public key");
            };
            case (#ok(p)) {
                let keccak256_hex = arrayToText(calcKeccak(AU.right(p.serialize(), 1), 256));
                let address: Text = "0x" # TU.right(keccak256_hex, 24);

                return #ok(address);
            };
        };
    };

    public func getTransferData(
        address: Text, 
        amount: Nat64
    ): Result.Result<Text, Text> {
        if(address.size() != 42) {
            return #err("Invalid address");
        };
        
        let method_sig = "transfer(address,uint256)";
        let keccak256_hex = arrayToText(calcKeccak(TU.encodeUtf8(method_sig), 256));
        let method_id = TU.left(keccak256_hex, 7);

        let address_64 = TU.fill(TU.right(address, 2), '0', 64);

        let amount_hex = arrayToText(nat64ToArray(amount));
        let amount_64 = TU.fill(amount_hex, '0', 64);

        return #ok(method_id # address_64 # amount_64);
    };

    public func calcKeccak(
        val: [Nat8],
        bits: Nat
    ): [Nat8] {
        let hash = SHA3.Keccak(bits);
        hash.update(val);
        return hash.finalize();
    };

    public func nat64ToArray(
        value: Nat64
    ): [Nat8] {
        let res = Buffer.Buffer<Nat8>(8);
        
        // WebAssembly is little-endian and the evm is big-endian, so a conversion is needed
        var val = value;
        var hasLeading = false;
        while(val > 0) {
            let byte = (val >> 56) & 0xff;
            val <<= 8;
            if(hasLeading or byte != 0) {
                res.add(Nat8.fromNat(Nat64.toNat(byte)));
                hasLeading := true;
            };
        };

        return Buffer.toArray(res);
    };

    public func textToArray(
        value: Text
    ): [Nat8] {
        let res = Buffer.Buffer<Nat8>(32);

        let str = Iter.toArray(Text.toIter(value));
        let toSkip = if(str.size() >= 2 and str[0] == '0' and str[1] == 'x')
            2
        else
            0;

        var i = toSkip;
        while(i < str.size()) {
            let ms = TU.hexCharToNat32(str[i]);
            let ls = TU.hexCharToNat32(str[i+1]);
            res.add(Nat8.fromNat(Nat32.toNat((ms << 4) | ls)));
            i += 2;
        };

        return Buffer.toArray(res);
    };

    public func arrayToNat64(
        arr: [Nat8]
    ): Nat64 {
        var res: Nat64 = 0;

        for(byte in arr.vals()) {
            res := (res << 8) | Nat64.fromNat(Nat8.toNat(byte));
        };

        return res;
    };

    public func arrayToText(
        arr: [Nat8]
    ): Text {
        var res = "";

        for(byte in arr.vals()) {
            let b = Nat32.fromNat(Nat8.toNat(byte));
            let ms = (b & 0xf0) >> 4;
            let ls = b & 0x0f;
            res #= Char.toText(TU.nat32ToHexChar(ms));
            res #= Char.toText(TU.nat32ToHexChar(ls));
        };

        return res;
    };

    public func rlpGetAsValue(
        dec: RlpTypes.Decoded
    ): [Nat8] {
        switch(dec) {
            case (#Uint8Array(val)) {
                return Buffer.toArray(val);
            };
            case (#Nested(_)) {
                return [];
            };
        };
    };

    public func rlpGetAsNat64(
        dec: RlpTypes.Decoded
    ): Nat64 {
        return arrayToNat64(rlpGetAsValue(dec));
    };

    public func rlpGetAsText(
        dec: RlpTypes.Decoded
    ): Text {
        return arrayToText(rlpGetAsValue(dec));
    };

    public func rlpGetAsList(
        dec: RlpTypes.Decoded
    ): [[Nat8]] {
        switch(dec) {
            case (#Uint8Array(_)) {
                return [];
            };
            case (#Nested(list)) {
                let res = Buffer.Buffer<[Nat8]>(list.size());
                for(item in list.vals()) {
                    switch(item) {
                        case (#Uint8Array(val)) {
                            res.add(Buffer.toArray(val));
                        };
                        case (#Nested(_)) {
                        };
                    };
                };
                return Buffer.toArray(res);
            };
        };
    };
};