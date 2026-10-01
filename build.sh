#!/bin/sh
# Wraps index.html into a complete HTML document for static hosting (Render, or any web server).
#
# index.html is kept as a bare fragment because the Claude artifact publish supplies its own
# <!doctype>, <head> and <body>. A plain web host gets none of that, so this adds the doctype,
# charset, viewport and the small reset the artifact wrapper provides. Everything above the
# page's <div class="shell"> (title, icon, fonts, styles) goes in <head>; the rest in <body>.
set -eu

src=index.html
out=public

split=$(grep -n -m1 '^<div class="shell">' "$src" | cut -d: -f1)
if [ -z "$split" ]; then
  echo "build: could not find <div class=\"shell\"> in $src" >&2
  exit 1
fi

mkdir -p "$out"
{
  cat <<'HEAD'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="description" content="MOFlect: a design screen for peptide-targeted MOF nanocarriers. Assemble a carrier, coating, peptide and cargo, and get a ranked shortlist before anything is synthesised. Demo build on a pre-programmed model.">
<style>:root{color-scheme:light;box-sizing:border-box;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}html{scroll-padding-top:env(safe-area-inset-top,0px)}body{margin:0;padding:0}img{max-width:100%}</style>
HEAD
  head -n "$((split - 1))" "$src"
  printf '</head>\n<body>\n'
  tail -n "+$split" "$src"
  printf '\n</body>\n</html>\n'
} > "$out/index.html"

echo "build: wrote $out/index.html ($(wc -c < "$out/index.html" | tr -d ' ') bytes)"
