// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import './token.sol';

contract NFT is ERC721Enumerable {
    constructor(string memory _uri, string memory _boxuri, address tokenContract) ERC721("CelebdayNFT", "CN") {
        URI = _uri;
        BOX_URI = _boxuri;
        tokenCT = Token(tokenContract);
    }

    Token public tokenCT;

    string public URI;
    string public BOX_URI;

    struct present {
        uint finalB;
        uint currentB;
    }

    // evenEmit을 쓰게된다면 chargeBalance() 금액충전함수를 쓸때, 누가 얼만큼 충전했는지 로그를 남기는 용도로 쓰일예정
 
    mapping(address=>mapping(uint=>present)) public PRESENT;                // 해당 주소의 몇번쨰 선물의 최종금액과 현재금액
    mapping(uint=>uint) public presentNum;                                  // 토큰아이디의 주인

    // NFT 민팅 함수 + 선물 등록과 통합할경우 (1안)
    function mintNFT1(uint _num, uint _price) public {
        address nftOwner = msg.sender;
        require(PRESENT[nftOwner][_num].finalB == 0);

        uint tokenID = totalSupply() + 1;

        presentNum[tokenID] = _num;                  // 몇번째 선물의 nft인지 저장하기

        PRESENT[nftOwner][_num].finalB = _price;     // 가격을 넣으면서 선물 등록하기

        _mint(nftOwner, tokenID);
    }

    // 선물 등록 함수 (2안)
    function setPresent2(uint _count, uint[] calldata _prices) public {       // 위시리스트를 설정한후 전체 선물을 등록할때
        address presentOwner = msg.sender;

        for(uint i = 0; i < _count; i++) {
            PRESENT[presentOwner][i+1].finalB = _prices[i];
        }
    }

    // NFT 민팅 함수 (2안)
    function mintNFT2(uint _num) public {
        address nftOwner = msg.sender;

        uint tokenID = totalSupply() + 1;

        presentNum[tokenID] = _num;                     // 몇번째 선물의 nft인지 저장하기

        _mint(nftOwner, tokenID);
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        address tokenOwner = ownerOf(_tokenId);
        uint presentNumber = presentNum[_tokenId];

        if(PRESENT[tokenOwner][presentNumber].finalB <= PRESENT[tokenOwner][presentNumber].currentB) {

            return string(abi.encodePacked(URI, '/', Strings.toString(_tokenId), '.json'));         // 금액이 달성했을경우 원래의 uri 사용
        } else {

            return BOX_URI;                                                                         // 금액이 달성하지 않았다면 선물상자 uri 사용
        }
    }

    // 선물에 돈 충전하는 함수
    function chargeBalance(address _to, uint _num, uint _price) public {
        require(PRESENT[_to][_num].finalB != 0);                                         // 선물이 들어가있는지 확인
        require(PRESENT[_to][_num].currentB < PRESENT[_to][_num].finalB);                // 해당 선물의 최종 금액보다 현재 충전된 금액이 적은지 확인

        PRESENT[_to][_num].currentB += _price;                                           // 선물의 현재 금액에 충전한 금액만큼 더하기

        // tokenCT.approve(address(this), _price);
        tokenCT.burn(_price);                                                            // 금액을 저장한후 사용된 코인은 없애버림
    }

    // 코인 구매
    function buyCoin(uint _amount) public {
        tokenCT.mintToken(_amount);                     // 갯수만큼 토큰을 구매하는 형식
    }

    // 충전된 금액 비율
    function getChargeRatio(address _address, uint _num) public view returns(uint) {       // 충전된 금액비율 보여주기    
        return (PRESENT[_address][_num].currentB * 100) / PRESENT[_address][_num].finalB;
    }
}