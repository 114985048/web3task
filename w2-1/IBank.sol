// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function withdraw(uint amount) external;

    function getContractBalance() external view returns(uint);

    function getBalance (address user) external view returns (uint);

    function admin() external view returns (address);
}