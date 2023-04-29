module {
    public type API = {
        create: (keyName: Text, derivationPath: [Blob]) -> async* Blob; 
        sign: (keyName: Text, derivationPath: [Blob], messageHash: Blob) -> async* Blob; 
    };
};