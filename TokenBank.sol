// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// ERC20标准接口
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
contract TokenBank {

    IERC20 public immutable token;  // 绑定的ERC20代币
    mapping(address => uint256) public deposits;  // 存款记录
    
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // 初始化时绑定代币合约
    constructor(IERC20 _token) {
        token = _token;
    }

    // 存款功能（需先授权额度）
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be positive");
        
        // 转移代币到银行合约
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
        
        // 更新存款记录
        deposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    // 提取功能（可提取全部存款）
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        
        // 更新存款记录（防重入攻击）
        deposits[msg.sender] -= amount;
        
        // 返回代币给用户
        bool success = token.transfer(msg.sender, amount);
        require(success, "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    // 查询合约代币余额
    function bankBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }


}