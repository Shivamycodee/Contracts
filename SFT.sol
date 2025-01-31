// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

 // contract created on amoy: 0x94C5b5A98cd17f9625657D309e91f39398aFa49F

contract SFT is ERC1155,Ownable {

    uint public constant GOLD = 1;
    uint public constant ADAMENTIUM = 2;
    uint public constant EXCALIBUR = 3;

   constructor() 
   ERC1155("https://ipfs.io/ipfs/bafybeihjjkwdrxxjnuwevlqtqmh3iegcadc32sio4wmo7bv2gbf34qs34a/{id}.json")
   Ownable(msg.sender)
   {}

     function mint(
        address to,
        uint256 id,
        uint256 amount
    ) external onlyOwner {
        _mint(to, id, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyOwner {
        _mintBatch(to, ids, amounts, "");
    }

    //OpenSea does not support the returned URI format. So we will need to overwrite the URI function to return the file name as a string

     function uri(uint256 _tokenid) override public pure returns (string memory) {   
        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/bafybeihjjkwdrxxjnuwevlqtqmh3iegcadc32sio4wmo7bv2gbf34qs34a/",
                Strings.toString(_tokenid),".json"
            )
        );
    }


}