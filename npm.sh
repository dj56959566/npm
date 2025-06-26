#!/bin/bash

set -e  # 遇到错误立即退出

echo "🚀 检查 Docker 是否安装..."
if ! command -v docker &> /dev/null; then
    echo "🔹 未检测到 Docker，开始安装..."
    curl -fsSL https://get.docker.com | bash
    sudo systemctl enable --now docker
fi

echo "🚀 检查 Docker Compose 是否安装..."
COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ 未检测到 Docker Compose 命令（docker-compose 或 docker compose），请先安装。"
    exit 1
fi

echo "🚀 创建 Nginx Proxy Manager 目录..."
mkdir -p /etc/docker/npm && cd /etc/docker/npm

# 交互输入端口，默认80、81、443
read -rp "请输入 HTTP 端口（默认80）: " PORT_HTTP
PORT_HTTP=${PORT_HTTP:-80}
read -rp "请输入 管理面板端口（默认81）: " PORT_PANEL
PORT_PANEL=${PORT_PANEL:-81}
read -rp "请输入 HTTPS 端口（默认443）: " PORT_HTTPS
PORT_HTTPS=${PORT_HTTPS:-443}

echo "🔹 设置端口映射为：HTTP $PORT_HTTP，管理面板 $PORT_PANEL，HTTPS $PORT_HTTPS"

echo "🚀 生成 docker-compose.yml..."
cat > docker-compose.yml <<EOF
services:
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '${PORT_HTTP}:80'
      - '${PORT_PANEL}:81'
      - '${PORT_HTTPS}:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

echo "🚀 启动 Nginx Proxy Manager..."
docker-compose up -d

IP=$(hostname -I | awk '{print $1}')
echo "✅ 安装完成！"
echo "🔹 访问管理面板：http://$IP:$PORT_PANEL"
echo "🔹 默认账号：admin@example.com / changeme"
