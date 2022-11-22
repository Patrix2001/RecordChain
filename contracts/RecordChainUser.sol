//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./RecordChainStorage.sol";

contract RecordChainUser is Ownable {
    /* Library User: Set Profile, View Profile */
    event UserUpdate(address indexed user);

    RecordChainStorage recordChain;

    constructor(address _recordChainAddress) {
        recordChain = RecordChainStorage(_recordChainAddress);
    }

    modifier checkAddress(address _userAddress) {
        require(_userAddress != address(0), "User Address is null");
        _;
    }

    function getUser(address _userAddress)
        public
        view
        checkAddress(_userAddress)
        returns (
            string memory name,
            string memory phone,
            uint256 role
        )
    {
        return recordChain.getUser(_userAddress);
    }

    /* User Role (1): Trainer, (2): Learner */
    function updateUser(
        address _userAddress,
        string memory _name,
        string memory _phone,
        uint256 _role
    ) public onlyOwner returns (bool) {
        bool success = recordChain.setUser(_userAddress, _name, _phone, _role);
        emit UserUpdate(msg.sender);
        return success;
    }
}
