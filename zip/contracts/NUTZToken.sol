// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NUTZToken is ERC20, Ownable {
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 5200000 * (10 ** uint256(DECIMALS));
    uint256 public constant BURN_RESERVOIR = 3000000 * (10 ** uint256(DECIMALS));
    uint256 public constant CREATOR_REWARDS = 800000 * (10 ** uint256(DECIMALS));
    uint256 public constant DEVELOPER_PAYMENT = 200000 * (10 ** uint256(DECIMALS));

    address private burnReservoir;
    address private creatorRewards;
    address private developerPayment;

    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event BurnReservoirSet(address indexed burnReservoir);
    event CreatorRewardsSet(address indexed creatorRewards);
    event DeveloperPaymentSet(address indexed developerPayment);

    constructor(address _initialOwner) ERC20("NUTZToken", "NUTZ") Ownable(_initialOwner) {
        _mint(_initialOwner, INITIAL_SUPPLY);
        emit TokensMinted(_initialOwner, INITIAL_SUPPLY);
    }

    function burnFromReservoir(uint256 _amount) external onlyOwner {
        require(_amount <= balanceOf(burnReservoir), "Insufficient tokens in reservoir");
        _burn(burnReservoir, _amount);
        emit TokensBurned(burnReservoir, _amount);
    }

    function setBurnReservoir(address _burnReservoir) external onlyOwner {
        require(_burnReservoir != address(0), "Invalid burn reservoir address");
        burnReservoir = _burnReservoir;
        emit BurnReservoirSet(burnReservoir);
    }

    function setCreatorRewards(address _creatorRewards) external onlyOwner {
        require(_creatorRewards != address(0), "Invalid creator rewards address");
        creatorRewards = _creatorRewards;
        emit CreatorRewardsSet(creatorRewards);
    }

    function setDeveloperPayment(address _developerPayment) external onlyOwner {
        require(_developerPayment != address(0), "Invalid developer payment address");
        developerPayment = _developerPayment;
        emit DeveloperPaymentSet(developerPayment);
    }
}
