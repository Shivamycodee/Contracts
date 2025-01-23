// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



interface IParaswap{

    struct SimpleData {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address[] callees;
        bytes exchangeData;
        uint256[] startIndexes;
        uint256[] values;
        address payable beneficiary;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    function simpleSwap(SimpleData memory data) external payable returns (uint256);
     function simpleBuy(SimpleData memory data) external payable;

}



contract TestStruct {

    function getEncode(IParaswap.SimpleData memory params) public pure returns(bytes memory){
        return abi.encode(params);
    }

    function getArrEncode(IParaswap.SimpleData[] memory params) public pure returns(bytes memory){
        return abi.encode(params);
    }

    function getDecode(bytes memory params) public pure returns(IParaswap.SimpleData memory){
        return abi.decode(params,(IParaswap.SimpleData));
    }

    function getArrDecode(bytes memory params) public pure returns(IParaswap.SimpleData[] memory){
        return abi.decode(params,(IParaswap.SimpleData[]));
    }

}