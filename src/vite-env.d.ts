/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_DIFY_API_URL: string
  readonly VITE_DIFY_API_KEY: string
  readonly VITE_APP_NAME: string
  readonly VITE_APP_DESCRIPTION: string
  readonly VITE_DEV_PORT: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
} 