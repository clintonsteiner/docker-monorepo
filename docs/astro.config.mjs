import { defineConfig } from 'astro/config';

export default defineConfig({
  // Cloudflare Pages configuration
  output: 'static',
  outDir: './dist',

  site: 'https://docker-monorepo.example.com',

  // Enable Markdown processing
  markdown: {
    shikiConfig: {
      theme: 'github-dark',
    },
  },
});
