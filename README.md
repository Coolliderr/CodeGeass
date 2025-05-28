# NFT Batch Minting API

这是一个基于 Node.js + Express + Ethers.js 的后端服务，用于调用合约函数 `adminBatchMintAuto` 批量铸造 NFT。

---

## 🚀 功能特色

- ✅ 支持批量 mint NFT 到指定地址
- ✅ 后端集成 Ethers.js，自动签名并发送交易
- ✅ 支持 API token 认证，提升安全性
- ✅ 使用 pm2 实现后台守护、开机自启

---

## 📦 环境准备

建议使用 Ubuntu 服务器 + Node.js 18+

```bash
sudo apt update
sudo apt install nodejs npm -y
sudo npm install -g pm2
