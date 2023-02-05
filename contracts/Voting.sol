// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract voting {
       
 
   struct Voter {
                
     uint weight;           // weight is accumulated by delegation
     string Cname;          // name of the candidate chosen to vote 
     address delegate;      //person delegated to
     bool voted;            // the voter has voted or not
   }

   address public manager;          // manager is the owner who deploys the contract
   string[] public candidateList;   // stores the names of the candidate participating in the election
  
   mapping(string => uint) noOfVotes;         // stores the no of votes of each candidate 
   mapping(address => Voter) public voters;   // stores the details of the voters
       
   constructor(){
    manager = msg.sender;                     
    }
       
    /*    this function is used to register the names of the candidates    */

    function registration(string memory _name ) public {
       require(msg.sender == manager,"Only the manager can do registration");
       candidateList.push(_name);
    }
     
    /*    this function is used by the manager  to give the right to vote to the voters  */ 
    function giveRightToVote(address _voter) public {
       require(msg.sender == manager,"Only manager can do give right to vote");
       require(voters[_voter].weight==0,"This person is already eligible to vote ");
       voters[_voter].weight=1;     
        
    }
    
     /*    this function allows the voters to delegate their vote to other account  */ 

    function delegate(address to) public {
      
       Voter storage sender = voters[msg.sender];
       require(!sender.voted, "You already voted.");
       require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)){     // checks if the person you are delegating has delegated its vote to someone else
            to = voters[to].delegate;                   
        }

        sender.voted= true;
        Voter storage delegate = voters[to];

        if(delegate.voted){
           // If the delegate already voted,
            // directly add to the number of votes
           noOfVotes[delegate.Cname] += sender.weight;
        }
        else{
            // If the delegate did not vote yet,
            // add to its weight.
            delegate.weight += sender.weight;
        }

    }

     /*  this function is used by the voters to give their vote by providing the name of the candidate  */ 

    function giveVote(string memory _name) public {
      
       Voter storage sender = voters[msg.sender]; 
       require(sender.weight != 0, "person has no right to vote"); 
       require(!sender.voted, " person has already voted.");
       sender.voted = true;
       sender.Cname = _name;
    
       noOfVotes[_name] += sender.weight;    
    }
      
    /*  this function provides us the name of the winning candidate  */   

      function winningCandidate() public view returns(string memory){
        
        require(candidateList.length>1,"No of candidate must be greater than 1 ");

        uint winningVoteCount=0;
        string memory _name;
        for(uint k = 0; k < candidateList.length; k++){
              if(noOfVotes[candidateList[k]] > winningVoteCount)
               {
                   winningVoteCount = noOfVotes[candidateList[k]];
                   _name = candidateList[k];
               }
        }
           return _name;
    }

}
