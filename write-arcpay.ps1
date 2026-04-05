$content = @'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract ArcPay {

    address public constant USDC = 0x3600000000000000000000000000000000000000;
    uint256 public constant MAX_BATCH = 200;

    address public owner;
    uint256 public totalBatches;
    uint256 public totalRecipients;
    uint256 public totalVolume;

    mapping(address => uint256) public senderVolume;
    mapping(address => uint256) public senderBatches;

    event BatchPaid(address indexed sender, uint256 recipientCount, uint256 totalAmount, uint256 timestamp);
    event SinglePaid(address indexed sender, address indexed recipient, uint256 amount, string note, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    function batchPay(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        require(recipients.length > 0, "ArcPay: empty batch");
        require(recipients.length <= MAX_BATCH, "ArcPay: batch too large");
        require(recipients.length == amounts.length, "ArcPay: length mismatch");

        uint256 total = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(recipients[i] != address(0), "ArcPay: zero address");
            require(amounts[i] > 0, "ArcPay: zero amount");
            total += amounts[i];
        }

        require(IERC20(USDC).balanceOf(msg.sender) >= total, "ArcPay: insufficient balance");
        require(IERC20(USDC).allowance(msg.sender, address(this)) >= total, "ArcPay: insufficient allowance");
        require(IERC20(USDC).transferFrom(msg.sender, address(this), total), "ArcPay: transfer failed");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(IERC20(USDC).transfer(recipients[i], amounts[i]), "ArcPay: payout failed");
        }

        totalBatches++;
        totalRecipients += recipients.length;
        totalVolume += total;
        senderVolume[msg.sender] += total;
        senderBatches[msg.sender]++;

        emit BatchPaid(msg.sender, recipients.length, total, block.timestamp);
    }

    function singlePay(
        address recipient,
        uint256 amount,
        string calldata note
    ) external {
        require(recipient != address(0), "ArcPay: zero address");
        require(amount > 0, "ArcPay: zero amount");
        require(IERC20(USDC).allowance(msg.sender, address(this)) >= amount, "ArcPay: insufficient allowance");
        require(IERC20(USDC).transferFrom(msg.sender, recipient, amount), "ArcPay: transfer failed");

        totalVolume += amount;
        senderVolume[msg.sender] += amount;

        emit SinglePaid(msg.sender, recipient, amount, note, block.timestamp);
    }

    function getBatchTotal(uint256[] calldata amounts) external pure returns (uint256 total) {
        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }
    }

    function getStats() external view returns (uint256, uint256, uint256) {
        return (totalBatches, totalRecipients, totalVolume);
    }

    function getSenderStats(address sender) external view returns (uint256 volume, uint256 batches) {
        return (senderVolume[sender], senderBatches[sender]);
    }
}
'@

Set-Content -Path "contracts\ArcPay.sol" -Value $content -Encoding UTF8
Write-Host "ArcPay.sol written successfully!"
