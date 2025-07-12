FROM node:18-alpine

# 安装必要的系统包
RUN apk add --no-cache curl

WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 暴露端口
EXPOSE PORT_PLACEHOLDER

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:PORT_PLACEHOLDER || exit 1

# 启动应用
CMD ["npm", "run", "preview"] 