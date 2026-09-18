<script setup>
import { nextTick, ref } from 'vue'
import { login } from '../services/auth'

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
    // 这里可接路由跳转 / 保存 token，例如：
    // localStorage.setItem('token', res.token)
    console.log('登录返回：', res)
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
      <div class="avatar">🔐</div>
      <h1>欢迎回来</h1>
      <p class="sub">登录你的账户以继续</p>

      <div class="field">
        <input type="text" id="user" v-model="user" placeholder=" " />
        <label for="user">用户名 / 邮箱</label>
      </div>

      <div class="field">
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

      <div class="divider">或使用以下方式</div>
      <div class="social">
        <button type="button">微信</button>
        <button type="button">GitHub</button>
        <button type="button">Google</button>
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
.card {
  width: 360px;
  max-width: 90vw;
  padding: 40px 34px 34px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 22px;
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  box-shadow: 0 24px 60px rgba(0, 0, 0, 0.45);
  transform-style: preserve-3d;
  transition: transform 0.15s ease-out;
  animation: floatIn 0.9s cubic-bezier(0.2, 0.8, 0.2, 1) both;
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

.avatar {
  width: 72px;
  height: 72px;
  margin: 0 auto 18px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--c1), var(--c2));
  display: grid;
  place-items: center;
  font-size: 34px;
  box-shadow: 0 8px 22px rgba(106, 92, 255, 0.5);
  animation: pulse 2.6s ease-in-out infinite;
}
@keyframes pulse {
  0%,
  100% {
    box-shadow: 0 8px 22px rgba(106, 92, 255, 0.5);
  }
  50% {
    box-shadow: 0 8px 34px rgba(255, 92, 168, 0.7);
  }
}

h1 {
  text-align: center;
  font-size: 22px;
  font-weight: 600;
  margin-bottom: 4px;
}
.sub {
  text-align: center;
  color: var(--muted);
  font-size: 13px;
  margin-bottom: 26px;
}

.field {
  position: relative;
  margin-bottom: 20px;
}
.field input {
  width: 100%;
  padding: 14px 44px 14px 16px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--line);
  border-radius: 12px;
  color: var(--text);
  font-size: 15px;
  outline: none;
  transition: border-color 0.25s, box-shadow 0.25s, background 0.25s;
}
.field input:focus {
  border-color: var(--c3);
  background: rgba(255, 255, 255, 0.1);
  box-shadow: 0 0 0 3px rgba(42, 209, 255, 0.18);
}
.field label {
  position: absolute;
  left: 16px;
  top: 14px;
  color: var(--muted);
  font-size: 15px;
  pointer-events: none;
  transition: all 0.2s ease;
}
.field input:focus + label,
.field input:not(:placeholder-shown) + label {
  top: -9px;
  left: 12px;
  font-size: 12px;
  color: var(--c3);
  background: var(--bg);
  padding: 0 6px;
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
}
.toggle:hover {
  color: var(--text);
}

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
.row a {
  color: var(--c3);
  text-decoration: none;
}
.row a:hover {
  text-decoration: underline;
}

.btn {
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(135deg, var(--c1), var(--c2));
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: transform 0.15s, box-shadow 0.25s;
  box-shadow: 0 10px 24px rgba(106, 92, 255, 0.4);
}
.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 14px 30px rgba(255, 92, 168, 0.5);
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
  background: linear-gradient(
    120deg,
    transparent,
    rgba(255, 255, 255, 0.45),
    transparent
  );
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
  color: var(--c2);
  opacity: 0;
  transition: opacity 0.3s;
}
.msg.show {
  opacity: 1;
}
.msg.ok {
  color: #4fe39a;
}

.divider {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--muted);
  font-size: 12px;
  margin: 22px 0 16px;
}
.divider::before,
.divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--line);
}
.social {
  display: flex;
  gap: 12px;
  justify-content: center;
}
.social button {
  flex: 1;
  padding: 10px;
  border: 1px solid var(--line);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.05);
  color: var(--text);
  cursor: pointer;
  font-size: 13px;
  transition: background 0.2s, transform 0.15s;
}
.social button:hover {
  background: rgba(255, 255, 255, 0.12);
  transform: translateY(-2px);
}
</style>
