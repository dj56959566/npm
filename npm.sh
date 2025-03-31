#!/bin/bash

set -e  # 遇到错误立即退出

echo "🚀 开始安装 Docker..."
curl -fsSL https://get.docker.com | bash
sudo systemctl enable --now docker

echo "🚀 安装 Docker Compose..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)
sudo curl -SL "https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "🚀 创建 Nginx Proxy Manager 目录..."
mkdir -p /opt/npm && cd /opt/npm

echo "🚀 生成 docker-compose.yml..."
cat > docker-compose.yml <<EOF
version: '3'
services:
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

echo "🚀 启动 Nginx Proxy Manager..."
docker-compose up -d

echo "✅ 安装完成！"
echo "🔹 访问管理面板：http://你的服务器IP:81"
echo "🔹 默认账号：admin@example.com / changeme"
