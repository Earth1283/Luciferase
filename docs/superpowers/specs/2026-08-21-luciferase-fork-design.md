# Luciferase Fork Design

## Summary

Luciferase is a compatibility-first server fork based on Lophine. It preserves
Lophine's established plugin, configuration, and source compatibility surfaces
while giving the distributable server a distinct public identity.

The project tagline is:

> Make your server glow in the dark.

Every primary project description must also state plainly that Luciferase is
forked from Lophine and link to the Lophine upstream repository.

## Goals

- Preserve Lophine's complete Git history and make future upstream syncing
  straightforward.
- Present Luciferase consistently in server-visible output, build metadata,
  distributable filenames, CI, and primary documentation.
- Preserve compatibility-sensitive Lophine identifiers so existing plugins,
  configuration, automation, and integrations continue to work.
- Remove workflows and links that would incorrectly use or represent
  LophineLabs infrastructure as Luciferase infrastructure.
- Leave the repository in a buildable, verifiable state suitable for future
  Luciferase-specific development.

## Non-goals

- Renaming Java packages under `fun.bm.lophine`.
- Renaming existing configuration files, configuration keys, resource keys,
  command names, or data directories solely for cosmetic consistency.
- Breaking or replacing existing Lophine API coordinates in this initial fork.
- Creating a new logo or broader visual identity.
- Adding new gameplay, performance, or server-management features.
- Configuring release publishing destinations without known Luciferase-owned
  infrastructure and credentials.

## Repository Lineage and Layout

The outer Luciferase repository will use Lophine commit `a57da43` from branch
`ver/26.2-hardfork` as its initial upstream baseline. The full reachable
Lophine history and tags will be retained rather than importing a source-only
snapshot.

The project files will live at the Luciferase repository root. The temporary
nested `Lophine` checkout is only an import source and will be removed after the
history and working tree are established. The repository will configure an
`upstream` remote pointing to:

`https://github.com/LophineLabs/Lophine`

No Luciferase `origin` URL will be invented. If the host environment has not
provided one, the repository will remain ready for the user to configure it.

## Branding Boundary

### Public Luciferase identity

The following surfaces will use the name `Luciferase`:

- README title, tagline, project description, build instructions, and artifact
  paths.
- Gradle root project identity and human-facing task descriptions.
- API and server subproject display names where changing them does not change
  compatibility coordinates.
- Server manifest implementation/specification titles and brand name.
- Server build information, version strings, console/crash-report guidance,
  and other user-visible product labels introduced by the existing rebrand
  patches.
- CI workflow and uploaded artifact display names.
- Paperclip/server distribution filenames.

The server brand ID will be `luciferase:luciferase`. Its compatibility check
will recognize Luciferase, Lophine, Folia, and Paper brand IDs so software that
tests ancestry continues to receive an accurate answer.

The initial fork will not claim a Luciferase bStats project or update service
that has not been provisioned. Existing telemetry or update integration must
not falsely publish Luciferase instances as Lophine, and unsupported
Luciferase-specific endpoints must not be invented.

### Preserved Lophine compatibility identity

The following remain unchanged in the initial fork:

- `fun.bm.lophine` Java package names and public classes.
- Existing Lophine configuration filenames, directories, keys, resource
  namespaces, and language keys.
- Commands and permission identifiers that contain `lophine`.
- Existing Lophine API group/artifact coordinates and compatibility-facing
  module paths where renaming would break consumers or patch application.
- Internal source comments and patch attribution that identify work inherited
  from Lophine.

User-facing prose inside compatibility resources may say Luciferase where it
describes the running product, but keys and paths remain stable.

## Attribution and Documentation

The primary README will lead with the Luciferase name and tagline, followed by
a prominent statement that it is a server fork based on Lophine. That statement
will link to the upstream repository. The README will retain the useful feature
summary, prerequisites, build commands, licensing information, and upstream
credit without retaining LophineLabs community, support, download, or issue
links as though they belong to Luciferase.

Existing license files and authorship history remain intact. Inherited code and
patch attribution will not be rewritten to obscure its origin.

Localized READMEs will not advertise stale Lophine release or support
infrastructure. If a complete translated Luciferase rewrite is not available,
they will provide a short accurate Luciferase introduction, upstream
attribution, and a link to the canonical English README rather than presenting
outdated operational details.

The local Git repository description will use `Make your server glow in the
dark.` GitHub repository metadata can only be set when a Luciferase origin is
known and authenticated; otherwise the handoff will give the user that exact
description to apply.

## Build and Patch Structure

Lophine is a Gradle patch-based Folia fork. The Luciferase change will remain a
small downstream patch layer rather than rewriting generated upstream source.
Branding changes will be made in the maintained Gradle build files and patch
files from which the build is generated.

Compatibility-sensitive source/module paths remain stable unless a path is
purely a distribution label. Server distribution archives will use Luciferase
names. The API's existing published coordinates remain available; this initial
fork does not introduce a second, unconfigured Maven publication namespace.

Patch subjects and contents created specifically for the downstream fork will
say Luciferase. Existing patch comments that attribute inherited Lophine work
remain Lophine.

## CI and External Services

The GitHub Actions workflow will build and validate Luciferase, then upload the
resulting server artifact. It will not:

- push to LophineLabs CNB repositories;
- trigger LophineLabs CNB release pipelines;
- publish to LophineLabs/Bacteriawa Maven repositories;
- use a LophineLabs CI identity;
- generate release links under the LophineLabs GitHub organization; or
- assume Luciferase release secrets or destinations that have not been
  provided.

Build dependencies may continue to read from required upstream repositories.
Removing an operational publishing action does not imply removing repositories
needed to compile inherited code.

The default workflow will run patch application and the Paperclip build, then
upload the produced Luciferase artifact. Release publishing can be designed
separately once the repository owner and destinations are known.

## Error Handling and Safe Defaults

- Unknown repository URLs are omitted rather than replaced with placeholders
  or guessed organizations.
- Missing Luciferase telemetry, update, Maven, and release services disable the
  corresponding fork-specific integration rather than silently using Lophine's
  service identity.
- Existing compatibility files are read from their Lophine paths so current
  installations can move to Luciferase without migration.
- The build should fail normally if patches no longer apply; verification will
  surface the exact failing patch rather than modifying generated output.

## Verification

Implementation is complete only after the following checks pass or any
environmental limitation is reported with its exact failing command:

1. Git history contains the selected Lophine baseline and an `upstream` remote
   points to the official Lophine repository.
2. The nested import checkout is absent and the project lives at repository
   root.
3. Focused searches confirm public runtime/build/docs surfaces use Luciferase,
   while compatibility identifiers under `fun.bm.lophine` and existing config
   namespaces remain intact.
4. No active CI or release step pushes to LophineLabs infrastructure.
5. Gradle configuration succeeds.
6. All maintained patches apply successfully.
7. The Paperclip server artifact builds and its filename and manifest branding
   identify Luciferase.
8. Repository status is reviewed to ensure only intended fork changes are
   included.

## Acceptance Criteria

- A user cloning the repository immediately understands that Luciferase is a
  Lophine-based server fork and sees the tagline "Make your server glow in the
  dark."
- A built server identifies itself as Luciferase in its public build metadata
  and distributable filename.
- Existing Lophine-compatible plugins and configuration do not require a
  namespace migration for this fork.
- The repository preserves upstream history and can fetch future Lophine
  changes through its `upstream` remote.
- CI cannot publish to or mutate LophineLabs-owned destinations.
