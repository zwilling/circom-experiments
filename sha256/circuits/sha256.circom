pragma circom 2.0.0;

// there is already a sha256 circuit in the library that we can reuse
include "../../circomlib/circuits/sha256/sha256.circom";

// lets compute the hash of a 8 bit input for testing.
// the private input is handed over as bit array and for testing with a .json input I did not want to use huge arrays
// for larger inputs it makes sense to generate the bit array input with some script
component main = Sha256(8);

/*
In the test I hash an ascii 'a'=01100001
the sha256 hash of it is 0xca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb

to build the proof, you can run:
```
cd sha256/example
snarkjs groth16 prove trusted_setup/sha256_0001.zkey witness.wtns proof.json public_input.json
```
This generates the proof and the public_input.

to verify the proof:
```
cd sha256/example
snarkjs groth16 verify trusted_setup/verification_key.json public_input.json proof.json
```
alternatively, there is also a verifyer.sol we could use, but I did not test this yet.
*/
