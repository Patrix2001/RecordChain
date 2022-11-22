//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./RecordChainTransaction.sol";

contract RecordChainStorage {
    struct User {
        string name;
        string phone;
        uint256 role;
    }

    struct Course {
        address trainer;
        string name;
        string institute;
        string instructor;
        uint256 price;
        bool isActive;
    }

    struct Certificate {
        address candidateAddress;
        address issuerAddress;
        string candidateName;
        string issuerName;
        string courseName;
        uint256 issuanceTime;
    }

    mapping(address => User) private userDetails;
    mapping(bytes32 => Course) private courseDetails;
    mapping(bytes32 => Certificate) private certificateCourse;
    mapping(address => bytes32[]) private trainerCourse;
    mapping(address => bytes32[]) private trainerTransaction;
    mapping(address => bytes32) private learnerCourse;
    mapping(address => bytes32) private learnerTransaction;
    mapping(address => bytes32) private learnerCertificate;
    mapping(bytes32 => address) private transactionCourse;

    function setUser(
        address _userAddress,
        string memory _name,
        string memory _phone,
        uint256 _role
    ) public returns (bool) {
        userDetails[_userAddress] = User({
            name: _name,
            phone: _phone,
            role: _role
        });
        return true;
    }

    function getUser(address _userAddress)
        public
        view
        returns (
            string memory name,
            string memory phone,
            uint256 role
        )
    {
        User memory profile = userDetails[_userAddress];
        return (profile.name, profile.phone, profile.role);
    }

    function getUserRole(address _userAddress) public view returns (uint256) {
        User memory profile = userDetails[_userAddress];
        return (profile.role);
    }

    function setCourse(
        bytes32 _courseId,
        address _trainer,
        string memory _name,
        string memory _institute,
        string memory _instructor,
        uint256 _price,
        bool _isActive
    ) public returns (bool) {
        courseDetails[_courseId] = Course({
            trainer: _trainer,
            name: _name,
            institute: _institute,
            instructor: _instructor,
            price: _price,
            isActive: _isActive
        });
        trainerCourse[_trainer].push(_courseId);
        return true;
    }

    function updateCourse(
        bytes32 _courseId,
        address _trainer,
        string memory _name,
        string memory _institute,
        string memory _instructor,
        uint256 _price,
        bool _isActive
    ) public returns (bool) {
        courseDetails[_courseId] = Course({
            trainer: _trainer,
            name: _name,
            institute: _institute,
            instructor: _instructor,
            price: _price,
            isActive: _isActive
        });
        return true;
    }

    function getCourse(bytes32[] memory _courseIds)
        public
        view
        returns (
            address[] memory,
            string[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        uint256 courseNumber = _courseIds.length;
        address[] memory trainer = new address[](courseNumber);
        string[] memory name = new string[](courseNumber);
        string[] memory institute = new string[](courseNumber);
        string[] memory instructor = new string[](courseNumber);
        uint256[] memory price = new uint256[](courseNumber);
        bool[] memory isActive = new bool[](courseNumber);
        for (uint256 i = 0; i < courseNumber; i++) {
            bytes32 courseId = _courseIds[i];
            trainer[i] = courseDetails[courseId].trainer;
            name[i] = courseDetails[courseId].name;
            institute[i] = courseDetails[courseId].institute;
            instructor[i] = courseDetails[courseId].instructor;
            price[i] = courseDetails[courseId].price;
            isActive[i] = courseDetails[courseId].isActive;
        }
        return (trainer, name, institute, instructor, price, isActive);
    }

    function getCourseById(bytes32 _courseId)
        public
        view
        returns (
            string memory name,
            string memory institute,
            string memory instructor,
            uint256 price,
            bool isActive
        )
    {
        Course memory profile = courseDetails[_courseId];

        return (
            profile.name,
            profile.institute,
            profile.instructor,
            profile.price,
            profile.isActive
        );
    }

    function getCourseByTrainer(address _trainer)
        public
        view
        returns (
            string[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        bytes32[] memory courseList = trainerCourse[_trainer];
        uint256 count = courseList.length;
        string[] memory name = new string[](count);
        string[] memory institute = new string[](count);
        string[] memory instructor = new string[](count);
        uint256[] memory price = new uint256[](count);
        bool[] memory isActive = new bool[](count);
        for (uint256 i = 0; i < count; i++) {
            bytes32 courseId = courseList[i];
            name[i] = courseDetails[courseId].name;
            institute[i] = courseDetails[courseId].institute;
            instructor[i] = courseDetails[courseId].instructor;
            price[i] = courseDetails[courseId].price;
            isActive[i] = courseDetails[courseId].isActive;
        }
        return (name, institute, instructor, price, isActive);
    }

    function getCourseByLearner(address _learner)
        public
        view
        returns (
            string memory name,
            string memory institute,
            string memory instructor,
            uint256 price,
            bool isActive
        )
    {
        Course memory profile = courseDetails[learnerCourse[_learner]];

        return (
            profile.name,
            profile.institute,
            profile.instructor,
            profile.price,
            profile.isActive
        );
    }

    function setTransaction(
        address _recordAddress,
        bytes32 _transactionId,
        string memory _courseName,
        uint256 _credits,
        address _owner,
        address _sender,
        address _recipient,
        bool _isPaid,
        uint256 _creationTime,
        uint256 _receivalTime
    ) public payable returns (bool) {
        bytes32 id = keccak256(
            abi.encodePacked(_recipient, _courseName, _credits)
        );

        address newTransaction = address(
            (new TransactionCourse){value: msg.value}(
                _recordAddress,
                _courseName,
                _owner,
                _sender,
                _recipient,
                _isPaid,
                _creationTime,
                _receivalTime
            )
        );
        transactionCourse[_transactionId] = newTransaction;
        learnerCourse[_sender] = id;
        learnerTransaction[_sender] = _transactionId;
        trainerTransaction[_recipient].push(_transactionId);
        return true;
    }

    function getTransaction(bytes32[] memory _transactionId)
        public
        view
        returns (address[] memory)
    {
        uint256 transactionNumber = _transactionId.length;
        address[] memory transaction = new address[](transactionNumber);
        for (uint256 i = 0; i < transactionNumber; i++) {
            transaction[i] = transactionCourse[_transactionId[i]];
        }
        return transaction;
    }

    function getTransactionByTrainer(address _trainer)
        public
        view
        returns (address[] memory)
    {
        bytes32[] memory transactionList = trainerTransaction[_trainer];
        uint256 count = transactionList.length;
        address[] memory transaction = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            transaction[i] = transactionCourse[transactionList[i]];
        }
        return transaction;
    }

    function getTransactionByLearner(address _learner)
        public
        view
        returns (address)
    {
        return transactionCourse[learnerTransaction[_learner]];
    }

    function setCertificate(
        bytes32 _certId,
        address _candidateAddress,
        address _issuerAddress,
        string memory _candidateName,
        string memory _issuerName,
        string memory _courseName,
        uint256 _issuanceTime
    ) public returns (bool) {
        certificateCourse[_certId] = Certificate({
            candidateAddress: _candidateAddress,
            issuerAddress: _issuerAddress,
            candidateName: _candidateName,
            issuerName: _issuerName,
            courseName: _courseName,
            issuanceTime: _issuanceTime
        });
        learnerCertificate[_candidateAddress] = _certId;
        return true;
    }

    function getCertificateByLearner(address _learner)
        public
        view
        returns (
            bytes32 certId,
            address candidateAddress,
            address issuerAddress,
            string memory candidateName,
            string memory issuerName,
            string memory courseName,
            uint256 issuanceTime
        )
    {
        Certificate memory certificate = certificateCourse[
            learnerCertificate[_learner]
        ];
        return (
            learnerCertificate[_learner],
            certificate.candidateAddress,
            certificate.issuerAddress,
            certificate.candidateName,
            certificate.issuerName,
            certificate.courseName,
            certificate.issuanceTime
        );
    }

    function checkCertificate(bytes32 _certificateId, address _learner)
        public
        view
        returns (bool)
    {
        Certificate memory storageCertificate = certificateCourse[
            _certificateId
        ];
        return storageCertificate.candidateAddress == _learner;
    }
}
