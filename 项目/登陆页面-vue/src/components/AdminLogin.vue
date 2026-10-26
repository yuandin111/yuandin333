<script setup>
import { ref } from 'vue'
import { adminLogin } from '../services/auth.js'

const emit = defineEmits(['success', 'back'])

const user = ref('')
const pass = ref('')
const showPass = ref(false)
const loading = ref(false)
const msg = ref('')
const msgOk = ref(false)

const flash = (text, ok) => {
  msg.value = text
  msgOk.value = ok
}

const submit = async () => {
  if (loading.value) return
  if (!user.value.trim() || !pass.value) {
    flash('请输入管理员账号和密码', false)
    return
  }
  loading.value = true
  msg.value = ''
  try {
    const data = await adminLogin({ username: user.value.trim(), password: pass.value })
    flash('验证通过，正在进入后台…', true)
    const name = data?.user?.username || user.value.trim()
    setTimeout(() => emit('success', { name, token: data.token }), 500)
  } catch (e) {
    flash(e.response?.data?.message || e.message || '登录失败，请检查网络或账号', false)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="admin-login">
    <div class="card">
      <div class="shield">🛡️</div>
      <h1 class="title">后台管理系统</h1>
      <p class="sub">咒术回战资料站 · 内容管理后台，仅限管理员</p>

      <label class="field">
        <span class="label">管理员账号</span>
        <input v-model="user" type="text" placeholder="请输入管理员账号" @keyup.enter="submit" />
      </label>

      <label class="field">
        <span class="label">密码</span>
        <div class="pass-wrap">
          <input
            v-model="pass"
            :type="showPass ? 'text' : 'password'"
            placeholder="请输入密码"
            @keyup.enter="submit"
          />
          <button type="button" class="eye" @click="showPass = !showPass">
            {{ showPass ? '🙈' : '👁️' }}
          </button>
        </div>
      </label>

      <p v-if="msg" class="msg" :class="{ ok: msgOk }">{{ msg }}</p>

      <button class="submit" :class="{ loading }" @click="submit">
        <span v-if="!loading">进入后台</span>
        <span v-else class="spinner"></span>
      </button>

      <button class="back" @click="emit('back')">← 返回首页</button>
    </div>
  </div>
</template>

<style scoped>
.admin-login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}
.card {
  width: 380px;
  max-width: 92vw;
  padding: 40px 34px 30px;
  text-align: center;
  background: rgba(20, 24, 58, 0.85);
  border: 1px solid rgba(42, 209, 255, 0.28);
  border-radius: 20px;
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.55), 0 0 40px rgba(42, 209, 255, 0.12);
  animation: popIn 0.35s cubic-bezier(0.2, 0.8, 0.2, 1);
}
@keyframes popIn {
  from { opacity: 0; transform: translateY(16px) scale(0.97); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}
.shield {
  font-size: 40px;
  margin-bottom: 10px;
  filter: drop-shadow(0 0 12px rgba(42, 209, 255, 0.6));
}
.title {
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 2px;
  background: linear-gradient(90deg, var(--c3), #ffffff);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}
.sub {
  font-size: 12px;
  color: var(--muted);
  margin: 10px 0 28px;
}
.field {
  display: block;
  text-align: left;
  margin-bottom: 16px;
}
.label {
  display: block;
  font-size: 12px;
  color: var(--muted);
  margin-bottom: 6px;
}
.field input {
  width: 100%;
  padding: 12px 14px;
  font-size: 14px;
  color: var(--text);
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--line);
  border-radius: 10px;
  outline: none;
  transition: border-color 0.25s, box-shadow 0.25s;
}
.field input:focus {
  border-color: rgba(42, 209, 255, 0.6);
  box-shadow: 0 0 0 3px rgba(42, 209, 255, 0.12);
}
.field input::placeholder {
  color: var(--muted);
}
.pass-wrap {
  position: relative;
}
.pass-wrap input {
  padding-right: 44px;
}
.eye {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 15px;
  opacity: 0.7;
}
.eye:hover {
  opacity: 1;
}
.msg {
  font-size: 12px;
  color: #ff8fb1;
  min-height: 16px;
  margin: 4px 0 12px;
}
.msg.ok {
  color: #4ade80;
}
.submit {
  display: grid;
  place-items: center;
  width: 100%;
  height: 46px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 4px;
  color: #fff;
  background: linear-gradient(135deg, var(--c1), var(--c3));
  box-shadow: 0 8px 20px rgba(42, 209, 255, 0.35);
  transition: transform 0.2s, box-shadow 0.25s;
}
.submit:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 28px rgba(42, 209, 255, 0.55);
}
.submit.loading {
  opacity: 0.8;
  cursor: wait;
}
.spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255, 255, 255, 0.4);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}
.back {
  margin-top: 18px;
  border: none;
  background: transparent;
  color: var(--muted);
  font-size: 13px;
  cursor: pointer;
  transition: color 0.2s;
}
.back:hover {
  color: var(--c3);
}
</style>
