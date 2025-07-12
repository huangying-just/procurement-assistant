# 采购专家助手 - Docker 部署指南

## 系统要求

- **Docker**: 20.10.0 或更高版本
- **Docker Compose**: 2.0.0 或更高版本
- **内存**: 至少 2GB RAM
- **存储**: 至少 5GB 可用空间

## 1. 安装 Docker

### Ubuntu/Debian
```bash
# 更新包索引
sudo apt update

# 安装必要的包
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 设置稳定版仓库
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# 启动Docker
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
```

### CentOS/RHEL
```bash
# 安装必要的包
sudo yum install -y yum-utils

# 设置仓库
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装Docker Engine
sudo yum install docker-ce docker-ce-cli containerd.io

# 启动Docker
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
```

## 2. 安装 Docker Compose

```bash
# 下载Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

## 3. 部署应用

### 3.1 克隆项目
```bash
# 克隆项目到服务器
git clone <your-repository-url> procurement-assistant
cd procurement-assistant
```

### 3.2 构建和启动
```bash
# 构建镜像并启动服务
docker-compose up -d --build

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 3.3 访问应用
- **直接访问**: http://localhost:3855
- **通过Nginx**: http://localhost:80

## 4. 管理命令

### 4.1 基本操作
```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f procurement-assistant
docker-compose logs -f nginx
```

### 4.2 更新应用
```bash
# 拉取最新代码
git pull origin main

# 重新构建并启动
docker-compose up -d --build

# 清理旧镜像
docker image prune -f
```

### 4.3 备份和恢复
```bash
# 备份数据
docker-compose exec procurement-assistant tar -czf /app/backup.tar.gz /app/dist

# 恢复数据
docker cp backup.tar.gz procurement-assistant:/app/
docker-compose exec procurement-assistant tar -xzf /app/backup.tar.gz -C /app/
```

## 5. 生产环境配置

### 5.1 环境变量
创建 `.env` 文件：
```bash
cat > .env << EOF
NODE_ENV=production
PORT=3855
DIFY_API_URL=https://api.dify.ai/v1
DIFY_API_KEY=app-j07Xbg1LZrwfXQ9ubGMMjeA1
EOF
```

### 5.2 SSL 证书配置
```bash
# 创建SSL目录
mkdir -p ssl

# 生成自签名证书（仅用于测试）
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem -out ssl/cert.pem \
  -subj "/C=CN/ST=State/L=City/O=Organization/CN=localhost"

# 启用HTTPS配置
sed -i 's/# server {/server {/g' nginx.conf
sed -i 's/#     listen 443/    listen 443/g' nginx.conf
```

### 5.3 监控配置
```bash
# 创建监控脚本
cat > monitor.sh << 'EOF'
#!/bin/bash

# 检查容器状态
if ! docker-compose ps | grep -q "procurement-assistant.*Up"; then
    echo "$(date): Container is down, restarting..." >> logs/monitor.log
    docker-compose restart procurement-assistant
fi

# 检查内存使用
MEMORY_USAGE=$(docker stats --no-stream --format "table {{.MemUsage}}" procurement-assistant | tail -1 | awk '{print $1}' | sed 's/[^0-9]//g')
if [ "$MEMORY_USAGE" -gt 1000 ]; then
    echo "$(date): High memory usage: ${MEMORY_USAGE}MB" >> logs/monitor.log
    docker-compose restart procurement-assistant
fi
EOF

chmod +x monitor.sh

# 添加到crontab
echo "*/5 * * * * $(pwd)/monitor.sh" | crontab -
```

## 6. 性能优化

### 6.1 资源限制
修改 `docker-compose.yml`：
```yaml
services:
  procurement-assistant:
    build: .
    ports:
      - "3855:3855"
    environment:
      - NODE_ENV=production
      - PORT=3855
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs
    networks:
      - procurement-network
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
        reservations:
          memory: 512M
          cpus: '0.25'
```

### 6.2 多实例部署
```yaml
services:
  procurement-assistant:
    build: .
    ports:
      - "3855:3855"
    environment:
      - NODE_ENV=production
      - PORT=3855
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs
    networks:
      - procurement-network
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
```

## 7. 故障排除

### 7.1 常见问题

**问题**: 容器无法启动
```bash
# 查看详细日志
docker-compose logs procurement-assistant

# 检查端口占用
sudo netstat -tlnp | grep :3855

# 检查磁盘空间
df -h
```

**问题**: 内存使用过高
```bash
# 查看资源使用
docker stats

# 重启容器
docker-compose restart procurement-assistant
```

**问题**: 网络连接问题
```bash
# 检查网络
docker network ls
docker network inspect procurement-assistant_procurement-network

# 测试容器间通信
docker-compose exec nginx ping procurement-assistant
```

### 7.2 日志管理
```bash
# 创建日志目录
mkdir -p logs

# 查看应用日志
docker-compose logs -f procurement-assistant

# 查看Nginx日志
docker-compose logs -f nginx

# 清理日志
docker system prune -f
```

## 8. 安全建议

1. **使用非root用户**: 在Dockerfile中使用非root用户运行应用
2. **定期更新镜像**: 定期更新基础镜像
3. **限制资源使用**: 设置内存和CPU限制
4. **使用私有网络**: 避免暴露不必要的端口
5. **扫描漏洞**: 定期扫描镜像漏洞
6. **备份数据**: 定期备份重要数据

## 9. 扩展部署

### 9.1 使用 Docker Swarm
```bash
# 初始化Swarm
docker swarm init

# 部署服务
docker stack deploy -c docker-compose.yml procurement

# 查看服务
docker service ls
```

### 9.2 使用 Kubernetes
```bash
# 创建命名空间
kubectl create namespace procurement

# 部署应用
kubectl apply -f k8s/

# 查看状态
kubectl get pods -n procurement
```

## 10. 监控和告警

### 10.1 使用 Prometheus + Grafana
```yaml
# 添加到 docker-compose.yml
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - procurement-network

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - procurement-network
```

---

**部署完成后，您的采购专家助手将在以下地址运行：**
- 直接访问: http://localhost:3855
- 通过Nginx: http://localhost:80
- HTTPS访问: https://localhost:443 (如果配置了SSL) 