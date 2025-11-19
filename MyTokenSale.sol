// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IMyToken {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address user) external view returns (uint256);
}

contract MyTokenSale {
    IMyToken public token;
    address public owner;
    uint256 public rate; // 每 1 ETH 可以拿到多少 token（按最小单位计算）

    event TokensPurchased(address indexed buyer, uint256 ethSpent, uint256 tokensBought);
    event EthWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token, uint256 _rate) {
        require(_token != address(0), "Token address is zero");
        require(_rate > 0, "rate is zero");
        token = IMyToken(_token);
        owner = msg.sender;
        rate = _rate;
    }

    // 用户买币：往合约转 ETH
    function buyTokens() external payable {
        require(msg.value > 0, "Send some ETH");

        // 计算可买多少 token（这里默认 1 ETH = rate 个最小单位 token）
        uint256 tokensToBuy = (msg.value * rate) / 1e18;
        require(tokensToBuy > 0, "ETH too small for any token");

        uint256 saleBalance = token.balanceOf(address(this));
        require(saleBalance >= tokensToBuy, "not enough tokens in sale");

        // 转代币给买家
        require(token.transfer(msg.sender, tokensToBuy), "token transfer failed");

        emit TokensPurchased(msg.sender, msg.value, tokensToBuy);
    }

    // owner 提取合约里收的 ETH
    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Not enough ETH");
        payable(owner).transfer(amount);
        emit EthWithdrawn(owner, amount);
    }

    // 查看合约里还有多少代币
    function tokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // 查看合约里有多少 ETH
    function ethBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
