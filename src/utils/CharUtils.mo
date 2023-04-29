import Char "mo:base/Char";

module {
    let ZERO_CHAR = 48: Nat32;
    let A_UC_CHAR=  65: Nat32;
    let A_LC_CHAR = 97: Nat32;

    public func toNat32(
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

    public func fromNat32(
        val: Nat32
    ): Char {
        if(val < 10) {
            return Char.fromNat32(ZERO_CHAR + val);
        }
        else {
            return Char.fromNat32(A_LC_CHAR + (val - 10));
        };
    };
}