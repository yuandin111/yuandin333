<script setup>
import { computed, onBeforeUnmount, ref } from 'vue'

// 咒力祈愿：纯前端演示卡池，不依赖后端接口、不写入数据库
const pool = [
  { name: '五条悟', icon: '😎', rarity: 'SSR', title: '现代最强 · 六眼', desc: '无下限术式 / 领域「无量空处」' },
  { name: '两面宿傩', icon: '👑', rarity: 'SSR', title: '诅咒之王', desc: '解 · 捌 / 领域「伏魔御厨子」' },
  { name: '乙骨忧太', icon: '🗡️', rarity: 'SSR', title: '特级术师', desc: '复制术式 · 里香' },
  { name: '伏黑甚尔', icon: '🔪', rarity: 'SSR', title: '术师杀手', desc: '天与咒缚 · 咒具运用' },
  { name: '虎杖悠仁', icon: '👊', rarity: 'SR', title: '东京校一年级', desc: '超人体质 · 宿傩容器' },
  { name: '伏黑惠', icon: '🐕', rarity: 'SR', title: '东京校一年级', desc: '十种影法术' },
  { name: '钉崎野蔷薇', icon: '🔨', rarity: 'SR', title: '东京校一年级', desc: '共鸣 · 锤与钉' },
  { name: '七海建人', icon: '☕', rarity: 'SR', title: '一级术师', desc: '十划经 · 七三' },
  { name: '夏油杰', icon: '🌑', rarity: 'SR', title: '前特级术师', desc: '咒灵操术 · 百鬼夜行' },
  { name: '东堂葵', icon: '💪', rarity: 'SR', title: '京都校三年级', desc: '不义游戏' },
  { name: '禅院真希', icon: '⚔️', rarity: 'R', title: '东京校二年级', desc: '天与咒缚 · 游云' },
  { name: '狗卷棘', icon: '🍙', rarity: 'R', title: '东京校二年级', desc: '咒言' },
  { name: '熊猫', icon: '🐼', rarity: 'R', title: '东京校二年级', desc: '自主思考咒骸' },
  { name: '家入硝子', icon: '💊', rarity: 'R', title: '高专校医', desc: '反转术式' },
  { name: '真人', icon: '🎭', rarity: 'R', title: '特级咒灵', desc: '无为转变' },
  { name: '漏瑚', icon: '🌋', rarity: 'R', title: '特级咒灵', desc: '领域「盖棺铁围山」' }
]

const total = ref(0)
const pity = ref(0) // 距上次 SSR 已抽次数，第 10 抽必出 SSR
const ssrCount = ref(0)
const results = ref([])
const history = ref([])
const drawing = ref(false)
const showHistory = ref(false)
let timer = null

const pityLeft = computed(() => Math.max(0, 10 - pity.value))
const bestRarity = computed(() => {
  if (results.value.some(c => c.rarity === 'SSR')) return 'SSR'
  if (results.value.some(c => c.rarity === 'SR')) return 'SR'
  return ''
})

const pickOne = (guaranteeSR = false) => {
  let rarity
  if (pity.value >= 9) {
    rarity = 'SSR'
  } else {
    const x = Math.random()
    rarity = x < 0.03 ? 'SSR' : x < 0.2 ? 'SR' : 'R'
    if (guaranteeSR && rarity === 'R') rarity = 'SR' // 十连最后一抽保底 SR 以上
  }
  const list = pool.filter(c => c.rarity === rarity)
  const picked = list[Math.floor(Math.random() * list.length)]
  pity.value = rarity === 'SSR' ? 0 : pity.value + 1
  total.value++
  if (rarity === 'SSR') ssrCount.value++
  return { ...picked, key: `${total.value}-${Math.random().toString(36).slice(2)}` }
}

const draw = (n) => {
  if (drawing.value) return
  drawing.value = true
  showHistory.value = false
  results.value = []
  clearTimeout(timer)
  timer = setTimeout(() => {
    const out = []
    for (let i = 0; i < n; i++) out.push(pickOne(n === 10 && i === 9))
    results.value = out
    history.value = [...out].reverse().concat(history.value).slice(0, 24)
    drawing.value = false
  }, 700)
}

onBeforeUnmount(() => clearTimeout(timer))
</script>

<template>
  <div class="gacha-body">
    <div class="meta">
      <span>累计 <b>{{ total }}</b> 抽</span>
      <span>SSR <b>{{ ssrCount }}</b></span>
      <span>保底还剩 <b>{{ pityLeft }}</b> 抽</span>
    </div>

    <div class="stage" aria-live="polite">
      <div v-if="drawing" class="summon">
        <div class="sigil">✦</div>
        <p>咒力汇聚中…</p>
      </div>

      <div v-else-if="!results.length" class="idle">
        <div class="idle-mark">呪</div>
        <p>御札已备妥，点击下方按钮开始祈愿</p>
        <span>SSR 3% · SR 17% · 十连必出 SR 以上 · 10 抽内必出 SSR</span>
      </div>

      <div v-else class="result">
        <p v-if="bestRarity" class="result-tip" :class="'tip-' + bestRarity.toLowerCase()">
          {{ bestRarity === 'SSR' ? '✦ 特级咒力降临 ✦' : '✧ 获得 SR 以上术师 ✧' }}
        </p>
        <div class="cards" :class="{ single: results.length === 1 }">
          <div
            v-for="(c, i) in results"
            :key="c.key"
            class="card"
            :class="'r-' + c.rarity.toLowerCase()"
            :style="{ animationDelay: i * 55 + 'ms' }"
          >
            <span class="rarity">{{ c.rarity }}</span>
            <span class="icon">{{ c.icon }}</span>
            <b class="name">{{ c.name }}</b>
            <span class="title">{{ c.title }}</span>
            <span class="desc">{{ c.desc }}</span>
          </div>
        </div>
      </div>
    </div>

    <div class="actions">
      <button class="g-btn" :disabled="drawing" @click="draw(1)">✦ 单次祈愿</button>
      <button class="g-btn primary" :disabled="drawing" @click="draw(10)">
        ✧ 十连祈愿 <small>必出 SR 以上</small>
      </button>
      <button class="g-btn ghost" @click="showHistory = !showHistory">
        祈愿记录 <small v-if="history.length">({{ history.length }})</small>
      </button>
    </div>

    <div v-if="showHistory" class="history">
      <template v-if="history.length">
        <div v-for="(h, i) in history" :key="h.key + i" class="h-row">
          <span class="h-rarity" :class="'r-text-' + h.rarity.toLowerCase()">{{ h.rarity }}</span>
          <span class="h-icon">{{ h.icon }}</span>
          <span class="h-name">{{ h.name }}</span>
          <span class="h-title">{{ h.title }}</span>
        </div>
        </template>
        <p v-else class="h-empty">还没有祈愿记录</p>
      </div>

    <p class="note">※ 本模块为前端演示，结果仅保存在当前页面，刷新即重置，不会写入数据库。</p>
  </div>
</template>

<style scoped>
/* 组件只负责功能面板：标题与容器视觉由首页的「独立专区」提供 */
.gacha-body {
  position: relative;
}

.meta {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px 14px;
  flex-wrap: wrap;
  margin-bottom: 20px;
  font-size: 12px;
  color: var(--muted);
}
.meta span {
  padding: 6px 14px;
  border: 1px solid var(--line);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.04);
}

.meta b {
  color: var(--c3);
  font-size: 15px;
  margin: 0 2px;
}

.stage {
  margin-top: 0;
  min-height: 190px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px dashed rgba(167, 139, 250, 0.28);
  border-radius: 14px;
  background: rgba(8, 5, 20, 0.45);
  padding: 20px;
}

.idle,
.summon {
  text-align: center;
  color: var(--muted);
  font-size: 13px;
}

.idle-mark {
  font-size: 46px;
  line-height: 1;
  margin-bottom: 12px;
  color: rgba(167, 139, 250, 0.65);
  text-shadow: 0 0 24px rgba(123, 47, 247, 0.7);
}

.idle span {
  display: block;
  margin-top: 10px;
  font-size: 11px;
  opacity: 0.7;
}

.sigil {
  font-size: 52px;
  color: var(--c3);
  animation: spin 1.1s linear infinite;
  text-shadow: 0 0 28px rgba(56, 217, 255, 0.8);
}

.summon p {
  margin-top: 12px;
  letter-spacing: 3px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.result {
  width: 100%;
}

.result-tip {
  text-align: center;
  font-size: 12px;
  letter-spacing: 3px;
  margin-bottom: 14px;
  color: var(--c3);
}

.tip-ssr {
  color: #ffd77a;
  text-shadow: 0 0 16px rgba(255, 190, 80, 0.7);
}

.cards {
  display: grid;
  /* 十连固定 5 列 = 两行满排，避免 7+3 这种残缺排布 */
  grid-template-columns: repeat(5, minmax(0, 1fr));
  justify-content: center;
  gap: 10px;
}
/* 单抽时不要被拉成一整行，居中显示一张 */
.cards.single {
  grid-template-columns: minmax(0, 180px);
  justify-content: center;
}

.card {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 4px;
  padding: 14px 8px 12px;
  border-radius: 12px;
  border: 1px solid rgba(167, 139, 250, 0.28);
  background: rgba(26, 15, 52, 0.85);
  animation: pop 0.42s ease both;
}

@keyframes pop {
  from { opacity: 0; transform: translateY(14px) scale(0.92); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.card.r-ssr {
  border-color: rgba(255, 196, 90, 0.75);
  background: linear-gradient(160deg, rgba(120, 60, 20, 0.5), rgba(26, 15, 52, 0.9));
  box-shadow: 0 0 22px rgba(255, 180, 70, 0.28), inset 0 0 18px rgba(255, 190, 80, 0.1);
}

.card.r-sr {
  border-color: rgba(167, 139, 250, 0.7);
  box-shadow: 0 0 16px rgba(123, 47, 247, 0.25);
}

.rarity {
  position: absolute;
  top: 6px;
  right: 8px;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 1px;
  color: var(--muted);
}

.r-ssr .rarity { color: #ffd77a; }
.r-sr .rarity { color: #c4b5fd; }

.icon {
  font-size: 32px;
  line-height: 1.2;
}

.name {
  font-size: 13px;
  color: var(--text);
}

.title {
  font-size: 10px;
  color: var(--c3);
}

.desc {
  font-size: 10px;
  color: var(--muted);
  line-height: 1.4;
}

.actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
  margin-top: 18px;
}

.g-btn {
  padding: 10px 22px;
  border-radius: 999px;
  border: 1px solid var(--line);
  background: rgba(255, 255, 255, 0.05);
  color: var(--text);
  font-size: 13px;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s, opacity 0.2s;
}

.g-btn small {
  font-size: 10px;
  opacity: 0.65;
  margin-left: 4px;
}

.g-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  border-color: rgba(56, 217, 255, 0.6);
  box-shadow: 0 0 16px rgba(56, 217, 255, 0.22);
}

.g-btn.primary {
  border-color: transparent;
  background: linear-gradient(90deg, var(--c1), var(--c2));
  font-weight: 600;
}

.g-btn.primary:hover:not(:disabled) {
  box-shadow: 0 0 22px rgba(232, 51, 110, 0.45);
}

.g-btn.ghost {
  background: transparent;
  color: var(--muted);
}

.g-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}
/* 键盘聚焦时给明确的焦点环 */
.g-btn:focus-visible {
  outline: 2px solid var(--c3);
  outline-offset: 3px;
}

.history {
  margin-top: 18px;
  max-height: 170px;
  overflow-y: auto;
  border-top: 1px solid var(--line);
  padding-top: 10px;
}

.h-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 5px 8px;
  font-size: 11px;
  color: var(--muted);
  border-bottom: 1px solid rgba(167, 139, 250, 0.1);
}

.h-rarity {
  width: 30px;
  font-weight: 700;
}

.r-text-ssr { color: #ffd77a; }
.r-text-sr { color: #c4b5fd; }
.r-text-r { color: var(--muted); }

.h-icon { font-size: 15px; }
.h-name { color: var(--text); min-width: 80px; }
.h-title { opacity: 0.7; }
.h-empty { text-align: center; font-size: 12px; color: var(--muted); padding: 12px; }

.note {
  margin-top: 14px;
  text-align: center;
  font-size: 10px;
  color: var(--muted);
  opacity: 0.7;
}

@media (max-width: 640px) {
  .cards { grid-template-columns: repeat(3, minmax(0, 1fr)); }
  .cards.single { grid-template-columns: minmax(0, 140px); }
  .stage { padding: 16px 12px; }
  .actions { gap: 8px; }
  .g-btn { padding: 9px 16px; font-size: 12px; }
  .meta { gap: 8px; }
  .meta span { padding: 5px 11px; }
}
/* 超窄屏（320~360）：两列保证卡面文字不碎行 */
@media (max-width: 360px) {
  .cards { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .g-btn { padding: 9px 12px; }
}
/* 窄屏按钮挤到贴边时，收起按钮内小字（保底说明舞台内已有） */
@media (max-width: 430px) {
  .g-btn { padding: 9px 13px; }
  .g-btn small { display: none; }
}
</style>
