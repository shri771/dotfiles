#!/usr/bin/env bash
# =============================================================================
#  safe-unzip.sh — Interactive, sandboxed, malware-aware extraction tool
#
#  Usage:
#    ./safe-unzip.sh -f <archive.zip> -o <output_dir> [OPTIONS]
#
#  Flags:
#    -f  PATH     Path to the zip file to inspect/extract       (required)
#    -o  DIR      Destination directory for final extracted files (required)
#    -s           Skip ClamAV scan  (not recommended)
#    -n           Skip sandbox — extract directly (not recommended)
#    -u           Auto-run freshclam before scanning
#    -t  DIR      Work directory for temporary extraction
#    -y           Non-interactive: auto-confirm non-security prompts
#    -h           Show this help message
#
#  Examples:
#    ./safe-unzip.sh -f ~/Downloads/show.zip -o ~/Videos/Show
#    ./safe-unzip.sh -f ~/Downloads/show.zip -o ~/Videos/Show -u
#    ./safe-unzip.sh -f show.zip -o /media/nas/shows -s -n   # skip ClamAV/sandbox only
# =============================================================================

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# ANSI colours
# ─────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
BLU='\033[0;34m'
CYN='\033[0;36m'
BLD='\033[1m'
RST='\033[0m'

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────
info()    { echo -e "${BLU}[INFO]${RST}  $*"; }
success() { echo -e "${GRN}[OK]${RST}    $*"; }
warn()    { echo -e "${YLW}[WARN]${RST}  $*"; }
danger()  { echo -e "${RED}[DANGER]${RST} $*"; }
header()  { echo -e "\n${BLD}${CYN}══════════════════════════════════════${RST}"; \
            echo -e "${BLD}${CYN}  $*${RST}"; \
            echo -e "${BLD}${CYN}══════════════════════════════════════${RST}"; }

# Ask yes/no — respects -y (auto-yes) flag
# Usage: ask_confirm "Question?" || { action_on_no }
ask_confirm() {
  local question="$1"
  if [[ "$AUTO_YES" == true ]]; then
    echo -e "${YLW}[AUTO]${RST}  $question → yes"
    return 0
  fi
  echo -e "${YLW}[?]${RST}    $question ${BLD}(y/N)${RST}: \c"
  read -r answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

cleanup_sandbox() {
  if [[ -n "${SANDBOX_DIR:-}" && -d "$SANDBOX_DIR" ]]; then
    case "$(basename "$SANDBOX_DIR")" in
      safe_extract_*)
        rm -rf -- "$SANDBOX_DIR"
        ;;
    esac
  fi
  if [[ "${AUTO_WORK_DIR:-false}" == true && -n "${WORK_DIR:-}" && -d "$WORK_DIR" ]]; then
    rmdir -- "$WORK_DIR" 2>/dev/null || true
  fi
  if [[ -n "${FRESHCLAM_CONFIG:-}" && -f "$FRESHCLAM_CONFIG" && "$FRESHCLAM_CONFIG" == /tmp/freshclam.*.conf ]]; then
    rm -f -- "$FRESHCLAM_CONFIG"
  fi
}

secure_abort() {
  local message="$1"
  danger "$message"
  danger "Stopping for safety. Nothing will be moved to the output directory."
  cleanup_sandbox
  exit 1
}

# Ask user to press Enter to continue — skipped by -y
pause() {
  if [[ "${AUTO_YES:-false}" == true ]]; then
    return 0
  fi
  echo -e "${BLU}[...]${RST}  Press ${BLD}Enter${RST} to continue…"
  read -r
}

resolve_tool() {
  local tool="$1"
  local path
  path="$(command -v "$tool")" || return 1
  readlink -f "$path" 2>/dev/null || printf '%s\n' "$path"
}

clam_db_has_defs() {
  local dir="$1"
  [[ -d "$dir" ]] || return 1
  find "$dir" -maxdepth 1 -type f \( -name '*.cvd' -o -name '*.cld' -o -name '*.cud' \) -print -quit | grep -q .
}

select_clam_db() {
  CLAMSCAN_DB_ARGS=()

  local candidates=(
    "$CLAMAV_DB_DIR"
    "/var/lib/clamav"
    "/var/cache/clamav"
  )

  local dir
  for dir in "${candidates[@]}"; do
    if clam_db_has_defs "$dir"; then
      CLAMSCAN_DB_ARGS=(--database "$dir")
      CLAMAV_ACTIVE_DB_DIR="$dir"
      return 0
    fi
  done

  CLAMAV_ACTIVE_DB_DIR=""
  return 1
}

freshclam_args() {
  FRESHCLAM_ARGS=(--datadir="$CLAMAV_DB_DIR")

  if [[ -r /etc/clamav/freshclam.conf ]]; then
    FRESHCLAM_ARGS=(--config-file=/etc/clamav/freshclam.conf "${FRESHCLAM_ARGS[@]}")
    return 0
  fi

  FRESHCLAM_CONFIG="$(mktemp /tmp/freshclam.XXXXXX.conf)"
  {
    printf 'DatabaseDirectory %s\n' "$CLAMAV_DB_DIR"
    printf 'DatabaseMirror database.clamav.net\n'
  } > "$FRESHCLAM_CONFIG"

  FRESHCLAM_ARGS=(--config-file="$FRESHCLAM_CONFIG" "${FRESHCLAM_ARGS[@]}")
}

is_media_or_subtitle_file() {
  local file="$1"
  local lower="${file,,}"

  case "$lower" in
    *.mkv|*.mp4|*.m4v|*.avi|*.mov|*.webm|*.wmv|*.flv|*.ts|*.m2ts|*.mpg|*.mpeg|*.3gp|*.ogv|*.mp3|*.m4a|*.aac|*.flac|*.opus|*.ogg|*.wav|*.srt|*.ass|*.ssa|*.vtt|*.sub)
      return 0
      ;;
  esac

  local type
  type="$(file -b "$file" 2>/dev/null || true)"
  echo "$type" | grep -Eiq 'Matroska|WebM|MPEG|ISO Media|AVI|QuickTime|Ogg|FLAC|WAVE|SubRip|subtitle'
}

move_extracted_contents() {
  local item
  local moved=false

  shopt -s dotglob nullglob
  for item in "$SANDBOX_DIR"/*; do
    mv -- "$item" "$OUTPUT_DIR/"
    moved=true
  done
  shopt -u dotglob nullglob

  if [[ "$moved" != true ]]; then
    secure_abort "Extraction directory is empty; nothing to move."
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Dependency checker
# ─────────────────────────────────────────────────────────────────────────────
MISSING_DEPS=()
check_deps() {
  local required=("unzip" "file" "bwrap" "clamscan" "freshclam" "binwalk" "strings")
  for cmd in "${required[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      MISSING_DEPS+=("$cmd")
    fi
  done

  if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    warn "The following tools are not in PATH:"
    for dep in "${MISSING_DEPS[@]}"; do
      echo -e "    ${RED}✗${RST} $dep"
    done
    echo ""
    warn "Install them via home-manager or:"
    echo -e "    ${CYN}nix-shell -p clamav unzip bubblewrap binwalk binutils file${RST}"
    echo ""

    # Only hard-fail if a non-skippable tool is missing
    local critical=("unzip" "file")
    for dep in "${critical[@]}"; do
      if [[ " ${MISSING_DEPS[*]} " == *" $dep "* ]]; then
        danger "$dep is required and missing. Cannot continue."
        exit 1
      fi
    done
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Defaults
# ─────────────────────────────────────────────────────────────────────────────
ZIP_FILE=""
OUTPUT_DIR=""
WORK_DIR="${SAFE_UNZIP_WORKDIR:-}"
AUTO_WORK_DIR=false
SKIP_SCAN=false
SKIP_SANDBOX=false
AUTO_UPDATE_DB=false
AUTO_YES=false
SANDBOX_DIR=""
KEEP_SANDBOX=false
CLAMAV_DB_DIR="${CLAMAV_DB_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/clamav}"
CLAMAV_ACTIVE_DB_DIR=""
CLAMSCAN_DB_ARGS=()
CLAMAV_STATUS="not run"
FRESHCLAM_ARGS=()
FRESHCLAM_CONFIG=""
UNZIP_BIN=""

trap 'if [[ "${KEEP_SANDBOX:-false}" != true ]]; then cleanup_sandbox; fi' EXIT

# ─────────────────────────────────────────────────────────────────────────────
# Usage / help
# ─────────────────────────────────────────────────────────────────────────────
usage() {
  echo -e ""
  echo -e "${BLD}safe-unzip${RST} — Sandboxed, malware-checked archive extraction"
  echo -e ""
  echo -e "${BLD}USAGE${RST}"
  echo -e "  $0 -f <archive.zip> -o <output_dir> [OPTIONS]"
  echo -e ""
  echo -e "${BLD}REQUIRED FLAGS${RST}"
  echo -e "  -f  PATH    Path to the .zip archive to process"
  echo -e "  -o  DIR     Final destination directory for extracted files"
  echo -e ""
  echo -e "${BLD}OPTIONAL FLAGS${RST}"
  echo -e "  -u          Run freshclam first to update ClamAV virus database"
  echo -e "  -t  DIR     Temporary extraction work directory"
  echo -e "  -s          Skip ClamAV scan           ${RED}(not recommended)${RST}"
  echo -e "  -n          Skip sandbox extraction    ${RED}(not recommended)${RST}"
  echo -e "  -y          Non-interactive, auto-confirm non-security prompts"
  echo -e "  -h          Show this help message"
  echo -e ""
  echo -e "${BLD}EXAMPLES${RST}"
  echo -e "  $0 -f ~/Downloads/show.zip -o ~/Videos/Show"
  echo -e "  $0 -f ~/Downloads/show.zip -o ~/Videos/Show -u"
  echo -e "  $0 -f ~/Downloads/show.zip -o ~/Videos/Show -t /mnt/bigdisk/work"
  echo -e "  $0 -f ~/Downloads/show.zip -o ~/Videos -s -n -y"
  echo -e ""
  echo -e "${BLD}SECURITY BEHAVIOR${RST}"
  echo -e "  Malware detections, dangerous extensions, unsafe paths,"
  echo -e "  symlinks, executable signatures, and scan errors always abort."
  echo -e ""
  exit 0
}

# ─────────────────────────────────────────────────────────────────────────────
# Parse flags
# ─────────────────────────────────────────────────────────────────────────────
while getopts ":f:o:t:unsyh" opt; do
  case $opt in
    f) ZIP_FILE="$OPTARG" ;;
    o) OUTPUT_DIR="$OPTARG" ;;
    t) WORK_DIR="$OPTARG" ;;
    u) AUTO_UPDATE_DB=true ;;
    n) SKIP_SANDBOX=true ;;
    s) SKIP_SCAN=true ;;
    y) AUTO_YES=true ;;
    h) usage ;;
    :) danger "Flag -$OPTARG requires an argument."; usage ;;
    \?) danger "Unknown flag: -$OPTARG"; usage ;;
  esac
done

# ─────────────────────────────────────────────────────────────────────────────
# Validate required arguments
# ─────────────────────────────────────────────────────────────────────────────
if [[ -z "$ZIP_FILE" || -z "$OUTPUT_DIR" ]]; then
  danger "Both -f (file) and -o (output dir) are required."
  usage
fi

if [[ ! -f "$ZIP_FILE" ]]; then
  danger "File not found: $ZIP_FILE"
  exit 1
fi

ZIP_FILE="$(realpath "$ZIP_FILE")"
ZIP_NAME="$(basename "$ZIP_FILE")"
OUTPUT_DIR="$(realpath -m "$OUTPUT_DIR")"

if [[ -n "$WORK_DIR" ]]; then
  WORK_DIR="$(realpath -m "$WORK_DIR")"
else
  WORK_DIR="$OUTPUT_DIR/.safe-unzip-work"
  AUTO_WORK_DIR=true
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 0 — Check dependencies
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 0 — Checking dependencies"
check_deps
UNZIP_BIN="$(resolve_tool unzip)"
if [[ ${#MISSING_DEPS[@]} -eq 0 ]]; then
  success "All tools present."
else
  warn "Some optional tools missing — their steps will be skipped."
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Inspect the ZIP file itself (before anything else)
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 1 — Inspecting the ZIP file itself"

info "Checking true file type of the archive..."
FILE_TYPE=$(file "$ZIP_FILE")
echo -e "    ${CYN}$FILE_TYPE${RST}"

# Verify it's actually a zip
if ! echo "$FILE_TYPE" | grep -qi "zip\|archive"; then
  danger "This file does not appear to be a ZIP archive."
  danger "Reported type: $FILE_TYPE"
  danger "It may be a disguised executable. Aborting."
  exit 1
fi
success "Confirmed as a ZIP archive."

info "Archive size: $(du -sh "$ZIP_FILE" | cut -f1)"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — List archive contents without extracting
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 2 — Listing archive contents (no extraction)"

info "Files inside the archive:"
echo ""
unzip -l "$ZIP_FILE"
echo ""

ARCHIVE_NAMES="$(unzip -Z -1 "$ZIP_FILE")" || secure_abort "Could not read archive names."

UNSAFE_NAMES=()
while IFS= read -r entry; do
  [[ -z "$entry" ]] && continue
  if [[ "$entry" == /* \
        || "$entry" == "." \
        || "$entry" == ".." \
        || "$entry" == ../* \
        || "$entry" == */../* \
        || "$entry" == */.. \
        || "$entry" == *\\* \
        || "$entry" =~ ^[A-Za-z]: ]]; then
    UNSAFE_NAMES+=("$entry")
  fi
done <<< "$ARCHIVE_NAMES"

if [[ ${#UNSAFE_NAMES[@]} -gt 0 ]]; then
  danger "Unsafe archive paths found:"
  for unsafe in "${UNSAFE_NAMES[@]}"; do
    danger "  → $unsafe"
  done
  secure_abort "Unsafe archive paths found."
else
  success "No unsafe archive paths found."
fi

# Dangerous extension check
DANGEROUS_EXTS="exe|bat|cmd|scr|com|vbs|js|ps1|msi|sh|elf|dll|jar|wsf|lnk|pif"
DANGEROUS_FOUND=$(printf '%s\n' "$ARCHIVE_NAMES" | awk 'length($0) && $0 !~ /\/$/ { print }' | grep -Ei "\.(${DANGEROUS_EXTS})$" || true)

if [[ -n "$DANGEROUS_FOUND" ]]; then
  danger "DANGEROUS file extensions found inside the archive!"
  echo "$DANGEROUS_FOUND"
  echo ""
  secure_abort "Dangerous file extensions found inside the archive."
else
  success "No dangerous extensions found in file list."
fi

pause

# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Update ClamAV database (optional, -u flag)
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 3 — ClamAV virus database"

if [[ "$SKIP_SCAN" == true ]]; then
  warn "ClamAV scan will be skipped (-s flag). This is not recommended."
elif [[ "$AUTO_UPDATE_DB" == true ]]; then
  info "Running freshclam to update virus definitions into: $CLAMAV_DB_DIR"
  if command -v freshclam &>/dev/null; then
    mkdir -p "$CLAMAV_DB_DIR"
    freshclam_args
    if [[ -n "$FRESHCLAM_CONFIG" ]]; then
      info "System freshclam config not found; using temporary config: $FRESHCLAM_CONFIG"
    fi
    if freshclam "${FRESHCLAM_ARGS[@]}" 2>&1; then
      success "Virus definitions updated."
    else
      warn "freshclam failed. Continuing only if existing definitions are available."
    fi
  else
    warn "freshclam not found — skipping DB update."
  fi

  if select_clam_db; then
    success "Using ClamAV definitions from: $CLAMAV_ACTIVE_DB_DIR"
  else
    secure_abort "No ClamAV definitions found. Run again with -u when network access is available, or set CLAMAV_DB_DIR."
  fi
else
  warn "Virus DB not updated. Run with -u to update before scanning."
  if select_clam_db; then
    info "Using existing ClamAV definitions from: $CLAMAV_ACTIVE_DB_DIR"
  else
    secure_abort "No existing ClamAV definitions found. Run with -u, set CLAMAV_DB_DIR, or explicitly pass -s to skip scanning."
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — ClamAV scan of the ZIP file
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 4 — ClamAV malware scan"

if [[ "$SKIP_SCAN" == true ]]; then
  warn "Skipping ClamAV scan as requested."
  CLAMAV_STATUS="skipped"
elif command -v clamscan &>/dev/null && select_clam_db; then
  info "Scanning $ZIP_NAME — this may take a moment..."
  echo ""

  mkdir -p "$WORK_DIR"
  SCAN_RESULT=0
  clamscan "${CLAMSCAN_DB_ARGS[@]}" --tempdir="$WORK_DIR" --verbose --archive-verbose "$ZIP_FILE" || SCAN_RESULT=$?

  echo ""
  if [[ $SCAN_RESULT -eq 0 ]]; then
    success "ClamAV found no known malware."
    CLAMAV_STATUS="archive clean"
  elif [[ $SCAN_RESULT -eq 1 ]]; then
    CLAMAV_STATUS="malware detected"
    secure_abort "ClamAV detected malware in the archive."
  else
    CLAMAV_STATUS="scan error"
    secure_abort "ClamAV exited with code $SCAN_RESULT while scanning the archive."
  fi
else
  CLAMAV_STATUS="unavailable"
  secure_abort "clamscan or ClamAV definitions not found. Use -s only if you intentionally want to skip antivirus scanning."
fi

pause

# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 — Sandboxed extraction
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 5 — Extracting archive"

mkdir -p "$WORK_DIR"
SANDBOX_DIR="$(mktemp -d "$WORK_DIR/safe_extract_XXXXXX")"
info "Temporary sandbox directory: $SANDBOX_DIR"
info "Work directory is on: $(df -h --output=target "$WORK_DIR" | tail -n 1 | xargs)"
info "Available space there: $(df -h --output=avail "$WORK_DIR" | tail -n 1 | xargs)"

if [[ "$SKIP_SANDBOX" == false ]] && command -v bwrap &>/dev/null; then
  info "Extracting inside bubblewrap sandbox (no network, no home dir access)..."
  echo ""

  if ! bwrap \
    --ro-bind /nix /nix \
    --ro-bind "$(dirname "$ZIP_FILE")" /input \
    --tmpfs /tmp \
    --dir /extract \
    --bind "$SANDBOX_DIR" /extract \
    --unshare-all \
    --new-session \
    "$UNZIP_BIN" "/input/$ZIP_NAME" -d /extract; then
    secure_abort "Sandboxed extraction failed."
  fi

  success "Extraction complete inside sandbox."
else
  if [[ "$SKIP_SANDBOX" == true ]]; then
    warn "Sandbox skipped (-n flag). Extracting directly."
  else
    secure_abort "bwrap not found. Install bubblewrap or explicitly pass -n to extract without sandbox."
  fi
  if ! unzip "$ZIP_FILE" -d "$SANDBOX_DIR"; then
    secure_abort "Extraction failed."
  fi
  success "Extraction complete (no sandbox)."
fi

echo ""
info "Extracted contents:"
ls -lah "$SANDBOX_DIR"

SYMLINKS_FOUND=()
while IFS= read -r -d '' link; do
  SYMLINKS_FOUND+=("$link -> $(readlink "$link")")
done < <(find "$SANDBOX_DIR" -type l -print0)

if [[ ${#SYMLINKS_FOUND[@]} -gt 0 ]]; then
  danger "Symlinks found in extracted files:"
  for link in "${SYMLINKS_FOUND[@]}"; do
    danger "  → $link"
  done
  secure_abort "Symlinks are not allowed in extracted archives."
else
  success "No symlinks found in extracted files."
fi

pause

# ─────────────────────────────────────────────────────────────────────────────
# STEP 6 — Inspect extracted files with `file`
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 6 — Verifying true file types of extracted files"

info "Running 'file' on all extracted files to check real types..."
echo ""

SUSPICIOUS_FILES=()
while IFS= read -r -d '' f; do
  TYPE=$(file "$f")
  FNAME=$(basename "$f")

  # Flag if file looks like an executable regardless of its name
  if echo "$TYPE" | grep -qi "executable\|PE32\|ELF\|script\|batch"; then
    echo -e "  ${RED}✗ SUSPICIOUS${RST}: $FNAME"
    echo -e "    ${RED}→ $TYPE${RST}"
    SUSPICIOUS_FILES+=("$f")
  else
    echo -e "  ${GRN}✓${RST} $FNAME"
    echo -e "    ${CYN}→ $TYPE${RST}"
  fi
done < <(find "$SANDBOX_DIR" -type f -print0)

echo ""
if [[ ${#SUSPICIOUS_FILES[@]} -gt 0 ]]; then
  danger "${#SUSPICIOUS_FILES[@]} suspicious file(s) detected with executable signatures!"
  for sf in "${SUSPICIOUS_FILES[@]}"; do
    danger "  → $sf"
  done
  secure_abort "Suspicious executable/script file signatures found after extraction."
else
  success "All extracted files have expected non-executable types."
fi

pause

# ─────────────────────────────────────────────────────────────────────────────
# STEP 7 — Scan extracted files with ClamAV
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 7 — ClamAV scan on extracted files"

if [[ "$SKIP_SCAN" == false ]] && command -v clamscan &>/dev/null && select_clam_db; then
  info "Scanning all extracted files recursively..."
  echo ""

  SCAN2_RESULT=0
  clamscan "${CLAMSCAN_DB_ARGS[@]}" --tempdir="$WORK_DIR" -r --verbose "$SANDBOX_DIR" || SCAN2_RESULT=$?

  if [[ $SCAN2_RESULT -eq 0 ]]; then
    success "ClamAV found no malware in extracted files."
    CLAMAV_STATUS="passed"
  elif [[ $SCAN2_RESULT -eq 1 ]]; then
    CLAMAV_STATUS="malware detected"
    secure_abort "ClamAV detected malware in extracted files."
  else
    CLAMAV_STATUS="scan error"
    secure_abort "ClamAV exited with code $SCAN2_RESULT while scanning extracted files."
  fi
else
  if [[ "$SKIP_SCAN" == true ]]; then
    warn "Skipping post-extraction ClamAV scan as requested."
  else
    secure_abort "Post-extraction ClamAV scan unavailable. Use -s only if you intentionally want to skip antivirus scanning."
  fi
fi

pause

# ─────────────────────────────────────────────────────────────────────────────
# STEP 8 — binwalk: detect hidden embedded files
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 8 — Checking for hidden embedded files (binwalk)"

if command -v binwalk &>/dev/null; then
  info "Running binwalk on all extracted files..."
  echo ""
  BINWALK_OUT=""
  while IFS= read -r -d '' f; do
    echo -e "${BLD}→ $(basename "$f")${RST}"
    binwalk "$f"
    echo ""
  done < <(find "$SANDBOX_DIR" -type f -print0)
  success "binwalk scan complete. Review output above for anything unexpected."
else
  warn "binwalk not found — skipping embedded file detection."
fi

pause

# ─────────────────────────────────────────────────────────────────────────────
# STEP 9 — strings: detect suspicious URLs / commands embedded in files
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 9 — Checking for suspicious strings in files"

if command -v strings &>/dev/null; then
  info "Searching non-media files for suspicious command strings..."
  echo ""

  FOUND_SUSPICIOUS=false
  SKIPPED_MEDIA=0
  while IFS= read -r -d '' f; do
    if is_media_or_subtitle_file "$f"; then
      ((SKIPPED_MEDIA+=1))
      continue
    fi

    HITS=$(strings "$f" | grep -Ei "(cmd\.exe|powershell|/bin/(ba)?sh|wget[[:space:]]|curl[[:space:]]|exec\(|eval\(|base64[[:space:]]|Invoke-WebRequest|Invoke-Expression)" || true)
    if [[ -n "$HITS" ]]; then
      warn "Suspicious strings in: $(basename "$f")"
      echo "$HITS" | head -20      # show first 20 matches only
      echo ""
      FOUND_SUSPICIOUS=true
    fi
  done < <(find "$SANDBOX_DIR" -type f -print0)

  if [[ "$SKIPPED_MEDIA" -gt 0 ]]; then
    info "Skipped generic strings scan for $SKIPPED_MEDIA media/subtitle file(s) to avoid binary-video false positives."
  fi

  if [[ "$FOUND_SUSPICIOUS" == false ]]; then
    success "No suspicious strings found."
  else
    secure_abort "Suspicious strings were found in extracted files."
  fi
else
  secure_abort "'strings' not found. Install binutils or remove this check deliberately."
fi

pause

# ─────────────────────────────────────────────────────────────────────────────
# STEP 10 — Move files to final destination
# ─────────────────────────────────────────────────────────────────────────────
header "STEP 10 — Moving files to destination"

info "Source:      $SANDBOX_DIR"
info "Destination: $OUTPUT_DIR"
echo ""

if ! ask_confirm "Move extracted files to $OUTPUT_DIR?"; then
  warn "Files left in sandbox dir: $SANDBOX_DIR"
  info "You can inspect them manually or re-run."
  KEEP_SANDBOX=true
  exit 0
fi

mkdir -p "$OUTPUT_DIR"

move_extracted_contents

success "Files moved to: $OUTPUT_DIR"
cleanup_sandbox
echo ""
info "Final contents:"
ls -lah "$OUTPUT_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
header "ALL CHECKS COMPLETE"
success "Archive was processed through all safety layers."
echo ""
echo -e "  ${BLD}Archive:${RST}     $ZIP_FILE"
echo -e "  ${BLD}Output:${RST}      $OUTPUT_DIR"
echo -e "  ${BLD}ClamAV scan:${RST} $CLAMAV_STATUS"
echo -e "  ${BLD}Sandbox:${RST}     $( [[ $SKIP_SANDBOX == true ]] && echo 'skipped' || echo 'used' )"
echo ""
