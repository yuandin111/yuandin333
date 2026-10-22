<script setup>
import { nextTick, onMounted, ref } from 'vue'
import { fetchCaptcha, register } from '../services/auth'

const emit = defineEmits(['switch'])

const user = ref('')
const code = ref('')
const pass = ref('')
const confirm = ref('')
const agree = ref(false)
const showPass = ref(false)
const showConfirm = ref(false)
const captchaId = ref('') // 当前验证码 id，提交时一起带上
const captchaImg = ref('') // 验证码图片（base64）
const captchaLoading = ref(false)
const loading = ref(false)
const msg = ref('')
const msgOk = ref(false)
const shaking = ref(false)
const card = ref(null)

const togglePass = () => {
  showPass.value = !showPass.value
}
const toggleConfirm = () => {
  showConfirm.value = !showConfirm.value
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

// 加载 / 刷新图形验证码
const loadCaptcha = async () => {
  if (captchaLoading.value) return
  captchaLoading.value = true
  code.value = ''
  try {
    const res = await fetchCaptcha()
    captchaId.value = res?.captchaId || ''
    captchaImg.value = res?.image || ''
  } catch (e) {
    captchaId.value = ''
    captchaImg.value = ''
    flash('验证码加载失败，请点击图片重试', false)
  } finally {
    captchaLoading.value = false
  }
}

onMounted(loadCaptcha)

const submit = async () => {
  if (loading.value) return
  if (!user.value.trim()) {
    flash('请输入用户名', false)
    return
  }
  if (!/^[a-zA-Z0-9]{4}$/.test(code.value.trim())) {
    flash('请输入图片上的 4 位验证码', false)
    return
  }
  if (pass.value.length < 6) {
    flash('密码至少 6 位', false)
    return
  }
  if (pass.value !== confirm.value) {
    flash('两次输入的密码不一致', false)
    return
  }
  if (!agree.value) {
    flash('请先同意服务条款', false)
    return
  }

  loading.value = true
  msg.value = ''
  try {
    const res = await register({
      username: user.value.trim(),
      captchaId: captchaId.value,
      code: code.value.trim(),
      password: pass.value
    })
    flash('注册成功，正在前往登录…', true)
    console.log('注册返回：', res)
    setTimeout(() => emit('switch', 'login'), 1600)
  } catch (e) {
    const text = e.response?.data?.message || '注册失败，请稍后重试'
    flash(text, false)
    loadCaptcha() // 验证码一次性使用，失败后自动换一张
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="card-wrap" @mousemove="onMove" @mouseleave="onLeave">
    <div class="card" ref="card" :class="{ shake: shaking }">
      <div class="avatar">✨</div>
      <h1>创建账户</h1>
      <p class="sub">注册一个新账户开始使用</p>

      <div class="field">
        <input type="text" id="ruser" v-model="user" placeholder=" " />
        <label for="ruser">用户名</label>
      </div>

      <div class="field captcha-field">
        <input
          type="text"
          id="rcode"
          v-model="code"
          maxlength="4"
          autocomplete="off"
          placeholder=" "
        />
        <label for="rcode">验证码</label>
        <img
          v-if="captchaImg"
          class="captcha-img"
          :src="captchaImg"
          alt="图形验证码"
          title="看不清？点击换一张"
          @click="loadCaptcha"
        />
        <span v-else class="captcha-img captcha-placeholder" @click="loadCaptcha">
          {{ captchaLoading ? '加载中' : '点击获取' }}
        </span>
      </div>

      <div class="field">
        <input
          :type="showPass ? 'text' : 'password'"
          id="rpass"
          v-model="pass"
          placeholder=" "
        />
        <label for="rpass">密码（至少 6 位）</label>
        <span class="toggle" @click="togglePass">{{ showPass ? '隐藏' : '显示' }}</span>
      </div>

      <div class="field">
        <input
          :type="showConfirm ? 'text' : 'password'"
          id="rconfirm"
          v-model="confirm"
          placeholder=" "
        />
        <label for="rconfirm">确认密码</label>
        <span class="toggle" @click="toggleConfirm">{{ showConfirm ? '隐藏' : '显示' }}</span>
      </div>

      <div class="row">
        <label><input type="checkbox" v-model="agree" /> 我已阅读并同意服务条款</label>
      </div>

      <button class="btn" :class="{ loading }" @click="submit">
        <span class="txt">注 册</span>
        <span class="spinner"></span>
      </button>

      <div class="msg" :class="{ show: !!msg, ok: msgOk }">{{ msg }}</div>

      <div class="switch">
        已有账号？<a href="#" @click.prevent="emit('switch', 'login')">返回登录</a>
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
  width: 380px;
  max-width: 92vw;
  padding: 36px 34px 30px;
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
  margin-bottom: 24px;
}

.field {
  position: relative;
  margin-bottom: 16px;
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

/* 验证码输入框 + 验证码图片 */
.captcha-field input {
  padding-right: 118px;
}
.captcha-img {
  position: absolute;
  right: 6px;
  top: 50%;
  transform: translateY(-50%);
  width: 100px;
  height: 34px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
  cursor: pointer;
  user-select: none;
  transition: box-shadow 0.2s, border-color 0.2s;
}
.captcha-img:hover {
  border-color: var(--c3);
  box-shadow: 0 0 0 3px rgba(42, 209, 255, 0.18);
}
.captcha-placeholder {
  display: grid;
  place-items: center;
  font-size: 12px;
  color: var(--muted);
}

.row {
  display: flex;
  align-items: center;
  font-size: 13px;
  color: var(--muted);
  margin-bottom: 22px;
}
.row label {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
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
}
</style>
