#!/bin/bash

# 采购专家助手 - 快速部署脚本
# 使用方法: ./deploy.sh

set -e

echo "🚀 开始部署采购专家助手..."

# 检查是否为root用户
if [ "$EUID" -eq 0 ]; then
    echo "❌ 请不要使用root用户运行此脚本"
    exit 1
fi

# 检查Node.js
if ! command -v node &> /dev/null; then
    echo "📦 安装 Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 检查PM2
if ! command -v pm2 &> /dev/null; then
    echo "📦 安装 PM2..."
    sudo npm install -g pm2
fi

# 创建部署目录
echo "📁 创建部署目录..."
sudo mkdir -p /var/www/procurement-assistant
sudo chown $USER:$USER /var/www/procurement-assistant

# 复制项目文件
echo "📋 复制项目文件..."
cp -r . /var/www/procurement-assistant/
cd /var/www/procurement-assistant

# 安装依赖
echo "📦 安装依赖..."
npm install --production

# 构建项目
echo "🔨 构建项目..."
npm run build

# 创建PM2配置文件
echo "⚙️ 创建PM2配置..."
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

# 创建日志目录
echo "📝 创建日志目录..."
sudo mkdir -p /var/log/pm2
sudo chown $USER:$USER /var/log/pm2

# 启动应用
echo "🚀 启动应用..."
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# 创建监控脚本
echo "📊 创建监控脚本..."
cat > monitor.sh << 'EOF'
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

chmod +x monitor.sh

# 添加到crontab
echo "⏰ 设置定时监控..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /var/www/procurement-assistant/monitor.sh") | crontab -

echo ""
echo "✅ 部署完成！"
echo ""
echo "📊 应用状态:"
pm2 status
echo ""
echo "🌐 访问地址: http://localhost:3855"
echo ""
echo "📝 常用命令:"
echo "  查看状态: pm2 status"
echo "  查看日志: pm2 logs procurement-assistant"
echo "  重启应用: pm2 restart procurement-assistant"
echo "  停止应用: pm2 stop procurement-assistant"
echo ""
echo "📚 详细文档请查看 DEPLOYMENT.md" 