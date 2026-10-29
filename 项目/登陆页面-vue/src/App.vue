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

onMounted(() => {
  const arr = []
  for (let i = 0; i < 60; i++) {
    arr.push({
      left: Math.random() * 100 + 'vw',
      top: Math.random() * 100 + 'vh',
      dur: 3 + Math.random() * 4 + 's',
      delay: Math.random() * 4 + 's',
      size: 1 + Math.random() * 2.5 + 'px'
    })
  }
  stars.value = arr

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

  <!-- 动态背景：闪烁星点 -->
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
        width: s.size,
        height: s.size
      }"
    ></span>
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
  background: #fff;
  border-radius: 50%;
  opacity: 0.8;
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

/* 两个视图层：登录页整体居中，首页可纵向滚动 */
.login-view {
  position: relative;
  z-index: 2;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
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
</style>
