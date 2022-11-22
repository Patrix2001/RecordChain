//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./RecordChainStorage.sol";

contract RecordChainCertificate {
    /* Library Certificate: Create Certificate, Learner-Certificate
    Proof Certificate */
    bytes32[] private certificateId;

    event NewCertificate(
        bytes32 certificateId,
        address indexed candidateAddress,
        address indexed issuerAddress
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

    function issueCertificate(
        address _candidateAddress,
        string memory _candidateName,
        string memory _issuerName,
        string memory _courseName
    ) public isUser(1) returns (bool) {
        require(msg.sender != address(0));

        bytes32 id = keccak256(abi.encodePacked(_candidateAddress, msg.sender));
        bool success = recordChain.setCertificate(
            id,
            _candidateAddress,
            msg.sender,
            _candidateName,
            _issuerName,
            _courseName,
            block.timestamp
        );

        emit NewCertificate(id, _candidateAddress, msg.sender);
        certificateId.push(id);
        return success;
    }

    function getCertificateLearner()
        public
        view
        isUser(2)
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
        require(msg.sender != address(0));

        (
            certId,
            candidateAddress,
            issuerAddress,
            candidateName,
            issuerName,
            courseName,
            issuanceTime
        ) = recordChain.getCertificateByLearner(msg.sender);
        return (
            certId,
            candidateAddress,
            issuerAddress,
            candidateName,
            issuerName,
            courseName,
            issuanceTime
        );
    }

    function proofCertificate(bytes32 _certificateId, address _learner)
        public
        view
        returns (bool)
    {
        return recordChain.checkCertificate(_certificateId, _learner);
    }
}
