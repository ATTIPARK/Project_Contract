// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// eventEmit 활용하자.........

contract PRESENT {
    struct balance {
        uint finalB;
        uint currentB;
    }

    struct chargeFromWho {
        address chargeF;
        uint chargeP;
    }

    // 생일당사자의 몇번 선물의 최종금액과 현재 충전된 금액
    mapping(address=>mapping(uint=>balance)) present;
    
    // 생일당사자의 몇번째 선물의 누가 얼마나 충전했는지
    mapping(address=>mapping(uint=>chargeFromWho[])) charge;                 // 필요 없어보임

    // 선물 등록 함수
    function setPresent(uint num, uint price) public {

        address to = msg.sender;

        require(present[to][num].finalB == 0);     // 선물이 들어가있는지 확인

        present[to][num].finalB = price;           // 최종금액을 넣으면서 선물 등록
    }

    // 돈 충전하는 함수
    function chargeBalance(address to, uint num, uint price) public {

        require(present[to][num].finalB != 0);                            // 선물이 들어가있는지 확인
        require(present[to][num].currentB < present[to][num].finalB);     // 해당 선물의 최종 금액보다 현재 충전된 금액이 적은지 확인

        address from = msg.sender;

        present[to][num].currentB += price;                                // 선물의 현재 금액에 충전한 금액만큼 더하기

        bool check = false;
        for(uint i = 0; i < charge[to][num].length; i++) {
            if(charge[to][num][i].chargeF == from) {                       // 충전하는 사람이 충전 한적이 있는지 확인
                charge[to][num][i].chargeP += price;                       // 충전한적이 있다면 전에 충전한 금액에 더하기
                check = true;
                break;
            }
        }

        if(check == false){
            charge[to][num].push(chargeFromWho(from, price));              // 충전한적이 없다면 푸쉬
        }

        if(present[to][num].currentB > present[to][num].finalB) {

            uint remain = present[to][num].currentB - present[to][num].finalB;    // 현재 충전된 금액이 최종금액 보다 많아 졌을경우 차액 계산

            // remain을 contract에서 생일당사자에게 보내주기
        } else {

            // 충전된 금액만큼 contract에 보내주기
        }
    }

    // 금액 달성치를 반환해주는 함수
    function getRation(address who, uint num) public view returns(uint) {

        // who 주소를 받아오기

        return present[who][num].currentB * 100 / present[who][num].finalB;         // 충전된 금액에 최종금액의 몇퍼센트인지 계산후 반환
    }

    // 해당 선물에 충전한 전체 인원과 금액을 반환해주는 함수
    function getWho(address who, uint num) public view returns(chargeFromWho[] memory) {

        // who 주소를 받아오기

        return charge[who][num];
    }
}