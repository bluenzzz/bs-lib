import { onMounted, onUnmounted, ref } from 'vue'
import { isEnvBrowser } from '../utils/misc'

interface NuiMessageData<T = unknown> {
  action: string
  data: T
}

type NuiHandlerSignature<T> = (data: T) => void

export function useNuiEvent<T = any>(action: string, handler: NuiHandlerSignature<T>) {
  const savedHandler = ref(handler)

  const eventListener = (event: MessageEvent<NuiMessageData<T>>) => {
    const { action: eventAction, data } = event.data

    if (eventAction === action && savedHandler.value) {
      // @ts-ignore
      if (import.meta.env.MODE === 'development') {
        console.log(`%c[EVENT] ->  ${eventAction}`, 'color:  yellow')
        console.log(data)
      }
      savedHandler.value(data)
    }
  }
  onMounted(() => {
    if (isEnvBrowser()) console.log(`%c[REGISTER] ${action}`, 'color:  green')
    window.addEventListener('message', eventListener)
    return () => {
      window.removeEventListener('message', eventListener)
    }
  })

  onUnmounted(() => {
    if (isEnvBrowser()) console.log(`%c[UNREGISTER] ${action}`, 'color:  green')
    window.removeEventListener('message', eventListener)
  })
}
