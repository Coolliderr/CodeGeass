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

// 合约 ABI
const abi = [
  "function adminBatchMintAuto(address to, (string uri,string dexcode,string dexname,string series,string publisher,string copyright,string platform,uint256 quantity,string createdAt) input) external",
  "function setCollectibleInfo(uint256 tokenId, string hash, string code) external",
  "function adminTransfer(address from, address to, uint256 tokenId) external",
  "function collectibleInfoMap(uint256) view returns (string name, string hash, string code, uint256 dexId, string series, string url, address author, string publisher, string copyright, string platform, address owner)",
  "function dexInfoMap(uint256) view returns (uint256 dexId, string dexcode, string dexname, string series, string baseURI, address author, string copyright, string publisher, string platform, uint256 amount, uint256 startId, uint256 endId, uint256 createdAt)",
  "function _findDexId(uint256 tokenId) view returns (uint256)",
  "function balanceOf(address owner) view returns (uint256)",
  "function lastDexCreatedBy(address owner) view returns (uint256)",
  "function ownerOf(uint256 tokenId) view returns (address)",
  "function totalSupply() view returns (uint256)",
  "function currentDexId() view returns (uint256)"
];

const contract = new ethers.Contract(process.env.CONTRACT_ADDRESS, abi, wallet);

// API：铸造 NFT
app.post('/api/mint', async (req, res) => {
  try {
    const { to, uri, dexcode, dexname, series, publisher, copyright, platform, quantity, createdAt } = req.body;

    if (!to || !uri || !dexcode || !dexname || !series || !publisher || !copyright || !platform || !createdAt || quantity === undefined || isNaN(quantity)) {
      return res.status(400).json({ error: "Missing calldata" });
    }

    const input = { uri, dexcode, dexname, series, publisher, copyright, platform, quantity, createdAt };
    const tx = await contract.adminBatchMintAuto(to, input);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// API：NFT 转移
app.post('/api/transfer', async (req, res) => {
  try {
    const { from, to, tokenId } = req.body;
    if (!from || !to || !tokenId) {
      return res.status(400).json({ error: "Missing tokenId, from or to" });
    }
    const tx = await contract.adminTransfer(from, to, tokenId);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// API：上传单个NFT藏品数据
app.post('/api/set-collectibles', async (req, res) => {
  try {
    const { tokenId, hash, code } = req.body;
    if (!tokenId || !hash || !code) {
      return res.status(400).json({ error: "Missing tokenId, hash or code" });
    }
    const tx = await contract.setCollectibleInfo(tokenId, hash, code);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// 获取单个藏品信息
app.get('/api/collectible', async (req, res) => {
  try {
    const tokenId = req.query.tokenId;
    if (!tokenId) return res.status(400).json({ error: 'tokenId is required' });

    const raw = await contract.collectibleInfoMap(tokenId);
    const data = {
      tokenId: tokenId.toString(),
      name: raw.name,
      hash: raw.hash,
      code: raw.code,
      dexId: raw.dexId.toString(),
      series: raw.series,
      url: raw.url,
      author: raw.author,
      publisher: raw.publisher,
      copyright: raw.copyright,
      platform: raw.platform,
      owner: raw.owner
    };
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 获取图鉴信息
app.get('/api/dex', async (req, res) => {
  try {
    const dexId = req.query.dexId;
    if (!dexId) return res.status(400).json({ error: 'dexId is required' });

    const raw = await contract.dexInfoMap(dexId);
    const data = {
      dexId: raw.dexId.toString(),
      dexcode: raw.dexcode,
      dexname: raw.dexname,
      series: raw.series,
      baseURI: raw.baseURI,
      author: raw.author,
      copyright: raw.copyright,
      publisher: raw.publisher,
      platform: raw.platform,
      amount: raw.amount.toString(),
      startId: raw.startId.toString(),
      endId: raw.endId.toString(),
      createdAt: raw.createdAt.toString()
    };
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 根据 tokenId 获取所属图鉴编号
app.get('/api/token-dex', async (req, res) => {
  try {
    const tokenId = req.query.tokenId;
    if (!tokenId) return res.status(400).json({ error: 'tokenId is required' });

    const dexId = await contract._findDexId(tokenId);
    res.json({ tokenId: tokenId.toString(), dexId: dexId.toString() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 获取地址持有 NFT 数量
app.get('/api/balance', async (req, res) => {
  try {
    const address = req.query.address;
    if (!address) return res.status(400).json({ error: 'address is required' });

    const balance = await contract.balanceOf(address);
    res.json({ address, balance: balance.toString() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 获取商户地址最后铸造的图鉴编号
app.get('/api/lastDexCreatedBy', async (req, res) => {
  try {
    const address = req.query.address;
    if (!address) return res.status(400).json({ error: 'address is required' });

    const lastDexCreatedBy = await contract.lastDexCreatedBy(address);
    res.json({ address, lastDexCreatedBy: lastDexCreatedBy.toString() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 查询某 tokenId 的拥有者
app.get('/api/owner', async (req, res) => {
  try {
    const tokenId = req.query.tokenId;
    if (!tokenId) return res.status(400).json({ error: 'tokenId is required' });

    const owner = await contract.ownerOf(tokenId);
    res.json({ tokenId: tokenId.toString(), owner });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 当前已铸造的 token 数量
app.get('/api/total-supply', async (req, res) => {
  try {
    const total = await contract.totalSupply();
    res.json({ totalSupply: total.toString() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 当前图鉴编号计数器
app.get('/api/current-dex-id', async (req, res) => {
  try {
    const current = await contract.currentDexId();
    res.json({ currentDexId: current.toString() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// API：生成新的以太坊钱包地址
app.get('/api/generate-wallet', (req, res) => {
  try {
    const wallet = ethers.Wallet.createRandom();

    res.json({
      address: wallet.address,
      privateKey: wallet.privateKey,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 启动 HTTP 服务
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API running at http://<your-ip>:${PORT}`);
});
