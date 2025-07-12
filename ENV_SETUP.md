# 环境变量配置指南

## 概述

本项目使用环境变量来管理敏感信息和配置，确保API密钥等敏感信息不会出现在代码中。

## 配置步骤

### 1. 复制环境变量模板

```bash
cp .env.example .env
```

### 2. 编辑环境变量文件

打开 `.env` 文件，填入您的实际配置：

```bash
# Dify API配置
VITE_DIFY_API_URL=https://api.dify.ai/v1
VITE_DIFY_API_KEY=your_actual_api_key_here

# 应用配置
VITE_APP_NAME=采购专家助手
VITE_APP_DESCRIPTION=专业的政府采购法律顾问AI

# 开发配置
VITE_DEV_PORT=3855
```

### 3. 获取Dify API密钥

1. 访问 [Dify官网](https://dify.ai/)
2. 注册并登录账户
3. 创建或选择一个应用
4. 在应用设置中找到API密钥
5. 复制API密钥到 `.env` 文件中的 `VITE_DIFY_API_KEY`

## 环境变量说明

| 变量名 | 描述 | 必需 | 默认值 |
|--------|------|------|--------|
| `VITE_DIFY_API_URL` | Dify API服务器地址 | 是 | https://api.dify.ai/v1 |
| `VITE_DIFY_API_KEY` | Dify API密钥 | 是 | 无 |
| `VITE_APP_NAME` | 应用名称 | 否 | 采购专家助手 |
| `VITE_APP_DESCRIPTION` | 应用描述 | 否 | 专业的政府采购法律顾问AI |
| `VITE_DEV_PORT` | 开发服务器端口 | 否 | 3855 |

## 安全注意事项

### ✅ 安全实践

1. **不要提交 `.env` 文件**：`.env` 文件已添加到 `.gitignore` 中
2. **使用环境变量**：所有敏感信息都通过环境变量传递
3. **定期更新密钥**：建议定期更换API密钥
4. **最小权限原则**：只使用必需的API权限

### ❌ 避免的做法

1. 不要在代码中硬编码API密钥
2. 不要将 `.env` 文件提交到版本控制
3. 不要在日志中输出敏感信息
4. 不要在客户端代码中暴露服务器端密钥

## 部署配置

### 开发环境

```bash
# 启动开发服务器
npm run dev
```

### 生产环境

在生产环境中，请通过以下方式设置环境变量：

#### Docker部署

```dockerfile
# 在Dockerfile中设置环境变量
ENV VITE_DIFY_API_URL=https://api.dify.ai/v1
ENV VITE_DIFY_API_KEY=your_production_api_key
```

#### 传统服务器部署

```bash
# 在服务器上设置环境变量
export VITE_DIFY_API_URL=https://api.dify.ai/v1
export VITE_DIFY_API_KEY=your_production_api_key
```

#### PM2部署

```json
{
  "apps": [{
    "name": "procurement-assistant",
    "script": "npm",
    "args": "run preview",
    "env": {
      "VITE_DIFY_API_URL": "https://api.dify.ai/v1",
      "VITE_DIFY_API_KEY": "your_production_api_key"
    }
  }]
}
```

## 故障排除

### 常见问题

1. **应用无法启动**：
   - 检查 `.env` 文件是否存在
   - 确认所有必需的环境变量都已设置

2. **API调用失败**：
   - 验证API密钥是否正确
   - 检查API服务器地址是否可访问

3. **环境变量未生效**：
   - 重启开发服务器
   - 检查变量名是否以 `VITE_` 开头

### 调试步骤

1. 检查环境变量是否正确加载：
   ```javascript
   console.log('API URL:', import.meta.env.VITE_DIFY_API_URL);
   console.log('API Key存在:', !!import.meta.env.VITE_DIFY_API_KEY);
   ```

2. 验证API连接：
   - 在浏览器开发者工具中查看网络请求
   - 确认请求头中包含正确的Authorization信息

## 更多信息

- [Vite环境变量文档](https://vitejs.dev/guide/env-and-mode.html)
- [Dify API文档](https://docs.dify.ai/getting-started/readme)
- [项目部署指南](./DEPLOYMENT.md) 