#!/bin/bash

# 项目创建脚本
# 使用方法: ./create-project.sh PROJECT_NAME PROJECT_DESCRIPTION PORT NGINX_PORT

set -e

# 检查参数
if [ $# -ne 4 ]; then
    echo "使用方法: $0 PROJECT_NAME PROJECT_DESCRIPTION PORT NGINX_PORT"
    echo "示例: $0 my-assistant \"我的AI助手\" 3856 8080"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_DESCRIPTION=$2
PORT=$3
NGINX_PORT=$4

# 验证端口号
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || ! [[ "$NGINX_PORT" =~ ^[0-9]+$ ]]; then
    echo "错误: 端口号必须是数字"
    exit 1
fi

# 检查端口是否被占用
if lsof -i :$PORT > /dev/null 2>&1; then
    echo "警告: 端口 $PORT 已被占用"
    read -p "是否继续? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

if lsof -i :$NGINX_PORT > /dev/null 2>&1; then
    echo "警告: 端口 $NGINX_PORT 已被占用"
    read -p "是否继续? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🚀 创建项目: $PROJECT_NAME"
echo "📝 描述: $PROJECT_DESCRIPTION"
echo "🌐 应用端口: $PORT"
echo "🔧 Nginx端口: $NGINX_PORT"
echo "=================================="

# 创建项目目录
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 复制模板文件
echo "📁 复制模板文件..."
cp -r "$(dirname "$0")"/* .
rm -f create-project.sh  # 删除创建脚本

# 替换占位符
echo "🔄 配置项目参数..."
find . -type f -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" -o -name "*.example" -o -name "Dockerfile" | xargs sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g"
find . -type f -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" -o -name "*.example" -o -name "Dockerfile" | xargs sed -i.bak "s/PROJECT_DESCRIPTION_PLACEHOLDER/$PROJECT_DESCRIPTION/g"
find . -type f -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" -o -name "*.example" -o -name "Dockerfile" | xargs sed -i.bak "s/PORT_PLACEHOLDER/$PORT/g"
find . -type f -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" -o -name "*.example" -o -name "Dockerfile" | xargs sed -i.bak "s/NGINX_PORT_PLACEHOLDER/$NGINX_PORT/g"

# 清理备份文件
find . -name "*.bak" -delete

# 复制环境变量文件
echo "🔐 设置环境变量..."
cp env.example .env

# 初始化 git
echo "📦 初始化 Git 仓库..."
git init
git add .
git commit -m "Initial commit from template"

# 安装依赖
echo "📦 安装依赖..."
npm install

echo ""
echo "✅ 项目创建完成!"
echo "📁 项目路径: $(pwd)"
echo ""
echo "🔧 下一步操作:"
echo "1. 编辑 .env 文件，配置 Dify API 密钥"
echo "2. 运行 'docker-compose up -d' 启动应用"
echo "3. 访问 http://localhost:$NGINX_PORT"
echo ""
echo "📚 更多信息请查看 AI_DEPLOYMENT_GUIDE.md" 