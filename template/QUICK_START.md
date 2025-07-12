# 快速开始指南

## 🚀 5分钟创建新项目

### 1. 使用创建脚本（推荐）
```bash
# 进入模板目录
cd template

# 创建新项目
./create-project.sh my-assistant "我的AI助手" 3856 8080

# 进入项目目录
cd my-assistant
```

### 2. 配置环境变量
```bash
# 编辑 .env 文件
nano .env

# 必须配置的变量：
# VITE_DIFY_API_KEY=your-dify-api-key-here
```

### 3. 启动应用
```bash
# Docker方式（推荐）
docker-compose up -d

# 或者开发模式
npm run dev
```

### 4. 验证部署
```bash
# 检查容器状态
docker-compose ps

# 访问应用
open http://localhost:8080
```

## 📋 端口规划建议

| 项目 | 应用端口 | Nginx端口 |
|------|----------|-----------|
| 项目1 | 3856 | 8080 |
| 项目2 | 3857 | 8081 |
| 项目3 | 3858 | 8082 |
| 项目4 | 3859 | 8083 |
| 项目5 | 3860 | 8084 |

## 🔧 常用命令

```bash
# 创建项目
./create-project.sh PROJECT_NAME "PROJECT_DESCRIPTION" PORT NGINX_PORT

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看状态
docker-compose ps
```

## 📝 项目配置检查清单

- [ ] 项目名称和描述
- [ ] 端口号（避免冲突）
- [ ] Dify API密钥
- [ ] 环境变量配置
- [ ] Docker服务启动
- [ ] 应用访问正常
- [ ] 流式输出功能
- [ ] Markdown渲染

## 🚨 常见问题

### 端口被占用
```bash
# 检查端口占用
lsof -i :PORT

# 修改端口配置
nano docker-compose.yml
```

### API密钥未配置
```bash
# 检查环境变量
cat .env

# 配置API密钥
nano .env
```

### 容器启动失败
```bash
# 查看错误日志
docker-compose logs app

# 重新构建
docker-compose build --no-cache
```

## 📚 更多信息

- 详细部署指南：`AI_DEPLOYMENT_GUIDE.md`
- 故障排除：查看日志和错误信息
- API文档：参考Dify官方文档 