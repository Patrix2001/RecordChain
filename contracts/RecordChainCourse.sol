//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./RecordChainStorage.sol";

contract RecordChainCourse {
    /* Library Course: Create Course, Update Course, 
    List Courses, Course-Trainer, Course-Learner */
    bytes32[] private courseId;

    event UpdateCourse(
        bytes32 courseId,
        address indexed trainer,
        bool isActive
    );

    modifier isUser(uint256 role) {
        require(
            recordChain.getUserRole(msg.sender) == role,
            "Only User Permissioned"
        );
        _;
    }

    RecordChainStorage recordChain;

    constructor(address _recordChainAddress) {
        recordChain = RecordChainStorage(_recordChainAddress);
    }

    function getCourseIds() public view returns (bytes32[] memory) {
        return courseId;
    }

    function createCourse(
        string memory _name,
        string memory _institute,
        string memory _instructor,
        uint256 _price
    ) public isUser(1) returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(msg.sender, _name, _price));
        bool success = recordChain.setCourse(
            id,
            msg.sender,
            _name,
            _institute,
            _instructor,
            _price,
            true
        );
        emit UpdateCourse(id, msg.sender, true);
        courseId.push(id);
        return success;
    }

    function updateCourse(
        uint256 _courseId,
        string memory _name,
        string memory _institute,
        string memory _instructor,
        uint256 _price,
        bool _isActive
    ) public isUser(1) returns (bool) {
        bytes32 id = courseId[_courseId];

        bool success = recordChain.updateCourse(
            id,
            msg.sender,
            _name,
            _institute,
            _instructor,
            _price,
            _isActive
        );
        emit UpdateCourse(id, msg.sender, _isActive);
        return success;
    }

    function getAllCourse()
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
        uint256 courseNumber = courseId.length;
        address[] memory trainer = new address[](courseNumber);
        string[] memory name = new string[](courseNumber);
        string[] memory institute = new string[](courseNumber);
        string[] memory instructor = new string[](courseNumber);
        uint256[] memory price = new uint256[](courseNumber);
        bool[] memory isActive = new bool[](courseNumber);
        (trainer, name, institute, instructor, price, isActive) = recordChain
            .getCourse(courseId);
        return (trainer, name, institute, instructor, price, isActive);
    }

    function getCourseTrainer()
        public
        view
        isUser(1)
        returns (
            string[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        uint256 courseNumber = courseId.length;
        string[] memory name = new string[](courseNumber);
        string[] memory institute = new string[](courseNumber);
        string[] memory instructor = new string[](courseNumber);
        uint256[] memory price = new uint256[](courseNumber);
        bool[] memory isActive = new bool[](courseNumber);
        (name, institute, instructor, price, isActive) = recordChain
            .getCourseByTrainer(msg.sender);
        return (name, institute, instructor, price, isActive);
    }

    function getCourseLearner()
        public
        view
        isUser(2)
        returns (
            string memory name,
            string memory institute,
            string memory instructor,
            uint256 price,
            bool isActive
        )
    {
        (name, institute, instructor, price, isActive) = recordChain
            .getCourseByLearner(msg.sender);
        return (name, institute, instructor, price, isActive);
    }
}
