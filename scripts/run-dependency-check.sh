#!/usr/bin/env bash

# OWASP Dependency-Check runner for CI/CD
# - Tries multiple common install paths
# - Generates HTML report
# - Does NOT fail the pipeline if tool is missing or scan fails

set -u  # treat unset vars as error (but we won't use -e so we can handle failures nicely)

PROJECT_NAME="${PROJECT_NAME:-Netflix}"
SCAN_PATH="${SCAN_PATH:-.}"
REPORT_DIR="${REPORT_DIR:-dependency-check-report}"
REPORT_FORMAT="${REPORT_FORMAT:-HTML}"

# Try to detect dependency-check binary
detect_dependency_check() {
  # 1) Env override
  if [[ -n "${DEPENDENCY_CHECK_BIN:-}" && -x "${DEPENDENCY_CHECK_BIN}" ]]; then
    echo "${DEPENDENCY_CHECK_BIN}"
    return 0
  fi

  # 2) Common locations
  local CANDIDATES=(
    "/usr/local/bin/dependency-check.sh"
    "/opt/dependency-check/dependency-check/bin/dependency-check.sh"
    "/opt/dependency-check/bin/dependency-check.sh"
    "dependency-check.sh"
  )

  for bin in "${CANDIDATES[@]}"; do
    if command -v "${bin}" >/dev/null 2>&1; then
      command -v "${bin}"
      return 0
    elif [[ -x "${bin}" ]]; then
      echo "${bin}"
      return 0
    fi
  done

  return 1
}

main() {
  echo "=== OWASP Dependency-Check ==="
  echo "Project   : ${PROJECT_NAME}"
  echo "Scan path : ${SCAN_PATH}"
  echo "Reports   : ${REPORT_DIR}"
  echo

  # Locate binary
  if ! DC_BIN="$(detect_dependency_check)"; then
    echo "[-] Dependency-Check binary not found."
    echo "    Tried: /usr/local/bin, /opt/dependency-check/dependency-check/bin, /opt/dependency-check/bin, PATH"
    echo "    Skipping OWASP scan (pipeline will NOT fail)."
    exit 0
  fi

  echo "[+] Using Dependency-Check binary: ${DC_BIN}"
  mkdir -p "${REPORT_DIR}"

  # Run scan (never fail the pipeline because of this)
  set +e
  "${DC_BIN}" \
    --project "${PROJECT_NAME}" \
    --scan "${SCAN_PATH}" \
    --format "${REPORT_FORMAT}" \
    --out "${REPORT_DIR}" \
    --enableExperimental \
    --noupdate
  DC_EXIT_CODE=$?
  set -e || true 2>/dev/null || true

  if [[ ${DC_EXIT_CODE} -ne 0 ]]; then
    echo "[-] Dependency-Check finished with exit code ${DC_EXIT_CODE}."
    echo "    This will NOT fail the pipeline, but check the report for details."
  else
    echo "[+] Dependency-Check completed successfully."
  fi

  echo
  echo "Reports generated under: ${REPORT_DIR}"
  echo "Open the HTML file (e.g. dependency-check-report.html) in a browser to view results."
}

main "$@"
