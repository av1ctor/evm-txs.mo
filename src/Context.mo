import Ecmult "mo:libsecp256k1/core/ecmult";
import Group "mo:libsecp256k1/core/group";

module {
    public func allocECMultContext(
        pre_g: ?[Group.AffineStorage]
    ): Ecmult.ECMultContext {
        return Ecmult.ECMultContext(pre_g);
    };

    public func allocECMultGenContext(
        prec: ?[[Group.AffineStorage]]
    ): Ecmult.ECMultGenContext {
        return Ecmult.ECMultGenContext(prec);
    };
    
    public func loadPreG(
        pre_g: Blob
    ): [Group.AffineStorage] {
        return Ecmult.loadPreG(pre_g);
    };
    
    public func loadPrec(
        prec: Blob
    ): [[Group.AffineStorage]] {
        return Ecmult.loadPrec(prec);
    };
}