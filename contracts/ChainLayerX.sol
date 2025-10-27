// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ChainLayerX
 * @dev A decentralized platform for secure data registration and verification on-chain.
 */
contract ChainLayerX {
    struct Record {
        string dataHash;
        uint256 timestamp;
        address owner;
    }

    mapping(uint256 => Record) private records;
    uint256 private recordCount;

    event RecordCreated(uint256 indexed id, address indexed owner, string dataHash, uint256 timestamp);
    event RecordVerified(uint256 indexed id, address indexed verifier, bool valid);

    /**
     * @dev Adds a new record to the blockchain.
     * @param _dataHash The hash of the data to be recorded.
     */
    function addRecord(string memory _dataHash) public {
        recordCount++;
        records[recordCount] = Record(_dataHash, block.timestamp, msg.sender);
        emit RecordCreated(recordCount, msg.sender, _dataHash, block.timestamp);
    }

    /**
     * @dev Retrieves details of a specific record by its ID.
     * @param _id The ID of the record to retrieve.
     */
    function getRecord(uint256 _id) public view returns (string memory, uint256, address) {
        require(_id > 0 && _id <= recordCount, "Record does not exist");
        Record memory r = records[_id];
        return (r.dataHash, r.timestamp, r.owner);
    }

    /**
     * @dev Verifies ownership of a record.
     * @param _id The ID of the record to verify.
     * @return isOwner True if the caller owns the record, false otherwise.
     */
    function verifyOwnership(uint256 _id) public view returns (bool isOwner) {
        require(_id > 0 && _id <= recordCount, "Record does not exist");
        return records[_id].owner == msg.sender;
    }

    /**
     * @dev Returns the total number of records stored.
     */
    function getTotalRecords() public view returns (uint256) {
        return recordCount;
    }
}
