<script setup>
import { computed, onMounted, ref } from 'vue'
import LoginCard from './components/LoginCard.vue'
import RegisterCard from './components/RegisterCard.vue'
import HomePage from './components/HomePage.vue'
import AdminLogin from './components/AdminLogin.vue'
import AdminPage from './components/AdminPage.vue'

// 视图状态：login = 登录/注册页，home = 首页，admin-login = 后台登录页，admin = 后台管理系统
const view = ref('login')
const mode = ref('login')
const user = ref('')
const adminUser = ref('')
// 当前登录用户的权限：0 = 管理员权限，1 = 默认权限（普通用户）
const permission = ref(1)
// 是否管理员：仅 permission = 0 可见后台入口并登录后台
const isAdmin = computed(() => permission.value === 0)

const stars = ref([])
// 飘落御札（符咒）装饰
const talismans = ref([])

onMounted(() => {
  const arr = []
  for (let i = 0; i < 60; i++) {
    arr.push({
      left: Math.random() * 100 + 'vw',
      top: Math.random() * 100 + 'vh',
      dur: 3 + Math.random() * 4 + 's',
      delay: Math.random() * 4 + 's',
      size: 1 + Math.random() * 2.5 + 'px',
      hue: Math.random() > 0.5 ? '#ffffff' : Math.random() > 0.5 ? '#c4b5fd' : '#7dd3fc'
    })
  }
  stars.value = arr

  // 生成 6 张御札：随机水平位置 / 下落时长 / 延迟 / 尺寸 / 旋转
  const tal = []
  for (let i = 0; i < 6; i++) {
    tal.push({
      left: 4 + Math.random() * 92 + 'vw',
      dur: 14 + Math.random() * 12 + 's',
      delay: -Math.random() * 20 + 's',
      scale: 0.75 + Math.random() * 0.5,
      sway: 2.4 + Math.random() * 2.6 + 's',
      char: ['封', '呪', '結', '印', '祓', '界'][i]
    })
  }
  talismans.value = tal

  // 已登录（token 还在）则刷新后直接进入对应页面
  const adminToken = localStorage.getItem('admin_token')
  const token = localStorage.getItem('token')
  // 刷新后恢复权限标记，缺省按默认权限（普通用户）处理
  permission.value = localStorage.getItem('permission') === '0' ? 0 : 1
  if (adminToken) {
    adminUser.value = localStorage.getItem('admin_user') || 'admin'
    user.value = localStorage.getItem('user') || 'User'
    view.value = 'admin'
  } else if (token) {
    user.value = localStorage.getItem('user') || 'User'
    view.value = 'home'
  }
})

// 登录成功：保存 token 与权限，并跳转首页
const onLoginSuccess = ({ name, token, permission: perm }) => {
  localStorage.setItem('token', token || 'demo-token')
  localStorage.setItem('user', name)
  // 仅 0 视为管理员权限，其余（含缺省）一律按默认权限处理
  permission.value = perm === 0 ? 0 : 1
  localStorage.setItem('permission', String(permission.value))
  user.value = name
  view.value = 'home'
}

// 退出登录：清除本地会话，回到登录页
const onLogout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  localStorage.removeItem('permission')
  permission.value = 1
  user.value = ''
  view.value = 'login'
  mode.value = 'login'
}

// 首页点击"后台管理"：已有后台会话直接进入，否则去后台登录页
const goAdmin = () => {
  // 非管理员权限（permission != 0）直接拦截，不允许进入后台登录页
  if (permission.value !== 0) return
  if (localStorage.getItem('admin_token')) {
    adminUser.value = localStorage.getItem('admin_user') || 'admin'
    view.value = 'admin'
  } else {
    view.value = 'admin-login'
  }
}

// 后台登录成功：保存管理员 token 并进入后台
const onAdminLoginSuccess = ({ name, token }) => {
  localStorage.setItem('admin_token', token)
  localStorage.setItem('admin_user', name)
  adminUser.value = name
  view.value = 'admin'
}

// 退出后台：仅清除后台会话，回到首页
const onAdminLogout = () => {
  localStorage.removeItem('admin_token')
  localStorage.removeItem('admin_user')
  adminUser.value = ''
  view.value = localStorage.getItem('token') ? 'home' : 'login'
}
</script>

<template>
  <!-- 动态背景：流动光斑 -->
  <div class="bg">
    <div class="blob b1"></div>
    <div class="blob b2"></div>
    <div class="blob b3"></div>
  </div>

  <!-- 动态背景：闪烁星点（咒力微尘） -->
  <div class="stars">
    <span
      v-for="(s, i) in stars"
      :key="i"
      class="star"
      :style="{
        left: s.left,
        top: s.top,
        '--dur': s.dur,
        '--delay': s.delay,
        '--star-c': s.hue,
        width: s.size,
        height: s.size
      }"
    ></span>
  </div>

  <!-- 登录/后台登录视图专属：领域展开法阵 + 飘落御札 + 竖排题字 -->
  <div v-if="view === 'login' || view === 'admin-login'" class="jjk-scene" aria-hidden="true">
    <!-- 领域展开法阵 -->
    <div class="domain">
      <svg class="domain-svg" viewBox="0 0 600 600">
        <circle cx="300" cy="300" r="292" fill="none" stroke="currentColor" stroke-width="1" stroke-dasharray="4 10" />
        <circle cx="300" cy="300" r="268" fill="none" stroke="currentColor" stroke-width="1.2" />
        <circle cx="300" cy="300" r="238" fill="none" stroke="currentColor" stroke-width="1" stroke-dasharray="26 8" />
        <circle cx="300" cy="300" r="150" fill="none" stroke="currentColor" stroke-width="1.5" />
        <circle cx="300" cy="300" r="120" fill="none" stroke="currentColor" stroke-width="1" stroke-dasharray="2 8" />
        <rect x="188" y="188" width="224" height="224" fill="none" stroke="currentColor" stroke-width="1.2" />
        <rect x="188" y="188" width="224" height="224" fill="none" stroke="currentColor" stroke-width="1" transform="rotate(45 300 300)" />
        <line x1="300" y1="8" x2="300" y2="112" stroke="currentColor" stroke-width="1" />
        <line x1="300" y1="488" x2="300" y2="592" stroke="currentColor" stroke-width="1" />
        <line x1="8" y1="300" x2="112" y2="300" stroke="currentColor" stroke-width="1" />
        <line x1="488" y1="300" x2="592" y2="300" stroke="currentColor" stroke-width="1" />
        <g fill="currentColor" font-size="17" font-family="serif" opacity="0.9">
          <text x="300" y="42" text-anchor="middle">呪</text>
          <text x="300" y="572" text-anchor="middle">術</text>
          <text x="28" y="306" text-anchor="middle">廻</text>
          <text x="572" y="306" text-anchor="middle">戦</text>
        </g>
      </svg>
    </div>

    <!-- 飘落御札 -->
    <div
      v-for="(t, i) in talismans"
      :key="'t' + i"
      class="talisman"
      :style="{
        left: t.left,
        '--fall': t.dur,
        '--fall-delay': t.delay,
        '--sway': t.sway,
        transform: `scale(${t.scale})`
      }"
    >
      <span class="talisman-char">{{ t.char }}</span>
    </div>

    <!-- 竖排题字 -->
    <div class="side-title left">呪術廻戦</div>
    <div class="side-title right">JUJUTSU<br />KAISEN</div>
  </div>

  <!-- 首页 -->
  <div v-if="view === 'home'" class="home-view">
    <HomePage :user="user" :is-admin="isAdmin" @logout="onLogout" @admin="goAdmin" />
  </div>

  <!-- 后台管理系统 -->
  <div v-else-if="view === 'admin'" class="admin-view">
    <AdminPage :user="adminUser" @logout="onAdminLogout" @expired="view = 'admin-login'" @home="view = 'home'" />
  </div>

  <!-- 后台登录页 -->
  <div v-else-if="view === 'admin-login'" class="login-view">
    <AdminLogin @success="onAdminLoginSuccess" @back="view = 'home'" />
  </div>

  <!-- 登录 / 注册 -->
  <div v-else class="login-view">
    <LoginCard v-if="mode === 'login'" @switch="mode = $event" @success="onLoginSuccess" />
    <RegisterCard v-else @switch="mode = $event" />
  </div>
</template>

<style scoped>
.bg {
  position: fixed;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  filter: blur(60px);
}
.blob {
  position: absolute;
  width: 46vmax;
  height: 46vmax;
  border-radius: 50%;
  opacity: 0.55;
  mix-blend-mode: screen;
  animation: drift 18s ease-in-out infinite;
}
.blob.b1 {
  background: var(--c1);
  top: -12%;
  left: -10%;
}
.blob.b2 {
  background: var(--c2);
  bottom: -18%;
  right: -8%;
  animation-delay: -6s;
}
.blob.b3 {
  background: var(--c3);
  top: 30%;
  left: 40%;
  animation-delay: -12s;
}
@keyframes drift {
  0% {
    transform: translate(0, 0) scale(1);
  }
  33% {
    transform: translate(8vw, 6vh) scale(1.15);
  }
  66% {
    transform: translate(-6vw, -4vh) scale(0.9);
  }
  100% {
    transform: translate(0, 0) scale(1);
  }
}

.stars {
  position: fixed;
  inset: 0;
  z-index: 1;
  pointer-events: none;
}
.star {
  position: absolute;
  background: var(--star-c, #fff);
  border-radius: 50%;
  opacity: 0.8;
  box-shadow: 0 0 6px var(--star-c, #fff);
  animation: twinkle var(--dur, 4s) ease-in-out infinite;
  animation-delay: var(--delay, 0s);
}
@keyframes twinkle {
  0%,
  100% {
    opacity: 0.15;
    transform: scale(0.6);
  }
  50% {
    opacity: 0.9;
    transform: scale(1.3);
  }
}

/* ================= 咒术场景装饰（登录视图专属） ================= */
.jjk-scene {
  position: fixed;
  inset: 0;
  z-index: 1;
  pointer-events: none;
  overflow: hidden;
}

/* 领域展开法阵 */
.domain {
  position: absolute;
  left: 50%;
  top: 50%;
  width: min(88vmin, 760px);
  height: min(88vmin, 760px);
  transform: translate(-50%, -50%);
  color: rgba(167, 139, 250, 0.34);
  filter: drop-shadow(0 0 18px rgba(123, 47, 247, 0.28));
}
.domain-svg {
  width: 100%;
  height: 100%;
  animation: domainSpin 90s linear infinite;
}
@keyframes domainSpin {
  to {
    transform: rotate(360deg);
  }
}

/* 飘落御札 */
.talisman {
  position: absolute;
  top: -140px;
  width: 26px;
  height: 92px;
  border-radius: 4px;
  background: linear-gradient(180deg, #efe6c8 0%, #e6d9b2 78%, #d9c896 100%);
  box-shadow: 0 0 14px rgba(232, 51, 110, 0.18);
  border: 1px solid rgba(120, 96, 40, 0.35);
  animation: talismanFall var(--fall, 18s) linear infinite;
  animation-delay: var(--fall-delay, 0s);
}
.talisman::before {
  content: '';
  position: absolute;
  top: 4px;
  left: 3px;
  right: 3px;
  height: 14px;
  border-radius: 2px;
  background: linear-gradient(180deg, #c0392b, #e8336e);
  opacity: 0.85;
}
.talisman-char {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  padding-top: 14px;
  font-family: "Songti SC", "SimSun", serif;
  font-size: 16px;
  font-weight: 700;
  color: #3a1d13;
  animation: talismanSway var(--sway, 3s) ease-in-out infinite alternate;
}
@keyframes talismanFall {
  0% {
    top: -140px;
    opacity: 0;
  }
  6% {
    opacity: 0.85;
  }
  94% {
    opacity: 0.85;
  }
  100% {
    top: 108vh;
    opacity: 0;
  }
}
@keyframes talismanSway {
  from {
    transform: rotate(-14deg) translateX(-7px);
  }
  to {
    transform: rotate(14deg) translateX(7px);
  }
}

/* 竖排题字 */
.side-title {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  writing-mode: vertical-rl;
  font-family: "Songti SC", "SimSun", serif;
  font-size: 30px;
  font-weight: 700;
  letter-spacing: 22px;
  color: rgba(196, 181, 253, 0.4);
  text-shadow:
    0 0 18px rgba(123, 47, 247, 0.55),
    0 0 44px rgba(123, 47, 247, 0.3);
  animation: titleBreath 5s ease-in-out infinite;
}
.side-title.left {
  left: clamp(16px, 6vw, 90px);
}
.side-title.right {
  right: clamp(16px, 6vw, 90px);
  font-size: 15px;
  font-family: "Segoe UI", system-ui, sans-serif;
  font-weight: 600;
  letter-spacing: 10px;
  color: rgba(125, 211, 252, 0.35);
  text-shadow: 0 0 16px rgba(56, 217, 255, 0.4);
  text-align: center;
  line-height: 2.4;
}
@keyframes titleBreath {
  0%,
  100% {
    opacity: 0.7;
  }
  50% {
    opacity: 1;
  }
}

/* 两个视图层：登录页整体居中，首页可纵向滚动 */
.login-view {
  position: relative;
  z-index: 2;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  padding: 24px 12px;
}
.home-view {
  position: relative;
  z-index: 2;
  height: 100vh;
  overflow-y: auto;
}
.admin-view {
  position: relative;
  z-index: 2;
  height: 100vh;
  overflow: hidden;
}

/* ===== 移动端适配 ===== */
@media (max-width: 760px) {
  .side-title {
    display: none;
  }
  .domain {
    width: 130vmin;
    height: 130vmin;
    opacity: 0.75;
  }
  /* 注册卡片较高时允许滚动，避免内容被裁切 */
  .login-view {
    align-items: flex-start;
    overflow-y: auto;
  }
}
@media (prefers-reduced-motion: reduce) {
  .domain-svg,
  .talisman,
  .talisman-char,
  .side-title {
    animation: none;
  }
}
</style>
