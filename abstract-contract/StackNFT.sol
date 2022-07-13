//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract NFTFARMING is ERC721{
    string baseURI;
    address payable owner;
    uint tokenId = 1;
    // mapping(address=>uint) UTS; //User Token Stacked by one user
    mapping(address=>mapping(address=>uint)) public UTS;
    mapping(address=>uint) TTS;//Total Token Stacked by all Users
    uint RP;
    mapping(address=>mapping(address=>uint)) DR;
    event Deposite(address user, address token, uint amount);
    event Withdraw(address user, address token, uint amount, uint nftId);
    constructor(string memory _tokenBaseURI) ERC721("B4RE", "B4RE"){
        owner = payable(msg.sender);
        _safeMint(msg.sender,tokenId);
        baseURI = _tokenBaseURI;
        tokenId++;
    }
    modifier onlyOwner {
        require(msg.sender==owner,"You are not the owner of this contract you can't call this function");
        _;
    }
    function depositeToken(address _token, uint _amount) public {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        UTS[_token][msg.sender] += _amount;
        TTS[_token]+=_amount;
        emit Deposite(msg.sender, _token, _amount);
    }
    function withdrawToken(address _token) public {
        IERC20(_token).transfer(msg.sender, UTS[_token][msg.sender]+DR[_token][msg.sender]);
        TTS[_token]-=(UTS[_token][msg.sender]+DR[_token][msg.sender]);
        delete UTS[_token][msg.sender];
        // minting token on withdraw 
        _safeMint(msg.sender,tokenId);
        tokenId++;
        emit Withdraw(msg.sender,_token,UTS[_token][msg.sender]+DR[_token][msg.sender],tokenId);
    }
    
    // owner can change RP at any time 
    function changeRP(uint _newRP) public onlyOwner{
        RP = _newRP;
    }
    //clarity needed
    function dailyRP(address _token) public {
        uint _DR = (RP/365) / (TTS[_token] * UTS[_token][msg.sender]);
        DR[_token][msg.sender] += _DR;
    }


    //Overridden Functions
    function _baseURI() view internal override returns(string memory){
        return baseURI;
    }

}
