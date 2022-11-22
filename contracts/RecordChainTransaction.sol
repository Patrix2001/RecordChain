//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./RecordChainStorage.sol";

uint256 constant reward = 1e18;

contract TransactionRegistry is Ownable {
    /* Library Transaction: Create Contract TransactionCourse, 
    List Transaction, Transaction-Trainer, Transaction-Learner */
    address private recordAddress;
    bytes32[] private transactionId;

    event NewTransaction(
        bytes32 transactionId,
        address indexed sender,
        address indexed recipient
    );

    modifier isUser(uint256 role) {
        require(
            recordChain.getUserRole(msg.sender) == role,
            "Only User Permissioned"
        );
        _;
    }

    RecordChainStorage recordChain;

    constructor(address _recordChainAddress) payable {
        recordChain = RecordChainStorage(_recordChainAddress);
        recordAddress = _recordChainAddress;
    }

    modifier minimumPay(uint256 _credits) {
        require(
            msg.value >= _credits + reward ||
                address(this).balance >= _credits + reward
        );
        _;
    }

    modifier isOnTransaction() {
        require(getTransactionLearner() == address(0), "Already enroll course");
        _;
    }

    function createTransaction(
        string memory _courseName,
        uint256 _credits,
        address _recipient
    )
        public
        payable
        minimumPay(_credits)
        isUser(2)
        isOnTransaction
        returns (bool)
    {
        bool active = checkCourse(_recipient, _courseName, _credits);
        require(active, "Course is not active");

        bytes32 id = keccak256(
            abi.encodePacked(msg.sender, _recipient, _courseName)
        );

        bool success = recordChain.setTransaction{value: _credits + reward}(
            recordAddress,
            id,
            _courseName,
            _credits,
            owner,
            msg.sender,
            _recipient,
            false,
            block.timestamp,
            0
        );

        emit NewTransaction(id, msg.sender, _recipient);
        transactionId.push(id);
        return success;
    }

    function getAllTransaction()
        public
        view
        onlyOwner
        returns (address[] memory)
    {
        return recordChain.getTransaction(transactionId);
    }

    function balance() public view onlyOwner returns (uint256) {
        return payable(address(this)).balance;
    }

    function transferBalance() public payable onlyOwner returns (bool) {
        return true;
    }

    function getTransactionTrainer()
        public
        view
        isUser(1)
        returns (address[] memory)
    {
        address[] memory transaction = new address[](transactionId.length);
        transaction = recordChain.getTransactionByTrainer(msg.sender);
        return transaction;
    }

    function getTransactionLearner() public view isUser(2) returns (address) {
        return recordChain.getTransactionByLearner(msg.sender);
    }

    function checkCourse(
        address _trainer,
        string memory _name,
        uint256 _price
    ) private view returns (bool) {
        bytes32 courseId = keccak256(abi.encodePacked(_trainer, _name, _price));
        (, , , , bool isActive) = recordChain.getCourseById(courseId);
        return isActive;
    }
}

contract TransactionCourse {
    /* Collect Credits to Owner, Send Credits to Trainer, Send Reward to Learner */
    string private courseName;
    address private owner;
    address private sender;
    address private recipient;
    bool private isPaid;
    uint256 private creationTime;
    uint256 private receivalTime;
    uint256 public credits = 999e18;

    modifier isAlreadyPaid() {
        require(!isPaid, "Complete Transaction");
        _;
    }

    RecordChainStorage recordChain;

    constructor(
        address _recordChainAddress,
        string memory _courseName,
        address _owner,
        address _sender,
        address _recipient,
        bool _isPaid,
        uint256 _creationTime,
        uint256 _receivalTime
    ) payable {
        recordChain = RecordChainStorage(_recordChainAddress);
        courseName = _courseName;
        owner = _owner;
        sender = _sender;
        recipient = _recipient;
        isPaid = _isPaid;
        creationTime = _creationTime;
        receivalTime = _receivalTime;
    }

    function sendCredit() external payable isAlreadyPaid {
        require(checkCertified(), "Need Certify");

        (bool sent, ) = sender.call{value: reward}("");
        require(sent, "Failed to send Ether");

        (bool paid, ) = recipient.call{value: address(this).balance}("");
        require(paid, "Failed to send Ether");

        isPaid = paid;
        receivalTime = block.timestamp;
    }

    function requestCredit() external payable isAlreadyPaid {
        credits = address(this).balance - reward;
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function payCourse() external payable isAlreadyPaid {
        require(msg.value == credits, "Credits Not Enough");
        (bool paid, ) = recipient.call{value: msg.value}("");
        require(paid, "Failed to send Ether");
        credits -= msg.value;
        isPaid = paid;
        receivalTime = block.timestamp;
    }

    function getBasicInformation()
        public
        view
        returns (
            string memory,
            address,
            address,
            address,
            bool,
            uint256,
            uint256
        )
    {
        return (
            courseName,
            owner,
            sender,
            recipient,
            isPaid,
            creationTime,
            receivalTime
        );
    }

    function balance() public view returns (uint256) {
        return payable(address(this)).balance;
    }

    function checkCertified() public view returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(sender, recipient));
        return recordChain.checkCertificate(id, sender);
    }
}
