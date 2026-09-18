import axios from 'axios'

// 后端地址：在 .env 里配置 VITE_API_BASE，例如 http://localhost:3000/api
// 未配置时走演示模式（模拟请求），方便本地直接预览
const BASE = import.meta.env.VITE_API_BASE || ''

const client = axios.create({
  baseURL: BASE,
  timeout: 8000,
  headers: { 'Content-Type': 'application/json' }
})

/**
 * 登录
 * @param {{ username: string, password: string }} payload
 * @returns {Promise<{ token: string, user?: any }>}
 */
export async function login({ username, password }) {
  if (!BASE) {
    // —— 演示模式：模拟网络请求 ——
    await new Promise((r) => setTimeout(r, 1400))
    return { token: 'demo-token', user: { name: username } }
  }

  const { data } = await client.post('/auth/login', { username, password })
  return data
}

export default { login }
