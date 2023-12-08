// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract BeansToken {
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed _operator,
        bool approved
    );
    event Minted(
        address indexed to,
        uint256 tokenId,
        uint256 amount,
        uint256 amountPaid
    );
    event BatchMinted(
        address[] indexed to,
        uint256 tokenId,
        uint256[] amount,
        uint256 amountPaid
    );
    event Burned(address indexed from, uint256 tokenId, uint256 amount);

    error Contract_Cannot_Receive_ERC1155_Tokens();
    error Fail_Sending_Tokens();
    error You_are_Not_The_Owner();
    error Invalid_Address();
    error You_Are_Not_Apprved();
    error Insuficient_Tokens_balance();
    error Insuficient_Token_balance(uint256, uint256);
    error Ids_And_balances_Dont_Match();
    error Address_And_Values_Dont_Match();
    error Incorrect_Value_Sent();
    error Amount_Canoot_Be_0();
    error The_Amount_Canoot_Be_0(uint256, uint256);
    error Invalid_Id_Token();
    error Ids_And_Amount_Dont_Match();
    error Exceeded_Max_Tokens();

    string public constant name = "Beans Token";
    string public constant symbol = "BEAN";
    address public immutable owner;
    uint256 public tokensCounter;
    uint256 public immutable PRICE_PER_TOKEN;
    uint8 public immutable MAX_TOKENS_PER_ID;

    mapping(address owner => mapping(uint256 tokenId => uint256 amount))
        public balanceOf;
    mapping(address owner => mapping(address operator => bool approved))
        public isApprovalForAll;

    constructor(uint256 _amount, uint8 _maxTokens) {
        owner = msg.sender;
        PRICE_PER_TOKEN = _amount;
        MAX_TOKENS_PER_ID = _maxTokens;
        tokensCounter++;
        uint256 tokenId = tokensCounter;
        balanceOf[owner][tokenId] += 20;
        emit Minted(owner, tokenId, 20, 0);
    }

    function balanceOfBatch(
        address[] calldata _owners,
        uint256[] calldata _ids
    ) external view returns (uint256[] memory) {
        uint256[] memory balance = new uint256[](_owners.length);
        address _owner;
        uint256 _id;
        for (uint256 i; i < _owners.length; ) {
            _owner = _owners[i];
            _id = _ids[i];
            if (_owner == address(0)) revert Invalid_Address();
            balance[i] = balanceOf[_owner][_id];
            unchecked {
                i++;
            }
        }
        return balance;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value,
        bytes calldata _data
    ) external {
        if (_to == address(0)) revert Invalid_Address();
        if (balanceOf[_from][_tokenId] < _value)
            revert Insuficient_Tokens_balance();
        if (msg.sender == _from) {
            unchecked {
                balanceOf[_from][_tokenId] -= _value;
                balanceOf[_to][_tokenId] += _value;
            }
        } else {
            if (!isApprovalForAll[_from][msg.sender])
                revert You_Are_Not_Apprved();
            unchecked {
                balanceOf[_from][_tokenId] -= _value;
                balanceOf[_to][_tokenId] += _value;
            }
        }
        emit TransferSingle(msg.sender, _from, _to, _tokenId, _value);
        if (_isContract(_to)) {
            _checkERC1155Receiver(_from, _to, _tokenId, _value, _data);
        }
        delete isApprovalForAll[_from][msg.sender];
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external {
        uint256 idsLength = _ids.length;
        uint256 valuesLength = _values.length;
        if (idsLength != valuesLength) revert Ids_And_Amount_Dont_Match();
        if (_to == address(0)) revert Invalid_Address();
        uint256 id;
        uint256 value;
        for (uint256 i; i < idsLength; ) {
            id = _ids[i];
            value = _values[i];
            if (value == 0) revert The_Amount_Canoot_Be_0(i, value);
            if (balanceOf[_from][id] < value)
                revert Insuficient_Token_balance(i, value);
            if (msg.sender == _from) {
                unchecked {
                    balanceOf[_from][id] -= value;
                    balanceOf[_to][id] += value;
                    i++;
                }
            } else {
                if (!isApprovalForAll[_from][msg.sender])
                    revert You_Are_Not_Apprved();
                unchecked {
                    balanceOf[_from][id] -= value;
                    balanceOf[_to][id] += value;
                    i++;
                }
            }
        }
        emit TransferBatch(msg.sender, _from, _to, _ids, _values);
        if (_isContract(_to)) {
            _checkERC1155BatchReceiver(_from, _to, _ids, _values, _data);
        }
        delete isApprovalForAll[_from][msg.sender];
    }

    function mint(address _to, uint256 _amount) external payable {
        if (_to == address(0)) revert Invalid_Address();
        uint256 amountToReceive = _amount * PRICE_PER_TOKEN;
        if (msg.value != amountToReceive) revert Incorrect_Value_Sent();
        tokensCounter++;
        uint256 tokenId = tokensCounter;
        balanceOf[_to][tokenId] += _amount;
        emit Minted(_to, tokenId, _amount, msg.value);
    }

    function batchMint(
        address[] calldata _to,
        uint256[] calldata _value
    ) external payable {
        uint256 adressesLength = _to.length;
        uint256 valueLength = _value.length;
        if (adressesLength != valueLength)
            revert Address_And_Values_Dont_Match();
        tokensCounter++;
        uint256 tokenId = tokensCounter;
        address to;
        uint256 value;
        uint256 counter;
        uint256 amountToPay;
        for (uint256 i; i < adressesLength; ) {
            to = _to[i];
            value = _value[i];
            unchecked {
                counter += value;
                amountToPay += value * PRICE_PER_TOKEN;
                if (to == address(0)) revert Invalid_Address();
                balanceOf[to][tokenId] += value;
                i++;
            }
        }
        if (counter > MAX_TOKENS_PER_ID) revert Exceeded_Max_Tokens();
        if (msg.value != amountToPay) revert Incorrect_Value_Sent();
        emit BatchMinted(_to, tokenId, _value, amountToPay);
    }

    function burn(uint256 _tokenId, uint256 _amount) external {
        if (_amount == 0) revert Amount_Canoot_Be_0();
        uint256 tokenId = tokensCounter;
        if (_tokenId == 0 || _tokenId > tokenId) revert Invalid_Id_Token();
        if (balanceOf[msg.sender][_tokenId] < _amount)
            revert Insuficient_Tokens_balance();
        balanceOf[msg.sender][_tokenId] -= _amount;
        emit Burned(msg.sender, _tokenId, _amount);
    }

    function batchBurn(
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) external {
        uint256 idsLength = _tokenIds.length;
        uint256 amountsLength = _amounts.length;
        if (idsLength != amountsLength) revert Ids_And_Amount_Dont_Match();
        uint256 id;
        uint256 amount;
        for (uint256 i; i < amountsLength; ) {
            id = _tokenIds[i];
            amount = _amounts[i];
            if (amount == 0) revert The_Amount_Canoot_Be_0(i, amount);
            if (balanceOf[msg.sender][id] < amount)
                revert Insuficient_Token_balance(i, amount);
            unchecked {
                balanceOf[msg.sender][id] -= amount;
                emit Burned(msg.sender, id, amount);
                i++;
            }
        }
    }

    function setApprovalFotAll(address _operator, bool _approved) external {
        if (_operator == address(0)) revert Invalid_Address();
        isApprovalForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function _isContract(address _to) public view returns (bool) {
        return _to.code.length != 0;
    }

    function _checkERC1155Receiver(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) public {
        (bool success, bytes memory result) = _to.call(
            abi.encodeWithSignature(
                "onERC1155Received(address,address,uint256,uint256,bytes)",
                _from,
                _to,
                _id,
                _value,
                _data
            )
        );
        bytes4 r = bytes4(result);
        bytes4 p = bytes4(
            keccak256(
                abi.encodeWithSignature(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            )
        );
        if (r != p) revert Contract_Cannot_Receive_ERC1155_Tokens();
        if (!success) revert Fail_Sending_Tokens();
    }

    function _checkERC1155BatchReceiver(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) public {
        (bool success, bytes memory result) = _to.call(
            abi.encodeWithSignature(
                "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)",
                _from,
                _to,
                _ids,
                _values,
                _data
            )
        );
        bytes4 r = bytes4(result);
        bytes4 p = bytes4(
            keccak256(
                abi.encodeWithSignature(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            )
        );
        if (r != p) revert Contract_Cannot_Receive_ERC1155_Tokens();
        if (!success) revert Fail_Sending_Tokens();
    }
}
