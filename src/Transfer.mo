import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Ecmult "mo:libsecp256k1/core/ecmult";
import Transaction "Transaction";
import Types "Types";
import Address "Address";
import HU "utils/HashUtils";
import AU "utils/ArrayUtils";
import TU "utils/TextUtils";
import EcdsaApi "interfaces/EcdsaApi";

module {
    public func getTransferERC20Data(
        address: Text, 
        amount: Nat64
    ): Result.Result<Text, Text> {
        if(address.size() != 42) {
            return #err("Invalid address");
        };
        
        let method_sig = "transfer(address,uint256)";
        let keccak256_hex = AU.toText(HU.keccak(TU.encodeUtf8(method_sig), 256));
        let method_id = TU.left(keccak256_hex, 7);

        let address_64 = TU.fill(TU.right(address, 2), '0', 64);

        let amount_hex = AU.toText(AU.fromNat64(amount));
        let amount_64 = TU.fill(amount_hex, '0', 64);

        return #ok(method_id # address_64 # amount_64);
    };

    public func signTransferERC20(
        address: Text,
        value: Nat64,
        contractAddress: Text,
        maxPriorityFeePerGas: Nat64,
        gasLimit: Nat64,
        maxFeePerGas: Nat64,
        chainId: Nat64,
        keyName: Text,
        derivationPath: [Blob],
        publicKey: [Nat8],
        nonce: Nat64,
        ctx: Ecmult.ECMultContext,
        api: EcdsaApi.API
    ): async* Result.Result<(Types.TransactionType, [Nat8]), Text> {
        switch(getTransferERC20Data(address, value)) {
            case (#err(msg)) {
                return #err(msg);
            };
            case (#ok(data)) {
                let tx: Types.Transaction1559 = {
                    nonce;
                    chainId;
                    maxPriorityFeePerGas;
                    maxFeePerGas;
                    gasLimit;
                    to = contractAddress;
                    value = 0;
                    data = "0x" # data;
                    accessList = [];
                    v = "0x00";
                    r = "0x00";
                    s = "0x00";
                };
                switch(Transaction.serialize(#EIP1559(?tx))) {
                    case (#err(msg)) {
                        return #err(msg);
                    };
                    case (#ok(rawTx)) {
                        return await* Transaction.signRawTx(
                            rawTx, chainId, keyName, derivationPath, publicKey, ctx, api);
                    };
                };
            };
        };
    };
}