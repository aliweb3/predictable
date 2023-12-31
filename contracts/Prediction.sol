// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract Prediction {
    enum Side {
        Twitter,
        Threads
    }
    struct Result {
        Side winner;
        Side loser;
    }
    Result public result;

    mapping(Side => uint) public bets;
    mapping(address => mapping(Side => uint)) betsPerGambler;

    address payable oracle;
    bool public electionFinished;

    constructor(address payable _oracle) {
        oracle = _oracle;
    }

    function placeBet(Side _side) external payable {
        require(electionFinished == false, "election is finished!");
        bets[_side] += msg.value;
        betsPerGambler[msg.sender][_side] += msg.value;
    }

    function whithdraw() external {
        uint gamblerBet = betsPerGambler[msg.sender][result.winner];
        require(gamblerBet > 0, "you do not have any winning bet");
        require(electionFinished == true, "election not finished");
        uint gain = gamblerBet + bets[result.loser] * gamblerBet / bets[result.winner];
        betsPerGambler[msg.sender][Side.Twitter] = 0;
        betsPerGambler[msg.sender][Side.Threads] = 0;
       payable(msg.sender).transfer(gain);
    }
    function reportResult(Side _winner , Side _loser) external {
        require(oracle == msg.sender , 'only oracle');
        require(electionFinished == false , 'election is finished');
        result.winner = _winner;
        result.loser = _loser;
        electionFinished = true;

    }

} 

