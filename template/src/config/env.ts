// 环境变量配置
export const env = {
  // Dify API配置
  DIFY_API_URL: import.meta.env.VITE_DIFY_API_URL || 'https://api.dify.ai/v1',
  DIFY_API_KEY: import.meta.env.VITE_DIFY_API_KEY || '',
  
  // 应用配置
  APP_NAME: import.meta.env.VITE_APP_NAME || '采购专家助手',
  APP_DESCRIPTION: import.meta.env.VITE_APP_DESCRIPTION || '专业的政府采购法律顾问AI',
  
  // 开发配置
  DEV_PORT: import.meta.env.VITE_DEV_PORT || 3855,
  
  // 环境检查
  isDevelopment: import.meta.env.DEV,
  isProduction: import.meta.env.PROD,
};

// 验证必需的环境变量
const requiredEnvVars = ['DIFY_API_KEY'];

export const validateEnv = () => {
  const missing = requiredEnvVars.filter(key => !env[key as keyof typeof env]);
  
  if (missing.length > 0) {
    console.error('缺少必需的环境变量:', missing);
    console.error('请检查 .env 文件是否正确配置');
    
    if (env.isDevelopment) {
      console.error('请复制 .env.example 到 .env 并填入正确的配置');
    }
    
    throw new Error(`缺少必需的环境变量: ${missing.join(', ')}`);
  }
};

// 开发环境下验证环境变量
if (env.isDevelopment) {
  validateEnv();
} 