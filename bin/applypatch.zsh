applypatch() {
  patch=$(pbpaste)
  if [[ $patch == "\`\`\`diff"*"\`\`\`"* ]]; then
    patch=${patch/'```diff'/''}
    patch=${patch/'```'/''}
  fi
  git apply - <<EOF
  $patch
EOF
}
