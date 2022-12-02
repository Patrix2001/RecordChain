//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./RecordChainStorage.sol";

uint256 constant REWARD = 1e18;

contract TransactionRegistry is Ownable {
    /* Library Transaction: Create Contract TransactionCourse, 
    List Transaction, Transaction-Trainer, Transaction-Learner */

    // State variables
    address private recordAddress;
    bytes32[] private transactionId;
    uint256 public limit; // max attempt course
    RecordChainStorage recordChain;

    // Events
    event NewTransaction(
        bytes32 transactionId,
        address indexed sender,
        address indexed recipient
    );

    // Modifiers
    modifier isUser(string memory role) {
        require(
            recordChain.getUserRole(msg.sender) ==
                keccak256(abi.encodePacked(role)),
            "Only User Permissioned"
        );
        _;
    }

    modifier isMaxAttempt() {
        require(
            limit > recordChain.countCourseByLearner(msg.sender),
            "You have reached the course registration limit"
        );
        _;
    }

    modifier minimumPay(uint256 _credits) {
        require(address(this).balance >= _credits + REWARD);
        _;
    }

    // constructor, initialize state variables within constructor
    constructor(address _recordChainAddress, uint256 _limit) payable {
        recordChain = RecordChainStorage(_recordChainAddress);
        recordAddress = _recordChainAddress;
        limit = _limit;
    }

    // public functions
    function balance() public view onlyOwner returns (uint256) {
        return payable(address(this)).balance;
    }

    function requestBalance() public onlyOwner returns (bool) {
        (bool paid, ) = owner.call{value: address(this).balance}("");
        require(paid, "Failed to send Ether");
        return paid;
    }

    function transferBalance() public payable onlyOwner returns (bool) {
        return true;
    }

    function setLimit(uint256 _limit) public onlyOwner returns (bool) {
        limit = _limit;
        return true;
    }

    function createTransaction(
        string memory _courseName,
        uint256 _credits,
        address _recipient
    )
        public
        minimumPay(_credits)
        isUser("LEARNER")
        isMaxAttempt
        returns (bool)
    {
        bytes32 courseId = keccak256(
            abi.encodePacked(_recipient, _courseName, _credits)
        );
        (address trainer, , , , , bool isActive, ) = recordChain.getCourseById(
            courseId
        );
        require(isActive, "Course is not active");

        bytes32 id = keccak256(
            abi.encodePacked(msg.sender, _recipient, _courseName)
        );
        require(!checkTransaction(id), "Already enroll course");

        address newTransaction = address(
            (new TransactionCourse){value: _credits + REWARD}(
                recordAddress,
                courseId,
                owner,
                msg.sender,
                trainer,
                false,
                block.timestamp,
                0
            )
        );
        bool success = recordChain.setTransaction(
            newTransaction,
            id,
            courseId,
            msg.sender
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

    function getTransactionTrainer()
        public
        view
        isUser("TRAINER")
        returns (address[] memory)
    {
        address[] memory transaction = new address[](transactionId.length);
        transaction = recordChain.getTransactionByTrainer(msg.sender);
        return transaction;
    }

    function getTransactionLearner()
        public
        view
        isUser("LEARNER")
        returns (address[] memory)
    {
        return recordChain.getTransactionByLearner(msg.sender);
    }

    function checkTransaction(bytes32 _transactionId)
        private
        view
        returns (bool)
    {
        for (uint256 i = 0; i < transactionId.length; i++) {
            if (transactionId[i] == _transactionId) {
                return true;
            }
        }
        return false;
    }
}

contract TransactionCourse {
    /* Collect Credits to Owner, Send Credits to Trainer, Send reward to Learner */
    bytes32 private courseId;
    address private owner;
    address private sender;
    address private recipient;
    bool private isPaid;
    uint256 private creationTime;
    uint256 private receivalTime;
    uint256 private credits = 999e18;
    bool public isRequested;
    bool private isSentReward;
    RecordChainStorage recordChain;

    modifier isAlreadyPaid() {
        require(!isPaid, "Complete Transaction");
        _;
    }

    modifier isAlreadyRequest() {
        require(!isRequested, "You already request");
        _;
    }

    constructor(
        address _recordChainAddress,
        bytes32 _courseId,
        address _owner,
        address _sender,
        address _recipient,
        bool _isPaid,
        uint256 _creationTime,
        uint256 _receivalTime
    ) payable {
        recordChain = RecordChainStorage(_recordChainAddress);
        courseId = _courseId;
        owner = _owner;
        sender = _sender;
        recipient = _recipient;
        isPaid = _isPaid;
        creationTime = _creationTime;
        receivalTime = _receivalTime;
    }

    function sendCredit() external payable isAlreadyPaid {
        require(checkCertified(), "Need Certify");
        if (!isSentReward) {
            (bool sent, ) = sender.call{value: REWARD}("");
            require(sent, "Failed to send Ether");
            isSentReward = sent;
        }
        (bool paid, ) = recipient.call{value: address(this).balance}("");
        require(paid, "Failed to send Ether");
        isPaid = paid;
        receivalTime = block.timestamp;
    }

    function requestCredit() external payable isAlreadyPaid isAlreadyRequest {
        credits = address(this).balance - REWARD;
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
        isRequested = sent;
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
            bytes32,
            address,
            address,
            address,
            bool,
            uint256,
            uint256
        )
    {
        return (
            courseId,
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

    function checkCertified() private view returns (bool) {
        (, string memory name, , , , , ) = recordChain.getCourseById(courseId);
        bytes32 id = keccak256(abi.encodePacked(sender, recipient, name));
        return recordChain.checkCertificate(id, sender);
    }
}
