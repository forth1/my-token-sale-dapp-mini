// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract MyToken {
    // 基本信息
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // 余额 / 授权
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // owner & 暂停
    address public owner;
    bool public paused;

    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Paused(address indexed account);
    event Unpaused(address indexed account);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Token is paused");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        uint256 amount = initialSupply * (10 ** uint256(decimals));
        totalSupply = amount;
        balanceOf[msg.sender] = amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // 基础转账
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        require(to != address(0), "Zero address");
        require(balanceOf[msg.sender] >= value, "Not enough balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    // 授权
    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // 代扣转账
    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
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

    // 🪙 铸币（只有 owner）
    function mint(address to, uint256 value) external onlyOwner {
        require(to != address(0), "Zero address");
        uint256 amount = value;
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    // 🔥 销毁（只有 owner，可以销毁自己或别人）
    function burn(address from, uint256 value) external onlyOwner {
        require(balanceOf[from] >= value, "Not enough balance to burn");
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Burn(from, value);
        emit Transfer(from, address(0), value);
    }
}
