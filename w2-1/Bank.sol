// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

pragma solidity ^0.8.0;

contract Bank {
    // 管理员地址
    address public admin;

    // 记录每个地址的存款余额
    mapping(address => uint256) public balances;

    // 记录存款金额前3名的用户
    address[3] public topDepositors;

    // 记录存款金额前3名的金额
    uint256[3] public topBalances;

    // 事件声明
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed admin, uint256 amount);

    // 修饰符：仅管理员可调用
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // 构造函数，设置部署者为管理员
    constructor() {
        admin = msg.sender;
    }

    // 存款函数，允许通过 Metamask 等钱包直接存款
    receive() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");

        // 更新用户余额
        balances[msg.sender] += msg.value;

        // 更新前3名存款者
        updateTopDepositors(msg.sender, balances[msg.sender]);

        // 触发存款事件
        emit Deposited(msg.sender, msg.value);
    }

    // 提款函数，仅管理员可调用
    function withdraw(uint256 amount) external onlyAdmin {
        require(amount <= address(this).balance, "Insufficient contract balance");

        // 执行提款
        (bool success, ) = admin.call{value: amount}("");
        require(success, "Withdrawal failed");

        // 触发提款事件
        emit Withdrawn(admin, amount);
    }

    // 更新前3名存款者
    function updateTopDepositors(address user, uint256 newBalance) private {
        // 只有当新余额大于当前最小前3名余额或用户已在前3名时才更新
        if (newBalance > topBalances[2] || user == topDepositors[0] ||
        user == topDepositors[1] || user == topDepositors[2]) {

            // 查找用户是否已经在前3名
            uint256 index = 3;
            for (uint256 i = 0; i < 3; i++) {
                if (topDepositors[i] == user) {
                    index = i;
                    break;
                }
            }

            // 如果用户已经在前3名，更新其余额
            if (index < 3) {
                topBalances[index] = newBalance;
            } else {
                // 替换最小的余额和地址
                topDepositors[2] = user;
                topBalances[2] = newBalance;
            }

            // 重新排序前3名（冒泡排序）
            for (uint256 i = 0; i < 2; i++) {
                for (uint256 j = 0; j < 2 - i; j++) {
                    if (topBalances[j] < topBalances[j + 1]) {
                        // 交换余额
                        uint256 tempBalance = topBalances[j];
                        topBalances[j] = topBalances[j + 1];
                        topBalances[j + 1] = tempBalance;

                        // 交换地址
                        address tempAddress = topDepositors[j];
                        topDepositors[j] = topDepositors[j + 1];
                        topDepositors[j + 1] = tempAddress;
                    }
                }
            }
        }
    }

    // 查询合约余额
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 查询特定地址的存款余额
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}
