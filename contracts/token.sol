// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Token is Ownable, ERC20("CelebdayToken", "CT") {

    function MintToken(uint _amount) public onlyOwner {
        _mint(msg.sender, _amount);
        // _mint(address(this), _amount);
    }

    function decimals() public pure override returns(uint8) {
        return 0;
    }

    // function buyToken(uint _amount) public {             // 충전할만한 토큰 구매하기
    //     transfer(msg.sender, _amount);
    // }
}