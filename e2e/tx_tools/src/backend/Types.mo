module {
    public type CreateAddressResponse = {
        address: Text;
    };
    
    public type SignTransactionResponse = {
        sign_tx: [Nat8];
    };
    
    public type DeployEVMContractResponse = {
        tx: [Nat8];
    };
    
    public type UserResponse = {
        address: Text;
        //transactions: TransactionChainData;
    };
}