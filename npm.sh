#!/bin/bash

set -e  # 遇到错误立即退出

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
echo "🔹 访问管理面板：http://你的服务器IP:81"
echo "🔹 默认账号：admin@example.com / changeme"
