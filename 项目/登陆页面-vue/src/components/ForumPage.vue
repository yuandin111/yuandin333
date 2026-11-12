<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  backendReady, getCategories, getPosts, getPost, getComments,
  createPost, updatePost, deletePost, toggleLike, addComment, deleteComment, fmtTime
} from '../services/community.js'
import { resolveUrl } from '../services/auth.js'

const props = defineProps({ user: { type: String, default: 'User' } })
const emit = defineEmits(['back', 'friends'])

const categories = ref([{ key: 'all', name: '全部', icon: '✦', count: 0 }])
const activeCat = ref('all')
const sort = ref('new')
const searchInput = ref('')
const keyword = ref('')
const page = ref(1)
const posts = ref([])
const total = ref(0)
const hasMore = ref(false)
const loading = ref(false)
const error = ref('')
const toast = ref('')
const busy = ref(false)

const showComposer = ref(false)
const editingId = ref(null)
const form = ref({ title: '', category: 'fanwork', tags: '', content: '' })

const detail = ref(null)
const comments = ref([])
const commentText = ref('')
const replyTarget = ref(null)

const isAdmin = () => localStorage.getItem('permission') === '0'
const canManage = (p) => p && (p.authorName === props.user || isAdmin())
const initial = (name) => (name || 'U').trim().charAt(0).toUpperCase()

const gradients = {
  fanwork: 'linear-gradient(135deg,#7b2ff7,#e8336e)',
  fanart: 'linear-gradient(135deg,#38d9ff,#7b2ff7)',
  discuss: 'linear-gradient(135deg,#e8336e,#f59e0b)',
  lore: 'linear-gradient(135deg,#0ea5e9,#6366f1)',
  chat: 'linear-gradient(135deg,#10b981,#38d9ff)'
}
const excerpt = (text) => (text || '').replace(/\n+/g, ' ').trim().slice(0, 96)
const catName = (key) => categories.value.find((c) => c.key === key)?.name || '同人二创'
const catIcon = (key) => categories.value.find((c) => c.key === key)?.icon || '✍️'

const coverStyle = (p) => {
  const url = p?.coverUrl ? resolveUrl(p.coverUrl) : ''
  return url
    ? { backgroundImage: `url(${url})`, backgroundSize: 'cover', backgroundPosition: 'center' }
    : { background: gradients[p?.category] || gradients.fanwork }
}

const groupedComments = computed(() => {
  const roots = comments.value.filter((c) => !c.parentId)
  const children = comments.value.filter((c) => c.parentId)
  return roots.map((r) => ({ ...r, replies: children.filter((c) => c.parentId === r.id) }))
})

function notify(msg) {
  toast.value = msg
  setTimeout(() => { if (toast.value === msg) toast.value = '' }, 2200)
}

async function loadCategories() {
  try { categories.value = await getCategories() } catch (e) { /* 保留默认板块 */ }
}

async function load(reset = true) {
  if (!backendReady()) { error.value = '未配置后端地址，社区功能需要连接后端'; return }
  if (reset) page.value = 1
  loading.value = true
  error.value = ''
  try {
    const data = await getPosts({
      category: activeCat.value, q: keyword.value, sort: sort.value, page: page.value, size: 8
    })
    posts.value = data.list || []
    total.value = data.total || 0
    hasMore.value = Boolean(data.hasMore)
  } catch (e) {
    error.value = e.message || '加载失败'
    posts.value = []
  } finally {
    loading.value = false
  }
}

function switchCat(key) { activeCat.value = key; load(true) }
function setSort(s) { sort.value = s; load(true) }
function doSearch() { keyword.value = searchInput.value.trim(); load(true) }
function clearSearch() { searchInput.value = ''; keyword.value = ''; load(true) }
function changePage(delta) {
  const next = page.value + delta
  if (next < 1) return
  if (delta > 0 && !hasMore.value) return
  page.value = next
  load(false)
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

async function openDetail(id) {
  if (busy.value) return
  busy.value = true
  replyTarget.value = null
  commentText.value = ''
  try {
    const [p, cs] = await Promise.all([getPost(id), getComments(id)])
    detail.value = p
    comments.value = cs || []
    const row = posts.value.find((x) => x.id === id)
    if (row) { row.viewCount = p.viewCount; row.commentCount = p.commentCount }
  } catch (e) {
    notify(e.message || '打开失败')
  } finally { busy.value = false }
}

async function doLike(post) {
  if (!post) return
  try {
    const r = await toggleLike(post.id)
    post.liked = r.liked
    post.likeCount = r.likeCount
    if (detail.value?.id === post.id) {
      detail.value.liked = r.liked
      detail.value.likeCount = r.likeCount
    }
    notify(r.liked ? '已点赞' : '已取消点赞')
  } catch (e) { notify(e.message || '操作失败') }
}

function replyTo(c) {
  replyTarget.value = { parentId: c.parentId || c.id, name: c.userName }
  commentText.value = ''
}

async function submitComment() {
  const text = commentText.value.trim()
  if (!text || !detail.value) return
  try {
    await addComment(detail.value.id, {
      content: text,
      parentId: replyTarget.value?.parentId || null,
      replyToName: replyTarget.value?.name || null
    })
    commentText.value = ''
    replyTarget.value = null
    comments.value = await getComments(detail.value.id)
    detail.value.commentCount = (detail.value.commentCount || 0) + 1
    const row = posts.value.find((x) => x.id === detail.value.id)
    if (row) row.commentCount = detail.value.commentCount
  } catch (e) { notify(e.message || '评论失败') }
}

async function removeCmt(id) {
  try {
    await deleteComment(id)
    comments.value = await getComments(detail.value.id)
    detail.value.commentCount = Math.max(0, (detail.value.commentCount || 1) - 1)
  } catch (e) { notify(e.message || '删除失败') }
}

function openComposer(post = null) {
  editingId.value = post?.id || null
  form.value = post
    ? { title: post.title, category: post.category, tags: post.tags || '', content: post.content }
    : { title: '', category: activeCat.value === 'all' ? 'fanwork' : activeCat.value, tags: '', content: '' }
  showComposer.value = true
}

async function submitPost() {
  const f = form.value
  if (!f.title.trim() || !f.content.trim()) { notify('标题和正文不能为空'); return }
  try {
    if (editingId.value) await updatePost(editingId.value, f)
    else await createPost(f)
    showComposer.value = false
    notify(editingId.value ? '修改成功' : '发帖成功')
    await loadCategories()
    load(true)
  } catch (e) { notify(e.message || '提交失败') }
}

async function removePost(id) {
  if (!window.confirm('确定删除这篇帖子吗？')) return
  try {
    await deletePost(id)
    detail.value = null
    notify('已删除')
    await loadCategories()
    load(true)
  } catch (e) { notify(e.message || '删除失败') }
}

onMounted(() => { loadCategories(); load(true) })
</script>

<template>
  <div class="forum">
    <header class="topbar">
      <button class="back" @click="emit('back')">← 返回首页</button>
      <div class="brand">
        <span class="mark">社</span>
        <div>
          <h1>高专社区 · 论坛</h1>
          <p>同人二创 / 同人图绘 / 剧情讨论 / 术式考据 / 闲聊水区</p>
        </div>
      </div>
      <div class="actions">
        <button class="ghost" @click="emit('friends')">🤝 好友</button>
        <button class="primary" @click="openComposer()">✍️ 发布作品</button>
        <span class="whoami" :title="'当前登录账号：' + user">
          <span class="avatar">{{ initial(user) }}</span>
          <span class="whoami-name">{{ user }}</span>
        </span>
      </div>
    </header>

    <div v-if="!backendReady()" class="notice">
      当前为演示模式（未配置 VITE_API_BASE），社区功能需要连接后端才能读写数据。
    </div>

    <section class="board">
      <div class="tabs">
        <button
          v-for="c in categories" :key="c.key"
          :class="{ active: activeCat === c.key }"
          @click="switchCat(c.key)"
        >
          <span class="t-icon">{{ c.icon }}</span>{{ c.name }}<i>{{ c.count }}</i>
        </button>
      </div>

      <div class="toolbar">
        <div class="search">
          <span>🔍</span>
          <input v-model="searchInput" placeholder="搜索标题 / 正文 / 作者 / 标签" @keyup.enter="doSearch" />
          <button v-if="keyword" class="clear" @click="clearSearch">清除</button>
          <button class="go" @click="doSearch">搜索</button>
        </div>
        <div class="sort">
          <button :class="{ on: sort === 'new' }" @click="setSort('new')">最新</button>
          <button :class="{ on: sort === 'hot' }" @click="setSort('hot')">热门</button>
        </div>
      </div>

      <p v-if="error" class="err">{{ error }}</p>
      <div v-if="loading" class="state">正在载入帖子…</div>

      <div v-else class="posts">
        <article v-for="p in posts" :key="p.id" class="post" @click="openDetail(p.id)">
          <div class="cover" :style="coverStyle(p)">
            <span>{{ catIcon(p.category) }}</span>
          </div>
          <div class="post-main">
            <div class="post-tags">
              <span class="badge">{{ p.categoryName }}</span>
              <span v-if="p.isTop" class="flag top">置顶</span>
              <span v-if="p.isEssence" class="flag essence">精华</span>
              <span v-for="t in (p.tags || '').split(',').filter(Boolean).slice(0, 3)" :key="t" class="tag">#{{ t }}</span>
            </div>
            <h2>{{ p.title }}</h2>
            <p class="excerpt">{{ excerpt(p.content) }}<span v-if="p.content?.length > 96">…</span></p>
            <div class="meta">
              <span class="who"><i>{{ initial(p.authorName) }}</i>{{ p.authorName }}</span>
              <span>{{ fmtTime(p.createTime) }}</span>
              <span class="spacer"></span>
              <span :class="{ liked: p.liked }">♥ {{ p.likeCount || 0 }}</span>
              <span>💬 {{ p.commentCount || 0 }}</span>
              <span>👁 {{ p.viewCount || 0 }}</span>
            </div>
          </div>
        </article>
        <div v-if="!posts.length" class="state">这个板块还没有帖子，来发第一篇吧 ✍️</div>
      </div>

      <div class="pager">
        <button :disabled="page <= 1" @click="changePage(-1)">← 上一页</button>
        <span>第 {{ page }} 页 · 共 {{ total }} 篇</span>
        <button :disabled="!hasMore" @click="changePage(1)">下一页 →</button>
      </div>
    </section>

    <!-- 发帖 / 编辑 -->
    <div v-if="showComposer" class="mask" @click.self="showComposer = false">
      <div class="modal composer">
        <header>
          <h3>{{ editingId ? '编辑帖子' : '发布作品' }}</h3>
          <button class="x" @click="showComposer = false">✕</button>
        </header>
        <div class="form-body">
          <label>标题<input v-model="form.title" maxlength="120" placeholder="例如：【同人】放学后的便利店" /></label>
          <div class="row">
            <label>板块
              <select v-model="form.category">
                <option v-for="c in categories.slice(1)" :key="c.key" :value="c.key">{{ c.name }}</option>
              </select>
            </label>
            <label>标签（逗号分隔）<input v-model="form.tags" placeholder="日常,治愈,连载" /></label>
          </div>
          <label>正文<textarea v-model="form.content" rows="12" placeholder="写下你的同人短篇、图绘说明或讨论…"></textarea></label>
          <p class="hint">支持换行；标题最多 120 字，正文最多 20000 字。请发布原创内容。</p>
        </div>
        <footer>
          <button class="ghost" @click="showComposer = false">取消</button>
          <button class="primary" @click="submitPost">{{ editingId ? '保存修改' : '发布' }}</button>
        </footer>
      </div>
    </div>

    <!-- 帖子详情 + 评论 -->
    <div v-if="detail" class="mask" @click.self="detail = null">
      <div class="modal detail-modal">
        <header>
          <div>
            <span class="badge">{{ detail.categoryName }}</span>
            <h3>{{ detail.title }}</h3>
            <p class="sub">{{ detail.authorName }} · {{ fmtTime(detail.createTime) }} · {{ detail.viewCount || 0 }} 次浏览</p>
          </div>
          <button class="x" @click="detail = null">✕</button>
        </header>
        <div class="article">
          <p v-for="(line, i) in (detail.content || '').split('\n')" :key="i">{{ line || '\u00a0' }}</p>
        </div>
        <div class="detail-actions">
          <button class="like" :class="{ on: detail.liked }" @click="doLike(detail)">♥ {{ detail.liked ? '已点赞' : '点赞' }} · {{ detail.likeCount || 0 }}</button>
          <button v-if="canManage(detail)" class="ghost" @click="openComposer(detail)">编辑</button>
          <button v-if="canManage(detail)" class="danger" @click="removePost(detail.id)">删除</button>
          <span class="spacer"></span>
          <span class="cmt-count">共 {{ comments.length }} 条评论</span>
        </div>

        <div class="comments">
          <div v-for="c in groupedComments" :key="c.id" class="cmt">
            <div class="cmt-head">
              <i>{{ initial(c.userName) }}</i>
              <b>{{ c.userName }}</b>
              <span>{{ fmtTime(c.createTime) }}</span>
              <span class="spacer"></span>
              <button @click="replyTo(c)">回复</button>
              <button v-if="c.userName === user || isAdmin()" @click="removeCmt(c.id)">删除</button>
            </div>
            <p>{{ c.content }}</p>
            <div v-for="r in c.replies" :key="r.id" class="sub-cmt">
              <i>{{ initial(r.userName) }}</i>
              <b>{{ r.userName }}</b>
              <span v-if="r.replyToName" class="reply-to">回复 @{{ r.replyToName }}</span>
              <span class="txt">{{ r.content }}</span>
              <span class="spacer"></span>
              <button @click="replyTo(r)">回复</button>
              <button v-if="r.userName === user || isAdmin()" @click="removeCmt(r.id)">删除</button>
            </div>
          </div>
          <div v-if="!comments.length" class="state small">还没有评论，来抢沙发吧～</div>
        </div>

        <div class="comment-box">
          <span v-if="replyTarget" class="replying">回复 @{{ replyTarget.name }} <button @click="replyTarget = null">✕</button></span>
          <textarea v-model="commentText" rows="2" placeholder="写下你的评论…（Ctrl+Enter 发送）" @keyup.ctrl.enter="submitComment"></textarea>
          <button class="primary" @click="submitComment">发送</button>
        </div>
      </div>
    </div>

    <div v-if="toast" class="toast">{{ toast }}</div>
  </div>
</template>

<style scoped>
.forum { min-height: 100vh; padding: 0 clamp(14px, 4vw, 56px) 60px; color: var(--text); }
.topbar {
  position: sticky; top: 0; z-index: 20;
  display: flex; align-items: center; gap: 18px;
  padding: 14px 0; margin-bottom: 18px;
  backdrop-filter: blur(16px);
  border-bottom: 1px solid var(--line);
}
.back, .ghost, .primary, .danger, .like, .sort button, .pager button, .go, .clear {
  font: inherit; cursor: pointer; border-radius: 10px; transition: .18s;
}
.back { background: transparent; border: 1px solid var(--line); color: var(--muted); padding: 8px 13px; font-size: 13px; }
.back:hover, .ghost:hover { color: #fff; border-color: #a78bfa; }
.brand { display: flex; align-items: center; gap: 12px; flex: 1; min-width: 0; }
.mark {
  width: 42px; height: 42px; flex: none; display: grid; place-items: center;
  border-radius: 13px; font-size: 21px; font-weight: 800;
  background: linear-gradient(135deg, #7b2ff7, #e8336e);
  box-shadow: 0 6px 24px rgba(123, 47, 247, .4);
}
.brand h1 { font-size: 19px; letter-spacing: .5px; }
.brand p { font-size: 11px; color: var(--muted); margin-top: 3px; }
.actions { display: flex; align-items: center; gap: 10px; }
.ghost { background: rgba(167,139,250,.1); border: 1px solid var(--line); color: var(--text); padding: 9px 15px; font-size: 13px; }
.primary { background: linear-gradient(135deg, #7b2ff7, #e8336e); border: none; color: #fff; padding: 9px 17px; font-size: 13px; font-weight: 700; box-shadow: 0 6px 22px rgba(123,47,247,.3); }
.primary:hover { filter: brightness(1.15); transform: translateY(-1px); }
.avatar { width: 34px; height: 34px; display: grid; place-items: center; border-radius: 50%; background: rgba(56,217,255,.16); border: 1px solid rgba(56,217,255,.4); font-weight: 700; font-size: 14px; }
/* 当前登录身份：多账号共用时明确显示「以谁的身份发帖」 */
.whoami {
  display: inline-flex; align-items: center; gap: 8px; max-width: 190px;
  padding: 4px 11px 4px 4px; border-radius: 999px;
  background: rgba(56,217,255,.08); border: 1px solid var(--line);
  color: var(--text); font-size: 12px;
}
.whoami .avatar { width: 26px; height: 26px; flex: none; font-size: 12px; }
.whoami-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.notice, .err { margin: 12px 0; padding: 11px 16px; border-radius: 12px; background: rgba(232,51,110,.12); border: 1px solid rgba(232,51,110,.35); font-size: 13px; }

.board { max-width: 1060px; margin: 0 auto; }
.tabs { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
.tabs button {
  display: inline-flex; align-items: center; gap: 7px; cursor: pointer;
  background: rgba(26,15,52,.6); border: 1px solid var(--line); color: var(--muted);
  padding: 9px 15px; border-radius: 999px; font: inherit; font-size: 13px; transition: .18s;
}
.tabs button:hover { color: #fff; transform: translateY(-1px); }
.tabs button.active { color: #fff; border-color: #a78bfa; background: linear-gradient(135deg, rgba(123,47,247,.55), rgba(232,51,110,.35)); box-shadow: 0 4px 18px rgba(123,47,247,.25); }
.tabs i { font-style: normal; font-size: 11px; opacity: .75; background: rgba(255,255,255,.12); padding: 1px 7px; border-radius: 999px; }
.t-icon { font-size: 15px; }

.toolbar { display: flex; gap: 12px; align-items: center; margin-bottom: 16px; flex-wrap: wrap; }
.search { flex: 1; min-width: 260px; display: flex; align-items: center; gap: 8px; background: rgba(26,15,52,.66); border: 1px solid var(--line); border-radius: 12px; padding: 5px 6px 5px 14px; }
.search input { flex: 1; background: transparent; border: none; outline: none; color: var(--text); font: inherit; font-size: 13px; }
.search input::placeholder { color: rgba(226,214,255,.4); }
.go { background: rgba(123,47,247,.5); border: none; color: #fff; padding: 8px 16px; font-size: 13px; }
.clear { background: transparent; border: none; color: var(--muted); font-size: 12px; padding: 6px; }
.sort { display: flex; background: rgba(26,15,52,.66); border: 1px solid var(--line); border-radius: 12px; padding: 4px; }
.sort button { border: none; background: transparent; color: var(--muted); padding: 7px 15px; font-size: 13px; }
.sort button.on { background: rgba(167,139,250,.28); color: #fff; }

.posts { display: grid; gap: 12px; }
.post {
  display: flex; gap: 16px; cursor: pointer;
  background: var(--card); border: 1px solid var(--line); border-radius: 16px;
  padding: 16px; backdrop-filter: blur(10px); transition: .2s;
}
.post:hover { border-color: rgba(167,139,250,.65); transform: translateY(-2px); box-shadow: 0 12px 32px rgba(0,0,0,.32); }
.cover { width: 108px; flex: none; border-radius: 12px; display: grid; place-items: center; font-size: 34px; opacity: .92; }
.post-main { flex: 1; min-width: 0; }
.post-tags { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; margin-bottom: 8px; }
.badge { font-size: 11px; padding: 3px 9px; border-radius: 6px; background: rgba(123,47,247,.3); border: 1px solid rgba(167,139,250,.4); }
.flag { font-size: 11px; padding: 3px 8px; border-radius: 6px; }
.flag.top { background: rgba(232,51,110,.25); color: #ffc2d6; }
.flag.essence { background: rgba(56,217,255,.2); color: #b9edff; }
.tag { font-size: 11px; color: var(--muted); }
.post h2 { font-size: 17px; font-weight: 700; margin-bottom: 7px; }
.excerpt { font-size: 13px; color: var(--muted); line-height: 1.7; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.meta { display: flex; align-items: center; gap: 14px; margin-top: 12px; font-size: 12px; color: var(--muted); flex-wrap: wrap; }
.meta .who { display: inline-flex; align-items: center; gap: 6px; color: var(--text); }
.meta i, .cmt-head i, .sub-cmt i { width: 22px; height: 22px; border-radius: 50%; display: inline-grid; place-items: center; font-style: normal; font-size: 11px; background: linear-gradient(135deg,#7b2ff7,#38d9ff); color: #fff; }
.spacer { flex: 1; }
.meta .liked { color: #ff7aa8; }
.state { text-align: center; padding: 44px 10px; color: var(--muted); font-size: 14px; }
.state.small { padding: 18px; font-size: 13px; }
.pager { display: flex; justify-content: center; align-items: center; gap: 18px; margin-top: 22px; font-size: 13px; color: var(--muted); }
.pager button { background: rgba(26,15,52,.7); border: 1px solid var(--line); color: var(--text); padding: 8px 16px; font-size: 13px; }
.pager button:disabled { opacity: .4; cursor: not-allowed; }

.mask { position: fixed; inset: 0; z-index: 50; background: rgba(5,2,14,.78); backdrop-filter: blur(6px); display: flex; align-items: center; justify-content: center; padding: 18px; }
.modal { width: min(760px, 100%); max-height: 90vh; display: flex; flex-direction: column; background: #170e2e; border: 1px solid rgba(167,139,250,.4); border-radius: 18px; box-shadow: 0 30px 80px rgba(0,0,0,.6); overflow: hidden; }
.modal > header { display: flex; align-items: flex-start; gap: 12px; padding: 18px 22px; border-bottom: 1px solid var(--line); }
.modal > header h3 { font-size: 17px; margin: 6px 0 0; }
.modal .sub { font-size: 12px; color: var(--muted); margin-top: 5px; }
.x { margin-left: auto; background: transparent; border: none; color: var(--muted); font-size: 18px; cursor: pointer; }
.x:hover { color: #fff; }
.form-body { padding: 20px 22px; overflow-y: auto; display: grid; gap: 14px; }
.form-body label { display: grid; gap: 7px; font-size: 12px; color: var(--muted); }
.form-body .row { display: grid; grid-template-columns: 1fr 1.4fr; gap: 14px; }
.form-body input, .form-body select, .form-body textarea {
  width: 100%; background: rgba(11,6,22,.65); border: 1px solid var(--line); border-radius: 10px;
  color: var(--text); padding: 10px 12px; font: inherit; font-size: 13px; outline: none; resize: vertical;
}
.form-body input:focus, .form-body textarea:focus { border-color: #a78bfa; }
.hint { font-size: 11px; color: var(--muted); }
.modal > footer { display: flex; justify-content: flex-end; gap: 10px; padding: 14px 22px; border-top: 1px solid var(--line); }

.detail-modal { width: min(820px, 100%); }
.article { padding: 20px 24px; overflow-y: auto; max-height: 34vh; font-size: 14px; line-height: 1.95; color: rgba(243,237,255,.9); white-space: pre-wrap; }
.article p { min-height: 1em; }
.detail-actions { display: flex; align-items: center; gap: 10px; padding: 12px 22px; border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); }
.like { border: 1px solid var(--line); background: rgba(26,15,52,.7); color: var(--text); padding: 8px 14px; font-size: 13px; }
.like.on { background: rgba(232,51,110,.3); border-color: rgba(232,51,110,.6); color: #ffc2d6; }
.danger { background: rgba(232,51,110,.12); border: 1px solid rgba(232,51,110,.35); color: #ff9dbd; padding: 8px 14px; font-size: 13px; }
.cmt-count, .replying { font-size: 12px; color: var(--muted); }
.comments { padding: 8px 22px; overflow-y: auto; max-height: 30vh; }
.cmt { padding: 12px 0; border-bottom: 1px dashed rgba(167,139,250,.2); }
.cmt-head, .sub-cmt { display: flex; align-items: center; gap: 8px; font-size: 12px; color: var(--muted); }
.cmt-head b, .sub-cmt b { color: var(--text); font-size: 13px; }
.cmt-head button, .sub-cmt button { background: none; border: none; color: var(--muted); cursor: pointer; font-size: 11px; }
.cmt-head button:hover, .sub-cmt button:hover { color: #a78bfa; }
.cmt > p { font-size: 13px; line-height: 1.75; margin: 8px 0 0 30px; }
.sub-cmt { margin: 10px 0 0 30px; padding: 9px 12px; background: rgba(167,139,250,.07); border-radius: 9px; flex-wrap: wrap; }
.reply-to { color: #c4b5fd; }
.sub-cmt .txt { color: var(--text); font-size: 13px; }
.comment-box { display: flex; align-items: center; gap: 10px; padding: 14px 22px; border-top: 1px solid var(--line); flex-wrap: wrap; }
.comment-box textarea { flex: 1; min-width: 200px; background: rgba(11,6,22,.65); border: 1px solid var(--line); border-radius: 10px; color: var(--text); padding: 9px 12px; font: inherit; font-size: 13px; outline: none; resize: vertical; }
.replying button { background: none; border: none; color: #ff9dbd; cursor: pointer; }
.toast { position: fixed; left: 50%; bottom: 34px; transform: translateX(-50%); z-index: 90; background: rgba(26,15,52,.96); border: 1px solid #a78bfa; padding: 11px 22px; border-radius: 999px; font-size: 13px; box-shadow: 0 12px 30px rgba(0,0,0,.5); }

@media (max-width: 720px) {
  .brand p { display: none; }
  .cover { width: 64px; font-size: 24px; }
  .post { gap: 11px; padding: 12px; }
  .form-body .row { grid-template-columns: 1fr; }
  .actions .ghost { display: none; }
}
</style>
