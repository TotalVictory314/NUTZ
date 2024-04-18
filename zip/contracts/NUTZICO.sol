// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NUTZICO is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    IERC20 public nutzToken;
    uint256 public constant ICO_PRICE = 1e18; // Price per token in wei (1 ETH per NUTZ for example)
    uint256 public constant ICO_CAP = 1000 * (10 ** 18); // Cap for the ICO in NUTZ tokens
    uint256 public constant ICO_START = 1622548800; // Example start time for the ICO
    uint256 public constant ICO_END = 1625130800; // Example end time for the ICO
    uint256 public totalRaised;
    bool public icoFinalized = false;

    // Events
    event ICOParticipation(address indexed participant, uint256 ethContributed, uint256 tokensPurchased);
    event ICOClosed(uint256 totalRaised);
    event TokenAddressSet(address indexed newTokenAddress);

    constructor(address _nutzTokenAddress, address _owner) Ownable(_owner) {
        require(_nutzTokenAddress != address(0), "Token address cannot be the zero address");
        nutzToken = IERC20(_nutzTokenAddress);
    }

    // Function for participants to join the ICO
    function participate() external payable nonReentrant {
        require(block.timestamp >= ICO_START && block.timestamp <= ICO_END, "ICO not active");
        require(msg.value >= ICO_PRICE, "ETH sent is below the price of one token");
        require(!icoFinalized, "ICO has been finalized");

        uint256 tokensToPurchase = msg.value.div(ICO_PRICE);
        require(tokensToPurchase <= nutzToken.balanceOf(address(this)), "Not enough tokens left for sale");
        require(totalRaised.add(tokensToPurchase) <= ICO_CAP, "ICO cap exceeded");

        totalRaised = totalRaised.add(tokensToPurchase);
        nutzToken.transfer(msg.sender, tokensToPurchase);

        emit ICOParticipation(msg.sender, msg.value, tokensToPurchase);
    }

    // Function to finalize the ICO
    function finalizeICO() external onlyOwner {
        require(block.timestamp > ICO_END, "ICO not ended yet");
        require(!icoFinalized, "ICO already finalized");

        icoFinalized = true;
        uint256 remainingTokens = nutzToken.balanceOf(address(this));
        if (remainingTokens > 0) {
            nutzToken.transfer(owner(), remainingTokens); // Send remaining tokens back to the owner
        }
        payable(owner()).transfer(address(this).balance); // Send raised ETH to the owner

        emit ICOClosed(totalRaised);
    }

    // Function to allow the owner to update the token address in case of migration
    function setTokenAddress(address _newTokenAddress) external onlyOwner {
        require(_newTokenAddress != address(0), "Invalid token address");
        nutzToken = IERC20(_newTokenAddress);
        emit TokenAddressSet(_newTokenAddress);
    }

    // ... additional functions and logic as needed ...
}
