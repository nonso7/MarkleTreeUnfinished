//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";



contract merkelTreeAirdrop {
    event TransferSuccessful(address indexed from, address indexed _to, uint256 indexed amount);

    address owner;
    IERC20 public token;
    IERC721 public bayc;
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;
    mapping(address => uint256) balances; 

    constructor( address _token, address _bayc, bytes32 _merkleRoot) {
        token = IERC20(_token);
        bayc = IERC721(_bayc);
        merkleRoot = _merkleRoot;
        owner = msg.sender;
    }

    function sanityCheck(address _user) private pure {
        require(_user == address(0), "Zero address detected");
        // if(_user == address(0)){
        //     revert ZeroAddressDetected();
        // }
    }

    // function _hasClaimedAirdrop() private view returns(bool) {
    //     sanityCheck(msg.sender);
    //     return claimed[msg.sender];
    // }

    // function transferFunds(address _to, uint256 _amount) public { 
    //     sanityCheck(msg.sender);
    //     require(_to != address(0), "can't send to"); 
    //     require(balances[msg.sender] >= _amount, "Insufficient funds!"); 

    //     balances[msg.sender] -= _amount; 

    //     token.transfer(_to, _amount); 
        
    //     emit TransferSuccessful(msg.sender, _to, _amount); 
    // }

    

    function claimAirdrop(uint _amount, bytes32[] calldata _merkelProof) external {
        sanityCheck(msg.sender);
        // if(!bayc.balanceOf(msg.sender)) {
        //     revert YouMustOwnABAYCnft();
        // }
         require(!claimed[msg.sender], "Airdrop already claimed");
        require(bayc.balanceOf(msg.sender) > 0, "Must own a BAYC NFT to claim");
        // if(_hasClaimedAirdrop()){
        //     revert (HasClaimedRewardsAlready);
        // }

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _amount));
        require(
            MerkleProof.verify(_merkelProof, merkleRoot, leaf),
            "Invalid Merkle proof."
        );

        claimed[msg.sender] = true;
        require(token.transfer(msg.sender, _amount), "Transfer failed.");
    }
}