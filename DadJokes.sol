// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DadJokes {
    struct Joke {
        string setup;
        string punchline;
        address creator;
        bool isDeleted;
    }

    mapping(uint256 => Joke) private jokes;
    uint256 private jokeCount;

    mapping(address =>uint256 ) public creatorBal;
    uint256 private constant CLASSIC_REWARD = 0.001 ether;
    uint256 private constant FUNNY_REWARD = 0.005 ether;
    uint256 private constant GROANER_REWARD = 0.01 ether;

    mapping(uint256 => uint256) private rewardAmounts;

    constructor(){
        rewardAmounts[1] = CLASSIC_REWARD;
        rewardAmounts[2] = FUNNY_REWARD;
        rewardAmounts[3] = GROANER_REWARD;
    }

    event JokeDeleted(uint256 indexed  jokeId);
    event BalanceWithdrawn(address creator, uint256 amount );
    event JokeAdded(uint256 indexed jokeId, address indexed creator);
    event JokeRewarded(uint256 indexed jokeId, uint8 indexed rewardType, uint256 indexed rewardAmount);

    function addJokes(string memory _setup, string memory _punchline) public {
        jokes[jokeCount] = Joke(_setup, _punchline, msg.sender, false);
        emit JokeAdded(jokeCount, msg.sender);
        jokeCount++;

    }

    function getJokes() public view returns (Joke[] memory){

        Joke[] memory allJokes = new Joke[](jokeCount);
        uint256 counter = 0;

        for(uint256 i = 0; i < jokeCount; i++){
            if(!jokes[i].isDeleted){
                allJokes[counter] = jokes[i];
                counter++;

            }
        }
            if(counter == jokeCount){
                return allJokes;
            }else{
                Joke[] memory filteredJokes = new Joke[](counter);
                for(uint256 i = 0; i < counter; i++ ){
                    filteredJokes[i] = allJokes[i];
                }
                return filteredJokes;
            }
        

    }

    function rewardJoke(uint256 jokeId, uint8 _rewardType) public payable{
        require(jokeId < jokeCount, "Invalid joke index");
        require(_rewardType >= 1 && _rewardType <= 3, "RewardTyoe not between 1 and 3");
        require(!jokes[jokeId].isDeleted, "joke has been  deleted");

        uint256 rewardAmount = rewardAmounts[_rewardType];

        require(msg.value == rewardAmount, "invalid reward amount");
        creatorBal[jokes[jokeId].creator] += rewardAmount;
        emit JokeRewarded(jokeId, _rewardType, rewardAmount);



    }
    function deleteJoke(uint256 jokeId) public {
        require(jokeId < jokeCount, "invalid joke index");
        require(jokes[jokeId].creator == msg.sender, "Only joke creator can delete joke");
        require(!jokes[jokeId].isDeleted, "Joke has already been deleted");

        jokes[jokeId] = Joke("", "", address(0), true);
        emit JokeDeleted(jokeId);

    }

    function withdrawBalance() public {
        uint256 balance = creatorBal[msg.sender];
        require(balance > 0, "No balance to withdraw");

        creatorBal[msg.sender] = 0; 

        (bool success, ) = payable (msg.sender).call{value: balance}("");
        require(success, "Can't the balance");
        emit BalanceWithdrawn(msg.sender, balance);
    }







}