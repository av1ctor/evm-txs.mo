import SHA3 "mo:sha3";

module {
    public func keccak(
        val: [Nat8],
        bits: Nat
    ): [Nat8] {
        let hash = SHA3.Keccak(bits);
        hash.update(val);
        return hash.finalize();
    };
};