pragma circom 2.0.0;

template VoteProof(n) {
    signal input voterId;   // Unique identifier for the voter
    signal input hasVoted;  // 0 if not voted, 1 if voted
    signal input voteIndex; // Index of the proposal being voted for

    signal output validVote; // Output: 1 if the vote is valid, 0 otherwise

    // Ensure voter has not already voted
    assert(hasVoted == 0);

    // Ensure voteIndex is within the valid range [0, n-1]
    validVote <== (voteIndex >= 0 && voteIndex < n);
}

component main = VoteProof(2); // Circuit for 2 proposals
