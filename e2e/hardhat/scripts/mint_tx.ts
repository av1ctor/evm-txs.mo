import { ethers } from "hardhat";

function to_vec(s: string): string {
    let res = "";

    for(let i = 2; i < s.length; i += 2) {
        res += (res.length > 0? "; ": "") + parseInt(s.substr(i, 2), 16);
    }

    return res;
}

async function main() {
    const to = "0x6388a00fd84e9353a33c11991b17ef17954240e6";
    let tx = new ethers.Transaction();
    tx.type = 2; // EIP1559
    tx.chainId = 31337; // hardhat
    tx.nonce = 1; // assuming the send_ether.ts script was ran
    tx.maxPriorityFeePerGas = 100000n;
    tx.maxFeePerGas = 513319700n;
    tx.gasLimit = 100000n;
    tx.gasPrice = 875000000n;
    tx.value = ethers.parseEther("100.0"); // NFT price
    tx.data = ethers.id("mint()").substring(0, 10); // call mint() method
    tx.accessList = [];
    tx.signature = {
      r: "0x00",
      s: "0x00",
      v: "0x00",
    }
    tx.to = to;
    console.log(tx.serialized);
    console.log(`dfx canister call backend sign_raw_evm_tx "(vec {${to_vec(tx.serialized)}}, 31337)"`)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


