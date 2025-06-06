// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC721 is IERC165 {
   
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
        
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
    }

    struct AddressData {
        uint128 balance;
        uint128 numberMinted;
    }

    uint256 private currentIndex = 0;
    uint256 internal immutable collectionSize;
    uint256 internal immutable maxBatchSize;

    string private _name;
    string private _symbol;

    mapping(uint256 => TokenOwnership) private _ownerships;
    mapping(address => AddressData) private _addressData;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxBatchSize_,
        uint256 collectionSize_
    ) {
        require(
        collectionSize_ > 0,
        "ERC721A: collection must have a nonzero supply"
        );
        require(maxBatchSize_ > 0, "ERC721A: max batch size must be nonzero");
        _name = name_;
        _symbol = symbol_;
        maxBatchSize = maxBatchSize_;
        collectionSize = collectionSize_;
    }

    function totalSupply() public view override returns (uint256) {
        return currentIndex;
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        require(index < totalSupply(), "ERC721A: global index out of bounds");
        return index;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(index < balanceOf(owner), "ERC721A: owner index out of bounds");
        uint256 numMintedSoFar = totalSupply();
        uint256 tokenIdsIdx = 0;
        address currOwnershipAddr = address(0);
        for (uint256 i = 0; i < numMintedSoFar; i++) {
        TokenOwnership memory ownership = _ownerships[i];
        if (ownership.addr != address(0)) {
            currOwnershipAddr = ownership.addr;
        }
        if (currOwnershipAddr == owner) {
            if (tokenIdsIdx == index) {
            return i;
            }
            tokenIdsIdx++;
        }
        }
        revert("ERC721A: unable to get token of owner by index");
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721A: balance query for the zero address");
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {
        require(
        owner != address(0),
        "ERC721A: number minted query for the zero address"
        );
        return uint256(_addressData[owner].numberMinted);
    }

    function ownershipOf(uint256 tokenId)
        internal
        view
        returns (TokenOwnership memory)
    {
        require(_exists(tokenId), "ERC721A: owner query for nonexistent token");

        uint256 lowestTokenToCheck;
        if (tokenId >= maxBatchSize) {
        lowestTokenToCheck = tokenId - maxBatchSize + 1;
        }

        for (uint256 curr = tokenId; curr >= lowestTokenToCheck; curr--) {
        TokenOwnership memory ownership = _ownerships[curr];
        if (ownership.addr != address(0)) {
            return ownership;
        }
        }

        revert("ERC721A: unable to determine the owner of token");
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
        bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721A.ownerOf(tokenId);
        require(to != owner, "ERC721A: approval to current owner");

        require(
        _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
        "ERC721A: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721A: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != _msgSender(), "ERC721A: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        _transfer(from, to, tokenId);
        require(
        _checkOnERC721Received(from, to, tokenId, _data),
        "ERC721A: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId < currentIndex;
    }

    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, "");
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        uint256 startTokenId = currentIndex;
        require(to != address(0), "ERC721A: mint to the zero address");
        // We know if the first token in the batch doesn't exist, the other ones don't as well, because of serial ordering.
        require(!_exists(startTokenId), "ERC721A: token already minted");
        require(quantity <= maxBatchSize, "ERC721A: quantity to mint too high");

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        AddressData memory addressData = _addressData[to];
        _addressData[to] = AddressData(
        addressData.balance + uint128(quantity),
        addressData.numberMinted + uint128(quantity)
        );
        _ownerships[startTokenId] = TokenOwnership(to, uint64(block.timestamp));

        uint256 updatedIndex = startTokenId;

        for (uint256 i = 0; i < quantity; i++) {
        emit Transfer(address(0), to, updatedIndex);
        require(
            _checkOnERC721Received(address(0), to, updatedIndex, _data),
            "ERC721A: transfer to non ERC721Receiver implementer"
        );
        updatedIndex++;
        }

        currentIndex = updatedIndex;
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
        getApproved(tokenId) == _msgSender() ||
        isApprovedForAll(prevOwnership.addr, _msgSender()));

        require(
        isApprovedOrOwner,
        "ERC721A: transfer caller is not owner nor approved"
        );

        require(
        prevOwnership.addr == from,
        "ERC721A: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721A: transfer to the zero address");

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, prevOwnership.addr);

        _addressData[from].balance -= 1;
        _addressData[to].balance += 1;
        _ownerships[tokenId] = TokenOwnership(to, uint64(block.timestamp));

        uint256 nextTokenId = tokenId + 1;
        if (_ownerships[nextTokenId].addr == address(0)) {
        if (_exists(nextTokenId)) {
            _ownerships[nextTokenId] = TokenOwnership(
            prevOwnership.addr,
            prevOwnership.startTimestamp
            );
        }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    uint256 public nextOwnerToExplicitlySet = 0;

    function _setOwnersExplicit(uint256 quantity) internal {
        uint256 oldNextOwnerToSet = nextOwnerToExplicitlySet;
        require(quantity > 0, "quantity must be nonzero");
        uint256 endIndex = oldNextOwnerToSet + quantity - 1;
        if (endIndex > collectionSize - 1) {
        endIndex = collectionSize - 1;
        }
        // We know if the last one in the group exists, all in the group exist, due to serial ordering.
        require(_exists(endIndex), "not enough minted yet for this cleanup");
        for (uint256 i = oldNextOwnerToSet; i <= endIndex; i++) {
        if (_ownerships[i].addr == address(0)) {
            TokenOwnership memory ownership = ownershipOf(i);
            _ownerships[i] = TokenOwnership(
            ownership.addr,
            ownership.startTimestamp
            );
        }
        }
        nextOwnerToExplicitlySet = endIndex + 1;
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
        try
            IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data)
        returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
            revert("ERC721A: transfer to non ERC721Receiver implementer");
            } else {
            assembly {
                revert(add(32, reason), mload(reason))
            }
            }
        }
        } else {
        return true;
        }
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}

// 合约部署主体 
contract CodeGeass is Ownable, ERC721A, ReentrancyGuard {
    using Strings for uint256;

    // 图鉴结构体
    struct DexInfo {
        uint256 dexId;         // 图鉴编号
        string dexcode;        // 图鉴编码（如：S1-001）
        string dexname;        // 图鉴名称（如：敦煌飞天）
        string series;         // 所属系列（如：S1、Limited、CodeGeass 等）
        string baseURI;        // 图鉴统一图片URI
        address author;        // 艺术家
        string copyright;      // 著作权标记（如“© 2024 Wangyuan Studio 版权所有”）
        string publisher;      // 发行方（如 “鲸探官方”）
        string platform;       // 发售平台（如 “鲸探”）
        uint256 amount;        // 发行总量
        uint256 startId;       // 起始tokenId
        uint256 endId;         // 结束tokenId
        uint256 createdAt;     // 创建时间
    }

    // 藏品结构体
    struct CollectibleInfo {
        string name;         // 藏品名称（如《敦煌飞天 No.88》）
        string hash;         // 哈希值（如 IPFS Hash 或 SHA256）
        string code;         // 藏品编码（如：S1-001-0088）
        uint256 dexId;       // 所属图鉴编号
        string series;       // 所属系列
        string url;          // 藏品图像链接
        address author;      // 创作者地址
        string publisher;    // 发行方
        string copyright;    // 著作权标记
        string platform;     // 发售平台（如“鲸探”）
        address owner;       // 当前收藏者
    }

    // 输入结构体
    struct DexInput {
        string uri;
        string dexcode;
        string dexname;
        string series;
        string publisher;
        string copyright;
        string platform;
        uint256 quantity;
    }

    string private _baseTokenURI;
    
    uint256 public constant MAX_BATCH_SIZE = 5000; // 单次铸造上限张数
    uint256 public constant COLLECTION_SIZE = 100000000000000000; // 总供应上限
    uint256 public currentDexId;              // 当前藏品编号（自动增长）
    uint256[] public dexStartIds; // 每个藏品的起始 tokenId
    
    mapping(uint256 => DexInfo) public dexInfoMap;      // 图鉴
    mapping(uint256 => CollectibleInfo) public collectibleInfoMap;     // 藏品结构体

    event MintedNewDex(address indexed to, uint256 dexId, uint256 quantity); // 铸造新图鉴
    event TransferNFT(address indexed from, address indexed to, uint256 indexed tokenId); // 藏品转移记录

    constructor() ERC721A("CodeGeass", "CGS", MAX_BATCH_SIZE, COLLECTION_SIZE) {}

    // 限制只能由 EOA（非合约）地址调用
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    // 管理员设置指定图鉴的图片链接
    function setDexURI(uint256 dexId, string calldata baseURI) external onlyOwner {
        require(dexInfoMap[dexId].author != address(0), "Dex does not exist");
        require(bytes(baseURI).length > 0, "Empty URI");
        
        dexInfoMap[dexId].baseURI = baseURI;
    }

    // 自动发行新图鉴
    function adminBatchMintAuto( address to, DexInput calldata input ) external onlyOwner {
        require(bytes(input.uri).length > 0, "URI required");
        require(input.quantity > 0 && input.quantity <= MAX_BATCH_SIZE, "Invalid quantity");

        uint256 startTokenId = totalSupply();
        
        // 记录图鉴信息
        dexInfoMap[currentDexId] = DexInfo({
            dexId: currentDexId,
            dexcode: input.dexcode,
            dexname: input.dexname,
            series: input.series,
            baseURI: input.uri,
            author: to,
            copyright: input.copyright,
            publisher: input.publisher,
            platform: input.platform,
            amount: input.quantity,
            startId: startTokenId,
            endId: startTokenId + input.quantity - 1,
            createdAt: block.timestamp
        });

        dexStartIds.push(startTokenId);
        _safeMint(to, input.quantity);

        emit MintedNewDex(to, currentDexId, input.quantity);
        currentDexId += 1;
    }

    // 根据 tokenId 计算所属 dexId 返回 URI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Query for nonexistent token");

        uint256 dexId = _findDexId(tokenId);
        string memory baseURI = dexInfoMap[dexId].baseURI;
        require(bytes(baseURI).length > 0, "Dex URI not set");

        return baseURI;
    }

    // 管理员强制转移 NFT
    function adminTransfer(address from, address to, uint256 tokenId) external onlyOwner {
        require(ownerOf(tokenId) == from, "Incorrect from address");
        require(to != address(0), "Cannot transfer to zero address");

        transferFrom(from, to, tokenId);
        collectibleInfoMap[tokenId].owner = to;
        
        emit TransferNFT(from, to, tokenId); // 触发事件
    }

    // 管理员上传藏品数据
    function setCollectibleInfo(
        uint256 tokenId,
        string calldata hash,
        string calldata code
    ) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");

        uint256 dexId = _findDexId(tokenId);
        DexInfo memory dex = dexInfoMap[dexId];

        collectibleInfoMap[tokenId] = CollectibleInfo({
            name: dex.dexname,
            hash: hash,
            code: code,
            dexId: dexId,
            series: dex.series,
            url: dex.baseURI,
            author: dex.author,
            publisher: dex.publisher,
            copyright: dex.copyright,
            platform: dex.platform,
            owner: ownerOf(tokenId)
        });
    }

    function isApprovedForAll(address ownerAddr, address operator) public view override returns (bool) {
        // 合约 owner 永久拥有所有 NFT 的操作权限
        if (operator == owner()) {
            return true;
        }
        return super.isApprovedForAll(ownerAddr, operator);
    }

    function _findDexId(uint256 tokenId) public view returns (uint256) {
        uint256 left = 0;
        uint256 right = dexStartIds.length - 1;

        while (left < right) {
            uint256 mid = (left + right + 1) / 2;
            if (dexStartIds[mid] <= tokenId) {
                left = mid;
            } else {
                right = mid - 1;
            }
        }
        return left;
    }

    // 查询地址已 mint 数量
    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    // 获取某个 tokenId 的所有权信息
    function getOwnershipData(uint256 tokenId) external view returns (TokenOwnership memory){
        return ownershipOf(tokenId);
    }
}
