// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ArcPay
 * @notice Batch USDC payments on Arc Testnet.
 *         One approval + one transaction = everyone gets paid.
 * @dev Uses Arc's native USDC ERC-20 interface (6 decimals)
 */

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract ArcPay {

    // ─── Constants ────────────────────────────────────────────
    /// @notice Arc Testnet USDC (6 decimals)
    address public constant USDC = 0x3600000000000000000000000000000000000000;

    /// @notice Max recipients per batch to avoid gas limits
    uint256 public constant MAX_BATCH = 200;

    // ─── State ────────────────────────────────────────────────
    address public owner;
    uint256 public totalBatches;
    uint256 public totalRecipients;
    uint256 public totalVolume; // in USDC (6 decimals)

    mapping(address => uint256) public senderVolume;
    mapping(address => uint256) public senderBatches;

    // ─── Events ───────────────────────────────────────────────
    event BatchPaid(
        address indexed sender,
        uint256 recipientCount,
        uint256 totalAmount,
        uint256 timestamp
    );

    event SinglePaid(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        string note,
        uint256 timestamp
    );

    // ─── Errors ───────────────────────────────────────────────
    error EmptyBatch();
    error BatchTooLarge(uint256 provided, uint256 max);
    error ArrayLengthMismatch();
    error ZeroAddress();
    error ZeroAmount();
    error InsufficientBalance(uint256 have, uint256 need);
    error InsufficientAllowance(uint256 have, uint256 need);
    error TransferFailed();

    // ─── Constructor ──────────────────────────────────────────
    constructor() {
        owner = msg.sender;
    }

    // ─── Core: Batch Payment ──────────────────────────────────

    /**
     * @notice Pay multiple recipients in ONE transaction.
     *         Sender must approve this contract for the total amount first.
     *
     * @param recipients  Array of recipient wallet addresses
     * @param amounts     Array of USDC amounts (6 decimals) matching recipients
     *
     * Steps for user:
     *  1. approve(ArcPay address, totalAmount)  ← 1 signature
     *  2. batchPay(recipients, amounts)          ← 1 signature
     *  Everyone gets paid ✅
     */
    function batchPay(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        // ── Validation ─────────────────────────────────────
        if (recipients.length == 0) revert EmptyBatch();
        if (recipients.length > MAX_BATCH) revert BatchTooLarge(recipients.length, MAX_BATCH);
        if (recipients.length != amounts.length) revert ArrayLengthMismatch();

        // ── Calculate total ────────────────────────────────
        uint256 total = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            if (recipients[i] == address(0)) revert ZeroAddress();
            if (amounts[i] == 0) revert ZeroAmount();
            total += amounts[i];
        }

        // ── Check balance & allowance ──────────────────────
        uint256 balance = IERC20(USDC).balanceOf(msg.sender);
        if (balance < total) revert InsufficientBalance(balance, total);

        uint256 allowance = IERC20(USDC).allowance(msg.sender, address(this));
        if (allowance < total) revert InsufficientAllowance(allowance, total);

        // ── Pull total from sender ─────────────────────────
        bool ok = IERC20(USDC).transferFrom(msg.sender, address(this), total);
        if (!ok) revert TransferFailed();

        // ── Distribute to all recipients ───────────────────
        for (uint256 i = 0; i < recipients.length; i++) {
            bool sent = IERC20(USDC).transfer(recipients[i], amounts[i]);
            if (!sent) revert TransferFailed();
        }

        // ── Update stats ───────────────────────────────────
        totalBatches++;
        totalRecipients += recipients.length;
        totalVolume += total;
        senderVolume[msg.sender] += total;
        senderBatches[msg.sender]++;

        emit BatchPaid(msg.sender, recipients.length, total, block.timestamp);
    }

    // ─── Core: Single Payment ─────────────────────────────────

    /**
     * @notice Send USDC to a single recipient with a note.
     * @param recipient  Wallet address to receive USDC
     * @param amount     USDC amount in 6 decimals
     * @param note       Optional payment reference
     */
    function singlePay(
        address recipient,
        uint256 amount,
        string calldata note
    ) external {
        if (recipient == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        uint256 balance = IERC20(USDC).balanceOf(msg.sender);
        if (balance < amount) revert InsufficientBalance(balance, amount);

        uint256 allowance = IERC20(USDC).allowance(msg.sender, address(this));
        if (allowance < amount) revert InsufficientAllowance(allowance, amount);

        bool ok = IERC20(USDC).transferFrom(msg.sender, recipient, amount);
        if (!ok) revert TransferFailed();

        totalVolume += amount;
        senderVolume[msg.sender] += amount;

        emit SinglePaid(msg.sender, recipient, amount, note, block.timestamp);
    }

    // ─── Views ────────────────────────────────────────────────

    /**
     * @notice Calculate total amount needed for a batch.
     *         Use this to know how much to approve before calling batchPay.
     */
    function getBatchTotal(
        uint256[] calldata amounts
    ) external pure returns (uint256 total) {
        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }
    }

    function getStats() external view returns (
        uint256 _totalBatches,
        uint256 _totalRecipients,
        uint256 _totalVolume
    ) {
        return (totalBatches, totalRecipients, totalVolume);
    }

    function getSenderStats(address sender) external view returns (
        uint256 volume,
        uint256 batches
    ) {
        return (senderVolume[sender], senderBatches[sender]);
    }
}
