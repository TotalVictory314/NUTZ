// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BurnReservoir is ReentrancyGuard, Ownable {
    IERC20 public nutzToken;
    uint256 public totalBurned;

    event TokensBurned(address indexed burner, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        require(_tokenAddress != address(0), "Token address cannot be the zero address");
        nutzToken = IERC20(_tokenAddress);
    }

    function burn(uint256 _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= nutzToken.balanceOf(address(this)), "Insufficient tokens to burn");

        nutzToken.transfer(address(0), _amount);
        totalBurned += _amount;

        emit TokensBurned(msg.sender, _amount);
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Token address cannot be the zero address");
        nutzToken = IERC20(_tokenAddress);
    }
}
