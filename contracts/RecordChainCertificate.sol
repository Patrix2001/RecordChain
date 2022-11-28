//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./RecordChainStorage.sol";
import "./Constant.sol";

contract RecordChainCertificate {
    /* Function Certificate: Create Certificate, Learner-Certificate
    Generate Certificate, Proof Certificate */

    // State variables
    bytes32[] private certificateId;
    RecordChainStorage recordChain;

    // Events
    event NewCertificate(
        bytes32 certificateId,
        address indexed candidateAddress,
        address indexed issuerAddress
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

    // public functions
    function issueCertificate(
        address _candidateAddress,
        bytes32 _courseId,
        uint256[] memory _score
    ) public isUser("TRAINER") returns (bool) {
        require(msg.sender != address(0));
        (
            ,
            string memory name,
            ,
            ,
            ,
            ,
            Constant.CourseLearningOutcome[] memory learningOutcomes
        ) = recordChain.getCourseById(_courseId);
        require(learningOutcomes.length == _score.length, "Invalid score");
        bytes32 id = keccak256(
            abi.encodePacked(_candidateAddress, msg.sender, name)
        );
        bool success = recordChain.setCertificate(
            id,
            _candidateAddress,
            _courseId,
            _score,
            block.timestamp
        );

        emit NewCertificate(id, _candidateAddress, msg.sender);
        certificateId.push(id);
        return success;
    }

    function getCertificateLearner()
        public
        view
        isUser("LEARNER")
        returns (
            bytes32[] memory certId,
            address[] memory candidateAddress,
            string[] memory courseName,
            string[] memory institute,
            uint256[] memory issuanceTime
        )
    {
        return recordChain.getCertificateByLearner(msg.sender);
    }

    function getCertificateId(bytes32 _certificateId)
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
        return recordChain.generateCertificate(_certificateId);
    }

    function proofCertificate(bytes32 _certificateId, address _learner)
        public
        view
        returns (bool)
    {
        return recordChain.checkCertificate(_certificateId, _learner);
    }
}
