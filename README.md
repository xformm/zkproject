![Alt](https://github.com/xformm/zkproject/model.png?raw=true)
Documentation

install node
```
brew install node
```
Check node and npm version and add it to your $PATH env variable

Install hardhart
```
npx hardhat
```

We initially have the following contract in model_dc.sol
```
// SPDX-License-Identifier: GPL-3.0

  

pragma solidity >=0.7.0 <0.9.0;

  

import "../../node_modules/hardhat/console.sol";

  

contract Ballot {

  

//Authority address (who deploys the contract)

address authority;

  

struct Voter {

string name; // Voter name

bool voted; // if true, that person already voted

uint vote; // index of the voted proposal

bool rightGranted; //if true, voter can use verification2

}

  

struct Proposal {

string name; // short name (up to 32 bytes)

uint voteCount; // number of accumulated votes

}

  

mapping(address => Voter) voters;

  

Proposal[] public proposals;

  

constructor() {

authority = msg.sender;

  

//Appends two proposals to Proposal

proposals.push(Proposal({ name: "Joe Biden", voteCount: 0 }));

proposals.push(Proposal({ name: "Donald Trump", voteCount: 0 }));

}

  

//Function to change name of voter

function changeName(string memory _name, address _address) public{

//Requirements

require(msg.sender != authority, "Authority can not vote");

require(msg.sender == _address, "Has no right to change name");

  

//Change name

voters[_address].name = _name;

}

  

//Function to give right to use function verification2

function giveRightToVerification2(address _address) public {

//Requirements

require( msg.sender == authority, "Only authority can give right to watch" );

  

//Grant permission

voters[_address].rightGranted = true;

}

  

//Function to log out

function logOut() public{

voters[msg.sender].rightGranted = false;

}

//Function to vote

function vote(uint _proposal) public {

Voter storage sender = voters[msg.sender];

//Requirements

require(msg.sender != authority, "Authority can not vote");

require(bytes(sender.name).length != 0, "Please change your name first");

require(!sender.voted, "Already voted");

  

//Add vote

sender.voted = true;

sender.vote = _proposal;

proposals[_proposal].voteCount += 1;

}

  

//Function to use Type 1 Verification

function verification1(address _address, uint _token) public view returns(bool voted_){

//Requirements

require(msg.sender == _address, "Has no right to verify");

require(_token == 123456 , "Invalid token");

  

//Shows if user voted

voted_ = voters[_address].voted;

}

  

//Function to use Type 2 Verification

function verification2(address _address, uint _token) public view returns(string memory name_, bool voted_, string memory vote_){

//Requirements

require(msg.sender == _address, "Has no right to verify");

require(_token == 123456 , "Invalid token");

require(voters[_address].rightGranted == true, "Has no right granted");

  

//Shows data voter

name_ = voters[_address].name;

voted_ = voters[_address].voted;

if (voted_ != false) {

vote_ = proposals[voters[_address].vote].name;

}

}

  

//Function to call winning proposal

function winningProposal() public view returns (uint winningProposal_, string memory winnerName_) {

//Winning proposal

uint winningVoteCount = 0;

for (uint p = 0; p < proposals.length; p++) {

if (proposals[p].voteCount > winningVoteCount) {

winningVoteCount = proposals[p].voteCount;

winningProposal_ = p;

}

}

if (winningProposal_ == 0 ){

winnerName_ = "NULL";

} else {

winnerName_ = proposals[winningProposal_].name;

}

}

  

}
```

Implementing Zero-Knowledge Proofs (ZKP) in your voting contract can enhance privacy and security by ensuring voters' anonymity and preventing coercion. Here's a step-by-step guide to integrating ZKP into your `e-voting` project:

ZKP allows a voter to prove that they are eligible to vote without revealing their identity or the vote they cast.

We'll use **zk-SNARKs** (Zero-Knowledge Succinct Non-Interactive Arguments of Knowledge), a popular ZKP implementation. Tools like circom and [snarkjs](https://github.com/iden3/snarkjs) can help generate the necessary circuits and proofs.

install snarkjs:
```
npm install -g circom snarkjs
```

Create a `vote.circom` file for ZKP logic. The circuit will:

1. Verify the voter's eligibility using a secret key.
```
template Vote() {

// Input signals

signal input voterSecret; // Voter's secret input

  

// Output signals

signal output computedHash;

  

// Constant multiplier (define it directly as a number)

signal multiplier;

multiplier <== 123456789; // Assign the constant value to a signal

  

// Compute hash

computedHash <-- voterSecret * multiplier;

}

  

component main = Vote();
```
have it in a circuit file e.g. `voting.circom` in the same directory as the `model_dc.sol file`

Compile the circuit and generate the proving/verifying keys:
```
circom voting.circom --r1cs --wasm --sym
```
 initiate the ceremony of  **powers of tau** which helps in generating the keys. Refer to https://academy.scrypt.io/en/courses/Build-a-zkSNARK-based-Battleship-Game-on-Bitcoin-6594f5d81bfaad396835bd33/lessons/3/chapters/1 for more info.

```
snarkjs powersoftau new bn128 12 pot12_0000.ptau 
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -e="$(openssl rand -base64 20)" 
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau
```

generate the key and export it to a json file
```
snarkjs groth16 setup vote.r1cs pot12_final.ptau vote.zkey
snarkjs zkey export verificationkey vote.zkey verification_key.json
```

Once you've generated the `verification_key.json`, you can use `snarkjs` to export a Solidity verifier contract:
```
snarkjs zkey export solidityverifier vote.zkey Verifier.sol
```
This will generate a `Verifier.sol` file, which contains the smart contract logic for verifying ZKP proofs.

 Deploy Verifier Contract: Deploy the `Verifier.sol` and `Ballot.sol` contracts in Remix.
 Generate Proofs Locally: Use `snarkjs` to generate ZKP proofs for voting:
```
snarkjs groth16 prove vote.zkey witness.wasm proof.json public.json
```

Pass the Proof to the Smart Contract: Call the `vote` function in your contract, passing:
- `proof` (from `proof.json`)
- `public inputs` (from `public.json`)


After successfully compiling your Circom circuit with `circom vote.circom --r1cs --wasm --sym`, and running the `snarkjs` setup and verification key export commands, the next steps involve generating and using the Zero-Knowledge Proof (ZKP) for your voting system.

Here’s a detailed step-by-step guide to proceed from there:

### **1. Generate the Zero-Knowledge Proof (ZKP)**

After the `verification_key.json` has been generated, the next step is to create a proof for a given witness (inputs) using **snarkjs**.
####  Generate a Witness
The witness is the set of inputs and computed values needed to generate the proof. To do this, you need to provide the inputs to the circuit.
- First, you need to input the values for the circuit. In your case, these could be the `voterSecret` and other inputs.
- To generate the witness, you'll use the **wasm** (compiled circuit) and the **input** values.
```
# Generate the witness
node vote_js/generate_witness.js vote_js/vote.wasm input.json witness.wtns
```

Here, `input.json` contains the input values in JSON format, such as:
```
{
  "voterSecret": 1234
}
```


generating proof
```
snarkjs groth16 prove voting.zkey witness.wtns proof.json public.json
```

verifying proof
```
snarkjs groth16 verify verification_key.json input.json proof.json
```
