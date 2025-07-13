// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBank.sol";
// Admin合约用于管理银行合约的资金提取
contract Admin{
    address public owner;//// 合约所有者地址
    // 事件定义

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);// 所有权转移事件

    event Withdrawal(address indexed bank, uint amount); // 从银行提款事件

    // 构造函数，设置部署者为所有者
    constructor() {
        owner = msg.sender;
    }

    // 修饰器：限制只有所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 转移合约所有权
    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0), "New owner cannot be zero address");

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;// 更新所有者
    }

    // 从指定的银行合约提取全部资金
    function adminWithdraw(IBank bank) public onlyOwner {
        // 获取银行合约余额
        uint256  balance = bank.getContractBalance();
        require(balance > 0 , "No funds to withdraw");
        // 调用银行合约的withdraw方法
        bank.withdraw(balance);
        // 触发提款事件
        emit Withdrawal(address(bank), balance);
    }
    // 接收以太币的回退函数
    receive() external payable {}
}