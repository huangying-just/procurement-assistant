#!/bin/bash

# API测试脚本

echo "🧪 API功能测试"
echo "=============="

# 检查环境变量
if [ ! -f ".env" ]; then
    echo "❌ .env 文件不存在"
    exit 1
fi

# 读取配置
source .env

if [ -z "$VITE_DIFY_API_KEY" ] || [ "$VITE_DIFY_API_KEY" = "your-dify-api-key-here" ]; then
    echo "❌ API密钥未配置"
    echo "请编辑 .env 文件，设置 VITE_DIFY_API_KEY"
    exit 1
fi

API_URL=${VITE_DIFY_API_URL:-"https://api.dify.ai/v1"}
API_KEY=$VITE_DIFY_API_KEY

echo "🔗 API地址: $API_URL"
echo "🔑 API密钥: ${API_KEY:0:10}..."

# 测试1: 阻塞模式API调用
echo ""
echo "📡 测试1: 阻塞模式API调用"
echo "========================"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/chat-messages" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": {},
    "query": "Hello, this is a test message",
    "response_mode": "blocking",
    "user": "test-user"
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 阻塞模式API调用成功"
    echo "响应: $(echo "$BODY" | jq -r '.answer' 2>/dev/null || echo "$BODY")"
else
    echo "❌ 阻塞模式API调用失败"
    echo "HTTP状态码: $HTTP_CODE"
    echo "响应: $BODY"
fi

# 测试2: 流式模式API调用
echo ""
echo "📡 测试2: 流式模式API调用"
echo "========================"

# 创建临时文件来存储流式响应
TEMP_FILE=$(mktemp)

# 使用curl进行流式请求
curl -s -N -X POST "$API_URL/chat-messages" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": {},
    "query": "Please tell me about artificial intelligence",
    "response_mode": "streaming",
    "user": "test-user"
  }' > "$TEMP_FILE" 2>&1

# 检查流式响应
if [ -s "$TEMP_FILE" ]; then
    echo "✅ 流式模式API调用成功"
    echo "响应片段:"
    head -n 5 "$TEMP_FILE"
    echo "..."
    echo "总行数: $(wc -l < "$TEMP_FILE")"
else
    echo "❌ 流式模式API调用失败"
    echo "响应: $(cat "$TEMP_FILE")"
fi

# 清理临时文件
rm -f "$TEMP_FILE"

# 测试3: 应用健康检查
echo ""
echo "🏥 测试3: 应用健康检查"
echo "===================="

if [ ! -z "$NGINX_PORT" ]; then
    HEALTH_URL="http://localhost:$NGINX_PORT/health"
    
    if curl -f -s "$HEALTH_URL" > /dev/null 2>&1; then
        echo "✅ 应用健康检查通过"
        echo "健康检查URL: $HEALTH_URL"
    else
        echo "⚠️  应用健康检查失败"
        echo "请确保应用正在运行: docker-compose up -d"
    fi
else
    echo "⚠️  NGINX_PORT 未配置，跳过健康检查"
fi

# 测试4: 前端应用访问
echo ""
echo "🌐 测试4: 前端应用访问"
echo "===================="

if [ ! -z "$NGINX_PORT" ]; then
    APP_URL="http://localhost:$NGINX_PORT"
    
    RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null "$APP_URL")
    
    if [ "$RESPONSE" = "200" ]; then
        echo "✅ 前端应用访问成功"
        echo "应用URL: $APP_URL"
    else
        echo "❌ 前端应用访问失败"
        echo "HTTP状态码: $RESPONSE"
    fi
else
    echo "⚠️  NGINX_PORT 未配置，跳过前端访问测试"
fi

# 测试总结
echo ""
echo "📊 测试总结"
echo "=========="

echo "🔍 测试完成，请查看上述结果"
echo ""
echo "🚀 如果所有测试通过，您的应用已准备就绪！"
echo "🌐 访问地址: http://localhost:${NGINX_PORT:-8080}"
echo ""
echo "🔧 如果有测试失败，请检查："
echo "  1. API密钥是否正确"
echo "  2. 网络连接是否正常"
echo "  3. 容器是否正在运行"
echo "  4. 端口是否被占用"
echo ""
echo "📚 更多帮助请查看 TROUBLESHOOTING.md" 