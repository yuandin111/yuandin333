<script setup>
import { onMounted, ref } from 'vue'
import LoginCard from './components/LoginCard.vue'

const stars = ref([])

onMounted(() => {
  const arr = []
  for (let i = 0; i < 60; i++) {
    arr.push({
      left: Math.random() * 100 + 'vw',
      top: Math.random() * 100 + 'vh',
      dur: 3 + Math.random() * 4 + 's',
      delay: Math.random() * 4 + 's',
      size: 1 + Math.random() * 2.5 + 'px'
    })
  }
  stars.value = arr
})
</script>

<template>
  <!-- 动态背景：流动光斑 -->
  <div class="bg">
    <div class="blob b1"></div>
    <div class="blob b2"></div>
    <div class="blob b3"></div>
  </div>

  <!-- 动态背景：闪烁星点 -->
  <div class="stars">
    <span
      v-for="(s, i) in stars"
      :key="i"
      class="star"
      :style="{
        left: s.left,
        top: s.top,
        '--dur': s.dur,
        '--delay': s.delay,
        width: s.size,
        height: s.size
      }"
    ></span>
  </div>

  <LoginCard />
</template>

<style scoped>
.bg {
  position: fixed;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  filter: blur(60px);
}
.blob {
  position: absolute;
  width: 46vmax;
  height: 46vmax;
  border-radius: 50%;
  opacity: 0.55;
  mix-blend-mode: screen;
  animation: drift 18s ease-in-out infinite;
}
.blob.b1 {
  background: var(--c1);
  top: -12%;
  left: -10%;
}
.blob.b2 {
  background: var(--c2);
  bottom: -18%;
  right: -8%;
  animation-delay: -6s;
}
.blob.b3 {
  background: var(--c3);
  top: 30%;
  left: 40%;
  animation-delay: -12s;
}
@keyframes drift {
  0% {
    transform: translate(0, 0) scale(1);
  }
  33% {
    transform: translate(8vw, 6vh) scale(1.15);
  }
  66% {
    transform: translate(-6vw, -4vh) scale(0.9);
  }
  100% {
    transform: translate(0, 0) scale(1);
  }
}

.stars {
  position: fixed;
  inset: 0;
  z-index: 1;
  pointer-events: none;
}
.star {
  position: absolute;
  background: #fff;
  border-radius: 50%;
  opacity: 0.8;
  animation: twinkle var(--dur, 4s) ease-in-out infinite;
  animation-delay: var(--delay, 0s);
}
@keyframes twinkle {
  0%,
  100% {
    opacity: 0.15;
    transform: scale(0.6);
  }
  50% {
    opacity: 0.9;
    transform: scale(1.3);
  }
}
</style>
