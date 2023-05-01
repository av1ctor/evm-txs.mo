import Error "mo:base/Error";
module {
    public type createFn = (keyName: Text, derivationPath: [Blob]) -> async* Blob;
    public type signFn = (keyName: Text, derivationPath: [Blob], messageHash: Blob) -> async* Blob;

    public class API(
        _create: createFn,
        _sign: signFn,
    ) {
        public let create = _create;
        public let sign = _sign;
    };
};