import Text "mo:base/Text";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Char "mo:base/Char";
import Int "mo:base/Int";
import Blob "mo:base/Blob";

module TextUtils {
    let ZERO_CHAR = 48: Nat32;
    let A_UC_CHAR=  65: Nat32;
    let A_LC_CHAR = 97: Nat32;

    public func hexCharToNat32(
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

    public func nat32ToHexChar(
        val: Nat32
    ): Char {
        if(val < 10) {
            return Char.fromNat32(ZERO_CHAR + val);
        }
        else {
            return Char.fromNat32(A_LC_CHAR + (val - 10));
        };
    };

    public func encodeUtf8(
        text: Text
    ): [Nat8] {
        return Blob.toArray(Text.encodeUtf8(text));
    };

    public func fill(
        text: Text,
        value: Char,
        chars: Nat
    ): Text {
        if(text.size() >= chars) {
            return text;
        };

        let src = _textToCharArray(text);
        let offset = Nat.sub(chars, src.size());
        var res = Array.init<Char>(chars, value);
        for(i in Iter.range(0, src.size()-1)) {
            res[offset + i] := src[i];
        };

        return _varCharArrayToText(res);
    };

    public func substring(
        arr: [Char], 
        start: Nat, 
        end: Nat
    ): [Char] {
        if(start <= end) {
            Array.tabulate(Nat.sub(end, start) + 1, func (i: Nat): Char = arr[start+i]);
        }
        else {
            [];
        };
    };

    public func left(
        text: Text,
        offset: Nat
    ): Text {
        let arr = _textToCharArray(text);
        let chars = substring(arr, 0, offset);
        return _charArrayToText(chars);
    };

    public func right(
        text: Text,
        offset: Nat
    ): Text {
        let arr = _textToCharArray(text);
        let chars = substring(arr, offset, arr.size() - 1);
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

    func _varCharArrayToText(
        text: [var Char] 
    ): Text {
        Text.fromIter(text.vals());
    };
};