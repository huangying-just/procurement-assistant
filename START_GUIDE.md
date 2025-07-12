# 启动和验证指南

## 🚀 如何启动应用

### 1. 开发模式（推荐用于开发）
```bash
npm run dev
```
- 启动开发服务器
- 支持热重载
- 通常运行在 http://localhost:3856 （如果3855被占用）

### 2. 生产预览模式（推荐用于测试）
```bash
# 先构建
npm run build

# 然后启动预览
npm run preview
```
- 启动生产版本预览
- 运行在 http://localhost:4173

### 3. PM2 生产模式（推荐用于部署）
```bash
# 构建应用
npm run build

# 启动PM2
pm2 start ecosystem.config.cjs

# 查看状态
pm2 status
```

## 🔍 如何检查应用状态

### 使用检查脚本（推荐）
```bash
./check-app.sh
```

### 手动检查
```bash
# 检查进程
ps aux | grep vite

# 检查端口
netstat -an | grep LISTEN | grep -E "(3855|4173|3856)"

# 或者使用lsof
lsof -i :4173
lsof -i :3855
```

## 📋 验证应用是否成功启动

### 1. 检查构建文件
```bash
ls -la dist/
```
应该看到：
- `index.html`
- `assets/` 目录
- 其他静态文件

### 2. 检查进程状态
应用启动后，您应该看到类似输出：
```
✅ 预览服务器正在运行
✅ 端口 4173 正在监听
🌐 访问地址: http://localhost:4173
```

### 3. 浏览器访问
打开浏览器访问：
- **预览模式**: http://localhost:4173
- **开发模式**: http://localhost:3856 (或3855)

### 4. 验证功能
- 页面正常加载
- 可以发送消息
- 流式响应正常工作
- Markdown 渲染正常

## 🛠️ 常见问题

### 问题1：端口被占用
```bash
# 查看端口占用
lsof -i :4173

# 杀死占用进程
kill -9 <PID>
```

### 问题2：构建失败
```bash
# 使用智能构建脚本
./build.sh

# 或者清理后重新构建
rm -rf dist node_modules
npm install
npm run build
```

### 问题3：应用无法访问
```bash
# 检查防火墙
# 确保端口未被阻止

# 检查应用日志
pm2 logs procurement-assistant
```

## 📊 应用状态指示器

### ✅ 正常状态
- 构建文件存在
- 进程正在运行
- 端口正在监听
- 浏览器可以访问

### ⚠️ 警告状态
- 端口冲突
- 内存使用过高
- 响应时间过长

### ❌ 错误状态
- 构建失败
- 进程崩溃
- 端口无法访问
- API 连接失败

## 🔧 快速命令

```bash
# 完整启动流程
npm run build && npm run preview

# 检查状态
./check-app.sh

# 停止应用
# 开发模式: Ctrl+C
# PM2模式: pm2 stop procurement-assistant

# 重启应用
pm2 restart procurement-assistant
```

## 📝 日志查看

```bash
# PM2 日志
pm2 logs procurement-assistant

# 实时日志
pm2 logs procurement-assistant --lines 50 -f
``` 