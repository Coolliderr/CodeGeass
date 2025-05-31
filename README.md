# 合约地址
https://polygonscan.com/address/0x06e14e0b43ec4df793c0dc97752c3328c2067ba3#code  
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

8✅、开放防火墙端口，并设置安全组（比如阿里云安全组添加3000端口，并将授权对象授权给平台指定的服务器，防止其他人恶意调用脚本）
```bash
sudo ufw allow 3000
```

9✅、调用API(x-api-token是访问权限token，在.env文件中修改)

(1) 管理员给指定地址批量MINT NFT  
当商户需要发行NFT的时候，后台调用此API，并根据回调结果执行小程序的其它程序  
```bash
curl -X POST http://<your-ip>:3000/api/mint \
  -H "Content-Type: application/json" \
  -H "x-api-token: abc123456" \
  -d '{
    "to": "0xabc123...", //商户地址，用于接收铸造的NFT
    "uri": "https://example.com/meta.json", //图片链接，可以是OSS链接
    "series": "S1", //系列
    "publisher": "MyStudio", //出版商
    "quantity": 5 //铸造数量
}'
```

(2) 管理员给指定地址转账 NFT  
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

10✅、API回调结果（success回调交易成功与否，txHash是交易成功后的交易哈希值，供用户查询真实性）
```bash
{
  "success":true,
  "txHash":"0x94fe7fafbbbc50dc4e8cbbbb1d13ef2273c1585dcf6607bdb8d71a788a3e9780"
}
```
