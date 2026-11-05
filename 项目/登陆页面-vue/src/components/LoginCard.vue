<script setup>
import { nextTick, ref } from 'vue'
import { login } from '../services/auth'

const emit = defineEmits(['switch', 'success'])

const user = ref('')
const pass = ref('')
const showPass = ref(false)
const loading = ref(false)
const msg = ref('')
const msgOk = ref(false)
const shaking = ref(false)
const card = ref(null)

const togglePass = () => {
  showPass.value = !showPass.value
}

const onMove = (e) => {
  const el = card.value
  if (!el) return
  const r = el.getBoundingClientRect()
  const px = (e.clientX - r.left) / r.width - 0.5
  const py = (e.clientY - r.top) / r.height - 0.5
  el.style.transform = `rotateY(${px * 12}deg) rotateX(${-py * 12}deg)`
}
const onLeave = () => {
  if (card.value) card.value.style.transform = ''
}

const flash = (text, ok) => {
  msg.value = text
  msgOk.value = ok
  if (!ok) {
    shaking.value = false
    nextTick(() => {
      shaking.value = true
    })
  } else {
    shaking.value = false
  }
}

const submit = async () => {
  if (loading.value) return
  if (!user.value.trim() || !pass.value) {
    flash('请输入用户名和密码', false)
    return
  }
  loading.value = true
  msg.value = ''
  try {
    const res = await login({ username: user.value.trim(), password: pass.value })
    flash('登录成功，正在跳转…', true)
    // 兼容两种返回结构：真实后端 { code, data:{ user, token } } / 演示模式 { token, user }
    const name = res?.data?.user?.username || res?.user?.name || user.value.trim()
    const token = res?.data?.token || res?.token || 'demo-token'
    // 权限：0 = 管理员权限（可见后台按钮、可登录后台），1 = 默认权限；缺省按默认权限处理
    const permission = res?.data?.user?.permission ?? res?.user?.permission ?? 1
    emit('success', { name, token, permission })
  } catch (e) {
    const text = e.response?.data?.message || '登录失败，请检查网络或账号'
    flash(text, false)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="card-wrap" @mousemove="onMove" @mouseleave="onLeave">
    <div class="card" ref="card" :class="{ shake: shaking }">
      <!-- 四角结界装饰 -->
      <span class="corner tl"></span>
      <span class="corner tr"></span>
      <span class="corner bl"></span>
      <span class="corner br"></span>

      <!-- 咒印徽章 -->
      <div class="emblem">
        <span class="emblem-ring"></span>
        <span class="emblem-ring r2"></span>
        <span class="emblem-core">咒</span>
      </div>

      <h1>欢迎回来</h1>
      <p class="sub">登录你的账户以继续</p>

      <div class="field">
        <svg class="icon" viewBox="0 0 24 24" fill="none">
          <circle cx="12" cy="8" r="3.6" stroke="currentColor" stroke-width="1.8" />
          <path d="M4.5 19.5c1.6-3.4 4.3-5 7.5-5s5.9 1.6 7.5 5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
        </svg>
        <input type="text" id="user" v-model="user" placeholder=" " />
        <label for="user">用户名</label>
      </div>

      <div class="field">
        <svg class="icon" viewBox="0 0 24 24" fill="none">
          <rect x="5" y="10.5" width="14" height="9" rx="2.4" stroke="currentColor" stroke-width="1.8" />
          <path d="M8.2 10.5V8a3.8 3.8 0 0 1 7.6 0v2.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
          <circle cx="12" cy="15" r="1.4" fill="currentColor" />
        </svg>
        <input
          :type="showPass ? 'text' : 'password'"
          id="pass"
          v-model="pass"
          placeholder=" "
        />
        <label for="pass">密码</label>
        <span class="toggle" @click="togglePass">{{ showPass ? '隐藏' : '显示' }}</span>
      </div>

      <div class="row">
        <label><input type="checkbox" /> 记住我</label>
        <a href="#">忘记密码？</a>
      </div>

      <button class="btn" :class="{ loading }" @click="submit">
        <span class="txt">登 录</span>
        <span class="spinner"></span>
      </button>

      <div class="msg" :class="{ show: !!msg, ok: msgOk }">{{ msg }}</div>

      <div class="switch">
        还没有账号？<a href="#" @click.prevent="emit('switch', 'register')">创建账户</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.card-wrap {
  position: relative;
  z-index: 2;
  perspective: 1200px;
}

/* ============ 卡片：结界式暗夜玻璃 ============ */
.card {
  position: relative;
  width: 380px;
  max-width: 92vw;
  padding: 42px 34px 32px;
  background:
    linear-gradient(160deg, rgba(38, 20, 72, 0.82), rgba(13, 7, 28, 0.92));
  border: 1px solid rgba(167, 139, 250, 0.38);
  border-radius: 6px 24px 6px 24px;
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  box-shadow:
    0 30px 90px rgba(0, 0, 0, 0.65),
    0 0 70px rgba(123, 47, 247, 0.22),
    inset 0 1px 0 rgba(255, 255, 255, 0.07);
  transform-style: preserve-3d;
  transition: transform 0.15s ease-out;
  animation: floatIn 0.9s cubic-bezier(0.2, 0.8, 0.2, 1) both;
}
/* 咒力斜纹质感 */
.card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: repeating-linear-gradient(
    -45deg,
    transparent 0 14px,
    rgba(167, 139, 250, 0.035) 14px 15px
  );
  pointer-events: none;
}
@keyframes floatIn {
  from {
    opacity: 0;
    transform: translateY(28px) scale(0.96);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* ============ 四角结界 ============ */
.corner {
  position: absolute;
  width: 22px;
  height: 22px;
  pointer-events: none;
}
.corner.tl {
  top: -3px;
  left: -3px;
  border-top: 2px solid var(--c3);
  border-left: 2px solid var(--c3);
  border-top-left-radius: 8px;
  filter: drop-shadow(0 0 6px rgba(56, 217, 255, 0.7));
}
.corner.tr {
  top: -3px;
  right: -3px;
  border-top: 2px solid var(--c2);
  border-right: 2px solid var(--c2);
  border-top-right-radius: 22px;
  filter: drop-shadow(0 0 6px rgba(232, 51, 110, 0.7));
}
.corner.bl {
  bottom: -3px;
  left: -3px;
  border-bottom: 2px solid var(--c2);
  border-left: 2px solid var(--c2);
  border-bottom-left-radius: 22px;
  filter: drop-shadow(0 0 6px rgba(232, 51, 110, 0.7));
}
.corner.br {
  bottom: -3px;
  right: -3px;
  border-bottom: 2px solid var(--c3);
  border-right: 2px solid var(--c3);
  border-bottom-right-radius: 8px;
  filter: drop-shadow(0 0 6px rgba(56, 217, 255, 0.7));
}

/* ============ 咒印徽章 ============ */
.emblem {
  position: relative;
  width: 86px;
  height: 86px;
  margin: 0 auto 18px;
  display: grid;
  place-items: center;
}
.emblem-core {
  position: relative;
  z-index: 2;
  width: 64px;
  height: 64px;
  display: grid;
  place-items: center;
  font-size: 32px;
  font-weight: 700;
  color: #fff;
  background: linear-gradient(135deg, var(--c1), var(--c2));
  border-radius: 50%;
  box-shadow:
    0 0 24px rgba(123, 47, 247, 0.65),
    inset 0 0 12px rgba(255, 255, 255, 0.25);
  text-shadow: 0 0 10px rgba(255, 255, 255, 0.55);
}
.emblem-ring {
  position: absolute;
  inset: 0;
  border: 1px dashed rgba(167, 139, 250, 0.75);
  border-radius: 50%;
  animation: spinSlow 14s linear infinite;
}
.emblem-ring.r2 {
  inset: -7px;
  border: 1px solid transparent;
  border-top-color: var(--c3);
  border-right-color: var(--c2);
  border-radius: 50%;
  animation: spinSlow 8s linear infinite reverse;
  filter: drop-shadow(0 0 5px rgba(123, 47, 247, 0.6));
}
@keyframes spinSlow {
  to {
    transform: rotate(360deg);
  }
}

/* ============ 标题 ============ */
h1 {
  text-align: center;
  font-size: 24px;
  font-weight: 700;
  letter-spacing: 3px;
  margin-bottom: 6px;
  background: linear-gradient(90deg, #ffffff 10%, #c4b5fd 50%, #f9a8c9 90%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  text-shadow: 0 0 26px rgba(167, 139, 250, 0.35);
}
.sub {
  text-align: center;
  color: var(--muted);
  font-size: 13px;
  letter-spacing: 1px;
  margin-bottom: 26px;
}
.sub::before,
.sub::after {
  content: '◇';
  font-size: 9px;
  color: rgba(167, 139, 250, 0.55);
  margin: 0 8px;
  vertical-align: 2px;
}

/* ============ 输入域 ============ */
.field {
  position: relative;
  margin-bottom: 20px;
}
.field .icon {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  width: 19px;
  height: 19px;
  color: rgba(196, 181, 253, 0.55);
  z-index: 2;
  transition: color 0.25s, filter 0.25s;
}
.field input {
  width: 100%;
  padding: 14px 48px 14px 44px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--line);
  border-radius: 12px;
  color: var(--text);
  font-size: 15px;
  outline: none;
  transition: border-color 0.25s, box-shadow 0.25s, background 0.25s;
}
.field input:focus {
  border-color: rgba(167, 139, 250, 0.85);
  background: rgba(123, 47, 247, 0.08);
  box-shadow:
    0 0 0 3px rgba(123, 47, 247, 0.22),
    0 0 18px rgba(123, 47, 247, 0.25);
}
.field:focus-within .icon {
  color: #c4b5fd;
  filter: drop-shadow(0 0 5px rgba(167, 139, 250, 0.8));
}
.field label {
  position: absolute;
  left: 44px;
  top: 14px;
  color: var(--muted);
  font-size: 15px;
  pointer-events: none;
  transition: all 0.2s ease;
  z-index: 2;
}
.field input:focus + label,
.field input:not(:placeholder-shown) + label {
  top: -9px;
  left: 14px;
  font-size: 12px;
  color: #c4b5fd;
  background: linear-gradient(180deg, #1c1038, #150a2c);
  padding: 0 6px;
  border-radius: 4px;
  text-shadow: 0 0 8px rgba(167, 139, 250, 0.7);
}
.toggle {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
  color: var(--muted);
  user-select: none;
  font-size: 13px;
  transition: color 0.2s;
  z-index: 2;
}
.toggle:hover {
  color: var(--c3);
}

/* ============ 辅助行 ============ */
.row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
  color: var(--muted);
  margin-bottom: 24px;
}
.row label {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
}
.row input[type='checkbox'] {
  accent-color: var(--c1);
}
.row a {
  color: var(--c3);
  text-decoration: none;
}
.row a:hover {
  text-decoration: underline;
  text-shadow: 0 0 10px rgba(56, 217, 255, 0.7);
}

/* ============ 按钮：咒力迸发 ============ */
.btn {
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(135deg, var(--c1), var(--c2));
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 6px;
  text-indent: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: transform 0.15s, box-shadow 0.25s;
  box-shadow: 0 10px 26px rgba(123, 47, 247, 0.45);
}
.btn:hover {
  transform: translateY(-2px);
  box-shadow:
    0 14px 32px rgba(232, 51, 110, 0.5),
    0 0 24px rgba(123, 47, 247, 0.55);
}
.btn:active {
  transform: translateY(0);
}
.btn::after {
  content: '';
  position: absolute;
  top: 0;
  left: -120%;
  width: 60%;
  height: 100%;
  background: linear-gradient(120deg, transparent, rgba(255, 255, 255, 0.5), transparent);
  transform: skewX(-20deg);
  animation: shine 3.2s ease-in-out infinite;
}
@keyframes shine {
  0%,
  60% {
    left: -120%;
  }
  100% {
    left: 140%;
  }
}
.btn .spinner {
  display: none;
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255, 255, 255, 0.4);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  vertical-align: middle;
}
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
.btn.loading .spinner {
  display: inline-block;
}
.btn.loading .txt {
  display: none;
}

/* ============ 抖动 / 提示 ============ */
.shake {
  animation: shake 0.45s;
}
@keyframes shake {
  10%,
  90% {
    transform: translateX(-2px);
  }
  20%,
  80% {
    transform: translateX(4px);
  }
  30%,
  50%,
  70% {
    transform: translateX(-7px);
  }
  40%,
  60% {
    transform: translateX(7px);
  }
}

.msg {
  text-align: center;
  font-size: 13px;
  margin-top: 14px;
  min-height: 18px;
  color: #ff8fb1;
  opacity: 0;
  transition: opacity 0.3s;
}
.msg.show {
  opacity: 1;
}
.msg.ok {
  color: #4fe39a;
}

.switch {
  text-align: center;
  font-size: 13px;
  color: var(--muted);
  margin-top: 18px;
}
.switch a {
  color: var(--c3);
  text-decoration: none;
  font-weight: 600;
}
.switch a:hover {
  text-decoration: underline;
  text-shadow: 0 0 10px rgba(56, 217, 255, 0.7);
}

/* ============ 移动端适配 ============ */
@media (max-width: 520px) {
  .card {
    padding: 34px 22px 26px;
    border-radius: 6px 18px 6px 18px;
  }
  .emblem {
    width: 74px;
    height: 74px;
  }
  .emblem-core {
    width: 54px;
    height: 54px;
    font-size: 26px;
  }
  h1 {
    font-size: 21px;
    letter-spacing: 2px;
  }
  .btn {
    letter-spacing: 4px;
    text-indent: 4px;
  }
}
</style>
