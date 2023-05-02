import Ecmult "mo:libsecp256k1/core/ecmult";
import Group "mo:libsecp256k1/core/group";

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

    // alias
    public type ECMultContext = Ecmult.ECMultContext;
    public type ECMultGenContext = Ecmult.ECMultGenContext;
    public func loadPreG(pre_g: Blob): [Group.AffineStorage] = Ecmult.loadPreG(pre_g);
    public func loadPrec(prec: Blob): [[Group.AffineStorage]] = Ecmult.loadPrec(prec);
}