<script setup lang="ts">
import { ref } from 'vue'
import { useNuiEvent } from '@/hooks/nuiEvent'

const state = ref({ show: false, key: '', text: '', color: '' })

useNuiEvent('Hoverfy', (data) => Object.assign(state.value, data))
</script>

<template>
  <div id="hoverfy" v-show="state.show">
    <div class="wrapper">
      <div class="box-key" :style="{ borderColor: state.color }">
        <span>{{ state.key }}</span>
      </div>
      <span>{{ state.text }}</span>
    </div>
  </div>
</template>
<style scoped lang="scss">
@keyframes pulse {
  0%,
  100% {
    transform: scale(0.95);
  }
  50% {
    transform: scale(0.8);
  }
}

#hoverfy {
  width: 100%;

  position: absolute;
  bottom: 1rem;

  .wrapper {
    width: 100%;
    height: 100%;

    display: flex;
    justify-content: center;
    align-items: center;

    gap: 1rem;

    .box-key {
      color: white;

      background-color: rgba(0, 0, 0, 0.3);

      padding: 0.3rem 0.8rem;

      border-radius: 2.5px;

      border: 1px solid #0093ff;

      display: flex;
      justify-content: center;
      align-items: center;

      animation: pulse 1.2s ease-in-out infinite;

      span {
        font-weight: 500;
        font-size: 1.4rem;
      }
    }

    & > span {
      color: white;

      font-weight: 400;
      letter-spacing: 0.02rem;

      font-size: 1.5rem;

      text-shadow: 0px 2px 10px rgba(0, 0, 0, 0.5);
    }
  }
}
</style>
