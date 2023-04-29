let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }

let packages = [
    { name = "base", 
      repo = "https://github.com/dfinity/motoko-base", 
      version = "f8112331eb94dcea41741e59c7e2eaf367721866", 
      dependencies = [] : List Text
    },
    { 
      name = "sha3", 
      repo = "https://github.com/hanbu97/motoko-sha3", 
      version = "v0.1.1", 
      dependencies = [] : List Text
    },
    { 
      name = "rlp", 
      repo = "https://github.com/relaxed04/rlp-motoko", 
      version = "master", 
      dependencies = [] : List Text
    },
    { 
      name = "libsecp256k1", 
      repo = "https://github.com/av1ctor/mo-libsecp256k1", 
      version = "main", 
      dependencies = ["base"]
    },
    { 
        name = "testing", 
        version = "main", 
        repo = "https://github.com/av1ctor/testing.mo",
        dependencies = [] : List Text
    }
] : List Package

let overrides = [
] : List Package

in  packages # overrides