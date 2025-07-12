#!/bin/bash

# 采购专家助手 - 应用状态检查脚本

echo "🔍 检查采购专家助手应用状态..."
echo "=================================="

# 检查构建文件
echo "📁 检查构建文件..."
if [ -d "dist" ]; then
    echo "✅ dist/ 目录存在"
    echo "   - 文件列表:"
    ls -la dist/ | head -10
    echo "   - 构建文件大小:"
    du -sh dist/
else
    echo "❌ dist/ 目录不存在，请先运行构建: npm run build"
    exit 1
fi

echo ""
echo "🔧 检查应用进程..."

# 检查开发服务器
DEV_PROCESS=$(ps aux | grep "vite.*dev" | grep -v grep)
if [ ! -z "$DEV_PROCESS" ]; then
    echo "🟡 开发服务器正在运行:"
    echo "   $DEV_PROCESS"
    DEV_PORT=$(echo "$DEV_PROCESS" | grep -o "localhost:[0-9]*" | head -1)
    if [ ! -z "$DEV_PORT" ]; then
        echo "   🌐 开发服务器地址: http://$DEV_PORT"
    fi
fi

# 检查预览服务器
PREVIEW_PROCESS=$(ps aux | grep "vite.*preview" | grep -v grep)
if [ ! -z "$PREVIEW_PROCESS" ]; then
    echo "✅ 预览服务器正在运行:"
    echo "   $PREVIEW_PROCESS"
else
    echo "❌ 预览服务器未运行"
fi

# 检查PM2进程
PM2_PROCESS=$(pm2 list | grep "procurement-assistant" 2>/dev/null)
if [ ! -z "$PM2_PROCESS" ]; then
    echo "✅ PM2 进程正在运行:"
    echo "   $PM2_PROCESS"
else
    echo "🟡 PM2 进程未运行"
fi

echo ""
echo "🌐 检查端口占用..."

# 检查常用端口
PORTS=(3855 4173 3856)
for port in "${PORTS[@]}"; do
    if netstat -an | grep -q ":$port.*LISTEN"; then
        echo "✅ 端口 $port 正在监听"
        echo "   🌐 访问地址: http://localhost:$port"
    else
        echo "⚪ 端口 $port 未被占用"
    fi
done

echo ""
echo "🚀 启动命令参考:"
echo "   开发模式: npm run dev"
echo "   构建应用: npm run build"
echo "   预览应用: npm run preview"
echo "   PM2启动: pm2 start ecosystem.config.cjs"

echo ""
echo "📋 应用状态检查完成!"

# 如果预览服务器在运行，显示访问提示
if [ ! -z "$PREVIEW_PROCESS" ]; then
    echo ""
    echo "🎉 应用正在运行！"
    echo "   请在浏览器中访问: http://localhost:4173"
    echo "   或者访问: http://localhost:3855"
fi 