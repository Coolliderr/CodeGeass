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

// 合约 ABI（请替换为你的实际 ABI）
const abi = [
  "function balanceOf(address owner) view returns (uint256)",
  "function transfer(address to, uint256 amount) returns (bool)"
];
const contract = new ethers.Contract(process.env.CONTRACT_ADDRESS, abi, wallet);

// API：转账
app.post('/api/transfer', async (req, res) => {
  try {
    const { to, amount } = req.body;
    const tx = await contract.transfer(to, ethers.parseUnits(amount.toString(), 18));
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 启动 HTTP 服务
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API running at http://<your-ip>:${PORT}`);
});