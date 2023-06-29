// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import './token.sol';

contract NFT is ERC721 {
    constructor(string memory _uri) ERC721("CelebdayNFT", "CN") {
        URI = _uri;
    }

    Token t_contract = new Token(); 

    string public URI;
    address public owner;

    struct present {
        uint finalB;
        uint currentB;
    }
 
    // 230621(nft발행당일) + 1(회원고유번호) = 2306211
    // mapping(address=>uint) public prsentIds;
    // reveal
    // uint public presentBalance;
    // mapping(uint=>uint) public presentBalance;              // tokenId => 목표금액
    // mapping(uint=>uint) public currentBalance;              // tokenId => 현재금액

    mapping(address=>mapping(uint=>present)) public PRESENT;           // 해당 주소의 몇번쨰 선물의 최종금액과 현재금액
    mapping(address=>uint) public nftIds;                              // 해당 주소의 고유번호 (본인생일 + 생성할때 주어진 번호)

    // 선물 등록 함수
    function setPresent(uint num, uint price) public {
        address to = msg.sender;
        require(PRESENT[to][num].finalB == 0);                  // 선물이 들어가있는지 확인
        PRESENT[to][num].finalB = price;                        // 최종금액을 넣으면서 선물 등록
    }

    // NFT 민팅 함수
    function mintNFT(uint date, uint id) public {               // 목표금액 인자로 받아야함 ??????
        owner = msg.sender;
        uint Id = getnftId(date, id);
        nftIds[owner] = Id;
        // _mint(owner, tokenId);
    }

    // token uri 주소를 바꿔줘야함
    function tokenURI(uint _tokenId) public override view returns(string memory) {
        /*
        if(목표금액 <= 현재금액) {
            return 최종 uri;                    // 최종 선물상자 열렸을떄 uri
        }
        */
        // return string(abi.encodePacked(URI, '/', Strings.toString(_tokenId), '.json'));         // 선물 상자 uri
    }

    // 돈 넣는 함수(input 금액)
    // require (nft 주인인지 확인)
    // reruire (token balance가 금액만큼 있는지 확인)
    // 금액 만큼 currentBalance에 넣기

    // 돈 충전하는 함수
    function chargeBalance(address to, uint num, uint price) public {
        require(PRESENT[to][num].finalB != 0);                                      // 선물이 들어가있는지 확인
        require(PRESENT[to][num].currentB < PRESENT[to][num].finalB);               // 해당 선물의 최종 금액보다 현재 충전된 금액이 적은지 확인

        // address from = msg.sender;

        PRESENT[to][num].currentB += price;                                         // 선물의 현재 금액에 충전한 금액만큼 더하기

        // if(PRESENT[to][num].currentB > PRESENT[to][num].finalB) {

        //     uint remain = PRESENT[to][num].currentB - PRESENT[to][num].finalB;      // 현재 충전된 금액이 최종금액 보다 많아 졌을경우 차액 계산

        //     // remain을 contract에서 생일당사자에게 보내주기
        // } else {

        //     // 충전된 금액만큼 contract에 보내주기
        // }
    }

    function getnftId(uint a, uint b) public pure returns(uint) {

        string memory ab = string(abi.encodePacked(Strings.toString(a), Strings.toString(b)));

        bytes memory bytesAB = bytes(ab);
        uint result;

        for (uint i = 0; i < bytesAB.length; i++) {
            uint c = uint(uint8(bytesAB[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }

        return result;
    }
}