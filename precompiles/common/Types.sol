// SPDX-License-Identifier: LGPL-v3
pragma solidity >=0.8.17;

struct Dec {
    uint256 value;
    uint8 precision;
}

/// @dev Coin is a struct that represents a token with a denomination and an amount.
struct Coin {
    string denom;
    uint256 amount;
}

/// @dev DecCoin is a struct that represents a token with a denomination, an amount and a precision.
struct DecCoin {
    string denom;
    uint256 amount;
    uint8 precision;
}

/// @dev PageResponse is a struct that represents a page response.
struct PageResponse {
    bytes nextKey;
    uint64 total;
}
