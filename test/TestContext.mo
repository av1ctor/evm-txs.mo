import Ecmult "mo:libsecp256k1/core/ecmult";
import PreG "consts/pre_g";
import Prec "consts/prec";

module {
    public class Context() {
        public let ecGenCtx = Ecmult.ECMultGenContext(?Ecmult.loadPrec(Prec.prec));
        public let ecCtx = Ecmult.ECMultContext(?Ecmult.loadPreG(PreG.pre_g));
    };
}