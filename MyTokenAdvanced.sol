// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract MyTokenAdvanced {
    // 基本信息
    string public name = "MyAdvancedToken";
    string public symbol = "MAT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // 余额 / 授权
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // owner、暂停、白名单
    address public owner;
    bool public paused;
    mapping(address => bool) public whitelist;

    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Paused(address indexed account);
    event Unpaused(address indexed account);
    event WhitelistUpdated(address indexed user, bool allowed);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenNotPausedOrWhitelisted() {
        // 没暂停，大家都能转；暂停时只有白名单能转
        require(!paused || whitelist[msg.sender], "Token paused and not whitelisted");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        uint256 amount = initialSupply * (10 ** uint256(decimals));
        totalSupply = amount;
        balanceOf[msg.sender] = amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // ⚖️ 转账（受暂停 + 白名单控制）
    function transfer(address to, uint256 value) public whenNotPausedOrWhitelisted returns (bool) {
        require(to != address(0), "Zero address");
        require(balanceOf[msg.sender] >= value, "Not enough balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public whenNotPausedOrWhitelisted returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPausedOrWhitelisted returns (bool) {
        require(to != address(0), "Zero address");
        require(balanceOf[from] >= value, "From balance not enough");
        require(allowance[from][msg.sender] >= value, "Allowance not enough");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    // 🔒 暂停 & 解除暂停
    function pause() external onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }

    // ✅ 管理白名单
    function setWhitelist(address user, bool allowed) external onlyOwner {
        whitelist[user] = allowed;
        emit WhitelistUpdated(user, allowed);
    }

    // 🪙 铸币（只有 owner）
    function mint(address to, uint256 value) external onlyOwner {
        require(to != address(0), "Zero address");
        totalSupply += value;
        balanceOf[to] += value;
        emit Mint(to, value);
        emit Transfer(address(0), to, value);
    }

    // 🔥 销毁
    function burn(address from, uint256 value) external onlyOwner {
        require(balanceOf[from] >= value, "Not enough balance to burn");
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Burn(from, value);
        emit Transfer(from, address(0), value);
    }
}
