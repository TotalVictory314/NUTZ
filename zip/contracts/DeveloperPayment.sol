// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DeveloperPayment is Ownable, ReentrancyGuard {
    IERC20 public immutable nutzToken;
    uint256 public developerAllocation;
    address public developerWallet;
    bool public paymentReleased = false;

    // Events
    event PaymentReleased(address indexed developer, uint256 amount);
    event DeveloperWalletUpdated(address indexed newDeveloperWallet);
    event TokenAddressUpdated(address indexed newTokenAddress);

    constructor(address _nutzTokenAddress, address _developerWallet, uint256 _allocation, address _initialOwner) Ownable(_initialOwner) {
        require(_nutzTokenAddress != address(0), "Token address cannot be the zero address");
        require(_developerWallet != address(0), "Developer wallet cannot be the zero address");
        require(_allocation > 0, "Allocation must be greater than 0");

        nutzToken = IERC20(_nutzTokenAddress);
        developerWallet = _developerWallet;
        developerAllocation = _allocation;
    }

    function releasePayment() external onlyOwner nonReentrant {
        require(!paymentReleased, "Payment already released");
        require(nutzToken.balanceOf(address(this)) >= developerAllocation, "Insufficient funds");

        paymentReleased = true;
        nutzToken.transfer(developerWallet, developerAllocation);
        emit PaymentReleased(developerWallet, developerAllocation);
    }

    function updateDeveloperWallet(address _newDeveloperWallet) external onlyOwner {
        require(_newDeveloperWallet != address(0), "New developer wallet cannot be the zero address");
        developerWallet = _newDeveloperWallet;
        emit DeveloperWalletUpdated(_newDeveloperWallet);
    }

    function updateTokenAddress(address _newTokenAddress) external onlyOwner {
        require(_newTokenAddress != address(0), "New token address cannot be the zero address");
        emit TokenAddressUpdated(_newTokenAddress);
    }

    // Additional functions and logic as needed
}
