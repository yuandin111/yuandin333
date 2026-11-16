<script setup>
// 自走棋 · 试玩版（一关）
// 规则：从「我的仓库」（祈愿抽到的卡）或借用试玩术师中上阵最多 4 人，
//       自动回合制讨伐「特级咒灵」。稀有度=战力，凑齐羁绊有加成，通关得咒力。
// 存档走 gameStore（localStorage），与祈愿共享咒力和角色仓库。
import { ref, computed, onBeforeUnmount } from 'vue'
import {
  getEnergy, getRoster, getSave, addEnergy,
  recordBattle, isFirstClearDone, markFirstClearDone
} from '../services/gameStore.js'

const emit = defineEmits(['go-gacha'])

// ---------- 基础数值 ----------
const RARITY = {
  SSR: { hp: 280, atk: 48, crit: 0.25 },
  SR: { hp: 200, atk: 33, crit: 0.18 },
  R: { hp: 150, atk: 23, crit: 0.12 }
}
const SKILL = {
  '五条悟': '无量空处', '两面宿傩': '伏魔御厨子', '乙骨忧太': '复制术式·里香',
  '伏黑甚尔': '天与咒缚', '虎杖悠仁': '超人体质', '伏黑惠': '十种影法术',
  '钉崎野蔷薇': '共鸣·锤与钉', '七海建人': '十划经·七三', '夏油杰': '百鬼夜行',
  '东堂葵': '不义游戏', '禅院真希': '天与咒缚·游云', '狗卷棘': '咒言',
  '熊猫': '咒骸形态', '家入硝子': '反转术式', '真人': '无为转变', '漏瑚': '盖棺铁围山'
}

// 借用试玩术师：仓库没角色也能玩，借用不消耗仓库、不计入收集
const TRIAL = [
  { name: '虎杖悠仁', icon: '👊', rarity: 'SR' },
  { name: '伏黑惠', icon: '🐕', rarity: 'SR' },
  { name: '钉崎野蔷薇', icon: '🔨', rarity: 'SR' },
  { name: '七海建人', icon: '☕', rarity: 'SR' }
]

// 唯一关卡的敌方阵容
const ENEMY_TEAM = [
  { name: '漏瑚', icon: '🌋', hp: 360, atk: 30, skill: '盖棺铁围山' },
  { name: '真人', icon: '🎭', hp: 320, atk: 28, skill: '无为转变' },
  { name: '咒骸', icon: '🗿', hp: 160, atk: 15, skill: '—' }
]

// ---------- 存档状态 ----------
const roster = ref(getRoster())
const energy = ref(getEnergy())
const save = ref(getSave())
const firstDone = ref(isFirstClearDone())
const refresh = () => {
  roster.value = getRoster()
  energy.value = getEnergy()
  save.value = getSave()
  firstDone.value = isFirstClearDone()
}

// ---------- 上阵 ----------
const lineup = ref([]) // [{ name, icon, rarity, from }]
const MAX = 4
const tip = ref('')

const addToLineup = (u) => {
  if (battle.value.running) return
  if (lineup.value.length >= MAX) { tip.value = '最多上阵 4 名术师'; return }
  if (lineup.value.some(x => x.name === u.name)) { tip.value = `${u.name} 已在上阵中`; return }
  lineup.value.push({ name: u.name, icon: u.icon, rarity: u.rarity, from: u.from })
  tip.value = ''
}
const removeFromLineup = (i) => {
  if (battle.value.running) return
  lineup.value.splice(i, 1)
}

// ---------- 羁绊 ----------
const bonds = computed(() => {
  const names = new Set(lineup.value.map(u => u.name))
  const has = (...ns) => ns.every(n => names.has(n))
  const out = []
  if (has('虎杖悠仁', '伏黑惠', '钉崎野蔷薇'))
    out.push({ name: '一年级三人组', desc: '全队攻击 +20%', atk: 0.20 })
  if (has('五条悟', '乙骨忧太'))
    out.push({ name: '现代最强', desc: '全队攻击 +30%', atk: 0.30 })
  if (has('真人', '漏瑚'))
    out.push({ name: '特级咒灵', desc: '全队生命 +25%', hp: 0.25 })
  if (has('伏黑甚尔', '禅院真希', '钉崎野蔷薇'))
    out.push({ name: '咒具专精', desc: '暴击率 +25%', crit: 0.25 })
  return out
})
const buffs = computed(() => ({
  atk: bonds.value.reduce((s, b) => s + (b.atk || 0), 0),
  hp: bonds.value.reduce((s, b) => s + (b.hp || 0), 0),
  crit: bonds.value.reduce((s, b) => s + (b.crit || 0), 0)
}))

// ---------- 战斗 ----------
const battle = ref({
  phase: 'idle', // idle | fighting | win | lose
  allies: [], enemies: [], logs: [], round: 0
})

let timer = null
const uid = (p) => `${p}-${Math.random().toString(36).slice(2, 8)}`
const pushLog = (text) => { battle.value.logs.push(text) }
const rnd = (a, b) => a + Math.random() * (b - a)

const startBattle = () => {
  if (battle.value.phase === 'fighting') return
  if (!lineup.value.length) { tip.value = '请先在下方上阵至少 1 名术师'; return }
  tip.value = ''

  const bf = buffs.value
  const allies = lineup.value.map(u => {
    const base = RARITY[u.rarity] || RARITY.R
    const hp = Math.round(base.hp * (1 + bf.hp))
    return {
      uid: uid('a'), name: u.name, icon: u.icon, rarity: u.rarity,
      skill: SKILL[u.name] || '术式', side: 'ally',
      atk: Math.round(base.atk * (1 + bf.atk)), crit: Math.min(0.9, base.crit + bf.crit),
      hp, maxHp: hp, alive: true
    }
  })
  const enemies = ENEMY_TEAM.map(e => ({
    uid: uid('e'), name: e.name, icon: e.icon, skill: e.skill, side: 'enemy',
    atk: e.atk, crit: 0.12, hp: e.hp, maxHp: e.hp, alive: true
  }))

  battle.value = { phase: 'fighting', allies, enemies, logs: [], round: 0 }
  pushLog('⚔️ 战斗开始：渋谷 · 特级咒灵讨伐')
  if (bonds.value.length) pushLog(`🔗 羁绊生效：${bonds.value.map(b => b.name).join(' / ')}`)
  nextRound()
}

const aliveUnits = (arr) => arr.filter(u => u.alive)

function nextRound() {
  if (battle.value.phase !== 'fighting') return
  // 每轮重新编队：存活我方先手，再敌方
  const queue = [...aliveUnits(battle.value.allies), ...aliveUnits(battle.value.enemies)]
  battle.value.round += 1
  pushLog(`—— 第 ${battle.value.round} 回合 ——`)
  let i = 0
  const step = () => {
    if (battle.value.phase !== 'fighting') return
    if (i >= queue.length) {
      // 判断胜负
      if (!aliveUnits(battle.value.enemies).length) return finish(true)
      if (!aliveUnits(battle.value.allies).length) return finish(false)
      timer = setTimeout(nextRound, 420)
      return
    }
    const actor = queue[i++]
    if (actor.alive) takeAction(actor)
    // 每次行动后立刻检查，避免已倒下单位继续行动
    if (!aliveUnits(battle.value.enemies).length) return finish(true)
    if (!aliveUnits(battle.value.allies).length) return finish(false)
    timer = setTimeout(step, 520)
  }
  step()
}

function takeAction(actor) {
  const foes = actor.side === 'ally' ? battle.value.enemies : battle.value.allies
  const targets = aliveUnits(foes)
  if (!targets.length) return
  const target = targets[Math.floor(Math.random() * targets.length)]
  const crit = Math.random() < actor.crit
  const base = actor.atk * rnd(0.9, 1.12)
  const dmg = Math.round(base * (crit ? 1.7 : 1))
  target.hp = Math.max(0, target.hp - dmg)
  if (target.hp === 0) target.alive = false
  const who = `${actor.icon}${actor.name}`
  const whom = `${target.icon}${target.name}`
  let line = crit
    ? `${who} 发动「${actor.skill}」暴击 → ${whom} -${dmg} 💥`
    : `${who} → ${whom} -${dmg}`
  if (target.hp === 0) line += ' ☠️倒下'
  pushLog(line)
}

function finish(win) {
  clearTimeout(timer)
  battle.value.phase = win ? 'win' : 'lose'
  const first = win && !firstDone.value
  const reward = win ? (first ? 1500 : 400) : 100
  addEnergy(reward)
  recordBattle(win)
  if (first) markFirstClearDone()
  pushLog(win
    ? `🎉 讨伐成功！${first ? '（首通）' : ''}获得 ${reward} 咒力`
    : `💀 讨伐失败，获得 ${reward} 咒力安慰，调整阵容再来`)
  refresh()
}

const resetBattle = () => {
  clearTimeout(timer)
  battle.value = { phase: 'idle', allies: [], enemies: [], logs: [], round: 0 }
}

onBeforeUnmount(() => clearTimeout(timer))
</script>

<template>
  <div class="chess-body">
    <!-- 状态栏 -->
    <div class="meta">
      <span>🔮 咒力 <b>{{ energy.toLocaleString() }}</b></span>
      <span>🏆 讨伐 <b>{{ save.stats.wins }}</b> / {{ save.stats.plays }} 胜</span>
      <span>📦 仓库角色 <b>{{ roster.length }}</b></span>
      <span class="clear-badge" :class="{ done: firstDone }">
        {{ firstDone ? '✓ 已通关' : '○ 关卡未通关' }}
      </span>
    </div>

    <div class="chess-grid">
      <!-- 左：布阵 -->
      <div class="panel lineup-panel">
        <div class="panel-head">
          <h3>我的布阵 <small>{{ lineup.length }}/{{ MAX }}</small></h3>
          <span class="hint">稀有度越高越强</span>
        </div>

        <div class="slots">
          <div
            v-for="i in MAX"
            :key="'slot' + i"
            class="slot"
            :class="{ filled: !!lineup[i - 1] }"
          >
            <template v-if="lineup[i - 1]">
              <span class="s-icon">{{ lineup[i - 1].icon }}</span>
              <span class="s-name">{{ lineup[i - 1].name }}</span>
              <span class="s-rarity" :class="'r-' + lineup[i - 1].rarity.toLowerCase()">{{ lineup[i - 1].rarity }}</span>
              <button class="s-remove" title="下阵" @click="removeFromLineup(i - 1)">×</button>
            </template>
            <template v-else><span class="s-empty">空位 {{ i }}</span></template>
          </div>
        </div>

        <!-- 羁绊 -->
        <div class="bond-area">
          <p class="sub-title">🔗 羁绊加成</p>
          <div v-if="bonds.length" class="bond-list">
            <div v-for="b in bonds" :key="b.name" class="bond active">
              <b>{{ b.name }}</b><span>{{ b.desc }}</span>
            </div>
          </div>
          <p v-else class="bond-empty">上阵特定角色组合可激活羁绊（如一年级三人组）</p>
        </div>

        <!-- 角色来源 -->
        <div class="source-area">
          <p class="sub-title">我的仓库 <small>（祈愿抽到）</small></p>
          <div v-if="roster.length" class="unit-list">
            <button
              v-for="u in roster"
              :key="u.name"
              class="unit"
              :class="['r-border-' + u.rarity.toLowerCase(), { picked: lineup.some(x => x.name === u.name) }]"
              :disabled="battle.phase === 'fighting'"
              @click="addToLineup({ name: u.name, icon: u.icon, rarity: u.rarity, from: 'roster' })"
            >
              <span class="u-icon">{{ u.icon }}</span>
              <span class="u-info"><b>{{ u.name }}</b><small>{{ u.rarity }} · ×{{ u.count }}</small></span>
              <span class="u-plus">＋</span>
            </button>
          </div>
          <button v-else class="empty-cta" @click="emit('go-gacha')">
            🐉 仓库还是空的，去祈愿抽几张卡 →
          </button>

          <p class="sub-title trial-title">借用术师 <small>（试玩用，不耗仓库）</small></p>
          <div class="unit-list">
            <button
              v-for="u in TRIAL"
              :key="'trial-' + u.name"
              class="unit trial"
              :class="['r-border-' + u.rarity.toLowerCase(), { picked: lineup.some(x => x.name === u.name) }]"
              :disabled="battle.phase === 'fighting'"
              @click="addToLineup({ name: u.name, icon: u.icon, rarity: u.rarity, from: 'trial' })"
            >
              <span class="u-icon">{{ u.icon }}</span>
              <span class="u-info"><b>{{ u.name }}</b><small>{{ u.rarity }} · 借用</small></span>
              <span class="u-plus">＋</span>
            </button>
          </div>
        </div>
      </div>

      <!-- 右：战场 -->
      <div class="panel battle-panel">
        <div class="panel-head">
          <h3>关卡 · 特级咒灵讨伐</h3>
          <span class="hint">ROUND {{ battle.round || '-' }}</span>
        </div>

        <!-- 敌方 -->
        <p class="side-label enemy-label">敌方咒灵</p>
        <div class="fight-row">
          <div
            v-for="e in battle.enemies.length ? battle.enemies : ENEMY_TEAM"
            :key="e.uid || e.name"
            class="fighter"
            :class="{ dead: e.alive === false, foe: true }"
          >
            <span class="f-icon">{{ e.icon }}</span>
            <span class="f-name">{{ e.name }}</span>
            <div class="hpbar"><i :style="{ width: (e.alive === false ? 0 : (e.hp ?? e.maxHp ?? e.hp) / (e.maxHp || e.hp) * 100) + '%' }"></i></div>
            <span class="f-hp">{{ e.alive === false ? '倒下' : Math.max(0, e.hp ?? e.maxHp) + '/' + (e.maxHp || e.hp) }}</span>
          </div>
        </div>

        <div class="versus">⚔</div>

        <!-- 我方 -->
        <p class="side-label ally-label">我方术师</p>
        <div class="fight-row">
          <template v-if="battle.allies.length">
            <div
              v-for="a in battle.allies"
              :key="a.uid"
              class="fighter"
              :class="{ dead: !a.alive }"
            >
              <span class="f-icon">{{ a.icon }}</span>
              <span class="f-name">{{ a.name }}</span>
              <div class="hpbar"><i :style="{ width: (a.hp / a.maxHp * 100) + '%' }"></i></div>
              <span class="f-hp">{{ a.hp }}/{{ a.maxHp }}</span>
            </div>
          </template>
          <template v-else>
            <div v-for="i in Math.max(1, lineup.length)" :key="'pre' + i" class="fighter ghost">
              <span class="f-icon">？</span>
              <span class="f-name">待上阵</span>
              <div class="hpbar"><i style="width:0%"></i></div>
              <span class="f-hp">—</span>
            </div>
          </template>
        </div>

        <!-- 操作 -->
        <div class="battle-actions">
          <p v-if="tip" class="tip-msg">{{ tip }}</p>
          <button
            v-if="battle.phase !== 'fighting'"
            class="fight-btn"
            :disabled="!lineup.length"
            @click="startBattle"
          >{{ battle.phase === 'idle' ? '⚔ 开始讨伐' : '↻ 再战一次' }}</button>
          <button v-else class="fight-btn fighting" disabled>战斗中…</button>
          <button v-if="battle.phase !== 'idle'" class="clear-btn" @click="resetBattle">清空战场</button>
        </div>

        <!-- 结算横幅 -->
        <div v-if="battle.phase === 'win' || battle.phase === 'lose'" class="result-banner" :class="battle.phase">
          <template v-if="battle.phase === 'win'">🎉 讨伐成功！咒力已入账</template>
          <template v-else>💀 讨伐失败，换套阵容再试</template>
        </div>

        <!-- 战斗日志 -->
        <div class="log-box">
          <p v-if="!battle.logs.length" class="log-empty">战斗日志将在这里显示…</p>
          <p v-for="(l, i) in battle.logs" :key="i" class="log-line">{{ l }}</p>
        </div>
      </div>
    </div>

    <p class="note">※ 试玩版：存档保存在本浏览器（localStorage），咒力与祈愿共享；接入账号数据库为后续版本。</p>
  </div>
</template>

<style scoped>
.chess-body { position: relative; }
.meta {
  display: flex; justify-content: center; align-items: center;
  gap: 10px 14px; flex-wrap: wrap; margin-bottom: 20px; font-size: 12px; color: var(--muted);
}
.meta span { padding: 6px 14px; border: 1px solid var(--line); border-radius: 999px; background: rgba(255,255,255,0.04); }
.meta b { color: var(--c3); font-size: 15px; margin: 0 2px; }
.clear-badge { transition: all .2s; }
.clear-badge.done { color: #ffd77a; border-color: rgba(255,196,90,.5); background: rgba(255,196,90,.1); }

.chess-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; align-items: start; }
.panel {
  border: 1px solid var(--line); border-radius: 14px;
  background: rgba(8,5,20,0.45); padding: 18px;
}
.panel-head { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 14px; }
.panel-head h3 { margin: 0; font-size: 15px; color: var(--text); }
.panel-head h3 small { color: var(--c3); font-size: 12px; margin-left: 4px; }
.hint { font-size: 11px; color: var(--muted); }

/* 上阵槽 */
.slots { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; }
.slot {
  position: relative; min-height: 88px; border-radius: 10px;
  border: 1px dashed rgba(167,139,250,.3); background: rgba(255,255,255,0.02);
  display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px;
  padding: 6px 3px; text-align: center;
}
.slot.filled { border-style: solid; border-color: rgba(167,139,250,.55); background: rgba(26,15,52,.7); }
.s-icon { font-size: 26px; line-height: 1; }
.s-name { font-size: 11px; color: var(--text); font-weight: 600; }
.s-rarity { font-size: 9px; font-weight: 700; }
.s-rarity.r-ssr { color: #ffd77a; }
.s-rarity.r-sr { color: #c4b5fd; }
.s-rarity.r-r { color: var(--muted); }
.s-empty { font-size: 11px; color: var(--muted); opacity: .6; }
.s-remove {
  position: absolute; top: -6px; right: -6px; width: 20px; height: 20px; border-radius: 50%;
  border: 1px solid var(--line); background: #2a1636; color: #fff; cursor: pointer; font-size: 14px; line-height: 1;
}
.s-remove:hover { background: var(--c2); }

.sub-title { font-size: 12px; color: var(--text); margin: 18px 0 8px; font-weight: 600; }
.sub-title small { color: var(--muted); font-weight: 400; font-size: 10px; }
.bond-area { margin-top: 4px; }
.bond-list { display: flex; flex-direction: column; gap: 6px; }
.bond { display: flex; align-items: center; gap: 10px; padding: 7px 10px; border-radius: 8px;
  background: rgba(123,47,247,.12); border: 1px solid rgba(167,139,250,.35); font-size: 11px; }
.bond b { color: #c4b5fd; }
.bond span { color: var(--muted); }
.bond-empty { font-size: 11px; color: var(--muted); opacity: .7; margin: 0; }

.unit-list { display: grid; grid-template-columns: 1fr 1fr; gap: 7px; max-height: 172px; overflow-y: auto; padding-right: 2px; }
.unit {
  display: flex; align-items: center; gap: 8px; text-align: left; cursor: pointer;
  padding: 7px 8px; border-radius: 9px; border: 1px solid var(--line);
  background: rgba(255,255,255,0.03); color: var(--text); transition: all .16s;
}
.unit:hover:not(:disabled) { border-color: rgba(56,217,255,.6); transform: translateY(-1px); }
.unit:disabled { opacity: .5; cursor: not-allowed; }
.unit.picked { border-color: rgba(255,196,90,.6); background: rgba(255,196,90,.08); }
.r-border-ssr { box-shadow: inset 0 0 0 1px rgba(255,196,90,.4); }
.r-border-sr { box-shadow: inset 0 0 0 1px rgba(167,139,250,.35); }
.u-icon { font-size: 22px; }
.u-info { display: flex; flex-direction: column; flex: 1; min-width: 0; }
.u-info b { font-size: 11px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.u-info small { font-size: 9px; color: var(--muted); }
.u-plus { color: var(--c3); font-size: 15px; }
.unit.trial { opacity: .9; }
.empty-cta {
  width: 100%; padding: 14px; border-radius: 9px; cursor: pointer;
  border: 1px dashed rgba(167,139,250,.4); background: rgba(123,47,247,.08);
  color: var(--c3); font-size: 12px;
}
.empty-cta:hover { background: rgba(123,47,247,.16); }

/* 战场 */
.side-label { font-size: 11px; margin: 2px 0 8px; font-weight: 600; }
.enemy-label { color: #ff8f8f; }
.ally-label { color: #7dd3fc; }
.fight-row { display: flex; gap: 8px; flex-wrap: wrap; }
.fighter {
  flex: 1 1 76px; min-width: 70px; border-radius: 9px; padding: 8px 6px; text-align: center;
  border: 1px solid rgba(125,211,252,.35); background: rgba(20,35,60,.5);
  display: flex; flex-direction: column; align-items: center; gap: 4px; transition: all .25s;
}
.fighter.foe { border-color: rgba(255,143,143,.4); background: rgba(60,20,30,.5); }
.fighter.dead { opacity: .32; filter: grayscale(1); }
.fighter.ghost { opacity: .35; }
.f-icon { font-size: 24px; line-height: 1; }
.f-name { font-size: 11px; color: var(--text); font-weight: 600; }
.hpbar { width: 100%; height: 6px; border-radius: 99px; background: rgba(255,255,255,.1); overflow: hidden; }
.hpbar i { display: block; height: 100%; border-radius: 99px; background: linear-gradient(90deg, #38d9a9, #7dd3fc); transition: width .35s; }
.fighter.foe .hpbar i { background: linear-gradient(90deg, #ff6b6b, #ffa94d); }
.f-hp { font-size: 9px; color: var(--muted); }
.versus { text-align: center; font-size: 20px; color: rgba(255,196,90,.7); margin: 6px 0; }

.battle-actions { display: flex; gap: 10px; align-items: center; margin-top: 18px; flex-wrap: wrap; }
.tip-msg { margin: 0; font-size: 11px; color: #ffd77a; flex: 1 1 100%; }
.fight-btn {
  padding: 10px 26px; border-radius: 999px; border: 0; cursor: pointer; font-size: 13px; font-weight: 600;
  background: linear-gradient(90deg, var(--c1), var(--c2)); color: #fff; transition: box-shadow .2s, transform .2s;
}
.fight-btn:hover:not(:disabled) { transform: translateY(-2px); box-shadow: 0 0 20px rgba(232,51,110,.45); }
.fight-btn:disabled { opacity: .5; cursor: not-allowed; }
.fight-btn.fighting { background: rgba(255,255,255,.1); color: var(--muted); }
.clear-btn { padding: 9px 16px; border-radius: 999px; border: 1px solid var(--line); background: transparent; color: var(--muted); cursor: pointer; font-size: 12px; }
.clear-btn:hover { color: var(--text); border-color: var(--c3); }

.result-banner { margin-top: 14px; padding: 10px; border-radius: 9px; text-align: center; font-size: 13px; font-weight: 600; }
.result-banner.win { color: #ffd77a; background: rgba(255,196,90,.12); border: 1px solid rgba(255,196,90,.4); }
.result-banner.lose { color: #ff9f9f; background: rgba(255,90,90,.1); border: 1px solid rgba(255,90,90,.35); }

.log-box {
  margin-top: 14px; max-height: 150px; overflow-y: auto; border-top: 1px solid var(--line); padding-top: 10px;
  font-size: 11px; line-height: 1.7;
}
.log-empty { color: var(--muted); opacity: .6; margin: 0; text-align: center; }
.log-line { margin: 0 0 2px; color: var(--muted); }
.note { margin-top: 16px; text-align: center; font-size: 10px; color: var(--muted); opacity: .7; }

@media (max-width: 860px) {
  .chess-grid { grid-template-columns: 1fr; }
}
</style>
