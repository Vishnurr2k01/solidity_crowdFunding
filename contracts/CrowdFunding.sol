pragma solidity ^0.8.7;

contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public target;
    uint public deadline;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipent;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequest;

    constructor(uint _target,uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp < deadline,"deadline has passed");
        require(msg.value >= minimumContribution ,"min contribution is not met");
        
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
     function getContractBalance() public view returns(uint){
         return address(this).balance;
     }
    function refund() public{
        require(block.timestamp>deadline && raisedAmount < target,"not eligible");
        require(contributors[msg.sender]>0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
         
    }

    modifier onlyManager{
        require(msg.sender==manager,"only manger can access");
        _;
    }
    function createRequests(string memory _description,address payable _recipent,uint _value) public onlyManager{
        Request storage newRequest = requests[numRequest];
        numRequest++;
        newRequest.description = _description;
        newRequest.recipent = _recipent;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint _requesNo) public{
        require(contributors[msg.sender]>0,"must be a contributor");
        Request storage thisRequest = requests[_requesNo];
        require(thisRequest.voters[msg.sender]==false,"already voted");
        thisRequest.voters[msg.sender]= true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requesNo)public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequest = requests[_requesNo];
        require(thisRequest.completed==false,"req completed");
        require(thisRequest[noOfVoters]>noOfContributors/2);
        thisRequest.recipent.transfer(thisRequest.value);
        thisRequest.completed=true;
    }

}