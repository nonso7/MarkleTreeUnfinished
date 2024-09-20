//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";



contract merkelTreeAirdrop {
    error zeroAddressDetected();
    error HasClaimedRewardsAlready();
    error UnAuthorizedFunctionCall();
    error InvalidClaim();
    error ZeroValueDetected();
    error UnclaimedTokenStillMuch();
    error NftNotFound();


    event AirdropClaimed(address indexed _user, uint256 indexed _amount);
    event WithdrawalSuccessful(address indexed _owner, uint256 indexed _amount);
    event TransferSuccessful(address indexed _owner, address indexed _user, uint256 indexed _amount);

    address owner;
    address public token;
    address public nftAddress;
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;
    mapping(address => uint256) balances; 

    constructor( address _token, address _nftAddress, bytes32 _merkleRoot) {
        token = _token;
        nftAddress = _nftAddress;
        merkleRoot = _merkleRoot;
        owner = msg.sender;
        
    }

    function sanityCheck(address _user) private pure {
        require(_user == address(0), "Zero address detected");
        if(_user == address(0)){
            revert zeroAddressDetected();
        }
    }

    function _hasClaimedAirdrop() private view returns(bool) {
        sanityCheck(msg.sender);
        return claimed[msg.sender];
    }

    function getNFTBalance(address _user) view external returns(uint){
        return IERC721(nftAddress).balanceOf(_user);
    }

    function transferToken(address _to, uint256 _amount) public { 
        sanityCheck(msg.sender);
        require(_to != address(0), "can't send to"); 
        require(balances[msg.sender] >= _amount, "Insufficient funds!"); 

        balances[msg.sender] -= _amount; 

        IERC20(token).transfer(_to, _amount); 
        
        emit TransferSuccessful(msg.sender, _to, _amount); 
    }

    

    function claimAirdrop(uint _amount, bytes32[] calldata _merkelProof) external {
        sanityCheck(msg.sender);
        if(IERC721(nftAddress).balanceOf(msg.sender) < 1) {
            revert NftNotFound();
        }
        if(_hasClaimedAirdrop()){
            revert HasClaimedRewardsAlready();
        }

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _amount));
        if (!MerkleProof.verify(_merkelProof, merkleRoot, leaf)){
            revert InvalidClaim();
        }

        claimed[msg.sender] = true;
        require(IERC20(token).transfer(msg.sender, _amount), "Transfer failed.");
    }
}