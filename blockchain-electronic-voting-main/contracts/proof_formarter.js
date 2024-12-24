const fs = require('fs');

// Load the proof.json
const proof = JSON.parse(fs.readFileSync('proof.json', 'utf8'));
const public = JSON.parse(fs.readFileSync('public.json', 'utf8'));

// Extract the required elements
const proofA = proof.pi_a.slice(0, 2);
const proofB = [proof.pi_b[0].slice(0, 2), proof.pi_b[1].slice(0, 2)];
const proofC = proof.pi_c.slice(0, 2);
const pubSignal = public.slice(0, 2)

// Save the transformed proof
const formattedProof = { proofA, proofB, proofC, pubSignal};
fs.writeFileSync('formarted_proof.json', JSON.stringify(formattedProof, null, 2));

console.log('Proof formatted successfully!');
