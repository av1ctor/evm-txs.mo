module {
    public type CreateAddressResponse = {
        address: Text;
    };
    
    public type SignTransactionResponse = {
        tx: [Nat8];
        tx_text: Text;
    };
    
    public type DeployEVMContractResponse = {
        tx: [Nat8];
        tx_text: Text;
    };
}