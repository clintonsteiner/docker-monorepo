# Documentation Source

This directory contains the Astro documentation source files for the Docker monorepo.

## Structure

- `layouts/` - Reusable page layouts
- `pages/` - Documentation pages
  - `index.astro` - Home page
  - `projects/` - Project documentation
  - `contributing/` - Contributing guide

## Building

```bash
npm install
npm run docs:build
```

## Development

```bash
npm run docs:dev
```

Visit `http://localhost:3000` to preview the documentation.

## Deployment

Documentation is automatically deployed to Cloudflare Pages on push to master.

### Prerequisites for Manual Deployment

Set the following secrets in GitHub:
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token with Pages access
- `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare account ID

## Adding Pages

1. Create a `.astro` file in the `pages/` directory
2. Use the `Layout` component to wrap your content
3. Follow existing page structure for consistency
4. Run `npm run docs:build` to verify

Example:

```astro
---
import Layout from '../layouts/Layout.astro';
---

<Layout title="Page Title" description="Optional description">
  <h1>Page Title</h1>
  <p>Your content here</p>
</Layout>
```
