// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "TokenBank.sol";

// 支持回调的ERC20接口（目标合约实现tokensReceived）
interface IERC20WithCallback is IERC20 {
    function tokensReceived(address from, uint256 amount) external;
}

contract TokenBankV2 is TokenBank{

    constructor(IERC20 _token) TokenBank(_token) {}
        // 直接调用转账（必须由用户授权额度）
    function transferWithCallback(address to, uint256 amount) external {
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom failed");
        // 这只存了，不会自动调用tokensReceived
        // 需要目标实现 tokensReceived
        // 这里用户可以预先调用
    }

    // 实现 tokensReceived 来被调用，自动存款
    function tokensReceived(address from, uint256 amount) external {
        // 确认调用者是合法的目标ERC20支持回调的合约地址
        require(isSupportedToken(msg.sender), "Invalid token");
        // 更新存款
        deposits[from] += amount;
        emit Deposited(from, amount);
    }

    // 判断调用是否来自正确的token合约（可选：可扩展）
    function isSupportedToken(address tokenAddress) internal view returns (bool) {
        return tokenAddress == address(token);
        // 如果支持多种token，就需要维护支持的token列表
    }

} 