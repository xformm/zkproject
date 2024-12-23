// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

/**
 * @title ZKP-based E-Voting System
 */
contract ZKPBallot {
    // Authority address (deployer of the contract)
    address public authority;

    struct Voter {
        bool voted; // If true, the voter has cast a vote
        bytes32 voteCommitment; // Cryptographic commitment to the vote
        bool eligible; // Eligibility status for voting
    }

    struct Proposal {
        string name;   // Proposal name
        uint voteCount; // Count of votes received
    }

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    // Events
    event VoteCommitted(address indexed voter);
    event VotesTallied(uint[] results);

    constructor(string[] memory proposalNames) {
        authority = msg.sender;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    /**
     * @dev Grants voting eligibility to a voter.
     */
    function grantEligibility(address voter) public {
        require(msg.sender == authority, "Only authority can grant eligibility");
        require(!voters[voter].eligible, "Voter is already eligible");
        voters[voter].eligible = true;
    }

    /**
     * @dev Commit a vote using a cryptographic hash.
     * @param commitment Hash of the vote and secret.
     */
    function commitVote(bytes32 commitment) public {
        Voter storage voter = voters[msg.sender];
        require(voter.eligible, "You are not eligible to vote");
        require(!voter.voted, "You have already voted");

        voter.voteCommitment = commitment;
        voter.voted = true;

        emit VoteCommitted(msg.sender);
    }

    /**
     * @dev Tally votes using the commitments and corresponding ZKPs (off-chain verification assumed).
     * @param voteCounts Aggregated results per proposal (provided by off-chain).
     */
    function tallyVotes(uint[] memory voteCounts) public {
        require(msg.sender == authority, "Only authority can tally votes");
        require(voteCounts.length == proposals.length, "Invalid vote counts");

        for (uint i = 0; i < proposals.length; i++) {
            proposals[i].voteCount = voteCounts[i];
        }

        emit VotesTallied(voteCounts);
    }

    /**
     * @dev Get the winning proposal.
     */
    function winningProposal() public view returns (string memory winnerName) {
        uint winningVoteCount = 0;
        uint winningProposalIndex;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i;
            }
        }

        winnerName = proposals[winningProposalIndex].name;
    }
}
