#!/bin/bash

set -e  # 遇到错误立即退出

echo "🚀 检查 Docker 是否安装..."
if ! command -v docker &> /dev/null; then
    echo "🔹 未检测到 Docker，开始安装..."
    curl -fsSL https://get.docker.com | bash
    sudo systemctl enable --now docker
fi

echo "🚀 检查 Docker Compose 是否安装..."
if ! command -v docker-compose &> /dev/null; then
    echo "🔹 未检测到 Docker Compose，开始安装..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)
    sudo curl -SL "https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo "🚀 创建 Nginx Proxy Manager 目录..."
mkdir -p /etc/docker/npm && cd /etc/docker/npm

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
echo "🔹 访问管理面板：http://$(hostname -I | awk '{print $1}'):81"
echo "🔹 默认账号：admin@example.com / changeme"

