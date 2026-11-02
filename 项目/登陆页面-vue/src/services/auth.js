import axios from 'axios'

// 后端地址：在 .env 里配置 VITE_API_BASE，例如 http://localhost:8081/api
// 未配置时走演示模式（模拟请求），方便本地直接预览
const BASE = import.meta.env.VITE_API_BASE || ''

const client = axios.create({
  baseURL: BASE,
  timeout: 8000,
  headers: { 'Content-Type': 'application/json' }
})

// 后台管理专用请求实例：自动携带管理员 token
const adminClient = axios.create({
  baseURL: BASE,
  timeout: 8000,
  headers: { 'Content-Type': 'application/json' }
})
adminClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) {
    config.headers.Authorization = 'Bearer ' + token
  }
  return config
})

/**
 * 登录（用户名 + 密码）
 * @param {{ username: string, password: string }} payload
 * @returns {Promise<{ token: string, user?: any }>}
 */
export async function login({ username, password }) {
  if (!BASE) {
    // —— 演示模式：模拟网络请求 ——
    // 无真实数据库：账号名为 admin 视为管理员权限（0），其余为默认权限（1）
    // 需真实权限校验请配置后端地址 VITE_API_BASE
    await new Promise((r) => setTimeout(r, 1400))
    return {
      token: 'demo-token',
      user: { name: username, permission: username === 'admin' ? 0 : 1 }
    }
  }

  const { data } = await client.post('/auth/login', { username, password })
  return data
}

/**
 * 后台管理系统登录（仅管理员）
 * @param {{ username: string, password: string }} payload
 * @returns {Promise<{ code: number, message: string, data: { token: string, user: any } }>}
 */
export async function adminLogin({ username, password }) {
  const { data } = await client.post('/auth/admin-login', { username, password })
  if (data.code !== 200) {
    throw new Error(data.message || '登录失败')
  }
  return data.data
}

/** 注销后台登录（使 token 失效，失败也不影响本地清理） */
export async function adminLogout() {
  try {
    await adminClient.post('/auth/logout')
  } catch (e) {
    /* 忽略网络错误，本地照常清理 */
  }
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
    // 注册用户一律为默认权限（1），与后端规则保持一致
    await new Promise((r) => setTimeout(r, 1600))
    return { token: 'demo-token', user: { name: username, permission: 1 } }
  }

  const { data } = await client.post('/auth/register', { username, captchaId, code, password })
  return data
}

// ==================== 首页内容公开查询 ====================

/**
 * 查询首页展示数据（支持可选筛选参数）
 * @param {'characters'|'tools'|'events'} type
 * @param {object} [params] 可选筛选：characters→{camp}，tools→{gradeClass}，events→{era}
 * @returns {Promise<Array>} 失败时抛异常，调用方自行回退本地数据
 */
export async function fetchContent(type, params) {
  const { data } = await client.get('/' + type, { params: params || {} })
  if (data.code !== 200) {
    throw new Error(data.message || '查询失败')
  }
  return data.data || []
}

// ==================== 站内检索（后端跨表 LIKE） ====================

/**
 * 站内检索人物 / 咒具 / 事件
 * @param {string} q 关键词
 * @returns {Promise<Array<{kind,id,name,subtitle,desc,kindLabel}>|null>}
 *          演示模式（未配置后端）返回 null，调用方走本地过滤兜底
 */
export async function search(q) {
  if (!BASE) return null
  const { data } = await client.get('/search', { params: { q } })
  if (data.code !== 200) {
    throw new Error(data.message || '检索失败')
  }
  return data.data || []
}

/**
 * 把后端返回的相对地址（如 /uploads/xxx.png）拼成完整可访问地址
 * 完整 http(s) 地址原样返回；演示模式下原样返回
 */
export function resolveUrl(url) {
  if (!url) return ''
  if (/^https?:\/\//i.test(url)) return url
  // BASE 形如 http://localhost:8081/api，去掉末尾 /api 得到后端根地址
  const origin = (BASE || '').replace(/\/api\/?$/, '')
  return origin ? origin + url : url
}

// ==================== 后台图片上传 ====================

/**
 * 上传图片（需管理员 token，后端 /api/admin/** 有拦截器鉴权）
 * @param {File} file 浏览器文件对象
 * @returns {Promise<{url: string}>} 如 { url: '/uploads/xxx.png' }
 */
export async function uploadImage(file) {
  const fd = new FormData()
  fd.append('file', file)
  const { data } = await adminClient.post('/admin/upload', fd, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
  if (data.code !== 200) {
    const err = new Error(data.message || '上传失败')
    err.code = data.code
    throw err
  }
  return data.data
}

// ==================== 后台管理 CRUD ====================

/**
 * 后台管理通用请求
 * @param {'characters'|'tools'|'events'} type
 * @param {'list'|'create'|'update'|'remove'} action
 * @param {object} [payload] create/update 时的表单数据，update/remove 时 payload.id 必填
 */
export async function adminApi(type, action, payload) {
  let resp
  if (action === 'list') {
    resp = await adminClient.get(`/admin/${type}`)
  } else if (action === 'create') {
    resp = await adminClient.post(`/admin/${type}`, payload)
  } else if (action === 'update') {
    resp = await adminClient.put(`/admin/${type}/${payload.id}`, payload)
  } else if (action === 'remove') {
    resp = await adminClient.delete(`/admin/${type}/${payload.id}`)
  } else {
    throw new Error('未知操作: ' + action)
  }
  const data = resp.data
  if (data.code !== 200) {
    const err = new Error(data.message || '操作失败')
    err.code = data.code
    throw err
  }
  return data.data
}

export default { login, adminLogin, adminLogout, fetchCaptcha, register, fetchContent, search, resolveUrl, uploadImage, adminApi }
