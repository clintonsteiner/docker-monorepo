# Docker Monorepo Documentation

This directory contains the Astro-based documentation site for the Docker monorepo.

## Structure

```
docs/
├── astro.config.mjs        # Astro configuration
├── package.json            # Node dependencies and scripts
├── wrangler.toml          # Cloudflare Pages config
└── src/
    ├── layouts/
    │   └── Layout.astro   # Main page template with styling
    └── pages/
        ├── index.astro    # Home page with project overview
        ├── projects/      # Project documentation
        │   └── index.astro
        └── contributing/  # Contributing guide
            └── index.astro
```

## Building Locally

```bash
cd docs
npm install
npm run docs:build
```

The built site will be in `docs/dist/`

## Development Server

```bash
cd docs
npm run docs:dev
```

Visit `http://localhost:3000` to view and make changes in real-time.

## Deployment

Documentation is automatically deployed to Cloudflare Pages when changes are pushed to master.

### Manual Deployment

To deploy manually, ensure you have set these GitHub secrets:
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token with Pages access
- `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare account ID

Then run the workflow or push to master.

## Adding Documentation Pages

1. Create a new `.astro` file in `src/pages/`
2. Import the `Layout` component
3. Wrap your content with the layout
4. Run `npm run docs:build` to verify

Example:

```astro
---
import Layout from '../layouts/Layout.astro';
---

<Layout title="My Page" description="Page description">
  <h1>My Page</h1>
  <p>Content goes here</p>
</Layout>
```

## Project Documentation

The Astro site links to the main project READMEs:
- [Caddy with Cloudflare DNS](../caddy-cloudflaredns/README.md)
- [Jenkins API](../jenkinsapi/README.md)
- [Ollama LLM Server](../ollama/README.md)

## Technologies

- **Astro** - Static site generator
- **Cloudflare Pages** - Deployment and hosting
- **GitHub Actions** - Automated deployment

## Notes

- The documentation site is static (no server-side rendering)
- All documentation is built as HTML at deploy time
- Changes to `docs/` directory trigger automatic deployment
