import Array "mo:base/Array";

import Nat8 "mo:base/Nat8";
import Iter "mo:base/Iter";
module {
    public class RandomMock() {
        let n = Array.tabulateVar<Nat8>(32, func i = Nat8.fromNat(i));
        public let next = func(): [Nat8] {
            for(i in Iter.range(0, 31)) {
                n[i] := n[i] ^ 1;
            };
            return Array.freeze(n);
        };
    };
}