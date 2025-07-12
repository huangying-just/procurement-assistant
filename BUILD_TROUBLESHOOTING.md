# 构建问题排除指南

## 问题1：`tsc: not found`

当您在服务器端运行 `npm run build` 时遇到此错误，说明 TypeScript 编译器未安装。

### 错误信息
```
> procurement-assistant@1.0.0 build
> tsc && vite build

sh: 1: tsc: not found
```

## 解决方案

### 方案1：使用智能构建脚本（推荐）
```bash
# 使用项目提供的智能构建脚本
./build.sh
```

### 方案2：安装完整依赖
```bash
# 安装所有依赖（包括开发依赖）
npm install

# 然后构建
npm run build
```

### 方案3：全局安装 TypeScript
```bash
# 全局安装 TypeScript
sudo npm install -g typescript

# 验证安装
tsc --version

# 构建项目
npm run build
```

### 方案4：使用 npx
```bash
# 使用 npx 运行 TypeScript 编译器
npx tsc && npx vite build
```

### 方案5：修改构建脚本
修改 `package.json` 中的构建脚本：
```json
{
  "scripts": {
    "build": "npx tsc && npx vite build"
  }
}
```

## 问题2：TypeScript 类型错误

### 错误信息
```
src/config/env.ts:15:34 - error TS2339: Property 'DEV' does not exist on type 'ImportMetaEnv'.
src/config/env.ts:16:33 - error TS2339: Property 'PROD' does not exist on type 'ImportMetaEnv'.
src/main.tsx:2:22 - error TS7016: Could not find a declaration file for module 'react-dom/client'.
```

### 解决方案

这些错误已经在项目中修复：

1. **环境变量类型定义**：已在 `src/vite-env.d.ts` 中添加 `DEV` 和 `PROD` 属性
2. **React DOM 类型**：已在 `package.json` 中包含 `@types/react-dom`
3. **TypeScript 配置**：已在 `tsconfig.json` 中添加正确的类型引用

如果您仍然遇到类型错误，请确保：
```bash
# 清理并重新安装依赖
rm -rf node_modules package-lock.json
npm install

# 重新构建
npm run build
```

## 问题3：PostCSS 警告

### 警告信息
```
Warning: Module type of file:///path/to/postcss.config.js is not specified and it doesn't parse as CommonJS.
```

### 解决方案

已在 `package.json` 中添加 `"type": "module"` 字段修复此警告。

## 问题4：PM2 配置文件错误

### 错误信息
```
[PM2][ERROR] File ecosystem.config.js malformated
Error [ERR_REQUIRE_ESM]: require() of ES Module ecosystem.config.js not supported.
```

### 解决方案

由于项目使用了 `"type": "module"`，PM2 配置文件需要使用 CommonJS 格式。

**方案1**: 使用 `.cjs` 扩展名（推荐）
```bash
# 重命名配置文件
mv ecosystem.config.js ecosystem.config.cjs

# 启动 PM2
pm2 start ecosystem.config.cjs
```

**方案2**: 创建正确的配置文件
```bash
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'procurement-assistant',
    script: 'npm',
    args: 'run preview',
    cwd: '/opt/procurement-assistant',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3855
    },
    error_file: '/var/log/pm2/procurement-assistant-error.log',
    out_file: '/var/log/pm2/procurement-assistant-out.log',
    log_file: '/var/log/pm2/procurement-assistant-combined.log',
    time: true
  }]
};
EOF
```

## 为什么会出现这些问题？

1. **生产安装**: 使用 `npm install --production` 只安装 `dependencies`，不安装 `devDependencies`
2. **TypeScript 位置**: TypeScript 原本在 `devDependencies` 中，生产环境无法访问
3. **类型定义缺失**: 环境变量和模块类型定义不完整
4. **模块系统**: PostCSS 配置文件需要明确的模块类型声明
5. **ES 模块兼容性**: 添加 `"type": "module"` 后，所有 `.js` 文件都被视为 ES 模块，但 PM2 配置需要 CommonJS 格式

## 验证构建成功

构建成功后，您应该看到：
```bash
✅ 构建成功！
📁 构建文件位于 dist/ 目录
```

检查 `dist/` 目录：
```bash
ls -la dist/
```

应该包含：
- `index.html`
- `assets/` 目录（包含 CSS 和 JS 文件）
- 其他静态资源

## 部署建议

1. **使用智能构建脚本**: `./build.sh` 会自动处理所有问题
2. **完整依赖安装**: 在生产环境使用 `npm install`（不加 `--production`）
3. **全局 TypeScript**: 在服务器上全局安装 TypeScript
4. **清理构建**: 遇到问题时删除 `node_modules` 重新安装

## 相关文件

- `build.sh` - 智能构建脚本
- `package.json` - 已优化的依赖配置
- `tsconfig.json` - TypeScript 配置
- `src/vite-env.d.ts` - 类型定义文件
- `ecosystem.config.cjs` - PM2 配置文件（CommonJS 格式）
- `DEPLOYMENT.md` - 完整部署指南 