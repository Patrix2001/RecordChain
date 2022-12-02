//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./RecordChainStorage.sol";
import "./Constant.sol";

contract RecordChainCourse {
    /* Function Course: Create Course, Update Course, List Courses, 
    Course-Id, Course-Trainer, Course-Learner */

    // State variables
    bytes32[] private courseId;
    RecordChainStorage recordChain;

    // Events
    event UpdateCourse(
        bytes32 courseId,
        address indexed trainer,
        bool isActive
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

    // constructor, initialize state variables within constructor
    constructor(address _recordChainAddress) {
        recordChain = RecordChainStorage(_recordChainAddress);
    }

    // external functions
    function createCourse(
        string memory _name,
        uint256 _price,
        Constant.CourseLearningOutcome[] memory learningOutcome
    ) external isUser("TRAINER") returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(msg.sender, _name, _price));
        bool success = recordChain.setCourse(
            id,
            msg.sender,
            _name,
            _price,
            true,
            learningOutcome
        );
        emit UpdateCourse(id, msg.sender, true);
        courseId.push(id);
        return success;
    }

    // public functions
    function getCourseIds() public view returns (bytes32[] memory) {
        return courseId;
    }

    function updateCourse(bytes32 _courseId, bool _isActive)
        public
        isUser("TRAINER")
        returns (bool)
    {
        bool success = recordChain.updateCourse(_courseId, _isActive);
        emit UpdateCourse(_courseId, msg.sender, _isActive);
        return success;
    }

    function getAllCourse()
        public
        view
        returns (
            bytes32[] memory,
            address[] memory,
            string[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        uint256 courseNumber = courseId.length;
        address[] memory trainer = new address[](courseNumber);
        string[] memory name = new string[](courseNumber);
        string[] memory institute = new string[](courseNumber);
        string[] memory instructor = new string[](courseNumber);
        uint256[] memory price = new uint256[](courseNumber);
        bool[] memory isActive = new bool[](courseNumber);
        (trainer, name, institute, instructor, price, isActive) = recordChain
            .getCourse(courseId);
        return (
            courseId,
            trainer,
            name,
            institute,
            instructor,
            price,
            isActive
        );
    }

    function getCourseId(bytes32 _courseId)
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
        (
            trainer,
            name,
            institute,
            instructor,
            price,
            isActive,
            learningOutcomes
        ) = recordChain.getCourseById(_courseId);
        return (
            trainer,
            name,
            institute,
            instructor,
            price,
            isActive,
            learningOutcomes
        );
    }

    function getCourseTrainer()
        public
        view
        isUser("TRAINER")
        returns (
            bytes32[] memory id,
            string[] memory name,
            string[] memory institute,
            string[] memory instructor,
            uint256[] memory price,
            bool[] memory isActive
        )
    {
        (id, name, institute, instructor, price, isActive) = recordChain
            .getCourseByTrainer(msg.sender);
        return (id, name, institute, instructor, price, isActive);
    }

    function getCourseLearner()
        public
        view
        isUser("LEARNER")
        returns (
            bytes32[] memory id,
            string[] memory name,
            string[] memory institute,
            string[] memory instructor,
            uint256[] memory price,
            bool[] memory isActive
        )
    {
        (id, name, institute, instructor, price, isActive) = recordChain
            .getCourseByLearner(msg.sender);
        return (id, name, institute, instructor, price, isActive);
    }
}
