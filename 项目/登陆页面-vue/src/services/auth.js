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
 * 登录（用户名 + 密码）
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

/**
 * 获取图形验证码（图片）
 * @returns {Promise<{ captchaId: string, image: string }>} image 为 data:image/png;base64,...
 */
export async function fetchCaptcha() {
  if (!BASE) {
    // —— 演示模式：本地生成一张占位验证码图 ——
    await new Promise((r) => setTimeout(r, 400))
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="120" height="40"><rect width="120" height="40" fill="#f4f6fa"/><text x="60" y="28" font-family="sans-serif" font-size="24" font-weight="bold" fill="#4a5" text-anchor="middle">DEMO</text></svg>`
    return { captchaId: 'demo', image: 'data:image/svg+xml;base64,' + btoa(svg) }
  }

  const { data } = await client.get('/auth/captcha')
  // 后端返回统一结构 { code, message, data:{ captchaId, image } }
  return data?.data || data
}

/**
 * 注册（用户名 + 图形验证码 + 密码）
 * @param {{ username: string, captchaId: string, code: string, password: string }} payload
 * @returns {Promise<{ token?: string, user?: any }>}
 */
export async function register({ username, captchaId, code, password }) {
  if (!BASE) {
    // —— 演示模式：模拟网络请求 ——
    await new Promise((r) => setTimeout(r, 1600))
    return { token: 'demo-token', user: { name: username } }
  }

  const { data } = await client.post('/auth/register', { username, captchaId, code, password })
  return data
}

export default { login, fetchCaptcha, register }
