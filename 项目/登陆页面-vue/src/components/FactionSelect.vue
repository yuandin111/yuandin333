<script setup>
/**
 * 阵营选择器（登录 / 注册通用）
 * v-model 绑定选中的阵营 id，选择后由父组件联动主题。
 */
import { FACTIONS } from '../services/faction'

const props = defineProps({
  modelValue: { type: String, default: '' },
  compact: { type: Boolean, default: false }
})
const emit = defineEmits(['update:modelValue', 'change'])

const choose = (id) => {
  if (props.modelValue === id) return
  emit('update:modelValue', id)
  emit('change', id)
}
</script>

<template>
  <div class="faction-select" :class="{ compact }" role="radiogroup" aria-label="选择阵营">
    <button
      v-for="f in FACTIONS"
      :key="f.id"
      type="button"
      class="faction-option"
      :class="['faction-option--' + f.id, { active: modelValue === f.id }]"
      role="radio"
      :aria-checked="modelValue === f.id"
      @click="choose(f.id)"
    >
      <span class="faction-option__glyph" aria-hidden="true">
        <!-- 高专：五芒星结界 -->
        <svg v-if="f.icon === 'school'" viewBox="0 0 24 24" fill="none">
          <path d="M12 2.6 20 8.5l-3 9.6H7l-3-9.6 8-5.9Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round" />
          <path d="m12 6 4.2 3.1-1.6 5h-5.2l-1.6-5L12 6Z" fill="currentColor" opacity=".22" />
          <path d="M12 8.4v7.2M8.7 11.9h6.6" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" />
        </svg>
        <!-- 咒灵：咒印火焰 -->
        <svg v-else viewBox="0 0 24 24" fill="none">
          <path d="M12 2.4c.4 3-1.6 4.4-2.9 6.2-1.3 1.8-1.7 3.5-.6 5.1.8 1.2 2.2 1.7 3.5 1.7 2 0 3.6-1.3 3.6-3.3 0-1.6-.9-2.9-2-4 .2 1.7-.8 2.5-1.6 2.9.6-2.7-.4-5.3-2-8.6Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round" />
          <path d="M7.5 15.5c-1.6 1.4-2.4 3-1.6 4.6M16.5 15.5c1.6 1.4 2.4 3 1.6 4.6" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" />
        </svg>
      </span>
      <span class="faction-option__name">{{ f.name }}</span>
      <span class="faction-option__en">{{ f.en }}</span>
      <span class="faction-option__chars" aria-hidden="true">
        <span v-for="c in f.characters" :key="c.name" :title="c.name">{{ c.emoji }}</span>
      </span>
      <span class="faction-option__sigil">{{ f.sigil }}</span>
      <span class="faction-option__check" aria-hidden="true">
        <svg viewBox="0 0 16 16" fill="none"><path d="m3 8 3.2 3.2L13 4.5" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" /></svg>
      </span>
    </button>
  </div>
</template>

<style scoped>
.faction-select {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 11px;
}

.faction-option {
  --fc: var(--c1);
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 14px 4px 11px;
  border: 1px solid var(--line);
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.035);
  color: var(--text);
  font-family: inherit;
  cursor: pointer;
  overflow: hidden;
  transition: transform 0.28s var(--ease, cubic-bezier(0.22, 1, 0.36, 1)),
    border-color 0.28s, background 0.28s, box-shadow 0.28s;
}
.faction-option--school { --fc: #38d9ff; }
.faction-option--curse { --fc: #ff6b81; }

.faction-option::before {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(120% 80% at 50% 0%, color-mix(in srgb, var(--fc) 22%, transparent), transparent 70%);
  opacity: 0;
  transition: opacity 0.28s;
  pointer-events: none;
}
.faction-option:hover {
  transform: translateY(-3px);
  border-color: color-mix(in srgb, var(--fc) 55%, transparent);
}
.faction-option.active {
  border-color: var(--fc);
  background: color-mix(in srgb, var(--fc) 10%, rgba(255, 255, 255, 0.04));
  box-shadow: 0 8px 24px color-mix(in srgb, var(--fc) 26%, transparent),
    inset 0 0 0 1px color-mix(in srgb, var(--fc) 45%, transparent);
}
.faction-option.active::before { opacity: 1; }

.faction-option__glyph {
  position: relative;
  z-index: 1;
  width: 30px;
  height: 30px;
  color: var(--fc);
  margin-bottom: 8px;
  transition: transform 0.3s var(--ease, cubic-bezier(0.22, 1, 0.36, 1)), filter 0.3s;
}
.faction-option__glyph svg { width: 100%; height: 100%; }
.faction-option.active .faction-option__glyph {
  transform: scale(1.12);
  filter: drop-shadow(0 0 6px var(--fc));
}
.faction-option__name {
  position: relative;
  z-index: 1;
  font-size: 13px;
  font-weight: 650;
  letter-spacing: 0.5px;
}
.faction-option__en {
  position: relative;
  z-index: 1;
  margin-top: 3px;
  font-size: 8px;
  letter-spacing: 0.5px;
  color: var(--muted);
  white-space: nowrap;
}
.faction-option__chars {
  position: relative;
  z-index: 1;
  display: flex;
  gap: 2px;
  margin-top: 5px;
  font-size: 12px;
  line-height: 1;
  filter: grayscale(0.35);
  opacity: 0.75;
  transition: filter 0.28s, opacity 0.28s;
}
.faction-option.active .faction-option__chars { filter: grayscale(0); opacity: 1; }
.faction-option__sigil {
  position: absolute;
  left: 6px;
  top: 5px;
  font-family: 'Songti SC', 'SimSun', serif;
  font-size: 12px;
  color: color-mix(in srgb, var(--fc) 55%, transparent);
  line-height: 1;
}
.faction-option__check {
  position: absolute;
  top: 5px;
  right: 5px;
  width: 15px;
  height: 15px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  background: var(--fc);
  color: #0b0616;
  opacity: 0;
  transform: scale(0.4);
  transition: opacity 0.25s var(--ease, cubic-bezier(0.22, 1, 0.36, 1)),
    transform 0.25s var(--ease, cubic-bezier(0.22, 1, 0.36, 1));
}
.faction-option__check svg { width: 10px; height: 10px; }
.faction-option.active .faction-option__check { opacity: 1; transform: scale(1); }

.faction-select.compact .faction-option { padding: 10px 3px 8px; }
.faction-select.compact .faction-option__glyph { width: 25px; height: 25px; margin-bottom: 5px; }
.faction-select.compact .faction-option__en { display: none; }
.faction-select.compact .faction-option__chars { font-size: 11px; margin-top: 4px; }

@media (max-width: 520px) {
  .faction-option__en { font-size: 7px; letter-spacing: 0; }
  .faction-option__name { font-size: 12px; }
}
</style>
