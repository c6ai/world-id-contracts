// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ISemaphore} from "./interfaces/ISemaphore.sol";

contract SemaphoreAirdrop {
    error InvalidProof();

    ISemaphore internal immutable semaphore;
    uint256 internal immutable groupId;
    ERC20 public immutable token;
    address public immutable holder;
    uint256 public immutable airdropAmount;

    constructor(
        ISemaphore _semaphore,
        uint256 _groupId,
        ERC20 _token,
        address _holder,
        uint256 _airdropAmount
    ) payable {
        semaphore = _semaphore;
        groupId = _groupId;
        token = _token;
        holder = _holder;
        airdropAmount = _airdropAmount;
    }

    function claim(
        address receiver,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        if (
            !semaphore._isValidProof(
                string(abi.encodePacked(receiver)),
                semaphore.getRoot(groupId),
                nullifierHash,
                uint256(uint160(address(this))),
                proof
            )
        ) revert InvalidProof();

        semaphore.saveNullifierHash(nullifierHash);

        token.transferFrom(holder, receiver, airdropAmount);
    }
}