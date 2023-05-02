module {
    public type TransactionType = {
        #Legacy: ?TransactionLegacy;
        #EIP1559: ?Transaction1559;
        #EIP2930: ?Transaction2930;
    };

    public type TransactionBase = {
        chainId: Nat64;
        nonce: Nat64;
        gasLimit: Nat64;
        to: Text;
        value: Nat64;
        data: Text;
        v: Text;
        r: Text;
        s: Text;
    };
    
    public type TransactionLegacy = TransactionBase and {
        gasPrice: Nat64;
    };

    public type Transaction2930 = TransactionBase and {
        gasPrice: Nat64;
        accessList: [(Text, [Text])];
    };

    public type Transaction1559 = TransactionBase and {
        maxPriorityFeePerGas: Nat64;
        maxFeePerGas: Nat64;
        accessList: [(Text, [Text])];
    };
}