# 构建问题排除指南

## 问题：`tsc: not found`

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

## 为什么会出现这个问题？

1. **生产安装**: 使用 `npm install --production` 只安装 `dependencies`，不安装 `devDependencies`
2. **TypeScript 位置**: TypeScript 原本在 `devDependencies` 中，生产环境无法访问
3. **解决方案**: 已将 TypeScript 移至 `dependencies` 中

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

## 相关文件

- `build.sh` - 智能构建脚本
- `package.json` - 已优化的依赖配置
- `DEPLOYMENT.md` - 完整部署指南 