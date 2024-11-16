// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title BuyMeACoffee - A smart contract to support creators by sending ETH tips.
/// @dev Allows users to send tips with a memo, and the owner can withdraw the accumulated funds.
contract BuyMeACoffee {
    // Event to emit when a Memo is created.
    event NewMemo(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );
    
    // Memo struct to hold details about each coffee purchase.
    struct Memo {
        address from; // Address of the sender.
        uint256 timestamp; // Timestamp of the memo.
        string name; // Name of the sender.
        string message; // Message from the sender.
    }
    
    // Address of contract deployer (owner). Marked payable to allow withdrawal of funds.
    address payable public owner;

    // List to store all memos received.
    Memo[] private memos;

    /// @dev Constructor sets the deployer as the contract owner.
    constructor() {
        owner = payable(msg.sender);
    }

    /// @notice Fetches all memos stored in the contract.
    /// @return An array of Memo structs.
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

    /// @notice Allows users to buy a coffee for the owner by sending ETH and leaving a memo.
    /// @dev Requires the sender to send a non-zero amount of ETH.
    /// @param _name The name of the purchaser.
    /// @param _message A custom message from the purchaser.
    function buyCoffee(string memory _name, string memory _message) public payable {
        // Ensure the tip is greater than zero.
        require(msg.value > 0, "Can't buy coffee for free!");

        // Store the memo details in the memos array.
        memos.push(Memo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        ));

        // Emit a NewMemo event for off-chain tracking or analytics.
        emit NewMemo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        );
    }

    /// @notice Withdraws all ETH stored in the contract to the owner's address.
    /// @dev Only callable by the owner. Uses the `transfer` method for safety.
    function withdrawTips() public {
        require(msg.sender == owner, "Only the owner can withdraw tips!");
        require(address(this).balance > 0, "No funds available to withdraw!");

        // Transfer the entire contract balance to the owner.
        owner.transfer(address(this).balance);
    }
}
