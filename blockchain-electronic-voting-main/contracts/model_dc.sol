// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract Ballot {

    //Authority address (who deploys the contract)
    address authority;

    struct Voter {
        string name; // Voter name
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted proposal
        bool rightGranted; //if true, voter can use verification2
    }

    struct Proposal {
        string name;   // short name (up to 32 bytes)
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