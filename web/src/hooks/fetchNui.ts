import { isEnvBrowser } from '../utils/misc'
import { sleep } from '../utils/sleep'

export async function fetchNui<T = unknown>(
  eventName: string,
  data?: unknown,
  mockData?: T,
  mockAwait: number = 150,
): Promise<T> {
  const options = {
    method: 'post',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data),
  }

  if (isEnvBrowser()) {
    await sleep(mockAwait)
    if (!mockData) {
      console.log(`%c[FETCH MOCK MISSING] -> ${eventName}`, 'color:  red')
      console.log(data)
      return {} as T
    }
    console.log(`%c[FETCH] -> ${eventName}`, 'color:  orange')
    console.log(data)

    return mockData
  }

  if (import.meta.env.MODE === 'development') {
    console.log(`[FETCH] -> ${eventName}`, data)
  }

  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'nui-frame-app'

  const resp = await fetch(`https://${resourceName}/${eventName}`, options)

  const respFormatted = await resp.json()

  return respFormatted
}
