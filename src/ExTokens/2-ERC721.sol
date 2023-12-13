// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;



/// @notice ERC721 Token Implemeentation.

contract MonguerNft {
    event Transfer(address indexed from, address to, uint256 tokenId);
    event Approval(address indexed from, address spender, uint256 tokenId);
    event ApprovalForAll(
        address indexed owners,
        address spender,
        bool approved
    );
    event Minted(address indexed to, uint256 tokenId);
    event Burned(address indexed from, uint256 tokenId);

    error Invalid_Address();
    error Incorrect_Amount_Sent();
    error You_Are_Not_Approved();
    error You_Are_Not_The_owner();
    error Nft_Doesnt_Exist();
    error It_Is_Not_A_Contract();
    error Fail_Sending_Nft();
    error Insuficient_Amount_Sent();
    error Contract_Cannot_Receive_NFTS();
    error Has_Already_Been_Approved();

    string constant name = "Monguer Nft";
    string constant symbol = "Mongui";
    address public immutable owner;
    uint256 public nftCounter;

    mapping(address owner => uint256 amount) public balance;
    mapping(uint256 nftId => address owner) public owners;
    mapping(uint256 nftId => address spender) public getApprove;
    mapping(address owner => mapping(address spender => bool)) public isApprovalForAll;

    constructor() {
        owner = msg.sender;
        nftCounter++;
        uint256 nftId = nftCounter;
        owners[nftId] = owner;
        balance[owner]++;
    }

    function balanceOf(address _owners) external view returns (uint256) {
        if (_owners == address(0)) revert Invalid_Address();
        return balance[_owners];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        if (owners[_tokenId] == address(0)) revert Nft_Doesnt_Exist();
        return owners[_tokenId];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public {
        if (_to.code.length == 0) revert It_Is_Not_A_Contract();
        _checkERC721Receiver(_from, _to, _tokenId, data);
        transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        if (owners[_tokenId] == address(0)) revert Nft_Doesnt_Exist();
        if (_to == address(0)) revert Invalid_Address();
        if (owners[_tokenId] == msg.sender) {
            balance[_from]--;
            balance[_to]++;
            owners[_tokenId] = _to;
            emit Transfer(_from, _to, _tokenId);
        } else {
            if (owners[_tokenId] != _from) revert You_Are_Not_The_owner();
            if (getApprove[_tokenId] != msg.sender)
                revert You_Are_Not_Approved();
            balance[_from]--;
            balance[_to]++;
            owners[_tokenId] = _to;
            delete getApprove[_tokenId];
            emit Transfer(_from, _to, _tokenId);
        }
    }

    function transferFromForAll(address _from, address _to) external {
        if (_to == address(0)) revert Invalid_Address();
        if (msg.sender == _from) {
            for (uint256 i = 1; i <= nftCounter; i++) {
                if (owners[i] == _from) {
                    owners[i] = _to;
                    balance[_from]--;
                    balance[_to]++;
                    emit Transfer(_from, _to, i);
                }
            }
        } else {
            if (!isApprovalForAll[_from][msg.sender])
                revert You_Are_Not_Approved();
            for (uint256 i = 1; i <= nftCounter; i++) {
                if (owners[i] == _from) {
                    owners[i] = _to;
                    balance[_from]--;
                    balance[_to]++;
                    delete isApprovalForAll[_from][msg.sender];
                    emit Transfer(_from, _to, i);
                }
            }
        }
    }

    function approve(address _spender, uint256 _tokenId) external {
        if (owners[_tokenId] != msg.sender) revert You_Are_Not_The_owner();
        if (_spender == address(0)) revert Invalid_Address();
        getApprove[_tokenId] = _spender;
        emit Approval(msg.sender, _spender, _tokenId);
    }

    function setApprovalForAll(address _spender, bool _approved) external {
        if (_spender == address(0)) revert Invalid_Address();
        isApprovalForAll[msg.sender][_spender] = _approved;
        emit ApprovalForAll(msg.sender, _spender, _approved);
    }

    function mint(address _to) external payable {
        if (_to == address(0)) revert Invalid_Address();
        if (msg.value != 1 ether) revert Incorrect_Amount_Sent();
        if (msg.sender == address(0)) revert Invalid_Address();
        nftCounter++;
        uint256 nftId = nftCounter;
        owners[nftId] = _to;
        balance[_to]++;
        emit Minted(_to, nftId);
    }

    function burn(uint256 _tokenId) external {
        if (owners[_tokenId] != msg.sender) revert You_Are_Not_The_owner();
        balance[msg.sender]--;
        delete owners[_tokenId];
        emit Burned(msg.sender, _tokenId);
    }

    function _checkERC721Receiver(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) internal {
        (bool success, bytes memory result) = _to.call(
            abi.encodeWithSignature(
                "onERC721Received(address,address,uint256,bytes)",
                _from,
                _to,
                _tokenId,
                data
            )
        );
        bytes4 tt = bytes4(result);
        bytes4 gg = bytes4(
            keccak256(
                abi.encodeWithSignature(
                    "onERC721Received(address,address,uint256,bytes)"
                )
            )
        );
        if (tt != gg) revert Contract_Cannot_Receive_NFTS();
        if (!success) revert Fail_Sending_Nft();
    }
}
