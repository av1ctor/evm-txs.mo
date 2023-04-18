import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";

module {
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
};