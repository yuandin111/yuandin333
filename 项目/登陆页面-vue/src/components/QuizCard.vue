<script setup>
/**
 * 咒术问答 —— 了解《咒术回战》的术式、人物、咒具与事件
 * 单选题 + 即时判定 + 解析 + 计分；答对领取咒力（接替原自走棋的咒力产出）。
 */
import { computed, ref } from 'vue'
import { addEnergy } from '../services/gameStore.js'

// 题库：全部源自站内资料与作品设定
const BANK = [
  {
    cat: '术式', q: '五条悟的标志性领域展开叫什么名字？',
    options: ['无量空处', '伏魔御厨子', '嵌合兽带', 'Degeneration'],
    answer: 0,
    exp: '「无量空处」把对手的意识强行灌入无穷 information，使其无法思考与行动，是公认的最强领域之一。'
  },
  {
    cat: '人物', q: '被称为「诅咒之王」，死后化为二十根手指的是谁？',
    options: ['夏油杰', '两面宿傩', '羂索', '真人'],
    answer: 1,
    exp: '两面宿傩是千年前的诅咒之王，死后手指散落各地成为特级咒物，也是虎杖悠仁体内的「房客」。'
  },
  {
    cat: '咒具', q: '能强制解除发动中术式、被称为「破魔刀」的特级咒具是？',
    options: ['游云', '释魂刀', '天逆鉾', '万里锁'],
    answer: 2,
    exp: '天逆鉾是十手状胁差，可打断术式发动，是少数能突破五条悟无下限术式的咒具。'
  },
  {
    cat: '人物', q: '虎杖悠仁吞噬宿傩手指后，进入了哪所学校？',
    options: ['东京咒术高专', '京都咒术高专', '御三家本家', '咒术界高层'],
    answer: 0,
    exp: '作为宿傩容器，虎杖被带到东京咒术高专，在五条悟的指导下学习控制咒力。'
  },
  {
    cat: '事件', q: '五条悟在涩谷事变中被封印所使用的特级咒物是？',
    options: ['天逆鉾', '狱门疆', '游云', '黑绳'],
    answer: 1,
    exp: '狱门疆由得道高僧圆寂后的躯体制成，可将目标强制封印。五条悟被封入其中，直到「天使」出手解封。'
  },
  {
    cat: '术式', q: '伏黑惠所使用的术式是？',
    options: ['十种影法术', '共鸣', '无下限术式', '咒灵操术'],
    answer: 0,
    exp: '十种影法术通过影子召唤式神作战，如玉犬、鵺、大黑天等，是禅院家血脉传承的术式。'
  },
  {
    cat: '人物', q: '发动「百鬼夜行」、企图消灭所有非术师的是谁？',
    options: ['夏油杰', '五条悟', '七海建人', '乙骨忧太'],
    answer: 0,
    exp: '夏油杰在理念分歧后堕入诅咒师之路，发动百鬼夜行，后被转学生乙骨忧太与里香阻止。'
  },
  {
    cat: '咒具', q: '价值五亿日元、可直接斩裂魂魄的妖刀是？',
    options: ['游云', '释魂刀', '天逆鉾', '咒具化日本刀'],
    answer: 1,
    exp: '释魂刀无视物体硬度直斩魂魄，但需要能观测无生命体魂魄的眼睛才能发挥全力。'
  },
  {
    cat: '术式', q: '钉崎野蔷薇的术式是？',
    options: ['十划咒法', '共鸣', '芻灵咒法', '星泉'],
    answer: 1,
    exp: '共鸣让她把钉子与咒力注入对方，通过击打钉子对敌人造成对应部位的伤害。'
  },
  {
    cat: '事件', q: '在涩谷事变中战死的一级咒术师是？',
    options: ['七海建人', '虎杖悠仁', '伏黑惠', '东堂葵'],
    answer: 0,
    exp: '七海建人在涩谷事变中壮烈战死；同役中钉崎野蔷薇濒死、东堂葵断臂，咒术界损失惨重。'
  },
  {
    cat: '人物', q: '执掌「死灭回游」、不断更换身体的千年阴谋家是？',
    options: ['羂索', '真人', '花御', '漏瑚'],
    answer: 0,
    exp: '羂索占据夏油杰的躯体，以死灭回游收集咒力，编织波及全日本的巨大计划。'
  },
  {
    cat: '咒具', q: '唯一未被赋予术式、纯靠物理力量发挥威力的三节棍咒具是？',
    options: ['万里锁', '游云', '释魂刀', '黑绳'],
    answer: 1,
    exp: '游云是三节棍形态的特级咒具，威力随使用者力量增长，唯有天与咒缚者能发挥全部实力。'
  },
  {
    cat: '术式', q: '「领域展开」的本质最接近以下哪一项？',
    options: ['在领域内必中术式', '提升咒力上限', '召唤式神', '封印对手灵魂'],
    answer: 0,
    exp: '领域展开把术式铺满空间，使攻击在领域内「必中」，是术师的最高战斗形态。'
  },
  {
    cat: '人物', q: '在《0卷》中阻止夏油杰、其里香后来得以成佛的是谁？',
    options: ['乙骨忧太', '虎杖悠仁', '伏黑惠', '秤金次'],
    answer: 0,
    exp: '乙骨忧太与特级咒灵里香并肩，击败夏油杰，并让里香从诅咒中解脱成佛。'
  }
]

const REWARD_PER_CORRECT = 30

// 洗牌
const shuffle = (arr) => {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

const questions = ref(shuffle(BANK).slice(0, 10))
const idx = ref(0)
const score = ref(0)
const picked = ref(-1)          // 当前题选择的选项索引
const locked = ref(false)       // 是否已判定
const finished = ref(false)
const earned = ref(0)           // 本轮获得咒力

const current = computed(() => questions.value[idx.value])
const progress = computed(() => Math.round((idx.value / questions.value.length) * 100))
const correctCount = computed(() => score.value)

const isCorrect = (i) => locked.value && i === current.value.answer

const choose = (i) => {
  if (locked.value) return
  picked.value = i
  locked.value = true
  if (i === current.value.answer) {
    score.value++
    earned.value += REWARD_PER_CORRECT
    addEnergy(REWARD_PER_CORRECT)
  }
}

const next = () => {
  if (idx.value + 1 >= questions.value.length) {
    finished.value = true
    return
  }
  idx.value++
  picked.value = -1
  locked.value = false
}

const restart = () => {
  questions.value = shuffle(BANK).slice(0, 10)
  idx.value = 0
  score.value = 0
  picked.value = -1
  locked.value = false
  finished.value = false
  earned.value = 0
}

const rank = computed(() => {
  const p = score.value / questions.value.length
  if (p === 1) return { title: '特级术师', desc: '全科满分，咒术界的顶尖天才！' }
  if (p >= 0.8) return { title: '一级术师', desc: '造诣深厚，几题之差便是满分。' }
  if (p >= 0.6) return { title: '二级术师', desc: '基础扎实，再接再厉。' }
  if (p >= 0.4) return { title: '三级术师', desc: '略有了解，继续修行吧。' }
  return { title: '实习术师', desc: '多逛逛人物志与图鉴，很快就能进步。' }
})
</script>

<template>
  <div class="quiz">
    <div v-if="!finished" class="quiz-card">
      <!-- 顶部信息条 -->
      <div class="quiz-top">
        <span class="quiz-cat">{{ current.cat }}</span>
        <span class="quiz-count">第 {{ idx + 1 }} / {{ questions.length }} 题</span>
      </div>
      <div class="progress"><span :style="{ width: progress + '%' }"></span></div>

      <!-- 计分 -->
      <div class="quiz-score">
        <span>答对 <b>{{ score }}</b></span>
        <span class="quiz-earned">已获咒力 +{{ earned }}</span>
      </div>

      <!-- 题目 -->
      <h3 class="quiz-q">{{ current.q }}</h3>

      <!-- 选项 -->
      <div class="options">
        <button
          v-for="(opt, i) in current.options"
          :key="i"
          class="opt"
          :class="{
            correct: isCorrect(i),
            wrong: locked && picked === i && i !== current.answer,
            dim: locked && !isCorrect(i) && !(picked === i)
          }"
          :disabled="locked"
          @click="choose(i)"
        >
          <span class="opt-key">{{ 'ABCD'[i] }}</span>
          <span class="opt-text">{{ opt }}</span>
          <span v-if="isCorrect(i)" class="opt-mark">✓</span>
          <span v-else-if="locked && picked === i" class="opt-mark">✕</span>
        </button>
      </div>

      <!-- 解析 + 下一题 -->
      <div v-if="locked" class="explain" :class="picked === current.answer ? 'ok' : 'no'">
        <p class="explain-head">
          {{ picked === current.answer ? '回答正确 · 咒力 +' + REWARD_PER_CORRECT : '回答错误 · 正确答案是 ' + 'ABCD'[current.answer] }}
        </p>
        <p class="explain-body">{{ current.exp }}</p>
        <button class="next-btn" @click="next">
          {{ idx + 1 >= questions.length ? '查看结果 →' : '下一题 →' }}
        </button>
      </div>
    </div>

    <!-- 结果页 -->
    <div v-else class="quiz-card result">
      <div class="result-seal">{{ rank.title.charAt(0) }}</div>
      <h3 class="result-title">{{ rank.title }}</h3>
      <p class="result-desc">{{ rank.desc }}</p>
      <div class="result-stats">
        <div><b>{{ score }}</b><span>答对</span></div>
        <div><b>{{ questions.length - score }}</b><span>答错</span></div>
        <div><b>+{{ earned }}</b><span>咒力</span></div>
      </div>
      <button class="next-btn restart" @click="restart">↻ 再来一轮</button>
    </div>
  </div>
</template>

<style scoped>
.quiz { width: 100%; }
.quiz-card {
  position: relative;
  width: 560px;
  max-width: 100%;
  margin: 0 auto;
  padding: 28px 30px 30px;
  border-radius: 18px 6px 18px 6px;
  background: linear-gradient(160deg, rgba(38, 20, 72, 0.7), rgba(13, 7, 28, 0.9));
  border: 1px solid rgba(var(--rgb3), 0.3);
  box-shadow: 0 24px 70px rgba(0, 0, 0, 0.55), 0 0 50px rgba(var(--rgb1), 0.18);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
}

.quiz-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.quiz-cat {
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 2px;
  color: var(--c3);
  padding: 4px 12px;
  border: 1px solid rgba(var(--rgb3), 0.4);
  border-radius: 20px;
}
.quiz-count { font-size: 13px; color: var(--muted); }

.progress {
  height: 5px;
  border-radius: 5px;
  background: rgba(255, 255, 255, 0.08);
  overflow: hidden;
  margin-bottom: 16px;
}
.progress span {
  display: block;
  height: 100%;
  border-radius: 5px;
  background: linear-gradient(90deg, var(--c1), var(--c3));
  transition: width 0.4s cubic-bezier(0.22, 1, 0.36, 1);
}

.quiz-score {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  color: var(--muted);
  margin-bottom: 14px;
}
.quiz-score b { color: var(--text); font-size: 16px; }
.quiz-earned { color: #ffd36e; }

.quiz-q {
  font-size: 19px;
  line-height: 1.6;
  margin-bottom: 20px;
  color: var(--text);
  font-weight: 650;
}

.options { display: grid; gap: 10px; }
.opt {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 13px 15px;
  border-radius: 12px;
  border: 1px solid var(--line);
  background: rgba(255, 255, 255, 0.04);
  color: var(--text);
  font-size: 15px;
  font-family: inherit;
  text-align: left;
  cursor: pointer;
  transition: transform 0.2s, border-color 0.25s, background 0.25s, opacity 0.25s;
}
.opt:hover:not(:disabled) {
  transform: translateX(4px);
  border-color: var(--c3);
  background: rgba(var(--rgb1), 0.12);
}
.opt:disabled { cursor: default; }
.opt-key {
  flex: none;
  width: 26px;
  height: 26px;
  display: grid;
  place-items: center;
  border-radius: 7px;
  background: rgba(255, 255, 255, 0.08);
  font-size: 13px;
  font-weight: 700;
}
.opt-text { flex: 1; }
.opt-mark { font-size: 18px; font-weight: 700; }

.opt.correct {
  border-color: #4fe39a;
  background: rgba(79, 227, 154, 0.14);
}
.opt.correct .opt-key { background: #4fe39a; color: #06231a; }
.opt.correct .opt-mark { color: #4fe39a; }
.opt.wrong {
  border-color: #ff6b81;
  background: rgba(255, 107, 129, 0.14);
}
.opt.wrong .opt-key { background: #ff6b81; color: #2a0610; }
.opt.wrong .opt-mark { color: #ff6b81; }
.opt.dim { opacity: 0.42; }

.explain {
  margin-top: 18px;
  padding: 16px 18px;
  border-radius: 12px;
  border-left: 3px solid;
  background: rgba(255, 255, 255, 0.04);
  animation: rise 0.3s ease both;
}
.explain.ok { border-color: #4fe39a; }
.explain.no { border-color: #ff6b81; }
@keyframes rise {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
.explain-head { font-size: 14px; font-weight: 700; margin-bottom: 6px; }
.explain.ok .explain-head { color: #4fe39a; }
.explain.no .explain-head { color: #ff6b81; }
.explain-body { font-size: 13px; line-height: 1.7; color: var(--muted); }

.next-btn {
  margin-top: 14px;
  width: 100%;
  padding: 12px;
  border: 0;
  border-radius: 10px;
  background: linear-gradient(120deg, var(--c1), var(--c2));
  color: #fff;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 1px;
  font-family: inherit;
  cursor: pointer;
  transition: transform 0.2s, filter 0.2s;
}
.next-btn:hover { transform: translateY(-2px); filter: brightness(1.1); }

/* 结果页 */
.result { text-align: center; padding: 40px 30px; }
.result-seal {
  width: 84px;
  height: 84px;
  margin: 0 auto 18px;
  display: grid;
  place-items: center;
  font-family: 'Songti SC', 'SimSun', serif;
  font-size: 44px;
  color: #fff;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--c1), var(--c2));
  box-shadow: 0 0 30px rgba(var(--rgb1), 0.55), inset 0 0 14px rgba(255, 255, 255, 0.25);
}
.result-title {
  font-size: 26px;
  font-weight: 800;
  letter-spacing: 3px;
  background: linear-gradient(90deg, #fff, var(--c3));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  margin-bottom: 8px;
}
.result-desc { color: var(--muted); font-size: 14px; margin-bottom: 24px; }
.result-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 24px;
}
.result-stats div {
  padding: 14px 6px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--line);
}
.result-stats b { display: block; font-size: 24px; color: var(--c3); }
.result-stats span { font-size: 12px; color: var(--muted); }
.restart { max-width: 260px; margin: 0 auto; }

@media (max-width: 560px) {
  .quiz-card { padding: 22px 18px 24px; }
  .quiz-q { font-size: 17px; }
  .opt { font-size: 14px; padding: 11px 12px; }
}
</style>
