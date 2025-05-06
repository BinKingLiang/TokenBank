// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokensRecipient {
    function tokensReceived(address from, uint256 amount) external;
}

contract MyERC20WithHook is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // 初始化
    }
    
    // 新的转账函数，带回调
    function transferWithCallback(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        
        if (isContract(recipient)) {
            // 调用目标合约的tokensReceived方法
            (bool success, ) = recipient.call(
                abi.encodeWithSelector(
                    ITokensRecipient.tokensReceived.selector,
                    _msgSender(),
                    amount
                )
            );
            require(success, "tokensReceived call failed");
        }
        return true;
    }
    
    // 内部函数：检测是否为合约
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}