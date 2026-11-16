// 游戏存档：咒力钱包 + 角色仓库
// 试玩版先用 localStorage 持久化（不落库、不依赖后端），刷新不丢失。
// 后续若要接后端，只需把 load()/persist() 换成接口调用，其余组件无需改动。

const STORAGE_KEY = 'jjk_game_save_v1'
const INITIAL_ENERGY = 3000 // 试玩初始咒力，够玩几轮

const blank = () => ({
  energy: INITIAL_ENERGY,
  // 角色仓库：以角色名为 key，聚合稀有度与持有数量
  // { '五条悟': { name, icon, rarity, title, desc, count } }
  roster: {},
  // 战绩 / 首通标记
  stats: { plays: 0, wins: 0, firstClearDone: false }
})

// 同一浏览器多标签页共享时，实时从 localStorage 拉取一次，避免互相覆盖
function load() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return blank()
    const parsed = JSON.parse(raw)
    return {
      energy: Number.isFinite(parsed.energy) ? parsed.energy : INITIAL_ENERGY,
      roster: parsed.roster && typeof parsed.roster === 'object' ? parsed.roster : {},
      stats: { ...blank().stats, ...(parsed.stats || {}) }
    }
  } catch (e) {
    return blank()
  }
}

function persist(data) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
  } catch (e) {
    /* 隐私模式 / 存储配额满时静默降级为内存存档 */
  }
}

/** 读取当前存档快照（每次返回新对象，调用方改完不会污染内部） */
export function getSave() {
  const d = load()
  return { energy: d.energy, roster: { ...d.roster }, stats: { ...d.stats } }
}

export function getEnergy() {
  return load().energy
}

/** 消费咒力，余额不足返回 false 且不扣款 */
export function spendEnergy(cost) {
  const d = load()
  if (d.energy < cost) return false
  d.energy -= cost
  persist(d)
  return true
}

export function addEnergy(amount) {
  const d = load()
  d.energy += amount
  persist(d)
  return d.energy
}

/** 抽到的卡入仓库：同名累加 count，稀有度等以首次为准 */
export function addCharacter(card) {
  const d = load()
  const key = card.name
  if (d.roster[key]) {
    d.roster[key].count += 1
  } else {
    d.roster[key] = {
      name: card.name,
      icon: card.icon,
      rarity: card.rarity,
      title: card.title,
      desc: card.desc,
      count: 1
    }
  }
  persist(d)
}

/** 仓库列表（数组），按稀有度 SSR > SR > R、再按数量排序 */
export function getRoster() {
  const rank = { SSR: 3, SR: 2, R: 1 }
  return Object.values(load().roster).sort((a, b) => {
    const r = (rank[b.rarity] || 0) - (rank[a.rarity] || 0)
    return r !== 0 ? r : b.count - a.count
  })
}

export function recordBattle(win) {
  const d = load()
  d.stats.plays += 1
  if (win) d.stats.wins += 1
  persist(d)
  return d.stats
}

export function isFirstClearDone() {
  return !!load().stats.firstClearDone
}

export function markFirstClearDone() {
  const d = load()
  d.stats.firstClearDone = true
  persist(d)
}

/** 重置存档（调试 / 用户主动重开时用） */
export function resetSave() {
  persist(blank())
}

export const ENERGY_COST = { single: 100, ten: 1000 }
