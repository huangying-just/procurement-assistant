# 采购专家助手 - 服务器部署指南

## 系统要求

- **操作系统**: Ubuntu 18.04+ / CentOS 7+ / Debian 9+
- **Node.js**: 16.0.0 或更高版本
- **内存**: 至少 2GB RAM
- **存储**: 至少 10GB 可用空间
- **网络**: 稳定的网络连接

## 1. 服务器环境准备

### 1.1 更新系统
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 1.2 安装 Node.js
```bash
# 使用 NodeSource 仓库安装 Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node --version
npm --version
```

### 1.3 安装 PM2
```bash
# 全局安装 PM2
sudo npm install -g pm2

# 验证安装
pm2 --version
```

### 1.4 安装 Nginx (可选，用于反向代理)
```bash
# Ubuntu/Debian
sudo apt install nginx -y

# CentOS/RHEL
sudo yum install nginx -y
```

## 2. 项目部署

### 2.1 克隆项目
```bash
# 创建部署目录
sudo mkdir -p /var/www/procurement-assistant
sudo chown $USER:$USER /var/www/procurement-assistant

# 克隆项目（如果使用Git）
cd /var/www
git clone <your-repository-url> procurement-assistant
cd procurement-assistant

# 或者直接上传项目文件到服务器
```

### 2.2 安装依赖
```bash
cd /var/www/procurement-assistant
npm install --production
```

### 2.3 构建生产版本
```bash
npm run build
```

### 2.4 创建环境配置文件
```bash
# 创建环境变量文件
cat > .env << EOF
NODE_ENV=production
PORT=3855
DIFY_API_URL=https://api.dify.ai/v1
DIFY_API_KEY=your-apikey
EOF
```

## 3. PM2 配置

### 3.1 创建 PM2 配置文件
```bash
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'procurement-assistant',
    script: 'npm',
    args: 'run preview',
    cwd: '/var/www/procurement-assistant',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3855
    },
    error_file: '/var/log/pm2/procurement-assistant-error.log',
    out_file: '/var/log/pm2/procurement-assistant-out.log',
    log_file: '/var/log/pm2/procurement-assistant-combined.log',
    time: true
  }]
};
EOF
```

### 3.2 创建日志目录
```bash
sudo mkdir -p /var/log/pm2
sudo chown $USER:$USER /var/log/pm2
```

### 3.3 启动应用
```bash
# 使用 PM2 启动应用
pm2 start ecosystem.config.js

# 保存 PM2 配置
pm2 save

# 设置开机自启
pm2 startup
```

## 4. Nginx 反向代理配置 (推荐)

### 4.1 创建 Nginx 配置文件
```bash
sudo tee /etc/nginx/sites-available/procurement-assistant << 'EOF'
server {
    listen 80;
    server_name your-domain.com;  # 替换为您的域名

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # 静态文件缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # API 代理
    location /api/ {
        proxy_pass http://localhost:3855/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # 主应用
    location / {
        proxy_pass http://localhost:3855;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
```

### 4.2 启用站点
```bash
# 创建软链接
sudo ln -s /etc/nginx/sites-available/procurement-assistant /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

## 5. 防火墙配置

### 5.1 配置 UFW (Ubuntu)
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 5.2 配置 firewalld (CentOS)
```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## 6. SSL 证书配置 (推荐)

### 6.1 安装 Certbot
```bash
# Ubuntu/Debian
sudo apt install certbot python3-certbot-nginx -y

# CentOS/RHEL
sudo yum install certbot python3-certbot-nginx -y
```

### 6.2 获取 SSL 证书
```bash
sudo certbot --nginx -d your-domain.com
```

## 7. 监控和维护

### 7.1 PM2 常用命令
```bash
# 查看应用状态
pm2 status

# 查看日志
pm2 logs procurement-assistant

# 重启应用
pm2 restart procurement-assistant

# 停止应用
pm2 stop procurement-assistant

# 删除应用
pm2 delete procurement-assistant

# 监控资源使用
pm2 monit
```

### 7.2 日志管理
```bash
# 查看错误日志
tail -f /var/log/pm2/procurement-assistant-error.log

# 查看输出日志
tail -f /var/log/pm2/procurement-assistant-out.log

# 查看合并日志
tail -f /var/log/pm2/procurement-assistant-combined.log
```

### 7.3 系统监控脚本
```bash
# 创建监控脚本
cat > /var/www/procurement-assistant/monitor.sh << 'EOF'
#!/bin/bash

# 检查应用状态
if ! pm2 list | grep -q "procurement-assistant.*online"; then
    echo "$(date): Application is down, restarting..." >> /var/log/pm2/monitor.log
    pm2 restart procurement-assistant
fi

# 检查内存使用
MEMORY_USAGE=$(pm2 list | grep procurement-assistant | awk '{print $4}' | sed 's/[^0-9]//g')
if [ "$MEMORY_USAGE" -gt 1000 ]; then
    echo "$(date): High memory usage: ${MEMORY_USAGE}MB" >> /var/log/pm2/monitor.log
    pm2 restart procurement-assistant
fi
EOF

chmod +x /var/www/procurement-assistant/monitor.sh

# 添加到 crontab
echo "*/5 * * * * /var/www/procurement-assistant/monitor.sh" | crontab -
```

## 8. 备份策略

### 8.1 创建备份脚本
```bash
cat > /var/www/procurement-assistant/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/var/backups/procurement-assistant"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份应用文件
tar -czf $BACKUP_DIR/app_$DATE.tar.gz -C /var/www procurement-assistant

# 备份 PM2 配置
pm2 save
cp ~/.pm2/dump.pm2 $BACKUP_DIR/pm2_dump_$DATE.pm2

# 删除7天前的备份
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.pm2" -mtime +7 -delete

echo "Backup completed: $DATE" >> $BACKUP_DIR/backup.log
EOF

chmod +x /var/www/procurement-assistant/backup.sh

# 添加到 crontab (每天凌晨2点备份)
echo "0 2 * * * /var/www/procurement-assistant/backup.sh" | crontab -
```

## 9. 故障排除

### 9.1 常见问题

**问题**: 应用无法启动
```bash
# 检查端口是否被占用
sudo netstat -tlnp | grep :3855

# 检查日志
pm2 logs procurement-assistant
```

**问题**: 内存使用过高
```bash
# 查看内存使用情况
pm2 monit

# 重启应用
pm2 restart procurement-assistant
```

**问题**: Nginx 无法访问
```bash
# 检查 Nginx 状态
sudo systemctl status nginx

# 检查防火墙
sudo ufw status
```

### 9.2 性能优化

```bash
# 启用 gzip 压缩
sudo tee -a /etc/nginx/nginx.conf << 'EOF'
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_proxied any;
gzip_comp_level 6;
gzip_types
    text/plain
    text/css
    text/xml
    text/javascript
    application/json
    application/javascript
    application/xml+rss
    application/atom+xml
    image/svg+xml;
EOF
```

## 10. 更新部署

### 10.1 自动更新脚本
```bash
cat > /var/www/procurement-assistant/update.sh << 'EOF'
#!/bin/bash

cd /var/www/procurement-assistant

# 停止应用
pm2 stop procurement-assistant

# 拉取最新代码
git pull origin main

# 安装依赖
npm install --production

# 构建应用
npm run build

# 启动应用
pm2 start procurement-assistant

echo "Update completed at $(date)" >> /var/log/pm2/update.log
EOF

chmod +x /var/www/procurement-assistant/update.sh
```

## 11. 安全建议

1. **定期更新系统**: `sudo apt update && sudo apt upgrade`
2. **使用强密码**: 为所有账户设置强密码
3. **限制 SSH 访问**: 只允许密钥认证
4. **定期备份**: 确保数据安全
5. **监控日志**: 定期检查系统日志
6. **使用 HTTPS**: 配置 SSL 证书

## 12. 联系信息

如果在部署过程中遇到问题，请检查：
- PM2 日志: `pm2 logs procurement-assistant`
- Nginx 日志: `sudo tail -f /var/log/nginx/error.log`
- 系统日志: `sudo journalctl -u nginx`

---

**部署完成后，您的采购专家助手将在以下地址运行：**
- 本地访问: http://localhost:3855
- 域名访问: https://your-domain.com (如果配置了域名和SSL) 