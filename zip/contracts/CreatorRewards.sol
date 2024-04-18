// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CreatorRewards is Ownable, ReentrancyGuard {
    address public immutable tokenAddress;
    uint256 public totalRewardsAllocated;
    mapping(address => uint256) public rewards;
    mapping(address => bool) public approvedCreators;

    event CreatorApproved(address indexed creator);
    event RewardAdded(address indexed creator, uint256 amount);
    event RewardClaimed(address indexed creator, uint256 amount);
    event TokenAddressUpdated(address indexed newTokenAddress);

    constructor(address _tokenAddress, address _initialOwner) Ownable(_initialOwner) {
        require(_tokenAddress != address(0), "Token address cannot be the zero address");
        tokenAddress = _tokenAddress;
    }

    function approveCreator(address _creator, uint256 _rewardAmount) external onlyOwner {
        require(_creator != address(0), "Invalid creator address");
        require(_rewardAmount > 0, "Reward amount must be greater than 0");
        approvedCreators[_creator] = true;
        rewards[_creator] += _rewardAmount;
        totalRewardsAllocated += _rewardAmount;

        emit CreatorApproved(_creator);
        emit RewardAdded(_creator, _rewardAmount);
    }

    function claimRewards() external nonReentrant {
        require(approvedCreators[msg.sender], "Creator not approved");
        uint256 rewardAmount = rewards[msg.sender];
        require(rewardAmount > 0, "No rewards to claim");

        rewards[msg.sender] = 0;
        totalRewardsAllocated -= rewardAmount;
        require(payable(msg.sender).send(rewardAmount), "Reward transfer failed");

        emit RewardClaimed(msg.sender, rewardAmount);
    }

    function updateTokenAddress(address _newTokenAddress) external onlyOwner {
        require(_newTokenAddress != address(0), "Invalid token address");
        emit TokenAddressUpdated(_newTokenAddress);
    }

    // Additional functions and logic as needed
}
