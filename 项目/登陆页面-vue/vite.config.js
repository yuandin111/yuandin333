import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: true, // 监听 0.0.0.0，允许局域网设备通过 http://192.168.68.53:5173 访问
    port: 5173,
    open: true
  }
})
