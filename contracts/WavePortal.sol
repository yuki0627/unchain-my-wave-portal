// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "hardhat/console.sol";
contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message, bool result);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
        bool result;
    }

    Wave[] waves;

    /*
     * "address => uint mapping"は、アドレスと数値を関連付ける
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
        /*
         * 初期シードの設定
         */
        // console.log("seed", seed);
        // console.log("timestamp", block.timestamp);
        // console.log("difficulty", block.difficulty);
        seed = (block.timestamp + block.difficulty) % 100;
        // console.log("seed", seed);
    }

    function wave(string memory _message) public {
        /*
         * 現在ユーザーがwaveを送信している時刻と、前回waveを送信した時刻が15分以上離れていることを確認。
         */
        // require(
        //     lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
        //     "Wait 15m"
        // );

        /*
         * ユーザーの現在のタイムスタンプを更新する
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        /*
         *  ユーザーのために乱数を設定
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        bool result;
        if (seed <= 50) {
            

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
            result = success;
        } else {
            console.log("%s lose!", msg.sender);
            result = false;
        }

        waves.push(Wave(msg.sender, _message, block.timestamp, result));
        emit NewWave(msg.sender, block.timestamp, _message, result);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}