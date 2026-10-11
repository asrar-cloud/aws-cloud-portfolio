#!/bin/bash
set -euxo pipefail
dnf update -y
dnf install -y nginx
cat > /usr/share/nginx/html/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Asrar | EC2 web lab</title><style>body{font:18px system-ui;background:#0b1730;color:#eef7ff;min-height:100vh;display:grid;place-items:center}main{max-width:40rem;padding:2rem;border:1px solid #2b8299;border-radius:16px}h1{color:#ffad42}</style></head><body><main><h1>EC2 Linux web lab</h1><p>Amazon Linux 2023 · Nginx · Terraform</p><p>A small learning deployment by Asrar.</p></main></body></html>
HTML
systemctl enable --now nginx
