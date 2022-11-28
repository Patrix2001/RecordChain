//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./Constant.sol";

contract RecordChainStorage {
    struct User {
        string name;
        string phone;
        bytes32 role;
    }

    struct Institute {
        string name;
        string category;
        address[] trainer;
    }

    struct Learner {
        bytes32[] courseId;
        bytes32[] transactionId;
        bytes32[] certificateId;
    }

    struct Trainer {
        string institute;
        bytes32[] courseId;
        bytes32[] transactionId;
    }

    struct Course {
        address trainer;
        string name;
        string institute;
        string instructor;
        uint256 price;
        bool isActive;
        Constant.CourseLearningOutcome[] learningOutcomes;
    }

    struct Certificate {
        address candidateAddress;
        bytes32 courseId;
        uint256[] score;
        uint256 issuanceTime;
    }

    mapping(address => User) private userDetails;
    mapping(bytes32 => Course) private courseDetails;
    mapping(bytes32 => Certificate) private certificateCourse;
    mapping(bytes32 => address) private transactionCourse;
    mapping(bytes32 => Institute) private instituteDetails;
    mapping(address => Learner) private learnerDetails;
    mapping(address => Trainer) private trainerDetails;

    function setUser(
        address _userAddress,
        string memory _name,
        string memory _phone,
        bytes32 _role
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
            bytes32 role
        )
    {
        User memory profile = userDetails[_userAddress];
        return (profile.name, profile.phone, profile.role);
    }

    function getUserRole(address _userAddress) public view returns (bytes32) {
        User memory profile = userDetails[_userAddress];
        return (profile.role);
    }

    function setInstitute(
        bytes32 _instituteId,
        string memory _name,
        string memory _category
    ) public returns (bool) {
        instituteDetails[_instituteId].name = _name;
        instituteDetails[_instituteId].category = _category;
        return true;
    }

    function getInstitute(bytes32[] memory _instituteIds)
        public
        view
        returns (string[] memory, string[] memory)
    {
        uint256 instituteNumber = _instituteIds.length;
        string[] memory name = new string[](instituteNumber);
        string[] memory category = new string[](instituteNumber);
        for (uint256 i = 0; i < instituteNumber; i++) {
            bytes32 id = _instituteIds[i];
            name[i] = instituteDetails[id].name;
            category[i] = instituteDetails[id].category;
        }
        return (name, category);
    }

    function getInstituteById(bytes32 _instituteId)
        public
        view
        returns (
            string memory name,
            string memory category,
            address[] memory trainer
        )
    {
        Institute memory profile = instituteDetails[_instituteId];
        return (profile.name, profile.category, profile.trainer);
    }

    function setTrainer(bytes32 _instituteId, address _userAddress)
        public
        returns (bool)
    {
        trainerDetails[_userAddress].institute = instituteDetails[_instituteId]
            .name;
        instituteDetails[_instituteId].trainer.push(_userAddress);
        return true;
    }

    function getTrainer(address _trainerAddress)
        public
        view
        returns (
            string memory institute,
            bytes32[] memory courseId,
            bytes32[] memory transactionId
        )
    {
        Trainer memory profile = trainerDetails[_trainerAddress];
        return (profile.institute, profile.courseId, profile.transactionId);
    }

    function checkTrainer(bytes32 _instituteId, address _userAddress)
        public
        view
        returns (bool)
    {
        return
            keccak256(
                abi.encodePacked(trainerDetails[_userAddress].institute)
            ) ==
            keccak256(abi.encodePacked(instituteDetails[_instituteId].name));
    }

    function getLearner(address _learnerAddress)
        public
        view
        returns (
            bytes32[] memory courseId,
            bytes32[] memory transactionId,
            bytes32[] memory certificateId
        )
    {
        Learner memory profile = learnerDetails[_learnerAddress];
        return (profile.courseId, profile.transactionId, profile.certificateId);
    }

    function setCourse(
        bytes32 _courseId,
        address _trainer,
        string memory _name,
        uint256 _price,
        bool _isActive,
        Constant.CourseLearningOutcome[] memory learningOutcome
    ) public returns (bool) {
        Course memory course = courseDetails[_courseId];
        course.trainer = _trainer;
        course.name = _name;
        course.institute = trainerDetails[_trainer].institute;
        course.instructor = userDetails[_trainer].name;
        course.price = _price;
        course.isActive = _isActive;
        uint256 count = learningOutcome.length;
        for (uint256 i = 0; i < count; i++) {
            courseDetails[_courseId].learningOutcomes.push(
                Constant.CourseLearningOutcome({
                    name: learningOutcome[i].name,
                    weight: learningOutcome[i].weight,
                    score: learningOutcome[i].score,
                    credits: learningOutcome[i].credits
                })
            );
        }
        trainerDetails[_trainer].courseId.push(_courseId);
        return true;
    }

    function updateCourse(bytes32 _courseId, bool _isActive)
        public
        returns (bool)
    {
        courseDetails[_courseId].isActive = _isActive;
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
            Course memory course = courseDetails[courseId];
            trainer[i] = course.trainer;
            name[i] = course.name;
            institute[i] = course.institute;
            instructor[i] = course.instructor;
            price[i] = course.price;
            isActive[i] = course.isActive;
        }
        return (trainer, name, institute, instructor, price, isActive);
    }

    function getCourseById(bytes32 _courseId)
        public
        view
        returns (
            address trainer,
            string memory name,
            string memory institute,
            string memory instructor,
            uint256 price,
            bool isActive,
            Constant.CourseLearningOutcome[] memory learningOutcomes
        )
    {
        Course memory profile = courseDetails[_courseId];

        return (
            profile.trainer,
            profile.name,
            profile.institute,
            profile.instructor,
            profile.price,
            profile.isActive,
            profile.learningOutcomes
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
        bytes32[] memory courseList = trainerDetails[_trainer].courseId;
        uint256 count = courseList.length;
        string[] memory name = new string[](count);
        string[] memory institute = new string[](count);
        string[] memory instructor = new string[](count);
        uint256[] memory price = new uint256[](count);
        bool[] memory isActive = new bool[](count);
        (, name, institute, instructor, price, isActive) = getCourse(
            courseList
        );
        return (name, institute, instructor, price, isActive);
    }

    function getCourseByLearner(address _learner)
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
        bytes32[] memory courseList = learnerDetails[_learner].courseId;
        uint256 count = courseList.length;
        string[] memory name = new string[](count);
        string[] memory institute = new string[](count);
        string[] memory instructor = new string[](count);
        uint256[] memory price = new uint256[](count);
        bool[] memory isActive = new bool[](count);
        (, name, institute, instructor, price, isActive) = getCourse(
            courseList
        );
        return (name, institute, instructor, price, isActive);
    }

    function countCourseByLearner(address _learner)
        public
        view
        returns (uint256)
    {
        bytes32[] memory courseList = learnerDetails[_learner].courseId;
        return courseList.length;
    }

    function setTransaction(
        address _transactionAddress,
        bytes32 _transactionId,
        bytes32 _courseId,
        address _sender
    ) public payable returns (bool) {
        transactionCourse[_transactionId] = _transactionAddress;
        learnerDetails[_sender].transactionId.push(_transactionId);
        learnerDetails[_sender].courseId.push(_courseId);
        trainerDetails[courseDetails[_courseId].trainer].transactionId.push(
            _transactionId
        );
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
        bytes32[] memory transactionList = trainerDetails[_trainer]
            .transactionId;
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
        returns (address[] memory)
    {
        bytes32[] memory transactionList = learnerDetails[_learner]
            .transactionId;
        uint256 count = transactionList.length;
        address[] memory transaction = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            transaction[i] = transactionCourse[transactionList[i]];
        }
        return transaction;
    }

    function setCertificate(
        bytes32 _certId,
        address _candidateAddress,
        bytes32 _courseId,
        uint256[] memory _score,
        uint256 _issuanceTime
    ) public returns (bool) {
        certificateCourse[_certId] = Certificate({
            candidateAddress: _candidateAddress,
            courseId: _courseId,
            score: _score,
            issuanceTime: _issuanceTime
        });
        learnerDetails[_candidateAddress].certificateId.push(_certId);
        return true;
    }

    function generateCertificate(bytes32 _certificateId)
        public
        view
        returns (
            bytes32 certId,
            address candidateAddress,
            string memory candidateName,
            address issuerAddress,
            string memory issuerName,
            string memory courseName,
            string memory institute,
            Constant.CourseLearningOutcome[] memory learningOutcomes,
            uint256 issuanceTime
        )
    {
        certId = _certificateId;
        Certificate memory certificate = certificateCourse[certId];
        Course memory course = courseDetails[certificate.courseId];
        candidateAddress = certificate.candidateAddress;
        candidateName = userDetails[certificate.candidateAddress].name;
        issuerAddress = course.trainer;
        issuerName = userDetails[course.trainer].name;
        courseName = course.name;
        institute = course.institute;
        uint256 learnOutcome = course.learningOutcomes.length;
        for (uint256 i = 0; i < learnOutcome; i++) {
            learningOutcomes[i].name = course.learningOutcomes[i].name;
            learningOutcomes[i].weight = course.learningOutcomes[i].weight;
            learningOutcomes[i].score = certificate.score[i];
            learningOutcomes[i].credits = course.learningOutcomes[i].credits;
        }
        issuanceTime = certificate.issuanceTime;

        return (
            certId,
            candidateAddress,
            candidateName,
            issuerAddress,
            issuerName,
            courseName,
            institute,
            learningOutcomes,
            issuanceTime
        );
    }

    function getCertificateByLearner(address _learner)
        public
        view
        returns (
            bytes32[] memory,
            address[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory
        )
    {
        bytes32[] memory certId = learnerDetails[_learner].certificateId;
        uint256 count = certId.length;
        address[] memory candidateAddress = new address[](count);
        string[] memory courseName = new string[](count);
        string[] memory institute = new string[](count);
        uint256[] memory issuanceTime = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            bytes32 id = certId[i];
            Certificate memory certificate = certificateCourse[id];
            Course memory course = courseDetails[certificate.courseId];
            candidateAddress[i] = certificate.candidateAddress;
            courseName[i] = course.name;
            institute[i] = course.institute;
            issuanceTime[i] = certificate.issuanceTime;
        }

        return (certId, candidateAddress, courseName, institute, issuanceTime);
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
