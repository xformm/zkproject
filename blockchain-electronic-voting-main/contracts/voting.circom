template Vote() {
    // Input signals
    signal input voterSecret;  // Voter's secret input

    // Output signals
    signal output computedHash;
    

    // Constant multiplier (define it directly as a number)
    signal multiplier; 
    multiplier <== 123456789; // Assign the constant value to a signal

    // Compute hash
    computedHash <-- voterSecret * multiplier;
}

component main = Vote();
