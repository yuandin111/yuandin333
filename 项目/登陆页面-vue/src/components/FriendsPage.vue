<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import {
  backendReady, getOverview, getFriends, getRequests, removeFriend,
  searchUsers, sendRequest, acceptRequest, rejectRequest,
  getMessages, sendMessage, fmtTime
} from '../services/community.js'

const props = defineProps({ user: { type: String, default: 'User' } })
const emit = defineEmits(['back', 'forum'])

const tab = ref('friends')
const overview = ref({ friends: 0, pending: 0, unread: 0 })
const friends = ref([])
const incoming = ref([])
const outgoing = ref([])
const users = ref([])
const userQuery = ref('')
const loading = ref(false)
const error = ref('')
const toast = ref('')

const chat = ref(null)
const messages = ref([])
const msgInput = ref('')
let timer = null

const initial = (name) => (name || 'U').trim().charAt(0).toUpperCase()

function notify(msg) {
  toast.value = msg
  setTimeout(() => { if (toast.value === msg) toast.value = '' }, 2200)
}

async function wrap(fn) {
  if (!backendReady()) { error.value = '未配置后端地址，好友功能需要连接后端'; return }
  loading.value = true
  error.value = ''
  try { await fn() } catch (e) { error.value = e.message || '加载失败' } finally { loading.value = false }
}

async function loadOverview() {
  try { overview.value = await getOverview() } catch (e) { /* 忽略 */ }
}
async function loadFriends() {
  await wrap(async () => { friends.value = await getFriends() })
}
async function loadRequests() {
  await wrap(async () => {
    const r = await getRequests()
    incoming.value = r.incoming || []
    outgoing.value = r.outgoing || []
    overview.value.pending = r.pending || 0
  })
}
async function loadUsers() {
  await wrap(async () => { users.value = await searchUsers(userQuery.value.trim()) })
}
async function refreshAll() {
  await loadOverview()
  await Promise.all([loadFriends(), loadRequests(), loadUsers()])
}

async function sendReq(row) {
  if (row.relation === 'pending_received') { tab.value = 'requests'; return }
  const msg = window.prompt(`给 ${row.username} 的验证消息（可留空）：`, '你好，交个好友吧！')
  if (msg === null) return
  try {
    await sendRequest(row.id, msg)
    notify('好友申请已发送')
    await Promise.all([loadUsers(), loadRequests(), loadOverview()])
  } catch (e) { notify(e.message || '发送失败') }
}

async function accept(id) {
  try {
    await acceptRequest(id)
    notify('已添加好友')
    await refreshAll()
  } catch (e) { notify(e.message || '操作失败') }
}
async function reject(id) {
  try {
    await rejectRequest(id)
    notify('已拒绝申请')
    await Promise.all([loadRequests(), loadOverview()])
  } catch (e) { notify(e.message || '操作失败') }
}
async function remove(row) {
  if (!window.confirm(`确定与 ${row.friendName} 解除好友关系吗？`)) return
  try {
    await removeFriend(row.friendId)
    notify('已解除好友关系')
    if (chat.value?.friendId === row.friendId) closeChat()
    await refreshAll()
  } catch (e) { notify(e.message || '操作失败') }
}

async function loadChat() {
  if (!chat.value) return
  try { messages.value = await getMessages(chat.value.friendId) } catch (e) { /* 忽略 */ }
}

async function openChat(row) {
  chat.value = { friendId: row.friendId || row.id, friendName: row.friendName || row.username }
  await loadChat()
  await Promise.all([loadOverview(), loadFriends()])
  clearInterval(timer)
  timer = setInterval(async () => { await loadChat(); await loadOverview() }, 5000)
}
function closeChat() {
  clearInterval(timer)
  timer = null
  chat.value = null
  messages.value = []
}

async function sendMsg() {
  const text = msgInput.value.trim()
  if (!text || !chat.value) return
  try {
    await sendMessage(chat.value.friendId, text)
    msgInput.value = ''
    await loadChat()
  } catch (e) { notify(e.message || '发送失败') }
}

const relationLabel = (r) => ({
  none: '＋ 加好友', friend: '私信', pending_sent: '已发送', pending_received: '待你处理'
}[r] || '＋ 加好友')

onMounted(refreshAll)
onBeforeUnmount(() => clearInterval(timer))
</script>

<template>
  <div class="friends">
    <header class="topbar">
      <button class="back" @click="emit('back')">← 返回首页</button>
      <div class="brand">
        <span class="mark">友</span>
        <div>
          <h1>术师名录 · 好友</h1>
          <p>找到同好，交换灵感，聊聊同人二创</p>
        </div>
      </div>
      <div class="actions">
        <button class="ghost" @click="emit('forum')">✍️ 去论坛</button>
        <span class="avatar" :title="user">{{ initial(user) }}</span>
      </div>
    </header>

    <div v-if="!backendReady()" class="notice">当前为演示模式（未配置 VITE_API_BASE），好友功能需要连接后端。</div>

    <section class="panel">
      <div class="tabs">
        <button :class="{ active: tab === 'friends' }" @click="tab = 'friends'">🤝 我的好友 <i>{{ overview.friends }}</i></button>
        <button :class="{ active: tab === 'requests' }" @click="tab = 'requests'">📨 好友申请 <i v-if="overview.pending" class="hot">{{ overview.pending }}</i></button>
        <button :class="{ active: tab === 'discover' }" @click="tab = 'discover'">🔍 找人</button>
        <span class="spacer"></span>
        <span class="unread">未读私信 {{ overview.unread }}</span>
        <button class="refresh" @click="refreshAll">↻ 刷新</button>
      </div>

      <p v-if="error" class="err">{{ error }}</p>
      <div v-if="loading" class="state">载入中…</div>

      <!-- 好友列表 -->
      <div v-if="tab === 'friends'" class="cards">
        <article v-for="f in friends" :key="f.friendId" class="card">
          <div class="ava">{{ initial(f.friendName) }}</div>
          <div class="info">
            <h3>{{ f.friendName }}</h3>
            <p class="preview">{{ f.lastMessage || '还没有聊天记录，去打个招呼吧' }}</p>
            <span class="time">成为好友 {{ fmtTime(f.since) }}<template v-if="f.lastTime"> · 最近 {{ fmtTime(f.lastTime) }}</template></span>
          </div>
          <span v-if="f.unread" class="badge-unread">{{ f.unread }}</span>
          <div class="ops">
            <button class="primary" @click="openChat(f)">私信</button>
            <button class="danger" @click="remove(f)">删除</button>
          </div>
        </article>
        <div v-if="!loading && !friends.length" class="state">还没有好友，去「找人」页发个申请吧 🤝</div>
      </div>

      <!-- 好友申请 -->
      <div v-if="tab === 'requests'" class="req-wrap">
        <h4>收到的申请 <span>{{ incoming.length }}</span></h4>
        <div class="cards">
          <article v-for="r in incoming" :key="r.id" class="card">
            <div class="ava">{{ initial(r.fromUserName) }}</div>
            <div class="info">
              <h3>{{ r.fromUserName }}</h3>
              <p class="preview">「{{ r.message || '想加你为好友' }}」</p>
              <span class="time">{{ fmtTime(r.createTime) }}</span>
            </div>
            <div class="ops">
              <button class="primary" @click="accept(r.id)">同意</button>
              <button class="danger" @click="reject(r.id)">拒绝</button>
            </div>
          </article>
          <div v-if="!incoming.length" class="state small">暂时没有待处理的申请</div>
        </div>
        <h4>我发出的 <span>{{ outgoing.length }}</span></h4>
        <div class="cards">
          <article v-for="r in outgoing" :key="r.id" class="card">
            <div class="ava dim">{{ initial(r.toUserName) }}</div>
            <div class="info">
              <h3>{{ r.toUserName }}</h3>
              <p class="preview">「{{ r.message || '好友申请' }}」</p>
              <span class="time">{{ fmtTime(r.createTime) }} · 等待对方处理</span>
            </div>
            <span class="pending-tag">待处理</span>
          </article>
          <div v-if="!outgoing.length" class="state small">没有发出中的申请</div>
        </div>
      </div>

      <!-- 找人 -->
      <div v-if="tab === 'discover'" class="discover">
        <div class="search">
          <span>🔍</span>
          <input v-model="userQuery" placeholder="输入用户名搜索术师…" @keyup.enter="loadUsers" />
          <button class="go" @click="loadUsers">搜索</button>
        </div>
        <div class="cards">
          <article v-for="u in users" :key="u.id" class="card">
            <div class="ava">{{ initial(u.username) }}</div>
            <div class="info">
              <h3>{{ u.username }}<span class="uid">ID {{ u.id }}</span></h3>
              <p class="preview">高专社区成员</p>
            </div>
            <div class="ops">
              <button
                class="primary"
                :class="{ disabled: u.relation === 'pending_sent' }"
                :disabled="u.relation === 'pending_sent'"
                @click="u.relation === 'friend' ? openChat(u) : sendReq(u)"
              >{{ relationLabel(u.relation) }}</button>
            </div>
          </article>
          <div v-if="!loading && !users.length" class="state">没有找到匹配的用户</div>
        </div>
      </div>
    </section>

    <!-- 私信抽屉 -->
    <div v-if="chat" class="chat-drawer">
      <header>
        <div class="ava small">{{ initial(chat.friendName) }}</div>
        <div><h3>{{ chat.friendName }}</h3><p>私信 · 5 秒自动刷新</p></div>
        <span class="spacer"></span>
        <button class="x" @click="closeChat">✕</button>
      </header>
      <div class="msg-list">
        <div v-for="m in messages" :key="m.id" class="bubble" :class="{ mine: m.mine }">
          <p>{{ m.content }}</p>
          <span>{{ fmtTime(m.createTime) }}</span>
        </div>
        <div v-if="!messages.length" class="state small">还没有消息，说点什么吧～</div>
      </div>
      <div class="msg-input">
        <input v-model="msgInput" placeholder="输入消息，回车发送…" @keyup.enter="sendMsg" />
        <button class="primary" @click="sendMsg">发送</button>
      </div>
    </div>

    <div v-if="toast" class="toast">{{ toast }}</div>
  </div>
</template>

<style scoped>
.friends { min-height: 100vh; padding: 0 clamp(14px, 4vw, 56px) 60px; color: var(--text); }
.topbar { position: sticky; top: 0; z-index: 20; display: flex; align-items: center; gap: 18px; padding: 14px 0; margin-bottom: 18px; backdrop-filter: blur(16px); border-bottom: 1px solid var(--line); }
.back, .ghost, .primary, .danger, .refresh, .go, .x { font: inherit; cursor: pointer; border-radius: 10px; transition: .18s; }
.back { background: transparent; border: 1px solid var(--line); color: var(--muted); padding: 8px 13px; font-size: 13px; }
.back:hover, .ghost:hover { color: #fff; border-color: #a78bfa; }
.brand { display: flex; align-items: center; gap: 12px; flex: 1; min-width: 0; }
.mark { width: 42px; height: 42px; flex: none; display: grid; place-items: center; border-radius: 13px; font-size: 21px; font-weight: 800; background: linear-gradient(135deg, #38d9ff, #7b2ff7); box-shadow: 0 6px 24px rgba(56,217,255,.35); }
.brand h1 { font-size: 19px; letter-spacing: .5px; }
.brand p { font-size: 11px; color: var(--muted); margin-top: 3px; }
.actions { display: flex; align-items: center; gap: 10px; }
.ghost { background: rgba(167,139,250,.1); border: 1px solid var(--line); color: var(--text); padding: 9px 15px; font-size: 13px; }
.primary { background: linear-gradient(135deg, #7b2ff7, #e8336e); border: none; color: #fff; padding: 9px 17px; font-size: 13px; font-weight: 700; }
.primary:hover { filter: brightness(1.15); }
.primary.disabled { opacity: .5; cursor: not-allowed; }
.danger { background: rgba(232,51,110,.12); border: 1px solid rgba(232,51,110,.35); color: #ff9dbd; padding: 9px 15px; font-size: 13px; }
.avatar { width: 34px; height: 34px; display: grid; place-items: center; border-radius: 50%; background: rgba(56,217,255,.16); border: 1px solid rgba(56,217,255,.4); font-weight: 700; font-size: 14px; }
.notice, .err { margin: 12px 0; padding: 11px 16px; border-radius: 12px; background: rgba(232,51,110,.12); border: 1px solid rgba(232,51,110,.35); font-size: 13px; }

.panel { max-width: 940px; margin: 0 auto; }
.tabs { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 16px; }
.tabs button { display: inline-flex; align-items: center; gap: 7px; background: rgba(26,15,52,.6); border: 1px solid var(--line); color: var(--muted); padding: 9px 15px; border-radius: 999px; font: inherit; font-size: 13px; cursor: pointer; transition: .18s; }
.tabs button.active { color: #fff; border-color: #a78bfa; background: linear-gradient(135deg, rgba(123,47,247,.55), rgba(56,217,255,.25)); }
.tabs i { font-style: normal; font-size: 11px; background: rgba(255,255,255,.12); padding: 1px 7px; border-radius: 999px; }
.tabs i.hot { background: #e8336e; color: #fff; }
.spacer { flex: 1; }
.unread { font-size: 12px; color: var(--muted); }
.refresh { background: transparent; border: 1px solid var(--line); color: var(--muted); padding: 8px 13px; font-size: 12px; }

.cards { display: grid; gap: 10px; }
.card { display: flex; align-items: center; gap: 14px; background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 14px 16px; backdrop-filter: blur(10px); }
.card:hover { border-color: rgba(167,139,250,.6); }
.ava { width: 46px; height: 46px; flex: none; display: grid; place-items: center; border-radius: 50%; font-size: 19px; font-weight: 700; background: linear-gradient(135deg, #7b2ff7, #38d9ff); color: #fff; }
.ava.dim { opacity: .6; }
.ava.small { width: 36px; height: 36px; font-size: 15px; }
.info { flex: 1; min-width: 0; }
.info h3 { font-size: 15px; margin-bottom: 5px; }
.info h3 .uid { font-size: 11px; color: var(--muted); font-weight: 400; margin-left: 9px; }
.preview { font-size: 13px; color: var(--muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.time { display: block; font-size: 11px; color: rgba(226,214,255,.42); margin-top: 6px; }
.ops { display: flex; gap: 8px; flex: none; }
.badge-unread { background: #e8336e; color: #fff; font-size: 11px; min-width: 20px; height: 20px; border-radius: 999px; display: grid; place-items: center; padding: 0 5px; }
.pending-tag { font-size: 12px; color: #c4b5fd; border: 1px solid var(--line); padding: 5px 11px; border-radius: 999px; }
.state { text-align: center; padding: 40px 10px; color: var(--muted); font-size: 14px; }
.state.small { padding: 18px; font-size: 13px; }
.req-wrap h4 { font-size: 14px; margin: 18px 0 10px; color: #c4b5fd; }
.req-wrap h4 span { font-size: 12px; color: var(--muted); margin-left: 6px; }
.search { display: flex; align-items: center; gap: 9px; background: rgba(26,15,52,.66); border: 1px solid var(--line); border-radius: 12px; padding: 5px 6px 5px 14px; margin-bottom: 16px; }
.search input { flex: 1; background: transparent; border: none; outline: none; color: var(--text); font: inherit; font-size: 13px; }
.search input::placeholder { color: rgba(226,214,255,.4); }
.go { background: rgba(123,47,247,.5); border: none; color: #fff; padding: 8px 16px; font-size: 13px; }

.chat-drawer { position: fixed; right: 0; top: 0; bottom: 0; width: min(390px, 92vw); z-index: 60; display: flex; flex-direction: column; background: #170e2e; border-left: 1px solid rgba(167,139,250,.5); box-shadow: -20px 0 60px rgba(0,0,0,.55); }
.chat-drawer header { display: flex; align-items: center; gap: 11px; padding: 16px; border-bottom: 1px solid var(--line); }
.chat-drawer header h3 { font-size: 15px; }
.chat-drawer header p { font-size: 11px; color: var(--muted); margin-top: 3px; }
.x { background: transparent; border: none; color: var(--muted); font-size: 18px; }
.msg-list { flex: 1; overflow-y: auto; padding: 16px; display: flex; flex-direction: column; gap: 12px; }
.bubble { max-width: 82%; align-self: flex-start; background: rgba(167,139,250,.16); border: 1px solid rgba(167,139,250,.25); border-radius: 14px 14px 14px 4px; padding: 10px 13px; }
.bubble.mine { align-self: flex-end; background: linear-gradient(135deg, rgba(123,47,247,.65), rgba(232,51,110,.45)); border-color: transparent; border-radius: 14px 14px 4px 14px; }
.bubble p { font-size: 13px; line-height: 1.7; }
.bubble span { display: block; font-size: 10px; color: rgba(226,214,255,.55); margin-top: 5px; text-align: right; }
.msg-input { display: flex; gap: 8px; padding: 14px; border-top: 1px solid var(--line); }
.msg-input input { flex: 1; background: rgba(11,6,22,.65); border: 1px solid var(--line); border-radius: 10px; color: var(--text); padding: 10px 12px; font: inherit; font-size: 13px; outline: none; }
.toast { position: fixed; left: 50%; bottom: 34px; transform: translateX(-50%); z-index: 90; background: rgba(26,15,52,.96); border: 1px solid #a78bfa; padding: 11px 22px; border-radius: 999px; font-size: 13px; }

@media (max-width: 720px) {
  .brand p { display: none; }
  .card { padding: 12px; gap: 10px; }
  .ops { flex-direction: column; }
  .actions .ghost { display: none; }
  .unread { display: none; }
}
</style>
