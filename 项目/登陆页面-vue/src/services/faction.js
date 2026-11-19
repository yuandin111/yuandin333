/**
 * 阵营配置与主题切换 —— 《咒术回战》(呪術廻戦) 主题
 *
 * 对齐项目既有的 camp 数据模型（school 高专 / curse 咒灵·诅咒师）：
 * 原作中御三家（五条、禅院、日下部）隶属咒术师一方，并非独立阵营，
 * 真正的两大对立面是「咒术师」与「咒灵 / 诅咒师」。
 * 选择后覆盖 :root 主题色变量，使整站（卡片、法阵、光斑、按钮等）
 * 统一切换为该阵营的咒力配色。
 */

export const FACTIONS = [
  {
    id: 'school',
    name: '咒术高专',
    en: 'JUJUTSU HIGH',
    sigil: '祓',
    motto: '以咒祓咒，守护弱者',
    quote: '「最强的咒术师，五条悟」',
    icon: 'school',
    // 代表角色（动漫元素）
    characters: [
      { emoji: '😎', name: '五条悟' },
      { emoji: '🍥', name: '虎杖悠仁' },
      { emoji: '🐕', name: '伏黑惠' }
    ],
    // 高专 · 六眼青
    theme: {
      c1: '#2aa9d1',
      c2: '#1f7fd6',
      c3: '#38d9ff',
      bg: '#06121c',
      rgb1: '42, 169, 209',
      rgb3: '56, 217, 255'
    }
  },
  {
    id: 'curse',
    name: '咒灵 · 诅咒师',
    en: 'CURSED SPIRITS',
    sigil: '咒',
    motto: '诅咒之王，支配一切',
    quote: '「只要我还活着，你就别想死」',
    icon: 'curse',
    characters: [
      { emoji: '👹', name: '两面宿傩' },
      { emoji: '🎭', name: '真人' },
      { emoji: '🌑', name: '夏油杰' }
    ],
    // 咒灵 · 咒骸绯红
    theme: {
      c1: '#e8336e',
      c2: '#ff6b81',
      c3: '#ff922b',
      bg: '#160610',
      rgb1: '232, 51, 110',
      rgb3: '255, 146, 43'
    }
  }
]

const STORAGE_KEY = 'faction'

export const DEFAULT_FACTION = 'school'

/** 根据 id 获取阵营配置，找不到时回退默认阵营 */
export function getFaction(id) {
  return FACTIONS.find((f) => f.id === id) || FACTIONS.find((f) => f.id === DEFAULT_FACTION)
}

/** 读取本地保存的阵营 id */
export function loadFaction() {
  try {
    const id = localStorage.getItem(STORAGE_KEY)
    return getFaction(id).id
  } catch (_) {
    return DEFAULT_FACTION
  }
}

/** 保存阵营 id */
export function saveFaction(id) {
  try {
    localStorage.setItem(STORAGE_KEY, id)
  } catch (_) {
    /* 忽略隐私模式等存储异常 */
  }
}

/**
 * 应用阵营主题：覆盖 :root 上的 CSS 变量。
 */
export function applyFactionTheme(id) {
  const f = getFaction(id)
  const root = document.documentElement
  const s = root.style
  s.setProperty('--c1', f.theme.c1)
  s.setProperty('--c2', f.theme.c2)
  s.setProperty('--c3', f.theme.c3)
  s.setProperty('--bg', f.theme.bg)
  s.setProperty('--rgb1', f.theme.rgb1)
  s.setProperty('--rgb3', f.theme.rgb3)
  root.setAttribute('data-faction', f.id)
  return f
}

/** 读取并应用已保存的主题，返回当前阵营配置 */
export function initFactionTheme() {
  const id = loadFaction()
  return applyFactionTheme(id)
}
