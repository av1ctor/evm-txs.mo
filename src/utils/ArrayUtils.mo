import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";

module {
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
};