#!/usr/bin/env bash
set -euo pipefail

WP="$(which wp || echo /usr/bin/wp)"
WORKDIR="/tmp/xm_deploy_run"
LOG="$WORKDIR/deploy_log.txt"

mkdir -p "$WORKDIR"
exec > >(tee -a "$LOG") 2>&1

echo "[0] XM Deploy start $(date)"

# 1) Import media
if [ -d "$WORKDIR/site/assets" ]; then
  echo "[1] Media import"
  for f in "$WORKDIR"/site/assets/*; do
    [ -f "$f" ] || continue
    echo "IMPORT MEDIA: $f"
    $WP media import "$f" --porcelain || true
  done
fi

# 2) Pages
if [ -d "$WORKDIR/site/pages" ]; then
  echo "[2] Pages"
  for p in "$WORKDIR"/site/pages/*.html; do
    [ -f "$p" ] || continue
    slug=$(basename "$p" .html)
    title=$($WP eval "echo wp_strip_all_tags( preg_replace('/.*<h1[^>]*>(.*?)<\\/h1>.*/s', '\\$1', file_get_contents('$p')) );" 2>/dev/null || echo "$slug")
    post_id=$($WP post list --post_type=page --name="$slug" --field=ID --format=csv || true)
    if [ -z "$post_id" ]; then
      echo "CREATE PAGE: $slug"
      $WP post create "$p" --post_type=page --post_status=publish --post_name="$slug" --post_title="$title"
    else
      echo "UPDATE PAGE: $slug (ID $post_id)"
      $WP post update "$post_id" --post_content="$(cat "$p")" --post_title="$title"
    fi
  done
fi

# 3) Block patterns
if [ -d "$WORKDIR/site/block_patterns" ]; then
  echo "[3] Block patterns"
  for b in "$WORKDIR"/site/block_patterns/*.json; do
    [ -f "$b" ] || continue
    title=$(jq -r '.title // empty' "$b" 2>/dev/null || echo "")
    content=$(jq -r '.content // empty' "$b" 2>/dev/null || echo "")
    [ -z "$content" ] && content=$(cat "$b")
    if [ -n "$title" ]; then
      echo "REGISTER PATTERN: $title"
      $WP post create --post_type=wp_block --post_status=publish --post_title="$title" --post_content="$content" || true
    fi
  done
fi

echo "[9] XM Deploy done at $(date). Log: $LOG"
