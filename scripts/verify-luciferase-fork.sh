#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
GIT_COMMON_DIR="$(git -C "$ROOT_DIR" rev-parse --path-format=absolute --git-common-dir)"
SCOPE="${1:-all}"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_fixed() {
  local needle="$1"
  local file="$2"
  grep -Fq -- "$needle" "$ROOT_DIR/$file" || fail "$file is missing: $needle"
}

forbid_fixed() {
  local needle="$1"
  local file="$2"
  if grep -Fq -- "$needle" "$ROOT_DIR/$file"; then
    fail "$file still contains forbidden text: $needle"
  fi
}

verify_lineage() {
  local repository_description
  git -C "$ROOT_DIR" merge-base --is-ancestor a57da43 HEAD || fail "Lophine baseline is not in history"
  test "$(git -C "$ROOT_DIR" remote get-url upstream)" = "https://github.com/LophineLabs/Lophine" || fail "upstream URL is incorrect"
  test ! -d "$ROOT_DIR/Lophine" || fail "nested Lophine checkout still exists"
  repository_description="$(cat "$GIT_COMMON_DIR/description")"
  if [[ "$repository_description" != "Unnamed repository"* ]]; then
    test "$repository_description" = "Make your server glow in the dark." || fail "local repository description is incorrect"
  fi
}

verify_docs() {
  require_fixed "# Luciferase" "README.md"
  require_fixed "Make your server glow in the dark." "README.md"
  require_fixed "Luciferase is a server fork based on [Lophine](https://github.com/LophineLabs/Lophine)." "README.md"
  forbid_fixed "cnb.cool/LophineLabs" "README.md"
  forbid_fixed "bstats.org/signatures/server-implementation/Lophine" "README.md"
}

verify_runtime() {
  require_fixed 'rootProject.name = "luciferase"' "settings.gradle.kts"
  require_fixed 'Key BRAND_LUCIFERASE_ID = Key.key("luciferase", "luciferase");' "lophine-api/paper-patches/features/0001-Rebrand-to-Lophine.patch"
  require_fixed '"Brand-Id" to "luciferase:luciferase"' "lophine-server/build.gradle.kts.patch"
  require_fixed '"Brand-Name" to "Luciferase"' "lophine-server/build.gradle.kts.patch"
  require_fixed 'base.archivesName = "luciferase"' "lophine-server/build.gradle.kts.patch"
  require_fixed 'public static String serverModName = "Luciferase";' "lophine-server/src/main/java/me/earthme/luminol/config/modules/misc/ServerModNameConfig.java"
  require_fixed 'Luciferase auto-update is not configured; automatic updates remain disabled.' "lophine-server/src/main/java/me/earthme/luminol/utils/AutoUpdateHelper.java"
  test ! -e "$ROOT_DIR/lophine-server/minecraft-patches/features/0001-Set-Lophine-logo.patch" || fail "Lophine GUI logo patch is still active"
}

verify_ci() {
  require_fixed "name: Luciferase CI" ".github/workflows/build.yml"
  require_fixed "permissions:" ".github/workflows/build.yml"
  require_fixed "contents: read" ".github/workflows/build.yml"
  require_fixed "name: Luciferase server" ".github/workflows/build.yml"
  forbid_fixed "LophineLabs" ".github/workflows/build.yml"
  forbid_fixed "CNB" ".github/workflows/build.yml"
  forbid_fixed "PRIVATE_MAVEN_REPO" ".github/workflows/build.yml"
  test ! -e "$ROOT_DIR/.cnb.yml" || fail ".cnb.yml is still active"
  test ! -e "$ROOT_DIR/scripts/SetENV.sh" || fail "legacy release script is still active"
}

verify_compat() {
  require_fixed "group=fun.bm.lophine" "gradle.properties"
  test -d "$ROOT_DIR/lophine-server/src/main/java/fun/bm/lophine" || fail "Lophine Java compatibility package is missing"
  test -d "$ROOT_DIR/lophine-server/src/main/resources/assets/lophine/lang" || fail "Lophine resource namespace is missing"
  require_fixed 'include(name)' "settings.gradle.kts"
  require_fixed 'listOf("lophine-api", "lophine-server")' "settings.gradle.kts"
}

case "$SCOPE" in
  lineage) verify_lineage ;;
  docs) verify_docs ;;
  runtime) verify_runtime ;;
  ci) verify_ci ;;
  compat) verify_compat ;;
  all)
    verify_lineage
    verify_docs
    verify_runtime
    verify_ci
    verify_compat
    ;;
  *) fail "unknown scope: $SCOPE" ;;
esac

echo "Luciferase fork verification passed: $SCOPE"
