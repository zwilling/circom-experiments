# Simple makefile for operating circom

MODULE=balance

compile:
	circom circuits/${MODULE}.circom --r1cs --wasm --sym -o build

witness:
	node build/${MODULE}_js/generate_witness.js build/${MODULE}_js/balance.wasm example/input.json example/witness.wtns

setup:
	mkdir -p ../trusted_setup/${MODULE}
	snarkjs groth16 setup build/${MODULE}.r1cs ../trusted_setup/pot12_final.ptau ../trusted_setup/${MODULE}/${MODULE}_0000.zkey
	snarkjs zkey contribute ../trusted_setup/${MODULE}/${MODULE}_0000.zkey ../trusted_setup/${MODULE}/${MODULE}_0001.zkey --name="1st Contributor Name"
	snarkjs zkey export verificationkey ../trusted_setup/${MODULE}/${MODULE}_0001.zkey ../trusted_setup/${MODULE}/verification_key.json

proof:
	make witness
	snarkjs groth16 prove ../trusted_setup/${MODULE}/${MODULE}_0001.zkey example/witness.wtns example/proof.json example/public.json

verify:
	snarkjs groth16 verify ../trusted_setup/${MODULE}/verification_key.json example/public.json example/proof.json

all:
	make compile
	make setup
	make proof
	make verify