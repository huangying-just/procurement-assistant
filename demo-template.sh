#!/bin/bash

# 模板演示脚本
# 用于演示如何使用模板创建新项目

echo "🎯 AI助手项目模板演示"
echo "===================="

# 检查模板目录
if [ ! -d "template" ]; then
    echo "❌ 模板目录不存在"
    exit 1
fi

echo "📁 模板目录结构:"
tree template/ || ls -la template/

echo ""
echo "🚀 创建演示项目..."

# 设置演示项目参数
DEMO_PROJECT="demo-assistant"
DEMO_DESCRIPTION="演示AI助手项目"
DEMO_PORT="3857"
DEMO_NGINX_PORT="8081"

echo "项目名称: $DEMO_PROJECT"
echo "项目描述: $DEMO_DESCRIPTION"
echo "应用端口: $DEMO_PORT"
echo "Nginx端口: $DEMO_NGINX_PORT"

# 检查端口是否被占用
if lsof -i :$DEMO_PORT > /dev/null 2>&1; then
    echo "⚠️  端口 $DEMO_PORT 已被占用，请手动选择其他端口"
    exit 1
fi

if lsof -i :$DEMO_NGINX_PORT > /dev/null 2>&1; then
    echo "⚠️  端口 $DEMO_NGINX_PORT 已被占用，请手动选择其他端口"
    exit 1
fi

# 删除已存在的演示项目
if [ -d "$DEMO_PROJECT" ]; then
    echo "🗑️  删除已存在的演示项目..."
    rm -rf "$DEMO_PROJECT"
fi

# 使用模板创建项目
echo ""
echo "📦 使用模板创建项目..."
cd template
./create-project.sh "$DEMO_PROJECT" "$DEMO_DESCRIPTION" "$DEMO_PORT" "$DEMO_NGINX_PORT"

if [ $? -eq 0 ]; then
    echo "✅ 项目创建成功!"
    
    # 进入项目目录
    cd "$DEMO_PROJECT"
    
    echo ""
    echo "📋 项目文件列表:"
    ls -la
    
    echo ""
    echo "🔐 环境变量配置:"
    echo "请编辑 .env 文件，设置您的 Dify API 密钥"
    echo "然后运行以下命令启动应用:"
    echo ""
    echo "  cd $DEMO_PROJECT"
    echo "  nano .env  # 配置API密钥"
    echo "  docker-compose up -d  # 启动应用"
    echo "  ./check-status.sh  # 检查状态"
    echo "  ./test-api.sh  # 测试API"
    echo ""
    echo "🌐 访问地址: http://localhost:$DEMO_NGINX_PORT"
    
else
    echo "❌ 项目创建失败"
    exit 1
fi

echo ""
echo "🎉 演示完成!"
echo "📚 查看更多文档:"
echo "  - AI_DEPLOYMENT_GUIDE.md: 完整部署指南"
echo "  - QUICK_START.md: 快速开始"
echo "  - TROUBLESHOOTING.md: 故障排除"
echo "  - TEMPLATE_README.md: 模板说明" 