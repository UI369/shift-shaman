// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBAAL {
    function mintLoot(address[] calldata to, uint256[] calldata amount)
        external;

    function mintShares(address[] calldata to, uint256[] calldata amount)
        external;

    function shamans(address shaman) external returns (uint256);

    function isManager(address shaman) external returns (bool);

    function target() external returns (address);

    function totalSupply() external view returns (uint256);

    function sharesToken() external view returns (address);

    function lootToken() external view returns (address);
}

contract ShiftShaman {
    IBAAL public baal;
    IERC20 public sharesToken;

    uint256 public periodLength;
    uint256 public perPeriod;

    mapping(address => uint256) public claims;
    event Claim(address account, uint256 timeStamp);

    constructor(
        address _daoAddress,
        uint256 _periodLength,
        uint256 _perPeriod
    ) {
        baal = IBAAL(_daoAddress);
        sharesToken = IERC20(baal.sharesToken());
        periodLength = _periodLength;
        perPeriod = _perPeriod;
    }

    function claim() public {
        require(
            block.timestamp - claims[msg.sender] >= periodLength ||
                claims[msg.sender] == 0,
            "Can only claim once per period"
        );
        require(
            sharesToken.balanceOf(msg.sender) > 0,
            "Must have shares to claim"
        );

        uint256 amount = _calculate();
        _mintTokens(msg.sender, amount);
        claims[msg.sender] = block.timestamp;

        emit Claim(msg.sender, block.timestamp);
        // require that they haven't already claimed
        // calculate amount of shares to give
        // mint amount
        // store claim for a period
        // emit event
    }

    function _mintTokens(address to, uint256 amount) private {
        address[] memory _receivers = new address[](1);
        _receivers[0] = to;

        uint256[] memory _amounts = new uint256[](1);
        _amounts[0] = amount;
        baal.mintShares(_receivers, _amounts);
    }

    function _calculate() private returns (uint256) {
        return perPeriod;
    }
}
