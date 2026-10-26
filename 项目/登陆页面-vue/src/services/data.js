import axios from 'axios'

// 后端地址：与 auth.js 共用 .env 里的 VITE_API_BASE（如 http://localhost:8081/api）
const BASE = import.meta.env.VITE_API_BASE || ''

const client = axios.create({
  baseURL: BASE,
  timeout: 8000,
  headers: { 'Content-Type': 'application/json' }
})

// 后端统一返回结构：{ code, message, data }
// 这里取出最里层的 data（即真实的数组/对象）
const unwrap = (res) => res?.data?.data ?? []

/**
 * 获取人物志列表
 * @returns {Promise<Array>} 每项含 tags 字符串（英文逗号分隔）
 */
export async function fetchCharacters() {
  const res = await client.get('/characters')
  return unwrap(res)
}

/**
 * 获取咒具图鉴列表
 */
export async function fetchTools() {
  const res = await client.get('/tools')
  return unwrap(res)
}

/**
 * 获取时间线事件列表
 */
export async function fetchEvents() {
  const res = await client.get('/events')
  return unwrap(res)
}

export default { fetchCharacters, fetchTools, fetchEvents }
