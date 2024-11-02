// SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;

// 这是我的第一个智能合约测试

contract HelloWorld {
    string bytesVar= "Hello World";

    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }
    
    Info[] infos;

    mapping (uint256 id => Info info) infoMapping;

    function sayHello(uint256 _id) public view returns(string memory){
        // return bytesVar;
        // for(uint256 i= 0 ;i < infos.length;i++){
        //     if(infos[i].id == _id){
        //         return addInfo(infos[i].phrase);
        //     }
        // }
        if(infoMapping[_id].addr == address(0x0)){
            return addInfo(bytesVar);
        }else{
            return addInfo(infoMapping[_id].phrase);
        }
        // return addInfo(bytesVar);
    }

    function setHelloWorld(string memory newString, uint256 _id) public {
        // bytesVar = newString;
        Info memory info = Info(newString,_id,msg.sender);
        // infos.push(info);
        infoMapping[_id] = info;
    } 

    function addInfo(string memory helloWorldStr) internal pure returns(string memory){
        return string.concat(helloWorldStr,"form Frank's contract.");
    }
}