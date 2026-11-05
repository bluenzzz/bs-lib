<script setup lang="ts">
import { onMounted } from 'vue'
import { fetchNui } from './hooks/fetchNui'
import { isEnvBrowser } from './utils/misc'
import Hoverfy from './components/Hoverfy/Hoverfy.vue'

onMounted(() => {
  fetchNui('uiReady')
  if (!isEnvBrowser()) return
  document.body.style.background = `linear-gradient(90deg, rgba(0, 0, 0, 0.4) 0%, rgba(0, 0, 0, 0.4) 100%)`
})
</script>

<template>
  <Hoverfy />
</template>

<style scoped></style>
