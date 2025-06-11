# 合约地址
https://polygonscan.com/address/0xe05c4fea214205931e786137175534d5efd3da35#code  
# NFT Batch Minting API

这是一个基于 Node.js + Express + Ethers.js 的后端服务，用于后台调用合约。其中函数 `adminBatchMintAuto` 批量铸造 NFT，函数 `adminTransfer` 转移 NFT。

---

## 📦 环境准备

建议使用 Ubuntu 服务器 + Node.js 18+

1✅、安装最新版的node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

2✅、验证安装
```bash
node -v
npm -v
```

3✅、创建项目目录，在root文件夹新建一个名为  `nft` 的文件夹
```bash
mkdir nft && cd nft
npm init -y
```

4✅、安装脚本依赖库（ethers库用于调用区块链）
```bash
npm install express ethers dotenv
```
  
5✅、导入文件
把 `.env` 和 `index.js` 两个文件上传到创建的 `nft` 文件夹下

6✅、启动脚本服务
```bash
node index.js
```

7✅、开启pm2脚本自动运行（开启后关闭服务器依然运行）
```bash
sudo npm install -g pm2
pm2 start index.js --name ethers-api
pm2 save
pm2 startup
```

8✅、如果修改了脚本或者配置，输入重启命令
```bash
pm2 restart ethers-api
```

9✅、开放防火墙端口，并设置安全组（比如阿里云安全组添加3000端口，并将授权对象授权给平台指定的服务器，防止其他人恶意调用脚本）
```bash
sudo ufw allow 3000
```

## 📦 调用API

x-api-token是访问权限token，在.env文件中修改，`<your-ip>`换成你自己的服务器IP 或用测试IP：8.217.239.202

1✅、管理员给指定地址批量MINT NFT  
当商户需要发行NFT的时候，后台调用此API，并根据回调结果执行小程序的其它程序  
```bash
curl -X POST http://<your-ip>:3000/api/mint \
  -H "Content-Type: application/json" \
  -H "x-api-token: abc123456" \
  -d '{
    "to": "0xabc123...",                      // 商户地址，用于接收铸造的NFT
    "uri": "https://example.com/meta.json",   // 图片链接，通常是统一URI
    "dexcode": "S1-001",                      // 图鉴编码
    "dexname": "敦煌飞天",                    // 图鉴名称
    "series": "S1",                            // 所属系列
    "publisher": "MyStudio",                  // 出版社/发行方
    "copyright": "© 2024 MyStudio",           // 著作权标记
    "platform": "MyPlatform",                 // 发售平台名称
    "quantity": 5,                             // 铸造数量
    "createdAt": "2024-06-06 13:00"           // 图鉴创建时间
}'
```
```bash
{
  "success":true,
  "txHash":"0x94fe7fafbbbc50dc4e8cbbbb1d13ef2273c1585dcf6607bdb8d71a788a3e9780"
}
```

2✅、管理员给指定地址转账 NFT  
当商户的NFT在小程序端用户扣款后，后台调用此API，把NFT从商户地址转账给用户地址  
```bash
curl -X POST http://<your-ip>:3000/api/transfer \
  -H "Content-Type: application/json" \
  -H "x-api-token: abc123456" \
  -d '{
    "from": "0xabc123...", //从商户地址转出
    "to": "0xabc123...", //要接收的用户地址
    "tokenid": "100" // NFT编号
}'
```
```bash
{
  "success":true,
  "txHash":"0x94fe7fafbbbc50dc4e8cbbbb1d13ef2273c1585dcf6607bdb8d71a788a3e9780"
}
```
3✅、管理员给指定编号的NFT上传数据  
当商户的NFT卖出转账给用户后，后台调用此API，把一些藏品信息上传  
```bash
curl -X POST http://<your-ip>:3000/api/set-collectibles \
  -H "Content-Type: application/json" \
  -H "x-api-token: abc123456" \
  -d '{
    "tokenId": 1234,                          // 要设置信息的 NFT tokenId
    "hash": "QmXYZabc...123",                // 藏品哈希值（如 IPFS CID 或 SHA256）
    "code": "S1-001-0123"                    // 藏品编码（一般是图鉴编码 + 序号）
}'
```
```bash
{
  "success":true,
  "txHash":"0x94fe7fafbbbc50dc4e8cbbbb1d13ef2273c1585dcf6607bdb8d71a788a3e9780"
}
```
4✅、/api/collectible 获取单个藏品信息
```bash
curl -X GET "http://<your-ip>:3000/api/collectible?tokenId=2" \
  -H "x-api-token: abc123456"
```
```bash
{
  "tokenId":"2",
  "name":"大圣归来",
  "hash":"0xbdbcb710f020b7c79623bacd2a4fccc54f2db607823d7cd65a501e6493d50054",
  "code":"S1-001-0002",
  "dexId":"0",
  "series":"S1",
  "url":"https://himailx.oss-cn-hongkong.aliyuncs.com/%E5%9B%BE%E7%89%87/4943.png",
  "author":"0xaf07DCE2B9A6E056AB9C9E6B85723c064b7D7959",
  "publisher":"米哈游",
  "copyright":"© 2024 Wangyuan Studio 版权所有",
  "platform":"鲸探",
  "owner":"0xaf07DCE2B9A6E056AB9C9E6B85723c064b7D7959"
}
```
5✅、/api/dex 获取图鉴信息
```bash
curl -X GET "http://<your-ip>:3000/api/dex?dexId=0" \
  -H "x-api-token: abc123456"
```
```bash
{
  "dexId":"0",
  "dexcode":"S1-001",
  "dexname":"大圣归来",
  "series":"S1",
  "baseURI":"https://himailx.oss-cn-hongkong.aliyuncs.com/%E5%9B%BE%E7%89%87/4943.png",
  "author":"0xaf07DCE2B9A6E056AB9C9E6B85723c064b7D7959",
  "copyright":"© 2024 Wangyuan Studio 版权所有",
  "publisher":"米哈游",
  "platform":"鲸探",
  "amount":"100",
  "startId":"0",
  "endId":"99",
  "createdAt":"1748735032"
}
```
6✅、/api/token-dex 获取 tokenId 所属图鉴编号
```bash
curl -X GET "http://<your-ip>:3000/api/token-dex?tokenId=1234" \
  -H "x-api-token: abc123456"
```
```bash
{
  "tokenId":"8",
  "dexId":"0"
}
```
7✅、/api/balance 查询某地址的持仓数量
```bash
curl -X GET "http://<your-ip>:3000/api/balance?address=0xabc123..." \
  -H "x-api-token: abc123456"
```
```bash
{
  "address":"0x4FDC3F3F097678bee02dCeA78c8841fb54355BCa",
  "balance":"1"
}
```
8✅、/api/lastDexCreatedBy 查询某商户地址最后铸造的图鉴编号，用得到的编号去获取图鉴信息，从而输出 NFT tokenId 数组
```bash
curl -X GET "http://<your-ip>:3000/api/lastDexCreatedBy?address=0xabc123..." \
  -H "x-api-token: abc123456"
```
```bash
{
  "address":"0x4FDC3F3F097678bee02dCeA78c8841fb54355BCa",
  "lastDexCreatedBy":"1"
}
```
9✅、/api/owner 查询某 tokenId 拥有者
```bash
curl -X GET "http://<your-ip>:3000/api/owner?tokenId=1234" \
  -H "x-api-token: abc123456"
```
```bash
{
  "tokenId":"8",
  "owner":"0xaf07DCE2B9A6E056AB9C9E6B85723c064b7D7959"
}
```
10✅、/api/total-supply 查询当前已铸造的总 NFT 数量
```bash
curl -X GET "http://<your-ip>:3000/api/total-supply" \
  -H "x-api-token: abc123456"
```
```bash
{
  "totalSupply":"110"
}
```
11✅、/api/current-dex-id 查询图鉴编号计数器（用于查询合约中总共创建了多少个图鉴）
```bash
curl -X GET "http://<your-ip>:3000/api/current-dex-id" \
  -H "x-api-token: abc123456"
```
```bash
{
  "currentDexId":"2"
}
```
12✅、/api/generate-wallet 生成新以太坊地址 & 私钥
```bash
curl -X GET "http://<your-ip>:3000/api/generate-wallet" \
  -H "x-api-token: abc123456"
```
```bash
{
  "address":"0x13515299fc411A4a40d20d3539a4186E030d6703",
  "privateKey":"0xc980d22f4eff8d1762851f02a46dadf66b8cc511385fa47266c9d3ff5e114dcb"
}
```

# 读取交易记录（topic0 是事件索引，返回的结果中 topic1 是发送地址， topic2 是接收地址， topic3 是 NFT编号，）
```bash
https://api.polygonscan.com/api?module=logs&action=getLogs&fromBlock=0&toBlock=latest&address=0x13d33BB6Ce1DE1d04C49F7F121532dC119041fe4&topic0=0xa64cdec004d2859ac7547f4ed3252f53d0fa0b8dcbcc93a47894eee072714b62&apikey=7SZ3BU8XRYQFA8C316TF5YVMB1HPKIEEGK
```
返回结果  
```bash
{
  "status": "1",
  "message": "OK",
  "result": [
    {
      "address": "0x13d33bb6ce1de1d04c49f7f121532dc119041fe4",
      "topics": [
        "0xa64cdec004d2859ac7547f4ed3252f53d0fa0b8dcbcc93a47894eee072714b62", // topic0
        "0x000000000000000000000000902b6b2802cd8d26a9431f18ab4b3b92c8d9359c", // topic1
        "0x000000000000000000000000af07dce2b9a6e056ab9c9e6b85723c064b7d7959", // topic2
        "0x0000000000000000000000000000000000000000000000000000000000000000" // topic3
      ],
      "data": "0x",
      "blockNumber": "0x45135ce",
      "blockHash": "0x8669e28ba88704b068c131abfed6bbd0593445996ced8e6b5319cee8c8424cf7",
      "timeStamp": "0x6842c908", // 转账时间戳
      "gasPrice": "0x9a7d2a317",
      "gasUsed": "0x1c22f",
      "logIndex": "0x155",
      "transactionHash": "0xcd069cbf2df36b266aeaa7ae308b3bba6114824866d4d64dacbeb3a72e5af5b2",
      "transactionIndex": "0x43"
    }
  ]
}
```
解析代码1
```bash
//解析钱包地址如：0x000000000000000000000000902b6b2802cd8d26a9431f18ab4b3b92c8d9359c
function parseAddressFromData(data) {
    if (data.startsWith('0x')) data = data.slice(2);
    const addressHex = data.slice(-40); // 取最后40位（20字节）
    return '0x' + addressHex;
}

const raw = "0x000000000000000000000000902b6b2802cd8d26a9431f18ab4b3b92c8d9359c";
const address = parseAddressFromData(raw);
return { res:address }
```
解析代码2
```bash
//解析编号如：0x0000000000000000000000000000000000000000000000000000000000000001
function parseUint256FromHex(hex) {
    if (hex.startsWith('0x')) hex = hex.slice(2);
    return BigInt('0x' + hex);
}

const raw = "0x0000000000000000000000000000000000000000000000000000000000000001";
const value = parseUint256FromHex(raw);
return { res:value.toString() }
```
