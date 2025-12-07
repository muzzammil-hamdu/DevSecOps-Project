#!/usr/bin/env bash
set -e

DEPENDENCY_CHECK_BIN="/opt/dependency-check/bin/dependency-check.sh"

if [ ! -f "$DEPENDENCY_CHECK_BIN" ]; then
  echo "Dependency-Check not installed. Skipping."
  exit 0
fi

mkdir -p dependency-check-report

$DEPENDENCY_CHECK_BIN \
  --project "Netflix" \
  --scan "." \
  --format "HTML" \
  --out dependency-check-report \
  || true

echo "Dependency-Check completed."
