pragma solidity ^0.4.2; //We have to specify what version of the compiler this code will use

contract Voting {

  // We use the struct datatype to store the voter information.
  struct Candidat {
    uint numCandidat;       
    string  nomCandidat;  
  } 
 
  struct voter {
    address voterAddress; // adresse de l'électeur
    uint tokensBought;    //  Le nombre total des jetons de cet électeur
    uint[] tokensUsedPerCandidate;  
  }

  mapping (uint => Candidat) public candidats;
  uint[] public candidateList;
  uint public candidatID;

  mapping (address => voter) public voterInfo;
  mapping (uint => uint) public votesReceived;

  
  uint public totalTokens; // Total no. des jetons disponibles pour cette élection
  uint public balanceTokens; // Total no. de jetons encore disponibles à l'achat
  uint public tokenPrice; // Prix ​​par jeton

   
  
  function Voting(uint tokens, uint pricePerToken) public {
      totalTokens = tokens;
    balanceTokens = tokens;
    tokenPrice = pricePerToken;
  }

  function totalVotesFor(uint candidate) view public returns (uint) {
    return votesReceived[candidate];
  }


   function addCandidate(string _nomCandidat) public {
    candidatID++;
    var candidat = candidats[candidatID];
    candidat.numCandidat = candidatID + 1;
    candidat.nomCandidat = _nomCandidat;
    candidateList.push(candidatID);
 
  }
  
  function countCandidats() view public returns (uint) {
        return candidateList.length;
  }

  function candidateName(uint _idCandidate) view public returns (string, uint) {
        uint num = candidats[_idCandidate].numCandidat;
        return (candidats[_idCandidate].nomCandidat, votesReceived[num-1]);
  }

  function allCandidates() view public returns (uint[]) {
     return candidateList;

  }



  function voteForCandidate(uint candidate, uint votesInTokens) public {
    uint index = indexOfCandidate(candidate);
    require(index != uint(-1));

    
    
    if (voterInfo[msg.sender].tokensUsedPerCandidate.length == 0) {
       for (uint i = 0; i < candidateList.length; i++) {
        voterInfo[msg.sender].tokensUsedPerCandidate.push(0);
      }
    }

    // Make sure this voter has enough tokens to cast the vote
    uint availableTokens = voterInfo[msg.sender].tokensBought - totalTokensUsed(voterInfo[msg.sender].tokensUsedPerCandidate);
    require(availableTokens >= votesInTokens);

    votesReceived[candidate] += votesInTokens;

    // Store how many tokens were used for this candidate
    voterInfo[msg.sender].tokensUsedPerCandidate[index] += votesInTokens;
  }

  // Return the sum of all the tokens used by this voter.
  function totalTokensUsed(uint[] _tokensUsedPerCandidate) private view returns (uint) {
    uint totalUsedTokens = 0;
    for(uint i = 0; i < _tokensUsedPerCandidate.length; i++) {
      totalUsedTokens += _tokensUsedPerCandidate[i];
    }
    return totalUsedTokens;
  }

  function indexOfCandidate(uint candidate) view public returns (uint) {
    for (uint i = 0; i < candidateList.length; i++) {
      if (candidats[i].numCandidat == candidate) {
        return i;
      }
    }
    return uint(-1);
  }

  

  function buy() payable public returns (uint) {
    uint tokensToBuy = msg.value / tokenPrice;
    require(tokensToBuy <= balanceTokens);
    voterInfo[msg.sender].voterAddress = msg.sender;
    voterInfo[msg.sender].tokensBought += tokensToBuy;
    balanceTokens -= tokensToBuy;
    return tokensToBuy;
  }

  function tokensSold() view public returns (uint) {
    return totalTokens - balanceTokens;
  }

 
  function voterDetails(address user) view public returns (uint, uint[]) {
    return (voterInfo[user].tokensBought, voterInfo[user].tokensUsedPerCandidate);
  }

  function transferTo(address account) public {
    account.transfer(this.balance);
  }

}