//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./RecordChainStorage.sol";

contract RecordChainUser is Ownable {
    /* Function User: Set Profile, View Profile, Create Institute, 
    List Institute, View Institute, Update Trainer, View Trainer&Learner */

    // State variables
    bytes32[] private instituteId;
    RecordChainStorage recordChain;

    // Events
    event UserUpdate(
        address indexed user,
        string name,
        string phone,
        string role
    );
    event TrainerUpdate(address indexed user, string Institute);
    event InstituteUpdate(bytes32 indexed id, string name);

    // Modifiers
    modifier checkRole(string memory _role) {
        require(
            keccak256(abi.encodePacked(_role)) ==
                keccak256(abi.encodePacked("TRAINER")) ||
                keccak256(abi.encodePacked(_role)) ==
                keccak256(abi.encodePacked("LEARNER")),
            "Invalid Role"
        );
        _;
    }

    modifier checkAddress(address _userAddress) {
        require(_userAddress != address(0), "User Address is null");
        _;
    }

    // constructor, initialize state variables within constructor
    constructor(address _recordChainAddress) {
        recordChain = RecordChainStorage(_recordChainAddress);
    }

    // public functions
    function updateUser(
        address _userAddress,
        string memory _name,
        string memory _phone,
        string memory _role
    )
        public
        onlyOwner
        checkAddress(_userAddress)
        checkRole(_role)
        returns (bool)
    {
        bytes32 role_byte = keccak256(abi.encodePacked(_role));
        bool success = recordChain.setUser(
            _userAddress,
            _name,
            _phone,
            role_byte
        );
        emit UserUpdate(msg.sender, _name, _phone, _role);
        return success;
    }

    function getUser(address _userAddress)
        public
        view
        onlyOwner
        checkAddress(_userAddress)
        returns (
            string memory name,
            string memory phone,
            bytes32 role
        )
    {
        (name, phone, role) = recordChain.getUser(_userAddress);
        return (name, phone, role);
    }

    function createInstitute(string memory _name, string memory _category)
        public
        onlyOwner
        returns (bool)
    {
        bytes32 id = keccak256(abi.encodePacked(_name));
        bool success = recordChain.setInstitute(id, _name, _category);
        emit InstituteUpdate(id, _name);
        instituteId.push(id);
        return success;
    }

    function updateTrainer(address _userAddress, string memory _institute)
        public
        onlyOwner
        checkAddress(_userAddress)
        returns (bool)
    {
        require(isTrainer(_userAddress), "This user is not a Trainer");
        require(checkInstitute(_institute), "Institute not found");

        bytes32 id = keccak256(abi.encodePacked(_institute));
        bool success = recordChain.setTrainer(id, _userAddress);
        emit TrainerUpdate(_userAddress, _institute);
        return success;
    }

    function viewProfile()
        public
        view
        returns (
            string memory name,
            string memory phone,
            bytes32 role
        )
    {
        (name, phone, role) = recordChain.getUser(msg.sender);
        return (name, phone, role);
    }

    function getInstituteIds() public view returns (bytes32[] memory) {
        return instituteId;
    }

    function getAllInstitute()
        public
        view
        returns (string[] memory name, string[] memory category)
    {
        (name, category) = recordChain.getInstitute(instituteId);
        return (name, category);
    }

    function getInstituteId(string memory _name)
        public
        view
        returns (
            string memory name,
            string memory category,
            address[] memory trainer
        )
    {
        (name, category, trainer) = recordChain.getInstituteById(
            keccak256(abi.encodePacked(_name))
        );
        return (name, category, trainer);
    }

    function getTrainer(address _userAddress)
        public
        view
        returns (
            string memory institute,
            bytes32[] memory courseId,
            bytes32[] memory transactionId
        )
    {
        (institute, courseId, transactionId) = recordChain.getTrainer(
            _userAddress
        );
        return (institute, courseId, transactionId);
    }

    function verifyTrainer(string memory _name, address _userAddress)
        public
        view
        returns (bool)
    {
        bytes32 id = keccak256(abi.encodePacked(_name));
        return recordChain.checkTrainer(id, _userAddress);
    }

    function getLearner(address _userAddress)
        public
        view
        returns (
            bytes32[] memory courseId,
            bytes32[] memory transactionId,
            bytes32[] memory certificateId
        )
    {
        (courseId, transactionId, certificateId) = recordChain.getLearner(
            _userAddress
        );
        return (courseId, transactionId, certificateId);
    }

    // private functions
    function isTrainer(address _userAddress) private view returns (bool) {
        return
            recordChain.getUserRole(_userAddress) ==
            keccak256(abi.encodePacked("TRAINER"));
    }

    function checkInstitute(string memory _name) private view returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(_name));
        (string memory name, , ) = recordChain.getInstituteById(id);
        return id == keccak256(abi.encodePacked(name));
    }
}
