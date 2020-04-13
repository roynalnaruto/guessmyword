# Guess My Word
Implementation of [Guess My Word](https://hryanjones.com/guess-my-word/) using zkSNARKs to verify game operator's verdict.

# Overview
_NOTICE:_ This is work in progress.

* Circuits written using: [Circom](https://github.com/iden3/circom)
* zkSNARK proving system used: [snarkjs](https://github.com/iden3/snarkjs)

# Setup
* Install dependencies
```
$ yarn install
```
* Compile circuit
```
$ cd circuits
$ ../node_modules/.bin/circom circuit.circom \
    --r1cs --wasm --sym
```
* Trusted setup for the SNARK
```
$ ../node_modules/.bin/snarkjs setup
```
* Generate valid inputs (operator)
```
$ node generate-inputs.js
```
* Compute witness (operator)
```
$ ../node_modules/.bin/snarkjs calculatewitness \
    --wasm circuit.wasm
    --input input.json
    --witness witness.json
```
* Generate proof (operator)
```
$ ../node_modules/.bin/snarkjs proof
```
* Verify proof (game player)
```
$ ../node_modules/.bin/snarkjs verify
```
