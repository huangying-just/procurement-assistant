#!/bin/bash

# 应用状态检查脚本

echo "🔍 检查应用状态..."
echo "===================="

# 检查Docker服务
echo "🐳 检查Docker服务..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker 服务未运行"
    exit 1
fi

echo "✅ Docker 服务正常"

# 检查docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose 未安装"
    exit 1
fi

# 检查项目文件
echo ""
echo "📁 检查项目文件..."
REQUIRED_FILES=("docker-compose.yml" "Dockerfile" ".env" "package.json")

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 缺失"
        exit 1
    fi
done

# 检查环境变量
echo ""
echo "🔐 检查环境变量..."
if [ -f ".env" ]; then
    if grep -q "VITE_DIFY_API_KEY=your-dify-api-key-here" .env; then
        echo "⚠️  API密钥未配置，请编辑 .env 文件"
    else
        echo "✅ API密钥已配置"
    fi
    
    # 检查端口配置
    if grep -q "PORT=" .env; then
        PORT=$(grep "PORT=" .env | cut -d'=' -f2)
        echo "✅ 应用端口: $PORT"
    fi
    
    if grep -q "NGINX_PORT=" .env; then
        NGINX_PORT=$(grep "NGINX_PORT=" .env | cut -d'=' -f2)
        echo "✅ Nginx端口: $NGINX_PORT"
    fi
else
    echo "❌ .env 文件不存在"
    exit 1
fi

# 检查容器状态
echo ""
echo "📦 检查容器状态..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ 容器正在运行"
    docker-compose ps
else
    echo "⚠️  容器未运行"
    echo "使用 'docker-compose up -d' 启动容器"
fi

# 检查端口占用
echo ""
echo "🌐 检查端口状态..."
if [ ! -z "$PORT" ]; then
    if netstat -tulpn 2>/dev/null | grep -q ":$PORT "; then
        echo "✅ 端口 $PORT 正在监听"
    else
        echo "⚠️  端口 $PORT 未监听"
    fi
fi

if [ ! -z "$NGINX_PORT" ]; then
    if netstat -tulpn 2>/dev/null | grep -q ":$NGINX_PORT "; then
        echo "✅ 端口 $NGINX_PORT 正在监听"
    else
        echo "⚠️  端口 $NGINX_PORT 未监听"
    fi
fi

# 健康检查
echo ""
echo "🏥 健康检查..."
if [ ! -z "$NGINX_PORT" ]; then
    if curl -f -s http://localhost:$NGINX_PORT/health > /dev/null 2>&1; then
        echo "✅ 应用健康检查通过"
    else
        echo "⚠️  应用健康检查失败"
    fi
fi

# 检查日志
echo ""
echo "📋 最近日志..."
if docker-compose ps | grep -q "Up"; then
    echo "--- 应用日志 (最近5行) ---"
    docker-compose logs --tail=5 app 2>/dev/null || echo "无法获取应用日志"
fi

# 总结
echo ""
echo "📊 状态总结:"
echo "============"

# 获取容器状态
if docker-compose ps | grep -q "Up"; then
    echo "🟢 服务状态: 运行中"
    
    if [ ! -z "$NGINX_PORT" ]; then
        echo "🌐 访问地址: http://localhost:$NGINX_PORT"
    fi
    
    echo ""
    echo "🔧 管理命令:"
    echo "  查看日志: docker-compose logs -f"
    echo "  重启服务: docker-compose restart"
    echo "  停止服务: docker-compose down"
else
    echo "🔴 服务状态: 未运行"
    echo ""
    echo "🚀 启动命令:"
    echo "  docker-compose up -d"
fi

echo ""
echo "📚 更多帮助:"
echo "  故障排除: cat TROUBLESHOOTING.md"
echo "  快速指南: cat QUICK_START.md" 