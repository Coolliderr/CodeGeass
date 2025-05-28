const express = require('express');
const { ethers } = require('ethers');
require('dotenv').config();

const app = express();
app.use(express.json());

// Token 鉴权中间件
app.use((req, res, next) => {
  const token = req.headers['x-api-token'];
  if (token !== process.env.API_TOKEN) {
    return res.status(403).json({ error: 'Invalid API Token' });
  }
  next();
});

// Ethers 初始化
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// 合约 ABI（请替换为你的实际 ABI）,如果需要添加其它函数，也可以按照这个格式把合约上的函数写过来
const abi = [
  "function adminBatchMintAuto(address to, string uri, string series, string publisher, uint256 quantity) external",
  "function adminTransfer(address from, address to, uint256 tokenId) external"
];

const contract = new ethers.Contract(process.env.CONTRACT_ADDRESS, abi, wallet);

// API：铸造 NFT （由管理员调用）
app.post('/api/mint', async (req, res) => {
  try {
    const { to, uri, series, publisher, quantity } = req.body;

    const tx = await contract.adminBatchMintAuto(to, uri, series, publisher, quantity);
    await tx.wait();

    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// API：NFT 转移（由管理员调用）
app.post('/api/transfer', async (req, res) => {
  try {
    const { from, to, tokenId } = req.body;

    const tx = await contract.adminTransfer(from, to, tokenId);
    await tx.wait();

    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});


// 启动 HTTP 服务
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API running at http://<your-ip>:${PORT}`);
});
