#!/bin/bash

# 采购专家助手 - 智能构建脚本
# 自动处理 TypeScript 编译器问题

echo "🚀 开始构建采购专家助手..."

# 检查是否存在 node_modules
if [ ! -d "node_modules" ]; then
    echo "📦 安装依赖..."
    npm install
fi

# 检查 TypeScript 编译器是否可用
if ! command -v tsc &> /dev/null && ! npx tsc --version &> /dev/null 2>&1; then
    echo "⚠️  TypeScript 编译器未找到，正在安装..."
    
    # 尝试全局安装 TypeScript
    if command -v npm &> /dev/null; then
        echo "📦 全局安装 TypeScript..."
        npm install -g typescript
    else
        echo "❌ npm 未找到，请先安装 Node.js"
        exit 1
    fi
fi

# 构建项目
echo "🔨 开始构建..."

# 尝试使用本地 TypeScript
if [ -f "node_modules/.bin/tsc" ]; then
    echo "使用本地 TypeScript 编译器..."
    ./node_modules/.bin/tsc && npm run build
elif command -v tsc &> /dev/null; then
    echo "使用全局 TypeScript 编译器..."
    npm run build
else
    echo "使用 npx 运行 TypeScript..."
    npx tsc && npx vite build
fi

# 检查构建结果
if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
    echo "📁 构建文件位于 dist/ 目录"
    ls -la dist/
else
    echo "❌ 构建失败！"
    echo "💡 请检查错误信息，或尝试以下命令："
    echo "   npm install"
    echo "   npm install -g typescript"
    echo "   npm run build"
    exit 1
fi

echo "🎉 构建完成！" 