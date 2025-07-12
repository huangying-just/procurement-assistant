# AI项目创建和部署指南

## 项目概述
这是一个基于React + TypeScript + Dify API的智能助手项目模板，使用Docker进行部署。

## 🚀 快速创建新项目

### 1. 项目初始化
```bash
# 创建新项目目录
mkdir ${PROJECT_NAME}
cd ${PROJECT_NAME}

# 复制模板文件
cp -r /path/to/template/* .

# 初始化git
git init
git add .
git commit -m "Initial commit from template"
```

### 2. 项目配置
```bash
# 修改项目名称和描述
sed -i 's/PROJECT_NAME_PLACEHOLDER/${PROJECT_NAME}/g' package.json
sed -i 's/PROJECT_DESCRIPTION_PLACEHOLDER/${PROJECT_DESCRIPTION}/g' package.json

# 修改Docker配置中的端口
sed -i 's/PORT_PLACEHOLDER/${PORT}/g' docker-compose.yml
sed -i 's/PORT_PLACEHOLDER/${PORT}/g' nginx.conf
```

### 3. 环境变量配置
```bash
# 复制环境变量模板
cp .env.example .env

# 编辑环境变量
nano .env
```

必须配置的环境变量：
- `VITE_DIFY_API_URL`: Dify API地址
- `VITE_DIFY_API_KEY`: Dify API密钥
- `VITE_DEV_PORT`: 开发端口
- `VITE_APP_NAME`: 应用名称
- `VITE_APP_DESCRIPTION`: 应用描述

### 4. Docker部署
```bash
# 构建和启动
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

## 🔧 技术栈和关键配置

### 前端技术栈
- **React 18**: 用户界面框架
- **TypeScript**: 类型安全
- **Vite**: 构建工具
- **Tailwind CSS**: 样式框架
- **React Markdown**: Markdown渲染

### 关键配置说明

#### 1. TypeScript配置 (tsconfig.json)
```json
{
  "compilerOptions": {
    "types": ["vite/client", "node"]
  }
}
```
- 确保包含vite/client类型定义
- 避免DEV、PROD属性未定义错误

#### 2. Vite环境变量类型 (src/vite-env.d.ts)
```typescript
interface ImportMetaEnv {
  readonly VITE_DIFY_API_URL: string
  readonly VITE_DIFY_API_KEY: string
  readonly VITE_APP_NAME: string
  readonly VITE_APP_DESCRIPTION: string
  readonly VITE_DEV_PORT: string
  readonly DEV: boolean
  readonly PROD: boolean
  readonly MODE: string
}
```

#### 3. 模块系统配置 (package.json)
```json
{
  "type": "module"
}
```
- 避免PostCSS警告
- 确保ES模块兼容性

#### 4. 依赖配置
```json
{
  "dependencies": {
    "typescript": "^5.2.2"
  }
}
```
- TypeScript必须在dependencies中，不能在devDependencies
- 避免服务器构建时"tsc: not found"错误

## 🌊 流式输出配置

### 关键实现点

#### 1. API服务配置 (src/services/difyApi.ts)
```typescript
export const sendMessage = async (
  message: string,
  conversationId?: string,
  onChunk?: (chunk: string) => void
): Promise<DifyResponse> => {
  const response = await fetch(`${env.DIFY_API_URL}/chat-messages`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${env.DIFY_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      inputs: {},
      query: message,
      response_mode: 'streaming',
      conversation_id: conversationId,
      user: 'user-' + Date.now(),
    }),
  });

  // 流式处理
  const reader = response.body?.getReader();
  const decoder = new TextDecoder();
  let buffer = '';
  let fullContent = '';

  while (true) {
    const { done, value } = await reader!.read();
    if (done) break;

    buffer += decoder.decode(value, { stream: true });
    const lines = buffer.split('\n');
    buffer = lines.pop() || '';

    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.slice(6);
        if (data === '[DONE]') continue;
        
        try {
          const parsed = JSON.parse(data);
          if (parsed.event === 'message') {
            const content = parsed.answer || '';
            fullContent += content;
            onChunk?.(content);
          }
        } catch (e) {
          console.warn('解析流式数据失败:', e);
        }
      }
    }
  }

  return { answer: fullContent };
};
```

#### 2. 前端流式处理 (src/App.tsx)
```typescript
const handleSendMessage = async (message: string) => {
  const userMessage: Message = {
    id: Date.now().toString(),
    text: message,
    isUser: true,
    timestamp: new Date(),
  };

  const assistantMessage: Message = {
    id: (Date.now() + 1).toString(),
    text: '',
    isUser: false,
    timestamp: new Date(),
    isStreaming: true,
  };

  setMessages(prev => [...prev, userMessage, assistantMessage]);

  try {
    await sendMessage(message, conversationId, (chunk) => {
      setMessages(prev => prev.map(msg => 
        msg.id === assistantMessage.id 
          ? { ...msg, text: msg.text + chunk }
          : msg
      ));
    });

    // 流式完成后更新状态
    setMessages(prev => prev.map(msg => 
      msg.id === assistantMessage.id 
        ? { ...msg, isStreaming: false }
        : msg
    ));
  } catch (error) {
    console.error('发送消息失败:', error);
  }
};
```

## 🐳 Docker配置

### Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE ${PORT}

CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "${PORT}"]
```

### docker-compose.yml
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "${PORT}:${PORT}"
    environment:
      - NODE_ENV=production
      - PORT=${PORT}
    env_file:
      - .env
    restart: unless-stopped
    
  nginx:
    image: nginx:alpine
    ports:
      - "${NGINX_PORT}:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    restart: unless-stopped
```

## 🚨 常见问题和解决方案

### 1. 构建错误 "tsc: not found"
**解决方案**: 确保TypeScript在dependencies中
```json
{
  "dependencies": {
    "typescript": "^5.2.2"
  }
}
```

### 2. 流式输出不工作
**解决方案**: 
- 确保使用`response_mode: 'streaming'`
- 正确处理Server-Sent Events格式
- 实现流式数据解析和状态更新

### 3. 环境变量类型错误
**解决方案**: 在`src/vite-env.d.ts`中定义完整的类型
```typescript
interface ImportMetaEnv {
  readonly DEV: boolean
  readonly PROD: boolean
  readonly MODE: string
}
```

### 4. PM2配置错误
**解决方案**: 使用`.cjs`扩展名
```bash
mv ecosystem.config.js ecosystem.config.cjs
```

### 5. 端口冲突
**解决方案**: 
- 使用环境变量配置端口
- 检查端口占用：`lsof -i :PORT`
- 使用不同端口号

## 📝 项目结构

```
project/
├── src/
│   ├── components/          # React组件
│   │   ├── ChatMessage.tsx  # 消息组件（支持Markdown）
│   │   ├── ChatInput.tsx    # 输入组件
│   │   └── SuggestedQuestions.tsx
│   ├── services/
│   │   └── difyApi.ts       # Dify API服务（流式支持）
│   ├── config/
│   │   └── env.ts           # 环境变量配置
│   ├── types/
│   │   └── index.ts         # TypeScript类型定义
│   ├── vite-env.d.ts        # Vite环境变量类型
│   └── App.tsx              # 主应用组件
├── docker-compose.yml       # Docker编排
├── Dockerfile              # Docker镜像配置
├── nginx.conf              # Nginx配置
├── .env.example            # 环境变量模板
├── package.json            # 项目配置
├── tsconfig.json           # TypeScript配置
└── vite.config.ts          # Vite配置
```

## 🎯 部署检查清单

- [ ] 复制模板文件
- [ ] 修改项目名称和描述
- [ ] 配置环境变量
- [ ] 设置端口号（避免冲突）
- [ ] 配置Dify API密钥
- [ ] 运行Docker构建
- [ ] 验证应用访问
- [ ] 测试流式输出功能
- [ ] 测试Markdown渲染
- [ ] 检查日志输出

## 🔍 验证部署成功

```bash
# 检查容器状态
docker-compose ps

# 检查应用响应
curl http://localhost:${PORT}

# 检查日志
docker-compose logs -f app

# 访问应用
open http://localhost:${PORT}
```

## 📚 相关文档

- `TEMPLATE_README.md` - 模板项目说明
- `QUICK_START.md` - 快速开始指南
- `TROUBLESHOOTING.md` - 故障排除指南
- `API_GUIDE.md` - API集成指南 