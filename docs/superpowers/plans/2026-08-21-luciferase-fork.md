# Luciferase Fork Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the imported Lophine baseline into a compatibility-first Luciferase server fork that is visibly distinct, safely isolated from LophineLabs operations, and still compatible with Lophine plugins and configuration.

**Architecture:** Keep Lophine's patch directories, Java packages, configuration namespaces, and API coordinates as the compatibility layer. Add Luciferase identity only at repository, distribution, manifest, build-info, documentation, and CI boundaries; block integrations that would otherwise report to or download from Lophine services. A repository verification script encodes these boundaries and is expanded task-by-task before each implementation change.

**Tech Stack:** Git, Bash, Gradle Kotlin DSL, Comfreyweight/Paperweight patch files, Java 25, GitHub Actions YAML

**Spec:** `docs/superpowers/specs/2026-08-21-luciferase-fork-design.md`

## Global Constraints

- Use Lophine commit `a57da43` from `ver/26.2-hardfork` as the imported baseline and retain its reachable history and tags.
- Configure `upstream` as `https://github.com/LophineLabs/Lophine`; do not invent an `origin` URL.
- Use the exact tagline `Make your server glow in the dark.`
- State prominently that Luciferase is a server fork based on Lophine and link to the Lophine repository.
- Preserve `fun.bm.lophine`, existing Lophine config/resource/command/permission identifiers, and `fun.bm.lophine:lophine-api` compatibility coordinates.
- Use `luciferase:luciferase` as the runtime brand ID and recognize Luciferase, Lophine, Folia, and Paper as compatible brands.
- Do not add a logo, telemetry project, update endpoint, Maven publishing target, release destination, or repository owner that has not been provisioned.
- Do not allow active automation to push to, publish to, or trigger LophineLabs/CNB/Bacteriawa infrastructure.
- Continue reading dependency repositories required to compile inherited Lophine code.
- Use Java 25 and the existing Gradle wrapper.

---

### Task 1: Repository Lineage and Fork Contract

**Files:**
- Create: `scripts/verify-luciferase-fork.sh`
- Modify: `.git/description` (local repository metadata, not committed)
- Remove: `Lophine/` (ignored nested import checkout, after upstream tags are fetched)

**Interfaces:**
- Consumes: the current branch containing Lophine baseline commit `a57da43`
- Produces: `scripts/verify-luciferase-fork.sh [lineage|docs|runtime|ci|compat|all]`, plus a configured `upstream` remote

- [ ] **Step 1: Write the fork contract verifier**

Create `scripts/verify-luciferase-fork.sh` with this exact structure:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
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
  git -C "$ROOT_DIR" merge-base --is-ancestor a57da43 HEAD || fail "Lophine baseline is not in history"
  test "$(git -C "$ROOT_DIR" remote get-url upstream)" = "https://github.com/LophineLabs/Lophine" || fail "upstream URL is incorrect"
  test ! -d "$ROOT_DIR/Lophine" || fail "nested Lophine checkout still exists"
  test "$(cat "$ROOT_DIR/.git/description")" = "Make your server glow in the dark." || fail "local repository description is incorrect"
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
```

- [ ] **Step 2: Run the lineage scope and confirm it fails before setup**

Run:

```bash
bash scripts/verify-luciferase-fork.sh lineage
```

Expected: FAIL because the `upstream` remote is missing, the nested checkout exists, or the local description is still Git's default.

- [ ] **Step 3: Establish repository lineage and remove the redundant import**

Run:

```bash
git remote add upstream https://github.com/LophineLabs/Lophine
git fetch upstream --tags
printf '%s\n' 'Make your server glow in the dark.' > .git/description
rm -rf -- /root/luciferase/Lophine
chmod +x scripts/verify-luciferase-fork.sh
```

Before removal, confirm `git merge-base --is-ancestor a57da43 HEAD` succeeds and `git fetch upstream --tags` completes. The nested checkout is recoverable from the retained history and upstream remote.

- [ ] **Step 4: Run lineage and compatibility verification**

Run:

```bash
bash scripts/verify-luciferase-fork.sh lineage
bash scripts/verify-luciferase-fork.sh compat
```

Expected: both commands print `Luciferase fork verification passed`.

- [ ] **Step 5: Commit the fork contract**

```bash
git add scripts/verify-luciferase-fork.sh
git commit -m "chore: establish Luciferase fork lineage"
```

### Task 2: Documentation and Repository Identity

**Files:**
- Modify: `README.md`
- Modify: `README.en.md`
- Create: `README.zh-CN.md`
- Modify: `README.zh-TW.md`
- Modify: `LICENSE.md`
- Modify: `docs/CONTRIBUTING_EN.md`
- Modify: `docs/CONTRIBUTING.md`
- Modify: `docs/CONTRIBUTING_ZH_TW.md`
- Modify: `docs/CONTRIBUTING_JP.md`
- Modify: `.github/ISSUE_TEMPLATE/bug-report.yml`
- Modify: `.github/ISSUE_TEMPLATE/feature-request.yml`

**Interfaces:**
- Consumes: preserved compatibility names from the global constraints
- Produces: a canonical English `README.md`, accurate localized entry points, and Luciferase-facing contribution/issue guidance

- [ ] **Step 1: Run the documentation contract and confirm it fails**

Run:

```bash
bash scripts/verify-luciferase-fork.sh docs
```

Expected: FAIL because `README.md` still identifies the project as Lophine.

- [ ] **Step 2: Replace the canonical README with the Luciferase project page**

Write `README.md` with these sections and exact lead copy:

```markdown
# Luciferase

> Make your server glow in the dark.

Luciferase is a server fork based on [Lophine](https://github.com/LophineLabs/Lophine).
It carries Lophine's Folia-based optimizations, configurable vanilla behavior,
redstone-oriented features, bug fixes, and utility features into an independent
downstream project.
```

Follow the introduction with `Features`, `Compatibility`, `Requirements`,
`Building`, `API compatibility`, `Upstream`, `Contributing`, and `License`.
Use Java 25 and these build commands:

```bash
./gradlew applyAllPatches
./gradlew createPaperclipJar
```

State that the server JAR is written under `lophine-server/build/libs/` because
the module path remains stable for compatibility. Show
`fun.bm.lophine:lophine-api:26.2.build.+` as the preserved API coordinate. Do
not include download, issue, release, community, telemetry, repository-owner,
or mirror links for services that have not been configured.

- [ ] **Step 3: Make localized entry points accurate**

Change `README.en.md` into a short pointer to canonical `README.md`. Rewrite
`README.zh-TW.md` as a concise Traditional Chinese Luciferase introduction with
the tagline, explicit Lophine fork attribution, compatibility note, Java 25
requirement, the two Gradle build commands, and a link to `README.md`.

Rewrite the current Simplified Chinese material in the old `README.md` into
`README.zh-CN.md`, preserving the same concise facts. Add `README.zh-CN.md` to
the language links in `README.md` and `README.zh-TW.md`.

- [ ] **Step 4: Update license and contributor-facing product names without renaming compatibility paths**

Change the first English and Chinese paragraphs of `LICENSE.md` to say that
Luciferase is forked from Lophine and inherits the included upstream licenses.
Keep the GPL/MIT terms and author list unchanged.

In each `docs/CONTRIBUTING*.md`, change the title and project-introduction prose
to Luciferase. Add an early note equivalent to:

```markdown
Luciferase intentionally retains the `lophine-api`, `lophine-server`,
`fun.bm.lophine`, and `assets/lophine` names as compatibility interfaces.
Do not rename them in ordinary contributions.
```

Keep path names and inherited-patch attribution as Lophine where they describe
the compatibility layer. Update issue templates so prompts and sample version
strings say Luciferase while the diagnostic `lophine_config` path remains.

- [ ] **Step 5: Verify documentation and commit**

Run:

```bash
bash scripts/verify-luciferase-fork.sh docs
bash scripts/verify-luciferase-fork.sh compat
rg -n 'cnb\.cool/LophineLabs|bstats\.org/signatures/server-implementation/Lophine' README*.md
git diff --check
```

Expected: the verifier scopes pass, `rg` returns no matches, and `git diff --check` is silent.

Commit:

```bash
git add README.md README.en.md README.zh-CN.md README.zh-TW.md LICENSE.md docs/CONTRIBUTING*.md .github/ISSUE_TEMPLATE
git commit -m "docs: introduce Luciferase"
```

### Task 3: Build and Runtime Branding

**Files:**
- Modify: `settings.gradle.kts`
- Modify: `build.gradle.kts`
- Modify: `lophine-api/paper-patches/features/0001-Rebrand-to-Lophine.patch`
- Modify: `lophine-server/paper-patches/features/0001-Rebrand-to-Lophine.patch`
- Modify: `lophine-server/build.gradle.kts.patch`
- Modify: `lophine-server/src/main/java/me/earthme/luminol/config/modules/misc/ServerModNameConfig.java`
- Modify: `lophine-server/src/main/java/me/earthme/luminol/utils/AutoUpdateHelper.java`
- Modify: `lophine-server/src/main/resources/assets/lophine/lang/en_us.json`
- Modify: `lophine-server/src/main/resources/assets/lophine/lang/zh_cn.json`
- Modify: `lophine-server/src/main/resources/assets/lophine/lang/zh_tw.json`
- Remove: `lophine-server/minecraft-patches/features/0001-Set-Lophine-logo.patch`

**Interfaces:**
- Consumes: Lophine's existing patch stack and compatibility identifiers
- Produces: Luciferase build metadata, `luciferase:luciferase` runtime identity, Luciferase archive base names, and safe disabled integrations

- [ ] **Step 1: Run the runtime contract and confirm it fails**

Run:

```bash
bash scripts/verify-luciferase-fork.sh runtime
```

Expected: FAIL at the old Gradle root project name or the missing Luciferase brand ID.

- [ ] **Step 2: Change distribution-level Gradle identity**

In `settings.gradle.kts`, set:

```kotlin
rootProject.name = "luciferase"
```

Keep the included projects as `lophine-api` and `lophine-server`. Rename the
local variables `lophineVersionChannel` and `lophineBuildNumber` to
`luciferaseVersionChannel` and `luciferaseBuildNumber` without changing the
version format.

In `build.gradle.kts`, change only user-facing task metadata:

```kotlin
group = "luciferase"
description = "Sort Luciferase language files by key in ASCII (ordinal) order"
```

Keep the resource directory `assets/lophine/lang` unchanged.

- [ ] **Step 3: Add Luciferase brand identity while preserving ancestry**

Update the API rebrand patch so `ServerBuildInfo` contains all four constants:

```java
Key BRAND_PAPER_ID = Key.key("papermc", "paper");
Key BRAND_FOLIA_ID = Key.key("papermc", "folia");
Key BRAND_LOPHINE_ID = Key.key("lophinelabs", "lophine");
Key BRAND_LUCIFERASE_ID = Key.key("luciferase", "luciferase");
```

Update the server rebrand patch so `ServerBuildInfoImpl` defaults to
`BRAND_LUCIFERASE_ID` and `Luciferase`. Its compatibility expression must be:

```java
return brandId.equals(this.brandId)
    || brandId.equals(BRAND_PAPER_ID)
    || brandId.equals(BRAND_FOLIA_ID)
    || brandId.equals(BRAND_LOPHINE_ID)
    || brandId.equals(BRAND_LUCIFERASE_ID);
```

Change metrics version labels and strings from Lophine to Luciferase, but force
the unprovisioned metrics block off with:

```java
if (false) { // Luciferase - no bStats project has been provisioned
```

Change watchdog guidance to `If you are unsure or still think this is a Luciferase bug, report it to the Luciferase repository where you obtained this build.` Do not add a guessed issue URL. Retain the Lophine repository only where `PaperVersionFetcher` compares this downstream against its declared upstream; its download link must be described in the patch comment as the upstream source, not a Luciferase release destination.

- [ ] **Step 4: Brand manifests and distribution archives**

In `lophine-server/build.gradle.kts.patch`, add this alongside the existing
plugins/build configuration:

```kotlin
base.archivesName = "luciferase"
```

Set manifest values exactly as follows:

```kotlin
"Implementation-Title" to "Luciferase",
"Specification-Title" to "Luciferase",
"Specification-Vendor" to "Luciferase contributors",
"Brand-Id" to "luciferase:luciferase",
"Brand-Name" to "Luciferase",
```

Keep `implementation(project(":lophine-api"))` and the API publication coordinates unchanged.

- [ ] **Step 5: Disable unprovisioned external integrations and remove the inherited logo**

Change `ServerModNameConfig.serverModName` to `Luciferase`.

Add this non-constant capability method to `AutoUpdateHelper`:

```java
private static boolean updatesConfigured() {
    return false;
}
```

At the start of `load(boolean reload)`, after shutting down on reload and before
creating directories or threads, add:

```java
if (!updatesConfigured()) {
    LOGGER.warn("Luciferase auto-update is not configured; automatic updates remain disabled.");
    return;
}
```

This deliberately preserves the config class and key while ensuring even an
existing `enabled = true` configuration cannot download a Lophine release.
Update the three language-resource comments for auto-update to explain that it
is unavailable in this initial Luciferase fork; do not rename their keys.

Delete `lophine-server/minecraft-patches/features/0001-Set-Lophine-logo.patch`.
Leave the unused credited source images under `public/image/lophine/` intact as
upstream material, but remove all README references to them.

- [ ] **Step 6: Run focused verification and patch application**

Run:

```bash
bash scripts/verify-luciferase-fork.sh runtime
bash scripts/verify-luciferase-fork.sh compat
./gradlew applyAllPatches
git diff --check
```

Expected: both verifier scopes pass, Gradle ends with `BUILD SUCCESSFUL`, and
`git diff --check` is silent.

- [ ] **Step 7: Inspect generated branding and commit**

Run:

```bash
rg -n 'BRAND_LUCIFERASE_ID|Luciferase|luciferase:luciferase' paper-api paper-server folia-api folia-server
rg -n 'fun\.bm\.lophine|assets/lophine' lophine-api lophine-server | head -n 20
```

Expected: generated build-info sources contain Luciferase identity, while the
compatibility search still returns Lophine package/resource paths.

Commit:

```bash
git add settings.gradle.kts build.gradle.kts lophine-api lophine-server
git commit -m "feat: rebrand server runtime as Luciferase"
```

### Task 4: CI Isolation and Build Artifact

**Files:**
- Modify: `.github/workflows/build.yml`
- Remove: `.cnb.yml`
- Remove: `scripts/SetENV.sh`

**Interfaces:**
- Consumes: existing Gradle `applyAllPatches` and `createPaperclipJar` tasks
- Produces: read-only GitHub Actions CI that uploads a Luciferase server artifact and has no release/publish side effects

- [ ] **Step 1: Run the CI contract and confirm it fails**

Run:

```bash
bash scripts/verify-luciferase-fork.sh ci
```

Expected: FAIL because the inherited workflow still contains LophineLabs CNB and publishing steps.

- [ ] **Step 2: Replace the workflow with build-only CI**

Replace `.github/workflows/build.yml` with:

```yaml
name: Luciferase CI

on:
  push:
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v7
        with:
          fetch-depth: 0

      - name: Set up JDK 25
        uses: actions/setup-java@v5.7.0
        with:
          distribution: zulu
          java-version: 25

      - name: Set up Gradle
        uses: gradle/actions/setup-gradle@v6

      - name: Verify fork boundaries
        run: ./scripts/verify-luciferase-fork.sh all

      - name: Apply patches
        run: ./gradlew applyAllPatches

      - name: Build Paperclip server
        run: ./gradlew createPaperclipJar

      - name: Upload Luciferase server
        uses: actions/upload-artifact@v7
        with:
          name: Luciferase server
          path: lophine-server/build/libs/luciferase-paperclip-*.jar
          if-no-files-found: error
```

No write permission, secrets, publishing tasks, release action, Docker mirror,
or external API trigger is allowed in this workflow.

- [ ] **Step 3: Remove inherited operational publishing files**

Delete `.cnb.yml` and `scripts/SetENV.sh`. Do not remove dependency repository
declarations from Gradle; they are compile-time inputs rather than publishing
destinations.

- [ ] **Step 4: Verify CI isolation and commit**

Run:

```bash
bash scripts/verify-luciferase-fork.sh ci
rg -n 'LophineLabs|cnb\.cool|api\.cnb\.cool|PRIVATE_MAVEN_REPO|ncipollo/release-action' .github .cnb.yml scripts/SetENV.sh 2>/dev/null
git diff --check
```

Expected: the CI verifier passes, `rg` returns no active automation matches,
and `git diff --check` is silent.

Commit:

```bash
git add -A .github/workflows/build.yml .cnb.yml scripts/SetENV.sh
git commit -m "ci: isolate Luciferase builds from upstream publishing"
```

### Task 5: Full Build and Distribution Verification

**Files:**
- Modify only if verification exposes an error: the maintained source, patch,
  build, documentation, or verifier file responsible for that exact error

**Interfaces:**
- Consumes: Tasks 1-4
- Produces: a verified Luciferase Paperclip JAR and final evidence for every acceptance criterion

- [ ] **Step 1: Run repository contract verification**

Run:

```bash
./scripts/verify-luciferase-fork.sh all
git diff --check
```

Expected: the contract passes and the diff check is silent.

- [ ] **Step 2: Rebuild patches from a clean generated state**

Run:

```bash
./gradlew clean applyAllPatches
```

Expected: `BUILD SUCCESSFUL` with all Folia/Lophine patches applied.

- [ ] **Step 3: Build the server distribution**

Run:

```bash
./gradlew createPaperclipJar
```

Expected: `BUILD SUCCESSFUL` and exactly one current
`lophine-server/build/libs/luciferase-paperclip-*.jar` output.

- [ ] **Step 4: Inspect the built manifest and archive name**

Run:

```bash
artifact="$(find lophine-server/build/libs -maxdepth 1 -type f -name 'luciferase-paperclip-*.jar' -print -quit)"
test -n "$artifact"
unzip -p "$artifact" META-INF/MANIFEST.MF | tee /tmp/luciferase-manifest.txt
grep -F 'Implementation-Title: Luciferase' /tmp/luciferase-manifest.txt
grep -F 'Specification-Title: Luciferase' /tmp/luciferase-manifest.txt
grep -F 'Brand-Id: luciferase:luciferase' /tmp/luciferase-manifest.txt
grep -F 'Brand-Name: Luciferase' /tmp/luciferase-manifest.txt
```

Expected: all four manifest assertions pass.

- [ ] **Step 5: Audit public and compatibility names**

Run:

```bash
rg -n 'LophineLabs|cnb\.cool|bstats\.org/signatures/server-implementation/Lophine' README*.md .github scripts
rg -n 'fun\.bm\.lophine|assets/lophine|group=fun\.bm\.lophine' gradle.properties lophine-api lophine-server | head -n 40
git remote -v
git log --oneline --decorate -5
git status --short --branch
```

Expected: the first search finds no active operational/public link except the
intentional upstream attribution in README content, the compatibility search
finds preserved identifiers, `upstream` points to Lophine, history includes
`a57da43`, and status contains no unintended generated files.

- [ ] **Step 6: Fix only verified defects, rerun the failing command, and commit**

For each failure, modify the maintained source responsible for it, rerun that
exact failing command, then rerun Steps 1-5. Do not edit generated `paper-*` or
`folia-*` output directly.

If tracked fixes were required, commit them with:

```bash
git add -u
git commit -m "fix: complete Luciferase fork verification"
```

If no tracked fixes were required, do not create an empty commit.
