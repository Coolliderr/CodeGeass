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
