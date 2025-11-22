# XM Digital Hub — Website Repo

This repository contains the core structure for the XM Digital Hub website.

## Structure

- `deploy/xm_deploy.sh` – WP-CLI deployment script to import pages, media, and block patterns into WordPress.
- `site/pages/` – HTML content for Gutenberg pages.
- `site/block_patterns/` – JSON block pattern definitions for reusable blocks.
- `site/assets/` – (later) images and static assets.
- `REPO_MANIFEST.json` – metadata and notes about the deployment.

## High-level deployment logic

1. Upload this repo to a server connected to your WordPress instance.
2. Place the full content package (if any) in `/tmp/xm_deploy_run` on the server.
3. Run `bash deploy/xm_deploy.sh` with WP-CLI available.
4. The script will:
   - Create or update pages.
   - Import media (if present).
   - Register reusable block patterns.

## Next steps

- Connect this repo to WordPress.com Deployments.
- Configure GA4 + GTM + HubSpot integration at the environment level.
- Add the full page and asset set once the infrastructure is ready.# xm-digital-hub-site
