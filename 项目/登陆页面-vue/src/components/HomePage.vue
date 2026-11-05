<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { fetchContent, search, resolveUrl } from '../services/auth.js'
import GachaCard from './GachaCard.vue'

const props = defineProps({
  // 登录用户名，由 App.vue 传入
  user: { type: String, default: 'User' },
  // 是否管理员权限（permission = 0 时为 true）；false 则隐藏后台管理入口
  isAdmin: { type: Boolean, default: false }
})
const emit = defineEmits(['logout', 'admin'])

const initial = () => (props.user || 'U').trim().charAt(0).toUpperCase()

// ================= 顶部导航（锚点跳转，单页内滚动） =================
const menus = [
  { label: '首页', id: 'top', active: true },
  { label: '祈愿', id: 'gacha' },
  { label: '人物志', id: 'characters' },
  { label: '咒具图鉴', id: 'tools' },
  { label: '时间线', id: 'timeline' }
]
const scrollTo = (id) => {
  document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

// ================= 搜索（后端 /api/search 跨表检索，失败回退本地过滤） =================
const keyword = ref('')
const searching = ref(false)
const tip = ref('')
const showResults = ref(false)
const searchBox = ref(null)
// 后端检索结果；null 表示未走后端（演示模式或接口异常），用本地过滤兜底
const remoteResults = ref(null)
const hotTags = ['五条悟', '虎杖悠仁', '两面宿傩', '天逆鉾', '渋谷事变', '死灭回游']

// ================= 人物数据（本地兜底，优先使用后端数据） =================
const localCharacters = [
  {
    id: 'yuji', icon: '👊', name: '虎杖悠仁', role: '东京校一年级', camp: 'school',
    ability: '超人体质 · 宿傩容器', tags: ['主角', '容器'],
    desc: '为完成爷爷“帮助他人”的遗愿，吞下特级咒物“宿傩手指”的少年。身体能力与咒力总量远超常人，性格直率善良，越是绝境越会为他人挥拳。'
  },
  {
    id: 'megumi', icon: '🐕', name: '伏黑惠', role: '东京校一年级', camp: 'school',
    ability: '十种影法术', tags: ['式神'],
    desc: '禅院家分家出身的冷静战术派，以式神（玉犬、鵺、大蛇等）布阵取胜。嘴上说着功利，行动却始终站在保护同伴的那一侧。'
  },
  {
    id: 'nobara', icon: '🔨', name: '钉崎野蔷薇', role: '东京校一年级', camp: 'school',
    ability: '共鸣', tags: ['锤与钉'],
    desc: '从乡村来到东京的自信少女，以钉子与锤子为武器。讨厌被轻视，战斗直觉与意志力都极其出色，飒爽又鲜活。'
  },
  {
    id: 'gojo', icon: '😎', name: '五条悟', role: '特级咒术师 · 教师', camp: 'school',
    ability: '无下限术式 · 领域「无量空处」', tags: ['现代最强', '六眼'],
    desc: '现代最强咒术师，天生“六眼”持有者。护短、爱胡闹、实力深不可测；涩谷事变中被羂索以狱门疆封印，成为整个局势的转折点。'
  },
  {
    id: 'nanami', icon: '☕', name: '七海建人', role: '一级咒术师', camp: 'school',
    ability: '十划经', tags: ['社畜', '七三'],
    desc: '厌恶加班的前金融精英，习惯以“七三”比例分析目标弱点。沉稳可靠的职场前辈，涩谷事变中战死于真人之手。'
  },
  {
    id: 'shoko', icon: '💊', name: '家入硝子', role: '东京校校医', camp: 'school',
    ability: '反转术式', tags: ['治疗'],
    desc: '高专最强的“医生”，以反转术式治愈咒术造成的伤口。毒舌又可靠，是学生们最后的保险。'
  },
  {
    id: 'yuta', icon: '🗡️', name: '乙骨忧太', role: '特级咒术师', camp: 'school',
    ability: '复制 · 里香', tags: ['前传主角'],
    desc: '前传主角，与过咒怨灵“里香”立下婚约的特级术师，能复制他人术式。涩谷之后担任虎杖的“处刑人”，实则与五条一系并肩。'
  },
  {
    id: 'geto', icon: '🌑', name: '夏油杰', role: '前特级咒术师', camp: 'curse',
    ability: '咒灵操术', tags: ['挚友'],
    desc: '五条悟的昔日挚友，因理念相悖叛离高专，发动“百鬼夜行”。死后躯体被羂索夺取，沦为阴谋的皮囊。'
  },
  {
    id: 'todo', icon: '💪', name: '东堂葵', role: '京都校三年级', camp: 'school',
    ability: '不义游戏', tags: ['体操'],
    desc: '前体操选手，热血耿直的前辈，信奉“交到一百个朋友”。拍手即可交换物体位置，涩谷中为救虎杖付出一臂。'
  },
  {
    id: 'maki', icon: '⚔️', name: '禅院真希', role: '东京校二年级', camp: 'school',
    ability: '天与咒缚', tags: ['体术'],
    desc: '禅院家分家出身，以零咒力换取超凡体能的剑士。后突破束缚成为完全体，挥舞特级咒具“游云”大闹禅院家。'
  },
  {
    id: 'inumaki', icon: '🍙', name: '狗卷棘', role: '东京校二年级', camp: 'school',
    ability: '咒言', tags: ['语言'],
    desc: '语言即咒术的术师，平时用饭团配料示意咒言效果。沉默寡言，却总在关键时刻挡在同伴身前。'
  },
  {
    id: 'panda', icon: '🐼', name: '熊猫', role: '东京校二年级', camp: 'school',
    ability: '咒骸', tags: ['夜蛾造物'],
    desc: '夜蛾校长制造的自主思考咒骸，大哥型角色。肉体强悍、核心众多，是队伍里可靠的重型战力。'
  },
  {
    id: 'toji', icon: '🔪', name: '伏黑甚尔', role: '术师杀手', camp: 'curse',
    ability: '天与咒缚 · 咒具运用', tags: ['惠之父'],
    desc: '伏黑惠之父，零咒力的传说暗杀者。咒具运用出神入化，曾以天逆鉾重创五条悟，并成功刺杀星浆体天内理子。'
  },
  {
    id: 'mahito', icon: '🎭', name: '真人', role: '特级咒灵', camp: 'curse',
    ability: '无为转变', tags: ['改造灵魂'],
    desc: '由人类对自身的诅咒诞生的咒灵，能改造灵魂、重塑肉体。视人命为玩具，涩谷事变的核心凶手之一。'
  },
  {
    id: 'sukuna', icon: '👹', name: '两面宿傩', role: '诅咒之王', camp: 'curse',
    ability: '解 · 捌 · 领域「伏魔御厨子」', tags: ['千年最强'],
    desc: '千年前的最强术师，死后化为二十根特级咒物手指。寄宿于虎杖体内，冷静、残酷、唯我独尊，等待复活之日。'
  },
  {
    id: 'kenjaku', icon: '🧠', name: '羂索', role: '千年术师', camp: 'curse',
    ability: '咒灵操术 · 夺舍', tags: ['幕后黑手'],
    desc: '不断更换身体的千年阴谋家，现占据夏油杰的躯体。以“死灭回游”收集咒力，编织波及全日本的巨大漩涡。'
  }
]

// ================= 咒具数据（本地兜底，优先使用后端数据） =================
const localTools = [
  {
    id: 'sakahoko', icon: '🗡️', name: '天逆鉾', grade: '特级咒具', gradeClass: 'top',
    owner: '伏黑甚尔 → 被五条悟没收封印',
    desc: '十手状胁差，可强制解除发动中的术式，堪称“破魔刀”。怀玉篇中曾贯穿五条悟喉咙，是全作除黑绳外唯一能破防无下限术式的咒具。'
  },
  {
    id: 'playfulcloud', icon: '⛓️', name: '游云', grade: '特级咒具', gradeClass: 'top',
    owner: '伏黑甚尔 → 夏油杰 → 禅院真希',
    desc: '三节棍形态，唯一未被赋予术式的纯粹物理咒具。威力随使用者力量增长，天与咒缚者（甚尔、真希）方能发挥全部威力，最终在涩谷被破坏。'
  },
  {
    id: 'reihai', icon: '🔪', name: '释魂刀', grade: '特级咒具', gradeClass: 'top',
    owner: '伏黑甚尔',
    desc: '价值五亿日元的妖刀，无视一切物体硬度、直接斩裂魂魄。需要一双能观测无生命体魂魄的眼睛，才能发挥十二分效果。'
  },
  {
    id: 'banri', icon: '🔗', name: '万里锁', grade: '等级未知', gradeClass: 'unknown',
    owner: '伏黑甚尔',
    desc: '锁链根部不被观察到即可无限延长的咒具，常与天逆鉾搭配，进行远距离的束缚与攻击。'
  },
  {
    id: 'gokumonkyo', icon: '📦', name: '狱门疆', grade: '特级咒物', gradeClass: 'relic',
    owner: '羂索',
    desc: '得道高僧圆寂后的躯体，能将目标强制封印。涩谷事变中五条悟被它封入，后由“天使”的术式解开。'
  },
  {
    id: 'blackrope', icon: '🪢', name: '米格尔的黑绳', grade: '疑似特级咒具', gradeClass: 'maybe',
    owner: '米格尔·奥杜尔',
    desc: '诅咒师米格尔耗费数十年、以多种术式编织而成的绳索，能抵挡无下限术式，与天逆鉾并称可破“最强之防”的异物。'
  },
  {
    id: 'katana', icon: '⚔️', name: '咒具化的日本刀', grade: '咒具化（进行中）', gradeClass: 'unknown',
    owner: '三轮霞',
    desc: '新阴流剑士三轮霞的爱刀。常年注入咒力而产生“咒具化”现象——咒具的诞生，本就始于咒力的长年灌溉。'
  }
]

// ================= 事件时间线（本地兜底，优先使用后端数据） =================
const localEvents = [
  {
    id: 'e1', era: '约千年以前', title: '咒术全盛时代 · 宿傩之死',
    desc: '诅咒之王两面宿傩横行于世，死后化为二十根手指散落千年，成为咒术界最高机密——特级咒物。'
  },
  {
    id: 'e2', era: '怀玉 · 玉折', title: '星浆体暗杀与挚友分岐',
    desc: '五条悟与夏油杰的高专时代。术师杀手伏黑甚尔刺杀星浆体天内理子后被五条击毙；理念相悖的二人，自此走向不同的道路。'
  },
  {
    id: 'e3', era: '前传 · 0卷', title: '百鬼夜行',
    desc: '夏油杰发动“百鬼夜行”，欲消灭所有非术师。转学生乙骨忧太与里香挺身而出将其阻止，里香得以成佛。'
  },
  {
    id: 'e4', era: '2018年', title: '宿傩容器诞生',
    desc: '虎杖悠仁为救同学吞下宿傩手指，成为“容器”进入东京咒术高专，并在少年院事件中首次与宿傩直面。'
  },
  {
    id: 'e5', era: '2018年', title: '交流会与牺牲',
    desc: '京都姊妹校交流会明争暗斗；吉野顺平被真人诱入歧途；花御来袭，究极机械丸战死——少年们付出成长的代价。'
  },
  {
    id: 'e6', era: '2018 · 10月31日', title: '渋谷事变',
    desc: '万圣节之夜，涩谷被“帐”覆盖。五条悟遭狱门疆封印，七海建人战死，钉崎野蔷薇濒死，东堂断臂——咒术界根基动摇。'
  },
  {
    id: 'e7', era: '2018 · 11月', title: '死灭回游开幕',
    desc: '羂索启动全国结界猎杀游戏，津美纪被卷入其中。禅院家灭门、真希突破天与咒缚；高专众人为救人兼寻解封之法参战。'
  },
  {
    id: 'e8', era: '终局', title: '新宿决战',
    desc: '“天使”解开狱门疆，五条悟回归，与占据伏黑惠身体的宿傩展开跨时代决战并战死。虎杖以灵魂一击驱散诅咒之王，以人与人的联结收场。'
  }
]

// ================= 页面数据：默认用本地兜底数据，挂载后从后端拉取覆盖 =================
const characters = ref(localCharacters)
const tools = ref(localTools)
const events = ref(localEvents)

// 后端 tags 是逗号分隔字符串，统一转成数组
const normalizeTags = (list) =>
  list.map((c) => ({
    ...c,
    tags: Array.isArray(c.tags) ? c.tags : String(c.tags || '').split(/[,，、]/).filter(Boolean)
  }))

onMounted(async () => {
  try {
    const [chars, tls, evts] = await Promise.all([
      fetchContent('characters'),
      fetchContent('tools'),
      fetchContent('events')
    ])
    if (chars.length) characters.value = normalizeTags(chars)
    if (tls.length) tools.value = tls
    if (evts.length) events.value = evts
  } catch (e) {
    // 后端未启动时静默回退到本地数据，页面照常可用
    console.warn('内容接口不可用，已使用本地兜底数据：', e.message)
  }
})

// ================= 概览统计（跟随数据自动更新） =================
const stats = computed(() => [
  { label: '收录人物', value: String(characters.value.length) },
  { label: '咒具词条', value: String(tools.value.length) },
  { label: '事件节点', value: String(events.value.length) },
  { label: '传说跨度', value: '1000+年' }
])

// ================= 分区筛选（数据已全量加载，纯前端即时过滤） =================
// 人物：按阵营
const charFilter = ref('all')
const charFilterOptions = [
  { value: 'all', label: '全部' },
  { value: 'school', label: '高专' },
  { value: 'curse', label: '咒灵 · 诅咒师' }
]
const filteredCharacters = computed(() =>
  charFilter.value === 'all'
    ? characters.value
    : characters.value.filter((c) => c.camp === charFilter.value)
)

// 咒具：按等级样式
const toolFilter = ref('all')
const toolFilterOptions = [
  { value: 'all', label: '全部' },
  { value: 'top', label: '特级咒具' },
  { value: 'relic', label: '特级咒物' },
  { value: 'maybe', label: '疑似特级' },
  { value: 'unknown', label: '等级未知' }
]
const filteredTools = computed(() =>
  toolFilter.value === 'all'
    ? tools.value
    : tools.value.filter((t) => t.gradeClass === toolFilter.value)
)

// 时间线：按时期分组（前传时代 / 2018年 / 终局）
const eraGroup = (era) => {
  const s = era || ''
  if (s.includes('2018')) return 'y2018'
  if (s.includes('终局') || s.includes('新宿')) return 'final'
  return 'pre'
}
const eraFilter = ref('all')
const eraFilterOptions = [
  { value: 'all', label: '全部时期' },
  { value: 'pre', label: '前传时代' },
  { value: 'y2018', label: '2018年' },
  { value: 'final', label: '终局' }
]
const filteredEvents = computed(() =>
  eraFilter.value === 'all'
    ? events.value
    : events.value.filter((e) => eraGroup(e.era) === eraFilter.value)
)

// 配图地址：相对路径（/uploads/xxx.png）拼接后端根地址
const img = (url) => resolveUrl(url)

// ================= 搜索逻辑（后端检索优先，本地过滤兜底） =================
const searchIndex = computed(() => [
  ...characters.value.map((c) => ({
    ...c, kind: '人物',
    text: [c.name, c.role, c.ability, c.desc, ...(c.tags || [])].join(' ')
  })),
  ...tools.value.map((t) => ({
    ...t, kind: '咒具',
    text: [t.name, t.grade, t.owner, t.desc].join(' ')
  })),
  ...events.value.map((e) => ({
    ...e, kind: '事件',
    text: [e.era, e.title, e.desc].join(' ')
  }))
])

const results = computed(() => {
  // 后端检索结果优先展示
  if (remoteResults.value) return remoteResults.value
  const kw = keyword.value.trim().toLowerCase()
  if (!kw) return []
  return searchIndex.value.filter((i) => i.text.toLowerCase().includes(kw)).slice(0, 8)
})

// 结果条目统一化：人物/character → char，咒具/tool → tool，其余 → event
const kindOf = (item) => {
  const k = item.kind || ''
  if (k === 'character' || k === '人物') return 'char'
  if (k === 'tool' || k === '咒具') return 'tool'
  return 'event'
}

const doSearch = async () => {
  const kw = keyword.value.trim()
  if (!kw) {
    tip.value = '请输入搜索关键词'
    showResults.value = false
    return
  }
  showResults.value = true
  searching.value = true
  tip.value = ''
  try {
    const r = await search(kw)
    if (r) {
      // 后端可用：直接使用后端结果（统一结构 kind/id/name/subtitle/desc/kindLabel）
      remoteResults.value = r
      tip.value = r.length ? `命中 ${r.length} 条结果` : `未找到「${kw}」相关内容`
    } else {
      // 演示模式（未连后端）：本地过滤
      remoteResults.value = null
      tip.value = results.value.length
        ? `演示环境：命中 ${results.value.length} 条结果，连上后端可全站检索`
        : `演示环境：未找到「${kw}」相关内容`
    }
  } catch (e) {
    // 后端检索接口异常时回退本地过滤，页面照常可用
    remoteResults.value = null
    tip.value = results.value.length
      ? `命中 ${results.value.length} 条结果（后端检索暂不可用）`
      : `未找到「${kw}」相关内容`
  } finally {
    searching.value = false
  }
}

const pickResult = (item) => {
  showResults.value = false
  const kind = kindOf(item)
  if (kind === 'char') {
    // 后端结果只带 id，回当前数据里找完整对象；本地结果本身就是完整对象
    const c = characters.value.find((x) => x.id === item.id) || item
    openChar(c)
  } else if (kind === 'tool') {
    const t = tools.value.find((x) => x.id === item.id) || item
    openTool(t)
  } else {
    scrollTo('timeline')
    highlight(item.id)
  }
}

const onTag = (t) => {
  keyword.value = t
  doSearch()
}

// 点击搜索框外部时收起结果面板
const onDocClick = (e) => {
  if (searchBox.value && !searchBox.value.contains(e.target)) showResults.value = false
}

// ================= 详情弹窗 =================
const modal = ref(null)

// 与人物相关的事件：事件标题/简介中出现人物名即视为相关
const relatedEventsOf = (c) =>
  events.value.filter((e) => ((e.title || '') + (e.desc || '')).includes(c.name)).slice(0, 4)

// 与事件相关的人物：事件文本中出现人物名
const relatedCharsOf = (e) =>
  characters.value.filter((c) => ((e.title || '') + (e.desc || '')).includes(c.name)).slice(0, 6)

const openChar = (c) => {
  const related = relatedEventsOf(c)
  modal.value = {
    kind: '人物', name: c.name, tag: c.role, meta: '术式 / 能力：' + c.ability,
    desc: c.desc, image: c.imageUrl || '', icon: c.icon,
    extra: c.tags && c.tags.length ? '关键词：' + c.tags.join(' / ') : '',
    chipsLabel: '相关事件',
    chips: related.map((e) => ({ id: e.id, label: e.title }))
  }
}
const openTool = (t) => {
  modal.value = {
    kind: '咒具', name: t.name, tag: t.grade, meta: t.owner ? '持有者：' + t.owner : '',
    desc: t.desc, image: t.imageUrl || '', icon: t.icon, extra: ''
  }
}
const openEvent = (e) => {
  const related = relatedCharsOf(e)
  modal.value = {
    kind: '事件', name: e.title, tag: e.era, meta: '',
    desc: e.desc, image: e.imageUrl || '', icon: '',
    extra: '',
    chipsLabel: '相关人物',
    chips: related.map((c) => ({ id: c.id, label: c.name, char: c }))
  }
}

// 弹窗里的关联词条：人物词条打开人物弹窗；事件词条关弹窗、跳时间线并高亮
const pickChip = (chip) => {
  if (chip.char) {
    openChar(chip.char)
    return
  }
  closeModal()
  scrollTo('timeline')
  highlight(chip.id)
}
const closeModal = () => {
  modal.value = null
}
const onKey = (e) => {
  if (e.key === 'Escape') closeModal()
}

// ================= 时间线高亮 =================
const highlightId = ref('')
let hlTimer = null
const highlight = (id) => {
  highlightId.value = id
  clearTimeout(hlTimer)
  hlTimer = setTimeout(() => {
    highlightId.value = ''
  }, 2200)
}

onMounted(() => {
  document.addEventListener('click', onDocClick)
  document.addEventListener('keydown', onKey)
})
onBeforeUnmount(() => {
  document.removeEventListener('click', onDocClick)
  document.removeEventListener('keydown', onKey)
  clearTimeout(hlTimer)
})
</script>

<template>
  <!-- 咒力风格背景：网格 + 扫描线 -->
  <div class="tech-grid"></div>
  <div class="scanline"></div>

  <!-- ===== 顶部导航栏 ===== -->
  <header class="nav">
    <div class="logo">
      <span class="mark">咒</span>
      <span class="name">咒术回战</span>
      <span class="badge">JUJUTSU&nbsp;KAISEN</span>
    </div>

    <nav class="menu">
      <a
        v-for="(m, i) in menus"
        :key="i"
        href="#"
        :class="{ active: m.active }"
        @click.prevent="scrollTo(m.id)"
      >{{ m.label }}</a>
    </nav>

    <div class="user-area">
      <button v-if="isAdmin" class="admin-btn" title="进入后台管理系统" @click="emit('admin')">🛠️ 后台管理</button>
      <span class="bell" title="通知">🔔</span>
      <span class="avatar">{{ initial() }}</span>
      <span class="uname">{{ user }}</span>
      <button class="logout" @click="emit('logout')">退出登录</button>
    </div>
  </header>

  <!-- ===== 咒力祈愿（抽奖模块，置于页面顶端） ===== -->
  <GachaCard />

  <!-- ===== 主视觉区：欢迎语 + 搜索栏 ===== -->
  <main class="hero" id="top">
    <p class="eyebrow">// WELCOME BACK, 咒术师</p>
    <h1>欢迎回来，<span class="grad">{{ user }}</span></h1>
    <p class="sub">呪術廻戦 — 进入咒术世界资料库，探索术师、咒具与重大事件</p>

    <div class="search" ref="searchBox" :class="{ focus: keyword }">
      <span class="icon">🔍</span>
      <input
        v-model="keyword"
        type="text"
        placeholder="搜索人物、咒具、事件…"
        @keyup.enter="doSearch"
        @focus="keyword && (showResults = true)"
      />
      <button class="btn" :class="{ loading: searching }" @click="doSearch">
        <span v-if="!searching">搜 索</span>
        <span v-else class="spinner"></span>
      </button>

      <!-- 检索结果面板（后端跨表检索；演示/后端不可用时为本地过滤） -->
      <div v-if="showResults && results.length" class="search-panel">
        <div
          v-for="(r, i) in results"
          :key="i"
          class="r-item"
          @click="pickResult(r)"
        >
          <span class="r-kind" :class="'k-' + kindOf(r)">{{ r.kindLabel || r.kind }}</span>
          <span class="r-name">{{ r.name || r.title }}</span>
          <span class="r-desc">{{ r.subtitle || r.ability || r.grade || r.era }}</span>
        </div>
      </div>
    </div>

    <div class="tags">
      <span class="tag-label">热门：</span>
      <button v-for="(t, i) in hotTags" :key="i" class="tag" @click="onTag(t)">{{ t }}</button>
    </div>
    <p v-if="tip" class="tip">{{ tip }}</p>
  </main>

  <!-- ===== 概览统计 ===== -->
  <section class="stats">
    <div v-for="(s, i) in stats" :key="i" class="stat">
      <b>{{ s.value }}</b>
      <span>{{ s.label }}</span>
    </div>
  </section>

  <!-- ===== 人物志 ===== -->
  <section class="section" id="characters">
    <div class="s-head">
      <p class="s-eyebrow">// CHARACTERS</p>
      <h2 class="s-title">人物志</h2>
      <p class="s-sub">术师、诅咒师与咒灵 —— 点击卡片查看详细介绍</p>
    </div>
    <div class="filter-bar">
      <button
        v-for="o in charFilterOptions"
        :key="o.value"
        class="fchip"
        :class="{ on: charFilter === o.value }"
        @click="charFilter = o.value"
      >{{ o.label }}</button>
    </div>
    <div class="char-grid">
      <div
        v-for="(c, i) in filteredCharacters"
        :key="i"
        class="char-card"
        @click="openChar(c)"
      >
        <span class="camp" :class="'camp-' + c.camp">{{ c.camp === 'school' ? '高专' : '咒灵 · 诅咒师' }}</span>
        <div class="c-head">
          <span class="c-avatar">
            <img v-if="c.imageUrl" :src="img(c.imageUrl)" :alt="c.name" />
            <template v-else>{{ c.icon }}</template>
          </span>
          <div>
            <div class="c-name">{{ c.name }}</div>
            <div class="c-role">{{ c.role }}</div>
          </div>
        </div>
        <p class="c-ability">{{ c.ability }}</p>
        <p class="c-desc">{{ c.desc }}</p>
        <span class="c-more">查看详情 →</span>
      </div>
    </div>
    <p v-if="!filteredCharacters.length" class="filter-empty">该阵营下暂无人物</p>
  </section>

  <!-- ===== 咒具图鉴 ===== -->
  <section class="section" id="tools">
    <div class="s-head">
      <p class="s-eyebrow">// CURSED TOOLS</p>
      <h2 class="s-title">咒具图鉴</h2>
      <p class="s-sub">承载咒力的武器 —— 特级咒具与特级咒物</p>
    </div>
    <div class="filter-bar">
      <button
        v-for="o in toolFilterOptions"
        :key="o.value"
        class="fchip"
        :class="{ on: toolFilter === o.value }"
        @click="toolFilter = o.value"
      >{{ o.label }}</button>
    </div>
    <div class="tool-grid">
      <div
        v-for="(t, i) in filteredTools"
        :key="i"
        class="tool-card"
        @click="openTool(t)"
      >
        <span class="grade" :class="'g-' + t.gradeClass">{{ t.grade }}</span>
        <div class="t-head">
          <span class="t-icon">
            <img v-if="t.imageUrl" :src="img(t.imageUrl)" :alt="t.name" />
            <template v-else>{{ t.icon }}</template>
          </span>
          <div class="t-name">{{ t.name }}</div>
        </div>
        <p class="t-owner">{{ t.owner }}</p>
        <p class="t-desc">{{ t.desc }}</p>
        <span class="c-more">查看详情 →</span>
      </div>
    </div>
    <p v-if="!filteredTools.length" class="filter-empty">该等级下暂无咒具</p>
  </section>

  <!-- ===== 时间线 ===== -->
  <section class="section" id="timeline">
    <div class="s-head">
      <p class="s-eyebrow">// TIMELINE</p>
      <h2 class="s-title">重要事件时间线</h2>
      <p class="s-sub">从千年前的宿傩传说，到新宿的终局之战</p>
    </div>
    <div class="filter-bar">
      <button
        v-for="o in eraFilterOptions"
        :key="o.value"
        class="fchip"
        :class="{ on: eraFilter === o.value }"
        @click="eraFilter = o.value"
      >{{ o.label }}</button>
    </div>
    <div class="timeline">
      <div
        v-for="(e, i) in filteredEvents"
        :key="i"
        class="t-item"
        :class="{ hl: highlightId === e.id }"
        :id="e.id"
        @click="openEvent(e)"
      >
        <span class="t-num">{{ String(i + 1).padStart(2, '0') }}</span>
        <img v-if="e.imageUrl" :src="img(e.imageUrl)" :alt="e.title" class="t-thumb" />
        <div class="t-body">
          <span class="t-era">{{ e.era }}</span>
          <h3 class="t-title">{{ e.title }}</h3>
          <p class="t-desc">{{ e.desc }}</p>
          <span class="c-more">查看详情 →</span>
        </div>
      </div>
    </div>
    <p v-if="!filteredEvents.length" class="filter-empty">该时期下暂无事件</p>
  </section>

  <footer class="foot">咒术回战资料站 — 数据来自后端接口（未连接时展示内置演示数据）</footer>

  <!-- ===== 详情弹窗 ===== -->
  <div v-if="modal" class="modal-mask" @click.self="closeModal">
    <div class="modal">
      <button class="m-close" @click="closeModal">×</button>
      <div v-if="modal.image" class="m-image">
        <img :src="img(modal.image)" :alt="modal.name" />
      </div>
      <div class="m-tag">{{ modal.kind }} · {{ modal.tag }}</div>
      <h3 class="m-name">{{ modal.name }}</h3>
      <p v-if="modal.meta" class="m-meta">{{ modal.meta }}</p>
      <p class="m-desc">{{ modal.desc }}</p>
      <p v-if="modal.extra" class="m-extra">{{ modal.extra }}</p>
      <div v-if="modal.chips && modal.chips.length" class="m-chips">
        <span class="m-chips-label">{{ modal.chipsLabel }}：</span>
        <button
          v-for="chip in modal.chips"
          :key="chip.id"
          class="m-chip"
          @click="pickChip(chip)"
        >{{ chip.label }}</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ---------- 背景装饰 ---------- */
.tech-grid {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  background-image:
    linear-gradient(rgba(42, 209, 255, 0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(42, 209, 255, 0.05) 1px, transparent 1px);
  background-size: 44px 44px;
  -webkit-mask-image: radial-gradient(ellipse 90% 70% at 50% 30%, #000 30%, transparent 75%);
  mask-image: radial-gradient(ellipse 90% 70% at 50% 30%, #000 30%, transparent 75%);
}
.scanline {
  position: fixed;
  left: 0;
  right: 0;
  top: -20%;
  height: 140px;
  z-index: 0;
  pointer-events: none;
  background: linear-gradient(180deg, transparent, rgba(42, 209, 255, 0.07), transparent);
  animation: scan 7s linear infinite;
}
@keyframes scan {
  0% { top: -20%; }
  100% { top: 120%; }
}

/* ---------- 导航栏 ---------- */
.nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  padding: 0 32px;
  background: rgba(13, 16, 39, 0.72);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  border-bottom: 1px solid rgba(42, 209, 255, 0.18);
}
.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 17px;
  font-weight: 700;
  letter-spacing: 1px;
}
.logo .mark {
  width: 34px;
  height: 34px;
  display: grid;
  place-items: center;
  border-radius: 9px;
  font-size: 16px;
  font-weight: 700;
  background: linear-gradient(135deg, var(--c1), var(--c3));
  box-shadow: 0 0 16px rgba(42, 209, 255, 0.5);
}
.logo .name {
  background: linear-gradient(90deg, var(--c3), #ffffff);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}
.logo .badge {
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 2px;
  color: var(--c3);
  border: 1px solid rgba(42, 209, 255, 0.4);
  border-radius: 4px;
  padding: 2px 6px;
}

.menu {
  display: flex;
  gap: 4px;
}
.menu a {
  position: relative;
  padding: 8px 16px;
  color: var(--muted);
  text-decoration: none;
  font-size: 14px;
  border-radius: 8px;
  transition: color 0.25s, background 0.25s;
}
.menu a:hover {
  color: var(--text);
  background: rgba(42, 209, 255, 0.08);
}
.menu a.active {
  color: var(--text);
  background: rgba(42, 209, 255, 0.1);
}
.menu a.active::after {
  content: '';
  position: absolute;
  left: 16px;
  right: 16px;
  bottom: 2px;
  height: 2px;
  border-radius: 2px;
  background: var(--c3);
  box-shadow: 0 0 8px var(--c3);
}

.user-area {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 13px;
}
.bell {
  cursor: pointer;
  font-size: 16px;
  opacity: 0.75;
  transition: opacity 0.2s, transform 0.2s;
}
.bell:hover {
  opacity: 1;
  transform: scale(1.15);
}
.avatar {
  width: 34px;
  height: 34px;
  display: grid;
  place-items: center;
  border-radius: 50%;
  font-weight: 700;
  font-size: 15px;
  color: #fff;
  background: linear-gradient(135deg, var(--c1), var(--c2));
  box-shadow: 0 0 14px rgba(106, 92, 255, 0.5);
}
.uname {
  color: var(--text);
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.logout {
  padding: 7px 14px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  font-size: 13px;
  transition: color 0.25s, border-color 0.25s, box-shadow 0.25s;
}
.logout:hover {
  color: #ff8fb1;
  border-color: rgba(255, 92, 168, 0.5);
  box-shadow: 0 0 12px rgba(255, 92, 168, 0.25);
}
.admin-btn {
  padding: 7px 14px;
  border: 1px solid rgba(42, 209, 255, 0.45);
  border-radius: 8px;
  background: rgba(42, 209, 255, 0.08);
  color: var(--c3);
  cursor: pointer;
  font-size: 13px;
  transition: color 0.25s, border-color 0.25s, box-shadow 0.25s, background 0.25s;
}
.admin-btn:hover {
  background: rgba(42, 209, 255, 0.16);
  border-color: rgba(42, 209, 255, 0.7);
  box-shadow: 0 0 14px rgba(42, 209, 255, 0.35);
}

/* ---------- 主视觉 + 搜索栏 ---------- */
.hero {
  position: relative;
  z-index: 2;
  max-width: 780px;
  margin: 0 auto;
  padding: 40px 24px 54px;
  text-align: center;
}
.eyebrow {
  font-size: 12px;
  letter-spacing: 4px;
  color: var(--c3);
  margin-bottom: 14px;
}
.hero h1 {
  font-size: 38px;
  font-weight: 700;
  letter-spacing: 1px;
}
.grad {
  background: linear-gradient(90deg, var(--c1), var(--c2), var(--c3));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}
.sub {
  color: var(--muted);
  font-size: 15px;
  margin: 14px 0 38px;
}

.search {
  position: relative;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--line);
  transition: border-color 0.3s, box-shadow 0.3s;
}
.search:focus-within {
  border-color: rgba(42, 209, 255, 0.6);
  box-shadow: 0 0 0 4px rgba(42, 209, 255, 0.12), 0 0 32px rgba(42, 209, 255, 0.25);
}
.search .icon {
  padding-left: 12px;
  font-size: 15px;
}
.search input {
  flex: 1;
  min-width: 0;
  background: transparent;
  border: none;
  outline: none;
  color: var(--text);
  font-size: 15px;
  padding: 12px 8px;
}
.search input::placeholder {
  color: var(--muted);
}
.search .btn {
  display: grid;
  place-items: center;
  min-width: 96px;
  height: 44px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 600;
  color: #fff;
  letter-spacing: 2px;
  background: linear-gradient(135deg, var(--c1), var(--c3));
  box-shadow: 0 8px 20px rgba(42, 209, 255, 0.35);
  transition: transform 0.2s, box-shadow 0.25s;
}
.search .btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 28px rgba(42, 209, 255, 0.55);
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

/* ---------- 搜索结果面板 ---------- */
.search-panel {
  position: absolute;
  top: calc(100% + 10px);
  left: 0;
  right: 0;
  z-index: 50;
  text-align: left;
  background: rgba(13, 16, 39, 0.97);
  border: 1px solid rgba(42, 209, 255, 0.3);
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 18px 50px rgba(0, 0, 0, 0.5);
  animation: fadeIn 0.2s ease-out;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-4px); }
  to { opacity: 1; transform: translateY(0); }
}
.r-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 16px;
  cursor: pointer;
  transition: background 0.2s;
}
.r-item:hover {
  background: rgba(42, 209, 255, 0.1);
}
.r-kind {
  flex-shrink: 0;
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 999px;
  border: 1px solid var(--line);
  color: var(--muted);
}
.r-kind.k-char { color: var(--c3); border-color: rgba(42, 209, 255, 0.5); background: rgba(42, 209, 255, 0.1); }
.r-kind.k-tool { color: #ffd166; border-color: rgba(255, 209, 102, 0.5); background: rgba(255, 209, 102, 0.1); }
.r-kind.k-event { color: #c58bff; border-color: rgba(197, 139, 255, 0.5); background: rgba(197, 139, 255, 0.1); }
.r-name {
  font-size: 14px;
  font-weight: 600;
  white-space: nowrap;
}
.r-desc {
  margin-left: auto;
  font-size: 12px;
  color: var(--muted);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 45%;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 18px;
  font-size: 13px;
}
.tag-label {
  color: var(--muted);
}
.tag {
  padding: 5px 12px;
  border: 1px solid var(--line);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.05);
  color: var(--muted);
  cursor: pointer;
  font-size: 12px;
  transition: color 0.2s, border-color 0.2s, box-shadow 0.2s;
}
.tag:hover {
  color: var(--c3);
  border-color: rgba(42, 209, 255, 0.5);
  box-shadow: 0 0 10px rgba(42, 209, 255, 0.2);
}
.tip {
  margin-top: 14px;
  font-size: 12px;
  color: var(--c3);
  min-height: 16px;
}

/* ---------- 概览统计 ---------- */
.stats {
  position: relative;
  z-index: 2;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  max-width: 1080px;
  margin: 0 auto;
  padding: 0 24px;
}
.stat {
  text-align: center;
  padding: 18px 12px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 14px;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  transition: transform 0.3s, border-color 0.3s;
}
.stat:hover {
  transform: translateY(-3px);
  border-color: rgba(42, 209, 255, 0.4);
}
.stat b {
  font-size: 24px;
  background: linear-gradient(90deg, var(--c1), var(--c2), var(--c3));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}
.stat span {
  display: block;
  font-size: 12px;
  color: var(--muted);
  margin-top: 6px;
}

/* ---------- 分区标题 ---------- */
.section {
  position: relative;
  z-index: 2;
  max-width: 1180px;
  margin: 0 auto;
  padding: 64px 24px 0;
}
.s-head {
  text-align: center;
  margin-bottom: 36px;
}
.s-eyebrow {
  font-size: 12px;
  letter-spacing: 4px;
  color: var(--c3);
  margin-bottom: 10px;
}
.s-title {
  font-size: 26px;
  font-weight: 700;
  letter-spacing: 1px;
}
.s-sub {
  color: var(--muted);
  font-size: 13px;
  margin-top: 10px;
}

/* ---------- 分区筛选条 ---------- */
.filter-bar {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 8px;
  margin-bottom: 22px;
}
.fchip {
  padding: 6px 16px;
  border: 1px solid var(--line);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.05);
  color: var(--muted);
  font-size: 12px;
  cursor: pointer;
  transition: color 0.2s, border-color 0.2s, background 0.2s, box-shadow 0.2s;
}
.fchip:hover {
  color: var(--text);
  border-color: rgba(42, 209, 255, 0.4);
}
.fchip.on {
  color: var(--c3);
  border-color: rgba(42, 209, 255, 0.6);
  background: rgba(42, 209, 255, 0.12);
  box-shadow: 0 0 10px rgba(42, 209, 255, 0.2);
}
.filter-empty {
  text-align: center;
  color: var(--muted);
  font-size: 13px;
  padding: 18px 0 6px;
}

/* ---------- 人物卡片 ---------- */
.char-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}
.char-card {
  position: relative;
  display: flex;
  flex-direction: column;
  padding: 22px 20px 18px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  cursor: pointer;
  transition: transform 0.3s, border-color 0.3s, box-shadow 0.3s;
}
.char-card:hover {
  transform: translateY(-5px);
  border-color: rgba(42, 209, 255, 0.45);
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.4), 0 0 22px rgba(42, 209, 255, 0.12);
}
.camp {
  position: absolute;
  top: 14px;
  right: 14px;
  font-size: 10px;
  padding: 2px 8px;
  border-radius: 999px;
  border: 1px solid var(--line);
  color: var(--muted);
}
.camp-school { color: var(--c3); border-color: rgba(42, 209, 255, 0.5); background: rgba(42, 209, 255, 0.1); }
.camp-curse { color: #ff6b81; border-color: rgba(255, 107, 129, 0.5); background: rgba(255, 107, 129, 0.1); }
.c-head {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}
.c-avatar {
  width: 48px;
  height: 48px;
  flex-shrink: 0;
  display: grid;
  place-items: center;
  border-radius: 14px;
  font-size: 24px;
  background: rgba(42, 209, 255, 0.1);
  border: 1px solid rgba(42, 209, 255, 0.25);
  overflow: hidden;
}
.c-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 13px;
}
.c-name {
  font-size: 16px;
  font-weight: 700;
}
.c-role {
  font-size: 12px;
  color: var(--muted);
  margin-top: 2px;
}
.c-ability {
  font-size: 12px;
  color: var(--c3);
  margin-bottom: 10px;
}
.c-desc {
  font-size: 12.5px;
  line-height: 1.75;
  color: var(--muted);
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.c-more {
  margin-top: auto;
  padding-top: 12px;
  font-size: 12px;
  color: var(--c3);
}

/* ---------- 咒具卡片 ---------- */
.tool-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
.tool-card {
  position: relative;
  display: flex;
  flex-direction: column;
  padding: 22px 20px 18px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  cursor: pointer;
  transition: transform 0.3s, border-color 0.3s, box-shadow 0.3s;
}
.tool-card:hover {
  transform: translateY(-5px);
  border-color: rgba(255, 209, 102, 0.45);
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.4), 0 0 22px rgba(255, 209, 102, 0.12);
}
.grade {
  position: absolute;
  top: 14px;
  right: 14px;
  font-size: 10px;
  padding: 2px 8px;
  border-radius: 999px;
  border: 1px solid var(--line);
  color: var(--muted);
}
.g-top { color: #ffd166; border-color: rgba(255, 209, 102, 0.55); background: rgba(255, 209, 102, 0.12); }
.g-relic { color: #c58bff; border-color: rgba(197, 139, 255, 0.55); background: rgba(197, 139, 255, 0.12); }
.g-maybe { color: #ffa94d; border-color: rgba(255, 169, 77, 0.55); background: rgba(255, 169, 77, 0.12); }
.g-unknown { color: var(--muted); }
.t-head {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}
.t-icon {
  width: 44px;
  height: 44px;
  flex-shrink: 0;
  display: grid;
  place-items: center;
  border-radius: 13px;
  font-size: 22px;
  background: rgba(255, 209, 102, 0.1);
  border: 1px solid rgba(255, 209, 102, 0.25);
  overflow: hidden;
}
.t-icon img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 12px;
}
.t-name {
  font-size: 16px;
  font-weight: 700;
}
.t-owner {
  font-size: 12px;
  color: #c58bff;
  margin-bottom: 10px;
}
.t-desc {
  font-size: 12.5px;
  line-height: 1.75;
  color: var(--muted);
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* ---------- 时间线 ---------- */
.timeline {
  position: relative;
  max-width: 860px;
  margin: 0 auto;
}
.timeline::before {
  content: '';
  position: absolute;
  left: 11px;
  top: 8px;
  bottom: 8px;
  width: 2px;
  border-radius: 2px;
  background: linear-gradient(180deg, rgba(42, 209, 255, 0.8), rgba(106, 92, 255, 0.6), transparent);
}
.t-item {
  position: relative;
  display: flex;
  align-items: flex-start;
  gap: 16px;
  margin: 0 0 22px 44px;
  padding: 18px 22px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 14px;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  cursor: pointer;
  transition: border-color 0.3s, box-shadow 0.3s, transform 0.3s;
}
.t-item:hover {
  border-color: rgba(42, 209, 255, 0.4);
  transform: translateX(4px);
}
.t-num {
  flex-shrink: 0;
  font-size: 26px;
  font-weight: 800;
  line-height: 1.15;
  letter-spacing: 1px;
  color: rgba(42, 209, 255, 0.22);
  user-select: none;
}
.t-thumb {
  flex-shrink: 0;
  width: 84px;
  height: 84px;
  object-fit: cover;
  border-radius: 12px;
  border: 1px solid var(--line);
}
.t-body {
  flex: 1;
  min-width: 0;
}
.t-item::before {
  content: '';
  position: absolute;
  left: -38px;
  top: 24px;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: var(--bg);
  border: 2px solid var(--c3);
  box-shadow: 0 0 10px rgba(42, 209, 255, 0.8);
}
.t-item.hl {
  border-color: rgba(42, 209, 255, 0.7);
  box-shadow: 0 0 0 2px rgba(42, 209, 255, 0.25), 0 0 32px rgba(42, 209, 255, 0.25);
}
.t-era {
  display: inline-block;
  font-size: 11px;
  letter-spacing: 1px;
  color: var(--c3);
  border: 1px solid rgba(42, 209, 255, 0.4);
  border-radius: 999px;
  padding: 2px 10px;
  margin-bottom: 10px;
}
.t-title {
  font-size: 17px;
  font-weight: 700;
  margin-bottom: 8px;
}
.t-desc {
  font-size: 13px;
  line-height: 1.8;
  color: var(--muted);
}

/* ---------- 详情弹窗 ---------- */
.modal-mask {
  position: fixed;
  inset: 0;
  z-index: 100;
  background: rgba(5, 6, 18, 0.72);
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
  display: grid;
  place-items: center;
  padding: 24px;
  animation: fadeIn 0.25s;
}
.modal {
  position: relative;
  width: 520px;
  max-width: 92vw;
  max-height: 82vh;
  overflow-y: auto;
  padding: 32px 30px 28px;
  background: #14183a;
  border: 1px solid rgba(42, 209, 255, 0.35);
  border-radius: 18px;
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.6), 0 0 40px rgba(42, 209, 255, 0.15);
  animation: popIn 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
}
@keyframes popIn {
  from { opacity: 0; transform: translateY(16px) scale(0.97); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}
.m-close {
  position: absolute;
  top: 14px;
  right: 16px;
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
  color: var(--muted);
  font-size: 18px;
  cursor: pointer;
  transition: color 0.2s, background 0.2s;
}
.m-close:hover {
  color: var(--text);
  background: rgba(255, 255, 255, 0.12);
}
.m-tag {
  display: inline-block;
  font-size: 11px;
  letter-spacing: 1px;
  color: var(--c3);
  border: 1px solid rgba(42, 209, 255, 0.4);
  border-radius: 999px;
  padding: 3px 10px;
  margin-bottom: 14px;
}
.m-name {
  font-size: 24px;
  font-weight: 700;
  margin-bottom: 10px;
}
.m-meta {
  font-size: 13px;
  color: #c58bff;
  margin-bottom: 14px;
}
.m-desc {
  font-size: 14px;
  line-height: 1.9;
  color: var(--text);
}
.m-extra {
  margin-top: 16px;
  font-size: 12px;
  color: var(--muted);
}

/* ---------- 弹窗配图 ---------- */
.m-image {
  margin: -4px 0 16px;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid var(--line);
}
.m-image img {
  display: block;
  width: 100%;
  max-height: 220px;
  object-fit: cover;
}

/* ---------- 弹窗关联词条（相关事件 / 相关人物） ---------- */
.m-chips {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  margin-top: 18px;
  padding-top: 14px;
  border-top: 1px dashed var(--line);
}
.m-chips-label {
  font-size: 12px;
  color: var(--muted);
}
.m-chip {
  padding: 5px 12px;
  border: 1px solid rgba(42, 209, 255, 0.4);
  border-radius: 999px;
  background: rgba(42, 209, 255, 0.08);
  color: var(--c3);
  font-size: 12px;
  cursor: pointer;
  transition: background 0.2s, box-shadow 0.2s;
}
.m-chip:hover {
  background: rgba(42, 209, 255, 0.18);
  box-shadow: 0 0 10px rgba(42, 209, 255, 0.25);
}

/* ---------- 页脚 ---------- */
.foot {
  position: relative;
  z-index: 2;
  text-align: center;
  font-size: 12px;
  color: var(--muted);
  padding: 64px 24px 28px;
}

/* ---------- 响应式 ---------- */
@media (max-width: 1080px) {
  .char-grid { grid-template-columns: repeat(3, 1fr); }
  .tool-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 860px) {
  .menu { display: none; }
  .char-grid { grid-template-columns: repeat(2, 1fr); }
  .stats { grid-template-columns: repeat(2, 1fr); }
  .hero h1 { font-size: 28px; }
  .hero { padding-top: 36px; }
  .uname { display: none; }
}
@media (max-width: 560px) {
  .char-grid { grid-template-columns: 1fr; }
  .tool-grid { grid-template-columns: 1fr; }
}
</style>
