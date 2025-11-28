// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    ChainLayerX (Single Contract)
    Purpose: Unified Access + Credits + Data Storage Layer

    ✔ User Registration
    ✔ Credit-based API usage
    ✔ Pay-per-call top-up
    ✔ Blacklist protection
    ✔ On-chain data storage with timestamp + signature
*/

contract ChainLayerX {
    address public owner;
    uint256 public pricePerCredit = 0.005 ether;
    uint256 public nextEntryId = 1;

    struct User {
        bool registered;
        bool blacklisted;
        uint256 credits;
    }

    struct Entry {
        uint256 id;
        string payload;
        address creator;
        uint256 timestamp;
    }

    mapping(address => User) public users;
    mapping(uint256 => Entry) public entries;

    // Events
    event Registered(address indexed user);
    event CreditsAdded(address indexed user, uint256 credits);
    event Blacklisted(address indexed user);
    event Whitelisted(address indexed user);
    event Stored(uint256 indexed id, address indexed creator, string payload);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "Register first");
        require(!users[msg.sender].blacklisted, "Blacklisted");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// Register new user (free + 10 initial credits)
    function register() external {
        require(!users[msg.sender].registered, "Already registered");
        users[msg.sender] = User(true, false, 10);
        emit Registered(msg.sender);
    }

    /// Add usage credits by paying ETH
    function addCredits() external payable onlyRegistered {
        require(msg.value >= pricePerCredit, "Insufficient");
        uint256 credits = msg.value / pricePerCredit;
        users[msg.sender].credits += credits;
        emit CreditsAdded(msg.sender, credits);
    }

    /// Store data on-chain (cost 1 credit)
    function storeData(string calldata payload) external onlyRegistered {
        require(users[msg.sender].credits > 0, "No credits");
        users[msg.sender].credits -= 1;

        uint256 id = nextEntryId++;
        entries[id] = Entry(id, payload, msg.sender, block.timestamp);

        emit Stored(id, msg.sender, payload);
    }

    /// Read stored entry
    function readData(uint256 id) external view returns (Entry memory) {
        require(entries[id].id != 0, "Not found");
        return entries[id];
    }

    /// Admin — blacklist a user
    function blacklist(address user) external onlyOwner {
        users[user].blacklisted = true;
        emit Blacklisted(user);
    }

    /// Admin — remove from blacklist
    function whitelist(address user) external onlyOwner {
        users[user].blacklisted = false;
        emit Whitelisted(user);
    }

    /// Admin — withdraw contract balance
    function withdraw(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }
}
