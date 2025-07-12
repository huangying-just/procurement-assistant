# 采购专家助手

一个基于Dify API的政府采购法律顾问AI助手，提供专业的采购咨询服务。

## ✨ 功能特性

- 🤖 **智能对话**：基于Dify AI的实时流式对话
- 📚 **专业知识**：政府采购法律法规专业咨询
- 💬 **流式输出**：逐字显示AI回复，提供流畅的用户体验
- 📱 **响应式设计**：适配各种设备屏幕
- 🔒 **安全配置**：环境变量管理敏感信息
- 📝 **Markdown支持**：格式化的回复内容显示

## 🚀 快速开始

### 1. 环境配置

首先配置环境变量：

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填入您的Dify API密钥
# VITE_DIFY_API_KEY=your_actual_api_key_here
```

详细的环境变量配置请参考：[环境变量配置指南](./ENV_SETUP.md)

### 2. 安装依赖

```bash
npm install
```

### 3. 启动开发服务器

```bash
npm run dev
```

应用将在 http://localhost:3855 上运行（如果端口被占用，会自动选择其他端口）。

## 📋 环境变量

| 变量名 | 描述 | 必需 | 默认值 |
|--------|------|------|--------|
| `VITE_DIFY_API_URL` | Dify API服务器地址 | 是 | https://api.dify.ai/v1 |
| `VITE_DIFY_API_KEY` | Dify API密钥 | 是 | 无 |
| `VITE_APP_NAME` | 应用名称 | 否 | 采购专家助手 |
| `VITE_APP_DESCRIPTION` | 应用描述 | 否 | 专业的政府采购法律顾问AI |
| `VITE_DEV_PORT` | 开发服务器端口 | 否 | 3855 |

## 🛠️ 技术栈

- **前端框架**：React 18 + TypeScript
- **构建工具**：Vite
- **样式框架**：Tailwind CSS
- **UI组件**：Lucide React (图标)
- **Markdown渲染**：React Markdown + remark-gfm
- **API集成**：Dify AI API (流式输出)

## 📦 项目结构

```
procurement-assistant/
├── src/
│   ├── components/          # React组件
│   │   ├── ChatMessage.tsx  # 聊天消息组件
│   │   ├── ChatInput.tsx    # 输入框组件
│   │   └── SuggestedQuestions.tsx # 预设问题组件
│   ├── config/              # 配置文件
│   │   └── env.ts          # 环境变量配置
│   ├── services/           # API服务
│   │   └── difyApi.ts      # Dify API集成
│   ├── types/              # TypeScript类型定义
│   │   └── index.ts        # 类型定义
│   ├── App.tsx             # 主应用组件
│   └── main.tsx            # 应用入口
├── public/                 # 静态资源
├── .env.example           # 环境变量模板
├── .env                   # 环境变量配置（需要创建）
└── README.md              # 项目说明
```

## 🔧 开发指南

### 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产版本
npm run preview
```

### 代码规范

```bash
# 运行ESLint检查
npm run lint

# 运行TypeScript类型检查
npm run type-check
```

## 🚀 部署指南

项目支持多种部署方式：

### Docker部署

```bash
# 构建Docker镜像
docker build -t procurement-assistant .

# 运行容器
docker run -p 3012:80 procurement-assistant
```

详细指南：[Docker部署文档](./DOCKER_DEPLOYMENT.md)

### 传统服务器部署

使用PM2进行进程管理：

```bash
# 构建项目
npm run build

# 使用PM2启动
pm2 start ecosystem.config.js
```

详细指南：[服务器部署文档](./DEPLOYMENT.md)

## 🔐 安全注意事项

1. **环境变量**：所有敏感信息都通过环境变量管理
2. **API密钥**：不要在代码中硬编码API密钥
3. **版本控制**：`.env` 文件已添加到 `.gitignore` 中
4. **生产部署**：在生产环境中使用专门的API密钥

## 🐛 故障排除

### 常见问题

1. **应用无法启动**：检查 `.env` 文件是否存在且配置正确
2. **API调用失败**：验证Dify API密钥是否有效
3. **流式输出不工作**：检查网络连接和API服务状态

详细的故障排除指南：[环境变量配置指南](./ENV_SETUP.md#故障排除)

## 📖 相关文档

- [环境变量配置指南](./ENV_SETUP.md)
- [流式输出测试指南](./TESTING_GUIDE.md)
- [Docker部署文档](./DOCKER_DEPLOYMENT.md)
- [服务器部署文档](./DEPLOYMENT.md)

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [Dify](https://dify.ai/) - 提供AI对话API服务
- [React](https://reactjs.org/) - 前端框架
- [Tailwind CSS](https://tailwindcss.com/) - 样式框架
- [Vite](https://vitejs.dev/) - 构建工具 