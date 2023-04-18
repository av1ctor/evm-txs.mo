import Buffer "mo:base/Buffer";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Char "mo:base/Char";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Error "mo:base/Error";
import libsecp256k1 "mo:libsecp256k1";
import SHA3 "mo:sha3";
import Nat "mo:base/Nat";

module {
    public func getAddressFromPublicKey(
        pub_key_arr: [Nat8]
    ): Result.Result<Text, Text> {
        if(pub_key_arr.size() != 33) {
            return #err("Invalid length of public key");
        };

        let p = switch(libsecp256k1.parse_compressed(pub_key_arr)) {
            case (#err(e)) {
                return #err("Invalid public key");
            };
            case (#ok(p)) {
                let keccak256_hex = nat8ArrayToHexText(calcKeccak(_arrayRight(p.serialize(), 1), 256));
                let address: Text = "0x" # _textRight(keccak256_hex, 24);

                return #ok(address);
            };
        };
    };

    func _arrayRight<T>(
        arr: [T],
        offset: Nat
    ): [T] {
        let elms = arr.size() - offset;
        let res = Buffer.Buffer<T>(elms);

        var i = 0;
        while(i < elms) {
            res.add(arr[offset + i]);
            i += 1;
        };

        return Buffer.toArray(res);
    };

    func _textSubstring(
        arr: [Char], 
        start: Nat, 
        end: Nat
    ): [Char] {
        if(start <= end) {
            Array.tabulate(end - start + 1, func (i: Nat): Char = arr[start+i]);
        }
        else {
            [];
        };
    };

    func _textRight(
        text: Text,
        offset: Nat
    ): Text {
        let arr = _textToCharArray(text);
        let chars = _textSubstring(arr, offset, arr.size() - 1);
        return _charArrayToText(chars);
    };

    func _textToCharArray(
        text: Text
    ): [Char] {
        Iter.toArray(Text.toIter(text));
    };

    func _charArrayToText(
        text: [Char] 
    ): Text {
        Text.fromIter(text.vals());
    };

    public func calcKeccak(
        val: [Nat8],
        bits: Nat
    ): [Nat8] {
        let hash = SHA3.Keccak(bits);
        hash.update(val);
        return hash.finalize();
    };

    public func nat64ToNat8Array(
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

    let ZERO_CHAR = 48: Nat32;
    let A_UC_CHAR=  65: Nat32;
    let A_LC_CHAR = 97: Nat32;

    func _hexCharToNat32(
        char: Char
    ): Nat32 {
        let c = Char.toNat32(char);
        if(c >= A_LC_CHAR) {
            return c -% A_LC_CHAR +% 10;
        }
        else if(c >= A_UC_CHAR) {
            return c -% A_UC_CHAR +% 10;
        }
        else {
            return c -% ZERO_CHAR;
        };
    };

    func _nat32ToHexChar(
        val: Nat32
    ): Char {
        if(val < 10) {
            return Char.fromNat32(ZERO_CHAR + val);
        }
        else {
            return Char.fromNat32(A_LC_CHAR + (val - 10));
        };
    };

    public func hexTextToNat8Array(
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
            let ms = _hexCharToNat32(str[i]);
            let ls = _hexCharToNat32(str[i+1]);
            res.add(Nat8.fromNat(Nat32.toNat((ms << 4) | ls)));
            i += 2;
        };

        return Buffer.toArray(res);
    };

    public func nat8ArrayToNat64(
        arr: [Nat8]
    ): Nat64 {
        var res: Nat64 = 0;

        for(byte in arr.vals()) {
            res := (res << 8) | Nat64.fromNat(Nat8.toNat(byte));
        };

        return res;
    };

    public func nat8ArrayToHexText(
        arr: [Nat8]
    ): Text {
        var res = "";

        for(byte in arr.vals()) {
            let b = Nat32.fromNat(Nat8.toNat(byte));
            let ms = (b & 0xf0) >> 4;
            let ls = b & 0x0f;
            res #= Char.toText(_nat32ToHexChar(ms));
            res #= Char.toText(_nat32ToHexChar(ls));
        };

        return res;
    };
};