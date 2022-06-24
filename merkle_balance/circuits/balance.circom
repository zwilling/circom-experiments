pragma circom 2.0.0;

include "merkleProof.circom";
include "../../circomlib/circuits/poseidon.circom";

/*
Main circuit for prooving that an acount has a balance larger than balanceThreshold
For simplicity of this example, we use a Merkle tree instad of the Ethereum Patricia trie
*/

template BalanceProof(){
    // inputs that are made public (in the main component definition below)
    signal input balanceThreshold;
    // having addressHash as output makes it public and the circuit computes the value for me.
    // It is the same as having it as public input and checking that it matches
    signal output addressHash;
    signal input merkleRoot;

    // inputs that are kept private
    signal input balance;
    signal input address;
    signal input addressNonce;
    signal input addressStorageRoot;
    signal input addressCodeHash;
    signal input merklePathElements;
    signal input merklePathIndices;

    // verify the address hash
    component addressHashCircuit = Poseidon(1);
    addressHashCircuit.input[0] = address;
    addressHash <== addressHashCircuit.out;

    // verify balance Threshold
    // be careful because '>' operates in 'mod p' (https://docs.circom.io/circom-language/basic-operators/)
    balance > balanceThreshold === 1;

    // verify address data validity by constructing the merkle leaf
    component merkleLeaf = Poseidon(5);
    merkleLeaf.inputs[0] <== addressNonce;
    merkleLeaf.inputs[1] <== balance;
    merkleLeaf.inputs[2] <== addressStorageRoot;
    merkleLeaf.inputs[3] <== addressCodeHash;
    // Also put the address into the merkleLeaf. In patricia tries we would not need this because the path encodes the address
    merkleLeaf.inputs[3] <== address;

    // TODO: verify merkleProof
}

component main {public [balanceThreshold, addressHash, merkleRoot]} = BalanceProof();