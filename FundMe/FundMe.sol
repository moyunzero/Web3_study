// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 1. 创建一个收款函数
// 2. 记录投资人并且查看
// 3. 在锁定期结束后，达到目标值，生产商可以提款
// 4. 在锁定期内，没有达到目标值，投资人在锁定期以后退款

// require(condition,"")


contract FundMe{
    mapping (address => uint256) public fundersToAmount;

    uint256 constant MINIMUM_VALUE = 1 * 10 ** 18;

    AggregatorV3Interface internal dataFeed;


    // 目标值
    uint256 constant TARGET = 1000 * 10 ** 18;

    address public owner;

    uint256 deploymentTimestamp;
    uint256 lockTime;

    constructor(uint256 _lockTime){ 
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }

    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE,"Please send more ETH");
        require(block.timestamp < deploymentTimestamp + lockTime,"Funding locked till the end of lock time");
        fundersToAmount[msg.sender] += msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256){
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice / (10 ** 8);
    }

    function transferOwnership(address newOwner) public onlyOwner{
        // require(msg.sender == owner, "this function can only be called by owner");
        owner  = newOwner;
    }

    function getFund() external windowClosed onlyOwner{
        require(convertEthToUsd(address(this).balance) >= TARGET, "Target is not reached");
        // require(msg.sender == owner, "this function can only be called by owner");
        // require(block.timestamp <= deploymentTimestamp + lockTime, "refund locked till the end of lock");
        // payable (msg.sender).transfer(addres s(this).balance);
        // bool success = payable (msg.sender).send(address(this).balance);
        // require(success,"tx failed");
        // call:transfer ETH with data return value of function and bool

        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success,"transfer tx failed");
        fundersToAmount[msg.sender] = 0;
    } 

    function refund() external windowClosed{
        require(convertEthToUsd(address(this).balance) < TARGET, "Target is reached");
        require(fundersToAmount[msg.sender]!=0,"This address has not funded yet");
        //  require(block.timestamp >= deploymentTimestamp + lockTime, "refund locked till the end of lock");

        bool success;
        (success, ) = payable(msg.sender).call{value: fundersToAmount[msg.sender]}("");
        require(success,"transfer tx failed");
        fundersToAmount[msg.sender] = 0;
    }

    modifier windowClosed(){
        require(block.timestamp>=deploymentTimestamp + lockTime,"window is not closed");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"this function can only be called by owner");
        _;
    }
}