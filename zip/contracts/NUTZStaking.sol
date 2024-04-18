// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NUTZStaking is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    IERC20 public nutzToken;
    uint256 public constant STARTING_ANNUAL_RETURN = 25; // 25% initially
    uint256 public constant MINIMUM_ANNUAL_RETURN = 5; // 5% is the minimum
    uint256 public constant MINT_RATE_DECREASE = 5; // Decrease rate by 5%
    uint256 public constant TOKENS_PER_DECREASE = 250000 * (10 ** 18); // For every 250,000 tokens minted
    uint256 public totalStaked;
    uint256 public totalRewardsMinted;

    struct Stake {
        uint256 amount;
        uint256 rewardRate;
        uint256 stakingTime;
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 amount, uint256 rewardRate);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event TokensBurned(uint256 amount);

    constructor(address _nutzTokenAddress, address _owner) Ownable(_owner) {
        require(_nutzTokenAddress != address(0), "Token address cannot be the zero address");
        nutzToken = IERC20(_nutzTokenAddress);
    }

    function stakeTokens(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(nutzToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        uint256 currentRewardRate = getCurrentRewardRate();
        stakes[msg.sender] = Stake(_amount, currentRewardRate, block.timestamp);
        totalStaked = totalStaked.add(_amount);

        emit Staked(msg.sender, _amount, currentRewardRate);
    }

    function unstakeAndClaimRewards() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No tokens to unstake");

        uint256 reward = calculateReward(msg.sender);
        uint256 burnAmount = reward.mul(3).div(2); // Burn rate of 1.5x the reward
        nutzToken.transfer(address(nutzToken), burnAmount); // Assuming NUTZToken has a burn function

        require(nutzToken.transfer(msg.sender, userStake.amount.add(reward)), "Transfer failed");

        totalStaked = totalStaked.sub(userStake.amount);
        totalRewardsMinted = totalRewardsMinted.add(reward);

        delete stakes[msg.sender];

        emit Unstaked(msg.sender, userStake.amount);
        emit RewardPaid(msg.sender, reward);
        emit TokensBurned(burnAmount);
    }

    function getCurrentRewardRate() public view returns (uint256) {
        uint256 decreaseAmount = totalRewardsMinted.div(TOKENS_PER_DECREASE).mul(MINT_RATE_DECREASE);
        uint256 currentRewardRate = STARTING_ANNUAL_RETURN > decreaseAmount ? STARTING_ANNUAL_RETURN.sub(decreaseAmount) : MINIMUM_ANNUAL_RETURN;
        return currentRewardRate;
    }

    function calculateReward(address _user) public view returns (uint256) {
        Stake memory userStake = stakes[_user];
        uint256 stakingDuration = block.timestamp.sub(userStake.stakingTime);
        uint256 reward = userStake.amount.mul(userStake.rewardRate).mul(stakingDuration).div(365 days).div(100);
        return reward;
    }

    // ... additional functions and logic as needed ...
}
