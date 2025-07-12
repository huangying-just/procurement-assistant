# 故障排除指南

## 🚨 常见问题和解决方案

### 1. 构建问题

#### 问题：`tsc: not found`
```bash
# 错误信息
> tsc && vite build
sh: 1: tsc: not found
```

**解决方案**：
```bash
# 方案1：重新安装依赖
rm -rf node_modules package-lock.json
npm install

# 方案2：全局安装TypeScript
npm install -g typescript

# 方案3：使用npx
npx tsc && npx vite build
```

#### 问题：TypeScript类型错误
```bash
# 错误信息
error TS2339: Property 'DEV' does not exist on type 'ImportMetaEnv'
```

**解决方案**：已在模板中修复，确保 `src/vite-env.d.ts` 包含完整类型定义。

### 2. 流式输出问题

#### 问题：只显示时间，没有内容
**原因**：API响应格式解析错误

**解决方案**：
```typescript
// 检查API响应格式
if (parsed.event === 'message') {
  const content = parsed.answer || '';
  onChunk?.(content);
}
```

#### 问题：WebSocket连接失败
**原因**：端口配置错误

**解决方案**：
```bash
# 检查端口占用
lsof -i :PORT

# 修改端口配置
nano docker-compose.yml
```

### 3. Docker部署问题

#### 问题：容器启动失败
```bash
# 查看错误日志
docker-compose logs app

# 常见错误和解决方案
```

**端口冲突**：
```bash
# 检查端口占用
netstat -tulpn | grep :PORT

# 修改端口配置
nano docker-compose.yml
```

**环境变量未设置**：
```bash
# 检查环境变量
docker-compose exec app env | grep VITE

# 重新设置环境变量
nano .env
docker-compose restart
```

**构建失败**：
```bash
# 重新构建镜像
docker-compose build --no-cache

# 清理Docker缓存
docker system prune -a
```

### 4. API连接问题

#### 问题：API密钥无效
```bash
# 错误信息
401 Unauthorized
```

**解决方案**：
```bash
# 检查API密钥
cat .env | grep VITE_DIFY_API_KEY

# 测试API连接
curl -X POST "https://api.dify.ai/v1/chat-messages" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "test", "response_mode": "blocking", "user": "test"}'
```

#### 问题：API请求超时
**解决方案**：
```typescript
// 增加超时配置
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 30000);

const response = await fetch(url, {
  signal: controller.signal,
  // ...其他配置
});
```

### 5. 网络和代理问题

#### 问题：无法访问外部API
**解决方案**：
```bash
# 检查网络连接
ping api.dify.ai

# 检查DNS解析
nslookup api.dify.ai

# 配置代理（如需要）
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port
```

### 6. 性能问题

#### 问题：响应时间过长
**诊断步骤**：
```bash
# 检查容器资源使用
docker stats

# 检查应用日志
docker-compose logs -f app

# 检查网络延迟
ping api.dify.ai
```

**优化方案**：
```bash
# 增加容器资源限制
# 在docker-compose.yml中添加：
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '1.0'
```

## 🔍 调试工具

### 1. 日志查看
```bash
# 查看所有容器日志
docker-compose logs

# 查看特定服务日志
docker-compose logs app
docker-compose logs nginx

# 实时查看日志
docker-compose logs -f app

# 查看最近的日志
docker-compose logs --tail=50 app
```

### 2. 容器状态检查
```bash
# 查看容器状态
docker-compose ps

# 查看容器详细信息
docker-compose exec app ps aux

# 查看容器资源使用
docker stats
```

### 3. 网络诊断
```bash
# 检查容器网络
docker network ls
docker network inspect procurement-assistant_default

# 测试容器间连接
docker-compose exec nginx ping app

# 检查端口监听
docker-compose exec app netstat -tulpn
```

### 4. 应用健康检查
```bash
# 检查应用健康状态
curl -f http://localhost:PORT/health

# 检查API响应
curl -X POST http://localhost:PORT/api/test

# 检查静态文件
curl -I http://localhost:NGINX_PORT/
```

## 🛠️ 维护命令

### 日常维护
```bash
# 重启服务
docker-compose restart

# 更新镜像
docker-compose pull
docker-compose up -d

# 清理未使用的资源
docker system prune

# 备份数据
docker-compose exec app tar -czf backup.tar.gz /app/data
```

### 性能监控
```bash
# 监控容器资源
docker stats --no-stream

# 监控应用日志
tail -f /var/log/app.log

# 监控网络连接
netstat -an | grep :PORT
```

## 📋 问题诊断清单

### 启动问题
- [ ] 检查端口是否被占用
- [ ] 验证环境变量配置
- [ ] 确认Docker服务运行
- [ ] 检查镜像构建是否成功

### 功能问题
- [ ] 测试API连接
- [ ] 验证流式输出
- [ ] 检查Markdown渲染
- [ ] 确认用户界面响应

### 性能问题
- [ ] 监控资源使用
- [ ] 检查网络延迟
- [ ] 分析应用日志
- [ ] 优化配置参数

## 🆘 获取帮助

### 日志收集
```bash
# 收集诊断信息
./collect-logs.sh

# 生成问题报告
./generate-report.sh
```

### 联系支持
1. 收集错误日志
2. 记录重现步骤
3. 提供环境信息
4. 描述期望行为

## 📚 相关资源

- [Docker官方文档](https://docs.docker.com/)
- [Dify API文档](https://docs.dify.ai/)
- [React官方文档](https://reactjs.org/)
- [TypeScript官方文档](https://www.typescriptlang.org/)
- [Vite官方文档](https://vitejs.dev/) 