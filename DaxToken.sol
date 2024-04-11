// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./token/ERC20/ERC20.sol";
import "./token/ERC20/extensions/ERC20Burnable.sol";
import "./security/Pausable.sol";
import "./access/Ownable.sol";


contract DaxToken is ERC20, ERC20Burnable, Pausable, Ownable {
    uint256 public burnRate;
    constructor() ERC20("DaxToken", "DAX") {
        _mint(msg.sender, 42 * 10 ** 27);
        burnRate = 2; // Set initial burn rate to 3%
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

     function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // Function to update the burn rate
    function setBurnRate(uint256 newBurnRate) public onlyOwner {
        require(newBurnRate <= 100, "Burn rate cannot be more than 100%");
        burnRate = newBurnRate;
    }

    // Override the _transfer function to implement burning based on the variable burn rate
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        // Calculate the burn amount based on the current burn rate
        uint256 burnAmount = amount * burnRate / 100;

        // Calculate the amount to be transferred after burning
        uint256 sendAmount = amount - burnAmount;

        // Burn the calculated burn amount
        _burn(sender, burnAmount);

        // Proceed with the transfer after burning
        super._transfer(sender, recipient, sendAmount);
    }
}