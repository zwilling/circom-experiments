pragma circom 2.0.0;

include "merkleProof.circom";
include "../../circomlib/circuits/poseidon.circom";
include "../../circomlib/circuits/comparators.circom";

/*
Main circuit for prooving that an acount has a balance larger than balanceThreshold
For simplicity of this example, we use a Merkle tree instad of the Ethereum Patricia trie

@param levels: amount of levels in the Merkle tree
*/
template BalanceProof(levels){
    // inputs that are made public (in the main component definition below)
    signal input balanceThreshold;
    // having addressHash and merkleRoot as output makes it public and the circuit computes the value for me.
    // It is the same as having it as public input and checking that it matches
    signal output addressHash;
    signal output merkleRoot;

    // inputs that are kept private
    signal input balance;
    signal input address;
    signal input addressNonce;
    signal input addressStorageRoot;
    signal input addressCodeHash;
    signal input merklePathElements[levels];
    signal input merklePathIndices;

    // verify the address hash
    component addressHashCircuit = Poseidon(1);
    addressHashCircuit.inputs[0] <== address;
    addressHashCircuit.out ==> addressHash;

    // verify balance Threshold
    // be careful because '>' operates in 'mod p' (https://docs.circom.io/circom-language/basic-operators/)
    // this means that the uint256 maximum does not fit into 'mod p' and we have to make the inputs small enough in preprocessing
    // Circom enforces this with a limit to 252 bit numbers.
    component balanceCheck = GreaterEqThan(128);
    balanceCheck.in[0] <== balance;
    balanceCheck.in[1] <== balanceThreshold;
    balanceCheck.out === 1;

    // verify address data validity by constructing the merkle leaf
    component merkleLeaf = Poseidon(5);
    merkleLeaf.inputs[0] <== addressNonce;
    merkleLeaf.inputs[1] <== balance;
    merkleLeaf.inputs[2] <== addressStorageRoot;
    merkleLeaf.inputs[3] <== addressCodeHash;
    // Also put the address into the merkleLeaf. In patricia tries we would not need this because the path encodes the address
    merkleLeaf.inputs[4] <== address;

    // verify merkleProof
    component merkleProofCheck = MerkleProof(levels);
    merkleProofCheck.leaf <== merkleLeaf.out;
    merkleProofCheck.pathIndices <== merklePathIndices;
    for (var i = 0; i < levels; i++) {
        merkleProofCheck.pathElements[i] <== merklePathElements[i];
    }
    merkleProofCheck.root ==> merkleRoot; 
}

component main {public [balanceThreshold]} = BalanceProof(3);