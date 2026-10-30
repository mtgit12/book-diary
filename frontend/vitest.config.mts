import { configDefaults, defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [tsconfigPaths(), react()],
  test: {
    environment: 'jsdom',
    // e2e/ は Playwright のテストなので Vitest の対象から外す
    exclude: [...configDefaults.exclude, 'e2e/**'],
  },
})