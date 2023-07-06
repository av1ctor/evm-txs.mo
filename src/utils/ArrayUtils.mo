import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Char "mo:base/Char";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import CU "CharUtils";

module {
    public func fill<T>(
        arr: [T],
        size: Nat,
        default: T
    ): [T] {
        if(size <= arr.size()) {
            return arr;
        };

        let res = Array.tabulateVar<T>(size, func i = default);

        var i = 0;
        while(i < arr.size()) {
            res[i] := arr[i];
            i += 1;
        };

        return Array.freeze(res);
    };

    public func left<T>(
        arr: [T],
        offset: Nat
    ): [T] {
        let elms = offset + 1;
        let res = Buffer.Buffer<T>(elms);

        var i = 0;
        while(i < elms) {
            res.add(arr[i]);
            i += 1;
        };

        return Buffer.toArray(res);
    };

    public func right<T>(
        arr: [T],
        offset: Nat
    ): [T] {
        let elms = Nat.sub(arr.size(), offset);
        let res = Buffer.Buffer<T>(elms);

        var i = 0;
        while(i < elms) {
            res.add(arr[offset + i]);
            i += 1;
        };

        return Buffer.toArray(res);
    };

    public func slice<T>(
        arr: [T],
        offset: Nat,
        elms: Nat
    ): [T] {
        let res = Buffer.Buffer<T>(elms);

        var i = offset;
        while(i < offset + elms) {
            res.add(arr[i]);
            i += 1;
        };

        return Buffer.toArray(res);
    };

    public func stripLeft<T>(
        arr: [T],
        strip: (a: T) -> Bool
    ): [T] {
        var offset = 0;
        label L while(offset < arr.size()) {
            if(not strip(arr[offset])) {
                break L;
            };
        };
        
        let elms = Nat.sub(arr.size(), offset);
        let res = Buffer.Buffer<T>(elms);

        var i = 0;
        while(i < elms) {
            res.add(arr[offset + i]);
            i += 1;
        };

        return Buffer.toArray(res);
    };

    public func toNat64(
        arr: [Nat8]
    ): Nat64 {
        var res: Nat64 = 0;

        for(byte in arr.vals()) {
            res := (res << 8) | Nat64.fromNat(Nat8.toNat(byte));
        };

        return res;
    };

    public func toNat256(
        arr: [Nat8]
    ): Nat {
        var res: Nat = 0;
        for(byte in arr.vals()) {
            res := (res * 256) + Nat8.toNat(byte);
        };

        return res % (2**256);
    };

    public func fromNat64(
        value: Nat64
    ): [Nat8] {
        let res = Buffer.Buffer<Nat8>(8);
        
        // WebAssembly is little-endian and the evm is big-endian, so a conversion is needed
        var value64 = value;
        var hasLeading = false;
        var bytes = 0;
        while(bytes < 8 and (value64 > 0 or hasLeading)) {
            let byte = (value64 >> 56) & 0xff;
            value64 <<= 8;
            if(byte > 0 or hasLeading) {
                res.add(Nat8.fromNat(Nat64.toNat(byte)));
                hasLeading := true;
            };
            bytes += 1;
        };

        return Buffer.toArray(res);
    };

    public func fromNat256(
        value: Nat
    ): [Nat8] {
        let res = Buffer.Buffer<Nat8>(32);
        
        // WebAssembly is little-endian and the evm is big-endian, so a conversion is needed
        var value256 = value % (2**256);
        var hasLeading = false;
        var nibbles = 0;
        while(nibbles < 4 and (value256 > 0 or hasLeading)) {
            var value64 = Nat64.fromNat(value256 / (2**192));
            var bytes = 0;
            while(bytes < 8 and (value64 > 0 or hasLeading)) {
                let byte = (value64 >> 56) & 0xff;
                value64 <<= 8;
                if(byte > 0 or hasLeading) {
                    res.add(Nat8.fromNat(Nat64.toNat(byte)));
                    hasLeading := true;
                };
                bytes += 1;
            };

            value256 := (value256 * (2**64)) % (2**256);
            nibbles += 1;
        };

        return Buffer.toArray(res);
    };

    public func toText(
        arr: [Nat8]
    ): Text {
        var res = "";

        for(byte in arr.vals()) {
            let b = Nat32.fromNat(Nat8.toNat(byte));
            let ms = (b & 0xf0) >> 4;
            let ls = b & 0x0f;
            res #= Char.toText(CU.fromNat32(ms));
            res #= Char.toText(CU.fromNat32(ls));
        };

        return res;
    };

    public func fromText(
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
            let ms = CU.toNat32(str[i]);
            let ls = CU.toNat32(str[i+1]);
            res.add(Nat8.fromNat(Nat32.toNat((ms << 4) | ls)));
            i += 2;
        };

        return Buffer.toArray(res);
    };


};