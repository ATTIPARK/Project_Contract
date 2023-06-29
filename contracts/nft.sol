// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import './token.sol';

contract NFT_1 is ERC721Enumerable {
    constructor(string memory _uri, string memory _boxuri, address tokenContract) ERC721("CelebdayNFT", "CN") {
        URI = _uri;
        BOX_URI = _boxuri;
        tokenCT = ERC20(tokenContract);
    }

    Token t_contract = new Token();
    ERC20 public tokenCT;

    string public URI;
    string public BOX_URI;

    uint public tokenID = 1;

    struct present {
        uint finalB;
        uint currentB;
    }

    struct nftInfo {
        address Owner;
        uint presentNum;
    }

    // evenEmit을 쓰게된다면 chargeBalance() 금액충전함수를 쓸때, 누가 얼만큼 충전했는지 로그를 남기는 용도로 쓰일예정
 
    mapping(address=>mapping(uint=>present)) public PRESENT;                // 해당 주소의 몇번쨰 선물의 최종금액과 현재금액
    mapping(uint=>nftInfo) public NftData;                                  // 토큰아이디의 주인

    // 선물 등록 함수 1안일 경우 nft 민팅 함수와 통합해서 사용하기
    // function setPresent(uint _num, uint _price) public {                    // 선물을 하나씩 등록할때
    //     address presentOwner = msg.sender;
    //     require(PRESENT[presentOwner][_num].finalB == 0);                   // 선물이 들어가있는지 확인

    //     PRESENT[presentOwner][_num].finalB = _price;                        // 최종금액을 넣으면서 선물 등록
    // }

    // NFT 민팅 함수 + 선물 등록과 통합할경우 (1안)
    function mintNFT1(uint _num, uint _price) public {
        address nftOwner = msg.sender;
        require(PRESENT[nftOwner][_num].finalB == 0);

        NftData[tokenID].Owner = nftOwner;           // 몇번쨰 nft 의 주인 주소 저장하기
        NftData[tokenID].presentNum = _num;          // 몇번째 선물의 nft인지 저장하기

        PRESENT[nftOwner][_num].finalB = _price;
        _mint(nftOwner, tokenID);
        tokenID++;                                   // 민팅후 토큰번호 1증가
    }

    // 선물 등록 함수 (2안)
    function setPresent2(uint _count, uint[] memory _prices) public {       // 위시리스트를 설정한후 전체 선물을 등록할때
        address presentOwner = msg.sender;

        for(uint i = 0; i < _count; i++) {
            PRESENT[presentOwner][i+1].finalB = _prices[i];
        }
    }

    // NFT 민팅 함수 (2안)
    function mintNFT2(uint _num) public {
        address nftOwner = msg.sender;
        NftData[tokenID].Owner = nftOwner;           // 몇번쨰 nft 의 주인 주소 저장하기
        NftData[tokenID].presentNum = _num;          // 몇번째 선물의 nft인지 저장하기

        _mint(nftOwner, tokenID);
        tokenID++;                                   // 민팅후 토큰번호 1증가
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        address tokenOwner = NftData[_tokenId].Owner;
        uint presentNumber = NftData[_tokenId].presentNum;

        if(PRESENT[tokenOwner][presentNumber].finalB <= PRESENT[tokenOwner][presentNumber].currentB) {

            return string(abi.encodePacked(URI, '/', Strings.toString(_tokenId), '.json'));         // 금액이 달성했을경우 원래의 uri 사용
        } else {

            return BOX_URI;                                                                         // 금액이 달성하지 않았다면 선물상자 uri 사용
        }
    }

    // 돈 충전하는 함수
    function chargeBalance(address _to, uint _num, uint _price) public {
        require(PRESENT[_to][_num].finalB != 0);                                        // 선물이 들어가있는지 확인
        require(PRESENT[_to][_num].currentB < PRESENT[_to][_num].finalB);               // 해당 선물의 최종 금액보다 현재 충전된 금액이 적은지 확인
        
        // address from = msg.sender;

        PRESENT[_to][_num].currentB += _price;                                         // 선물의 현재 금액에 충전한 금액만큼 더하기

        t_contract.transferFrom(tx.origin, address(this), _price);                     // 충전된 금액만큼 contract에 보내주기
        tokenCT.transferFrom(tx.origin, address(this), _price);                     // 충전된 금액만큼 contract에 보내주기

        // if(PRESENT[_to][_num].currentB > PRESENT[_to][_num].finalB) {
            
        //     uint remain = PRESENT[_to][_num].currentB - PRESENT[_to][_num].finalB;      // 현재 충전된 금액이 최종금액 보다 많아 졌을경우 차액 계산
        //     t_contract.transfer(_to, remain);                                           // remain을 contract에서 생일당사자에게 보내기
        // }
    }

    function getChargeRatio(address _address, uint _num) public view returns(uint) {       // 충전된 금액비율 보여주기    
        return (PRESENT[_address][_num].currentB * 100) / PRESENT[_address][_num].finalB;
    }
}