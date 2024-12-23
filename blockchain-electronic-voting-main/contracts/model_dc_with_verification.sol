// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "../../node_modules/hardhat/console.sol";
import "./verify.sol"; // Import Verifier contract

contract Ballot {

    // Authority address (who deploys the contract)
    address public authority;
    Verifier public verifier; // Instance of the Verifier contract

    struct Voter {
        string name; // Voter name
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted proposal
        bool rightGranted; // if true, voter can use verification2
    }

    struct Proposal {
        string name;   // short name
        uint voteCount; // number of accumulated votes
    }

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor(address _verifierAddress) {
        authority = msg.sender;

        // Initialize the Verifier contract
        verifier = Verifier(_verifierAddress);

        // Appends two proposals to Proposal
        proposals.push(Proposal({name: "Joe Biden", voteCount: 0}));
        proposals.push(Proposal({name: "Donald Trump", voteCount: 0}));
    }

    // Function to vote with zk-SNARK proof verification
    function voteWithProof(
        uint[2] memory _proofA,
        uint[2][2] memory _proofB,
        uint[2] memory _proofC,
        uint[2] memory _pubSignals
    ) public {
        // Verify the zk-SNARK proof
        require(verifier.verifyProof(_proofA, _proofB, _proofC, _pubSignals), "Invalid proof");

        Voter storage sender = voters[msg.sender];

        // Ensure the voter is eligible
        require(msg.sender != authority, "Authority cannot vote");
        require(bytes(sender.name).length != 0, "Please register your name first");
        require(!sender.voted, "Already voted");

        uint proposalId = _pubSignals[0]; // Public signal that indicates the proposal ID

        // Cast the vote
        sender.voted = true;
        sender.vote = proposalId;
        proposals[proposalId].voteCount += 1;
    }

    // Other functions remain unchanged...

}

