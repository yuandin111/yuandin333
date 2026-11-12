import axios from 'axios'

/**
 * 社区功能（论坛 / 好友）接口封装。
 * 与 auth.js 保持同一套 VITE_API_BASE；这里额外自动带上普通用户 token。
 */
const BASE = import.meta.env.VITE_API_BASE || ''

const api = axios.create({ baseURL: BASE, timeout: 10000 })
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) config.headers.Authorization = 'Bearer ' + token
  return config
})

/**
 * 会话过期统一交给 App.vue 处理（弹明确提示后再回登录页）。
 * 以前这里直接删 token + window.location.reload()，用户只会看到页面莫名跳回登录页，
 * 而且首页「好友申请角标」这种可选请求也会触发，导致刚进社区就被踢出去。
 */
let expiredNotified = false
function notifyExpired(message) {
  if (expiredNotified) return
  expiredNotified = true
  localStorage.removeItem('token')
  window.dispatchEvent(new CustomEvent('auth-expired', {
    detail: message || '登录已过期，请重新登录'
  }))
  setTimeout(() => { expiredNotified = false }, 3000)
}

/**
 * @param {Promise} request axios 请求
 * @param {{ silent401?: boolean }} options silent401=true 时忽略 401（用于非关键的可选请求）
 */
async function unwrap(request, options = {}) {
  const { data } = await request
  if (data.code === 401) {
    if (!options.silent401) notifyExpired(data.message || '登录已过期，请重新登录')
    throw new Error(data.message || '请先登录')
  }
  if (data.code !== 200) throw new Error(data.message || '请求失败')
  return data.data
}

export const backendReady = () => Boolean(BASE)

// ==================== 论坛 ====================
export const getCategories = () => unwrap(api.get('/forum/categories'))
export const getPosts = (params) => unwrap(api.get('/forum/posts', { params }))
export const getPost = (id) => unwrap(api.get('/forum/posts/' + id))
export const getComments = (id) => unwrap(api.get('/forum/posts/' + id + '/comments'))
export const createPost = (payload) => unwrap(api.post('/forum/posts', payload))
export const updatePost = (id, payload) => unwrap(api.put('/forum/posts/' + id, payload))
export const deletePost = (id) => unwrap(api.delete('/forum/posts/' + id))
export const toggleLike = (id) => unwrap(api.post('/forum/posts/' + id + '/like'))
export const addComment = (id, payload) =>
  unwrap(api.post('/forum/posts/' + id + '/comments', payload))
export const deleteComment = (id) => unwrap(api.delete('/forum/comments/' + id))

// ==================== 好友 ====================
// 首页角标属于可选请求：会话失效时静默忽略，不要因为一个角标把整站踢回登录页
export const getOverview = (silent401 = false) =>
  unwrap(api.get('/friends/overview'), { silent401 })
export const searchUsers = (q) => unwrap(api.get('/friends/users', { params: { q } }))
export const getRequests = () => unwrap(api.get('/friends/requests'))
export const sendRequest = (toUserId, message) =>
  unwrap(api.post('/friends/requests', { toUserId, message }))
export const acceptRequest = (id) => unwrap(api.post(`/friends/requests/${id}/accept`))
export const rejectRequest = (id) => unwrap(api.post(`/friends/requests/${id}/reject`))
export const getFriends = () => unwrap(api.get('/friends/list'))
export const removeFriend = (id) => unwrap(api.delete('/friends/' + id))
export const getMessages = (peerId) =>
  unwrap(api.get('/friends/messages', { params: { peerId } }))
export const sendMessage = (toUserId, content) =>
  unwrap(api.post('/friends/messages', { toUserId, content }))

/** 统一格式化后端 LocalDateTime */
export function fmtTime(value) {
  if (!value) return ''
  const d = new Date(String(value).replace(' ', 'T'))
  if (Number.isNaN(d.getTime())) return String(value)
  const pad = (n) => String(n).padStart(2, '0')
  return `${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}
