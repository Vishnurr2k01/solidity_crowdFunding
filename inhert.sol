pragma solidity ^0.8.7;

    contract Ownable{
        address owner;

        constructor() public{
            owner = msg.sender;
        }
        modifier OnlyOwner(){
        require(msg.sender == owner,"must be owner");
        _;
    }

    }

    contract SecretThings{
    string secret ;
    constructor(string memory _secret) public{
        secret= _secret;
        
    }
    function getSecret() public  view  returns(string memory) {
        return secret;

    }
    }

    contract MyContract is Ownable{
        address secretVault;

    
 constructor(string memory _secret) public{
     SecretThings _secretThings = new SecretThings(_secret);
        secretVault= address(_secretThings);
        super;
    }
    function getSecret() public  view OnlyOwner  returns(string memory){
        SecretThings _secretThings = SecretThings(secretVault);
        return _secretThings.getSecret();

    }
    

}