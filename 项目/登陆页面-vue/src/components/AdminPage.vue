<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { adminApi, adminLogout } from '../services/auth.js'

const props = defineProps({
  // 当前登录的管理员用户名
  user: { type: String, default: 'admin' }
})
const emit = defineEmits(['logout', 'expired', 'home'])

// ==================== 板块配置 ====================
const sections = [
  {
    key: 'characters',
    label: '人物志管理',
    icon: '👤',
    columns: [
      { key: 'name', label: '人物', width: '170px' },
      { key: 'role', label: '身份', width: '160px' },
      { key: 'camp', label: '阵营', width: '110px', type: 'camp' },
      { key: 'ability', label: '术式 / 能力' },
      { key: 'sort', label: '排序', width: '70px' }
    ],
    fields: [
      { key: 'name', label: '人物名', required: true },
      { key: 'icon', label: '图标 emoji', placeholder: '例如：😎' },
      { key: 'role', label: '身份 / 称号', placeholder: '例如：特级咒术师 · 教师' },
      {
        key: 'camp', label: '阵营', type: 'select', options: [
          { value: 'school', label: '高专' },
          { value: 'curse', label: '咒灵 · 诅咒师' }
        ]
      },
      { key: 'ability', label: '术式 / 能力' },
      { key: 'tags', label: '关键词', placeholder: '多个关键词用英文逗号分隔，如：现代最强,六眼' },
      { key: 'desc', label: '详细介绍', type: 'textarea' },
      { key: 'sort', label: '排序（越小越靠前）', type: 'number' }
    ],
    defaults: { name: '', icon: '', role: '', camp: 'school', ability: '', tags: '', desc: '', sort: 0 }
  },
  {
    key: 'tools',
    label: '咒具图鉴管理',
    icon: '🗡️',
    columns: [
      { key: 'name', label: '咒具', width: '180px' },
      { key: 'grade', label: '等级', width: '130px', type: 'grade' },
      { key: 'owner', label: '持有者', width: '220px' },
      { key: 'desc', label: '介绍', type: 'ellipsis' },
      { key: 'sort', label: '排序', width: '70px' }
    ],
    fields: [
      { key: 'name', label: '咒具名', required: true },
      { key: 'icon', label: '图标 emoji', placeholder: '例如：🗡️' },
      { key: 'grade', label: '等级文字', placeholder: '例如：特级咒具' },
      {
        key: 'gradeClass', label: '等级样式', type: 'select', options: [
          { value: 'top', label: '特级（金色）' },
          { value: 'relic', label: '特级咒物（紫色）' },
          { value: 'maybe', label: '疑似特级（橙色）' },
          { value: 'unknown', label: '未知（灰色）' }
        ]
      },
      { key: 'owner', label: '持有者' },
      { key: 'desc', label: '详细介绍', type: 'textarea' },
      { key: 'sort', label: '排序（越小越靠前）', type: 'number' }
    ],
    defaults: { name: '', icon: '', grade: '', gradeClass: 'unknown', owner: '', desc: '', sort: 0 }
  },
  {
    key: 'events',
    label: '时间线管理',
    icon: '🕰️',
    columns: [
      { key: 'era', label: '时代', width: '150px' },
      { key: 'title', label: '事件标题', width: '220px' },
      { key: 'desc', label: '介绍', type: 'ellipsis' },
      { key: 'sort', label: '排序', width: '70px' }
    ],
    fields: [
      { key: 'era', label: '时代 / 时间', required: true, placeholder: '例如：2018 · 10月31日' },
      { key: 'title', label: '事件标题', required: true },
      { key: 'desc', label: '详细介绍', type: 'textarea' },
      { key: 'sort', label: '排序（越小越靠前）', type: 'number' }
    ],
    defaults: { era: '', title: '', desc: '', sort: 0 }
  }
]

const activeKey = ref('characters')
const active = computed(() => sections.find((s) => s.key === activeKey.value))

// ==================== 数据加载 ====================
const rows = ref([])
const loading = ref(false)
const toast = ref('')
const toastOk = ref(true)
let toastTimer = null

const showToast = (text, ok = true) => {
  toast.value = text
  toastOk.value = ok
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => (toast.value = ''), 2600)
}

// 接口返回 401 时强制回到后台登录页
const handleError = (e) => {
  if (e.code === 401) {
    showToast(e.message, false)
    emit('expired')
    return
  }
  showToast(e.message || '操作失败', false)
}

const load = async () => {
  loading.value = true
  try {
    rows.value = await adminApi(activeKey.value, 'list')
  } catch (e) {
    handleError(e)
  } finally {
    loading.value = false
  }
}

const switchSection = (key) => {
  if (activeKey.value === key) return
  activeKey.value = key
  closeModal()
  load()
}

// ==================== 新增 / 编辑弹窗 ====================
const modal = ref(null) // { mode: 'create'|'edit' }
const form = reactive({})
const saving = ref(false)

const openCreate = () => {
  Object.keys(form).forEach((k) => delete form[k])
  Object.assign(form, { ...active.value.defaults })
  modal.value = { mode: 'create' }
}

const openEdit = (row) => {
  Object.keys(form).forEach((k) => delete form[k])
  Object.assign(form, { ...active.value.defaults }, JSON.parse(JSON.stringify(row)))
  modal.value = { mode: 'edit' }
}

const closeModal = () => {
  modal.value = null
}

const save = async () => {
  if (saving.value) return
  for (const f of active.value.fields) {
    if (f.required && !String(form[f.key] ?? '').trim()) {
      showToast(`请填写「${f.label}」`, false)
      return
    }
  }
  saving.value = true
  try {
    const payload = { ...form }
    if (payload.sort === '' || payload.sort == null) payload.sort = 0
    payload.sort = Number(payload.sort) || 0
    if (modal.value.mode === 'create') {
      await adminApi(activeKey.value, 'create', payload)
      showToast('新增成功')
    } else {
      await adminApi(activeKey.value, 'update', payload)
      showToast('修改成功')
    }
    closeModal()
    load()
  } catch (e) {
    handleError(e)
  } finally {
    saving.value = false
  }
}

// ==================== 删除 ====================
const removing = ref(null)
const removeRow = async (row) => {
  if (!window.confirm(`确定删除「${row.name || row.title}」吗？此操作不可恢复。`)) return
  removing.value = row.id
  try {
    await adminApi(activeKey.value, 'remove', { id: row.id })
    showToast('删除成功')
    load()
  } catch (e) {
    handleError(e)
  } finally {
    removing.value = null
  }
}

// ==================== 退出后台 ====================
const onLogout = async () => {
  await adminLogout()
  emit('logout')
}

onMounted(load)
</script>

<template>
  <div class="admin">
    <!-- ===== 侧边栏 ===== -->
    <aside class="side">
      <div class="side-logo">
        <span class="mark">咒</span>
        <div>
          <div class="t1">咒术回战</div>
          <div class="t2">内容管理后台</div>
        </div>
      </div>
      <nav class="side-menu">
        <button
          v-for="s in sections"
          :key="s.key"
          class="side-item"
          :class="{ active: activeKey === s.key }"
          @click="switchSection(s.key)"
        >
          <span class="si-icon">{{ s.icon }}</span>{{ s.label }}
        </button>
      </nav>
      <div class="side-foot">数据改动实时同步首页</div>
    </aside>

    <!-- ===== 主区域 ===== -->
    <div class="main">
      <header class="topbar">
        <h2 class="page-title">{{ active.icon }} {{ active.label }}</h2>
        <div class="top-actions">
          <span class="admin-badge">🛡️ {{ user }}</span>
          <button class="btn ghost" @click="emit('home')">返回首页</button>
          <button class="btn danger-ghost" @click="onLogout">退出后台</button>
        </div>
      </header>

      <div class="toolbar">
        <span class="count">共 {{ rows.length }} 条数据</span>
        <button class="btn primary" @click="openCreate">＋ 新增</button>
      </div>

      <!-- 数据表格 -->
      <div class="table-wrap" :class="{ loading }">
        <table class="table">
          <thead>
            <tr>
              <th v-for="c in active.columns" :key="c.key" :style="c.width ? { width: c.width } : {}">
                {{ c.label }}
              </th>
              <th style="width: 140px">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id">
              <td v-for="c in active.columns" :key="c.key">
                <template v-if="c.key === 'name'">
                  <span class="cell-name"><span class="cell-icon">{{ row.icon }}</span>{{ row.name }}</span>
                </template>
                <template v-else-if="c.type === 'camp'">
                  <span class="pill" :class="row.camp === 'school' ? 'pill-cyan' : 'pill-red'">
                    {{ row.camp === 'school' ? '高专' : '咒灵 · 诅咒师' }}
                  </span>
                </template>
                <template v-else-if="c.type === 'grade'">
                  <span class="pill" :class="'pill-' + (row.gradeClass || 'unknown')">{{ row.grade }}</span>
                </template>
                <template v-else-if="c.type === 'ellipsis'">
                  <span class="ellipsis">{{ row[c.key] }}</span>
                </template>
                <template v-else>{{ row[c.key] }}</template>
              </td>
              <td>
                <button class="op edit" @click="openEdit(row)">编辑</button>
                <button class="op del" :disabled="removing === row.id" @click="removeRow(row)">
                  {{ removing === row.id ? '删除中' : '删除' }}
                </button>
              </td>
            </tr>
            <tr v-if="!rows.length && !loading">
              <td :colspan="active.columns.length + 1" class="empty">暂无数据，点击右上角「新增」创建第一条</td>
            </tr>
          </tbody>
        </table>
        <div v-if="loading" class="loading-mask"><span class="spinner"></span></div>
      </div>
    </div>

    <!-- 提示条 -->
    <transition name="fade">
      <div v-if="toast" class="toast" :class="{ err: !toastOk }">{{ toast }}</div>
    </transition>

    <!-- ===== 新增 / 编辑弹窗 ===== -->
    <div v-if="modal" class="modal-mask" @click.self="closeModal">
      <div class="modal">
        <button class="m-close" @click="closeModal">×</button>
        <h3 class="m-title">{{ modal.mode === 'create' ? '新增' : '编辑' }} · {{ active.label.replace('管理', '') }}</h3>
        <div class="form">
          <label v-for="f in active.fields" :key="f.key" class="f-item">
            <span class="f-label">{{ f.label }}<i v-if="f.required" class="req">*</i></span>
            <select v-if="f.type === 'select'" v-model="form[f.key]">
              <option v-for="o in f.options" :key="o.value" :value="o.value">{{ o.label }}</option>
            </select>
            <textarea v-else-if="f.type === 'textarea'" v-model="form[f.key]" rows="4" :placeholder="f.placeholder || ''"></textarea>
            <input v-else-if="f.type === 'number'" v-model="form[f.key]" type="number" :placeholder="f.placeholder || '0'" />
            <input v-else v-model="form[f.key]" type="text" :placeholder="f.placeholder || ''" />
          </label>
        </div>
        <div class="m-actions">
          <button class="btn ghost" @click="closeModal">取消</button>
          <button class="btn primary" :disabled="saving" @click="save">
            {{ saving ? '保存中…' : '保存' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin {
  position: relative;
  z-index: 2;
  display: flex;
  height: 100vh;
  overflow: hidden;
}

/* ---------- 侧边栏 ---------- */
.side {
  width: 216px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  padding: 22px 14px;
  background: rgba(13, 16, 39, 0.82);
  border-right: 1px solid rgba(42, 209, 255, 0.15);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
}
.side-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 8px 20px;
  border-bottom: 1px solid var(--line);
  margin-bottom: 16px;
}
.mark {
  width: 36px;
  height: 36px;
  display: grid;
  place-items: center;
  border-radius: 10px;
  font-weight: 700;
  background: linear-gradient(135deg, var(--c1), var(--c3));
  box-shadow: 0 0 16px rgba(42, 209, 255, 0.5);
}
.t1 { font-size: 15px; font-weight: 700; }
.t2 { font-size: 11px; color: var(--muted); margin-top: 2px; }
.side-menu {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.side-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 14px;
  border: 1px solid transparent;
  border-radius: 10px;
  background: transparent;
  color: var(--muted);
  font-size: 14px;
  cursor: pointer;
  text-align: left;
  transition: all 0.2s;
}
.side-item:hover {
  color: var(--text);
  background: rgba(42, 209, 255, 0.08);
}
.side-item.active {
  color: var(--text);
  background: rgba(42, 209, 255, 0.12);
  border-color: rgba(42, 209, 255, 0.35);
  box-shadow: 0 0 14px rgba(42, 209, 255, 0.12);
}
.si-icon { font-size: 16px; }
.side-foot {
  margin-top: auto;
  padding: 12px 8px 0;
  font-size: 11px;
  color: var(--muted);
  border-top: 1px solid var(--line);
}

/* ---------- 主区域 ---------- */
.main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  padding: 22px 28px;
  overflow-y: auto;
}
.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}
.page-title { font-size: 20px; font-weight: 700; }
.top-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}
.admin-badge {
  font-size: 13px;
  color: var(--c3);
  padding: 6px 12px;
  border: 1px solid rgba(42, 209, 255, 0.4);
  border-radius: 999px;
  background: rgba(42, 209, 255, 0.08);
}

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}
.count { font-size: 13px; color: var(--muted); }

/* ---------- 按钮 ---------- */
.btn {
  padding: 8px 18px;
  border-radius: 9px;
  font-size: 13px;
  cursor: pointer;
  border: 1px solid var(--line);
  background: transparent;
  color: var(--muted);
  transition: all 0.2s;
}
.btn.primary {
  border: none;
  color: #fff;
  font-weight: 600;
  background: linear-gradient(135deg, var(--c1), var(--c3));
  box-shadow: 0 6px 16px rgba(42, 209, 255, 0.3);
}
.btn.primary:hover { transform: translateY(-1px); box-shadow: 0 8px 22px rgba(42, 209, 255, 0.5); }
.btn.primary:disabled { opacity: 0.7; cursor: wait; transform: none; }
.btn.ghost:hover { color: var(--c3); border-color: rgba(42, 209, 255, 0.5); }
.btn.danger-ghost:hover { color: #ff8fb1; border-color: rgba(255, 92, 168, 0.5); }

/* ---------- 表格 ---------- */
.table-wrap {
  position: relative;
  flex: 1;
  overflow: auto;
  border: 1px solid var(--line);
  border-radius: 14px;
  background: var(--card);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}
.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.table th {
  position: sticky;
  top: 0;
  z-index: 1;
  text-align: left;
  padding: 13px 16px;
  font-size: 12px;
  color: var(--muted);
  font-weight: 600;
  background: rgba(13, 16, 39, 0.95);
  border-bottom: 1px solid var(--line);
  white-space: nowrap;
}
.table td {
  padding: 12px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  vertical-align: middle;
}
.table tbody tr { transition: background 0.15s; }
.table tbody tr:hover { background: rgba(42, 209, 255, 0.05); }
.cell-name { display: inline-flex; align-items: center; gap: 8px; font-weight: 600; white-space: nowrap; }
.cell-icon { font-size: 18px; }
.ellipsis {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  color: var(--muted);
  line-height: 1.6;
}
.empty {
  text-align: center;
  color: var(--muted);
  padding: 48px 0 !important;
}
.pill {
  display: inline-block;
  font-size: 11px;
  padding: 3px 10px;
  border-radius: 999px;
  border: 1px solid var(--line);
  color: var(--muted);
  white-space: nowrap;
}
.pill-cyan { color: var(--c3); border-color: rgba(42, 209, 255, 0.5); background: rgba(42, 209, 255, 0.1); }
.pill-red { color: #ff6b81; border-color: rgba(255, 107, 129, 0.5); background: rgba(255, 107, 129, 0.1); }
.pill-top { color: #ffd166; border-color: rgba(255, 209, 102, 0.55); background: rgba(255, 209, 102, 0.12); }
.pill-relic { color: #c58bff; border-color: rgba(197, 139, 255, 0.55); background: rgba(197, 139, 255, 0.12); }
.pill-maybe { color: #ffa94d; border-color: rgba(255, 169, 77, 0.55); background: rgba(255, 169, 77, 0.12); }

.op {
  padding: 5px 12px;
  margin-right: 8px;
  border-radius: 7px;
  font-size: 12px;
  cursor: pointer;
  background: transparent;
  transition: all 0.2s;
}
.op.edit { border: 1px solid rgba(42, 209, 255, 0.45); color: var(--c3); }
.op.edit:hover { background: rgba(42, 209, 255, 0.12); }
.op.del { border: 1px solid rgba(255, 92, 168, 0.45); color: #ff8fb1; }
.op.del:hover { background: rgba(255, 92, 168, 0.12); }
.op.del:disabled { opacity: 0.5; cursor: wait; }

.loading-mask {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  background: rgba(13, 16, 39, 0.5);
}
.spinner {
  width: 26px;
  height: 26px;
  border: 3px solid rgba(255, 255, 255, 0.25);
  border-top-color: var(--c3);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ---------- 提示条 ---------- */
.toast {
  position: fixed;
  top: 22px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 300;
  padding: 10px 22px;
  border-radius: 10px;
  font-size: 13px;
  color: #4ade80;
  background: rgba(13, 16, 39, 0.95);
  border: 1px solid rgba(74, 222, 128, 0.5);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}
.toast.err { color: #ff8fb1; border-color: rgba(255, 92, 168, 0.5); }
.fade-enter-active, .fade-leave-active { transition: opacity 0.25s, transform 0.25s; }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translate(-50%, -8px); }

/* ---------- 弹窗 ---------- */
.modal-mask {
  position: fixed;
  inset: 0;
  z-index: 200;
  background: rgba(5, 6, 18, 0.72);
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
  display: grid;
  place-items: center;
  padding: 24px;
}
.modal {
  position: relative;
  width: 560px;
  max-width: 94vw;
  max-height: 86vh;
  overflow-y: auto;
  padding: 28px 28px 22px;
  background: #14183a;
  border: 1px solid rgba(42, 209, 255, 0.35);
  border-radius: 16px;
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.6), 0 0 40px rgba(42, 209, 255, 0.15);
  animation: popIn 0.28s cubic-bezier(0.2, 0.8, 0.2, 1);
}
@keyframes popIn {
  from { opacity: 0; transform: translateY(14px) scale(0.97); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}
.m-close {
  position: absolute;
  top: 12px;
  right: 14px;
  width: 30px;
  height: 30px;
  border: none;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
  color: var(--muted);
  font-size: 17px;
  cursor: pointer;
}
.m-close:hover { color: var(--text); background: rgba(255, 255, 255, 0.12); }
.m-title { font-size: 17px; font-weight: 700; margin-bottom: 18px; }
.form { display: flex; flex-direction: column; gap: 13px; }
.f-label {
  display: block;
  font-size: 12px;
  color: var(--muted);
  margin-bottom: 5px;
}
.req { color: #ff6b81; font-style: normal; margin-left: 3px; }
.f-item input,
.f-item select,
.f-item textarea {
  width: 100%;
  padding: 10px 12px;
  font-size: 13px;
  font-family: inherit;
  color: var(--text);
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--line);
  border-radius: 9px;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}
.f-item select option { background: #14183a; color: var(--text); }
.f-item textarea { resize: vertical; line-height: 1.7; }
.f-item input:focus,
.f-item select:focus,
.f-item textarea:focus {
  border-color: rgba(42, 209, 255, 0.6);
  box-shadow: 0 0 0 3px rgba(42, 209, 255, 0.12);
}
.m-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

/* ---------- 响应式 ---------- */
@media (max-width: 860px) {
  .side { width: 64px; padding: 18px 8px; }
  .side-logo div, .side-item { font-size: 0; gap: 0; justify-content: center; }
  .side-item .si-icon { font-size: 18px; }
  .side-foot { display: none; }
  .main { padding: 16px; }
}
</style>
