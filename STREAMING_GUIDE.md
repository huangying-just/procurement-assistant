# 流式输出功能指南

## 概述

采购专家助手现在支持实时流式输出，这意味着AI的回复会逐字显示，提供更好的用户体验。

## 功能特点

### ⚡ 实时响应
- AI回复会逐字显示，无需等待完整回复
- 用户可以实时看到AI正在"思考"和"回答"
- 提供更自然的对话体验

### 📝 Markdown渲染
- AI回复支持完整的Markdown格式
- 包括标题、列表、代码块、引用等
- 用户消息保持纯文本显示

### 🔄 兼容性
- 保持与原有API的兼容性
- 支持流式和非流式两种模式
- 自动降级处理

## 技术实现

### API调用
```typescript
// 流式调用
const response = await sendMessage(message, conversationId, (chunk) => {
  // 处理每个数据块
  console.log('收到数据:', chunk);
});

// 非流式调用（兼容性）
const response = await sendMessage(message, conversationId);
```

### 数据处理
```typescript
// 解析流式数据
const lines = buffer.split('\n');
for (const line of lines) {
  if (line.startsWith('data: ')) {
    const data = line.slice(6);
    if (data === '[DONE]') break;
    
    const parsed = JSON.parse(data);
    if (parsed.event === 'message') {
      onStream(parsed.data.answer || '');
    }
  }
}
```

## 用户体验

### 视觉效果
- 打字机效果：文字逐字出现
- 加载动画：显示AI正在思考
- 实时更新：消息内容实时更新

### 交互体验
- 即时反馈：用户立即看到响应开始
- 可中断性：支持取消正在进行的请求
- 错误处理：网络错误时优雅降级

## 性能优化

### 内存管理
- 流式处理减少内存占用
- 及时释放不需要的数据
- 避免大块数据堆积

### 网络优化
- 使用Fetch API原生流式支持
- 减少网络延迟感知
- 支持断点续传

## 错误处理

### 网络错误
```typescript
try {
  const response = await sendMessage(message, conversationId, onStream);
} catch (error) {
  // 显示错误消息
  setMessages(prev => [...prev, {
    id: Date.now().toString(),
    content: '网络连接失败，请稍后重试',
    role: 'assistant',
    timestamp: new Date()
  }]);
}
```

### 解析错误
- 忽略无效的JSON数据
- 继续处理后续数据
- 保持应用稳定性

## 配置选项

### 环境变量
```bash
# Dify API配置
DIFY_API_URL=https://api.dify.ai/v1
DIFY_API_KEY=your-api-key

# 流式响应配置
STREAMING_ENABLED=true
STREAMING_TIMEOUT=30000
```

### 开发模式
```typescript
// 开发环境下的调试信息
if (process.env.NODE_ENV === 'development') {
  console.log('流式数据块:', chunk);
}
```

## 测试

### 单元测试
```typescript
import { testStreamingResponse } from './utils/streamTest';

// 测试流式响应
test('should handle streaming response', async () => {
  await testStreamingResponse();
});
```

### 集成测试
- 测试完整的对话流程
- 验证Markdown渲染
- 检查错误处理

## 故障排除

### 常见问题

**问题**: 流式响应不工作
```bash
# 检查网络连接
curl -X POST 'https://api.dify.ai/v1/chat-messages' \
  --header 'Authorization: Bearer your-api-key' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "inputs": {},
    "query": "test",
    "response_mode": "streaming",
    "conversation_id": "",
    "user": "test"
  }'
```

**问题**: Markdown渲染异常
```typescript
// 检查Markdown组件配置
<ReactMarkdown 
  remarkPlugins={[remarkGfm]}
  components={{
    // 自定义组件配置
  }}
>
  {content}
</ReactMarkdown>
```

### 调试技巧
1. 打开浏览器开发者工具
2. 查看Network标签页的流式请求
3. 检查Console中的错误信息
4. 验证API密钥和权限

## 未来计划

### 功能增强
- [ ] 支持语音流式输出
- [ ] 添加打字机音效
- [ ] 支持多语言流式输出
- [ ] 实现流式文件上传

### 性能优化
- [ ] 实现流式缓存
- [ ] 添加流式压缩
- [ ] 优化内存使用
- [ ] 支持流式分片

---

**流式输出功能已完全集成到采购专家助手中，为用户提供更流畅的对话体验！** 