# Suite: project brief

This repository is the front page of Love Suite, no app: the README presenting the apps,
`catalog.json` (the apps, their bundle ids, repositories and casks, which Suite Settings will read to show
and install the apps not installed yet), `SUITE_VERSION` (the `AA.Y` every repository shares) and the
scripts that act on every repository. It was the monorepo of every app until 2026-11-22; each app's repository kept its part of
that history, this one starts afresh.

## What is here

- `docs/`: the suite's technical documents, from the big picture to the mechanisms in depth
  (`docs/README.md` is the index). `docs/architecture.md` holds the principles and decisions
  (progressive enhancement, roles, where code and data go, releases) and what has to change to get
  there: read it before changing how the apps or repositories fit together. When a change in any
  repository makes a page wrong, update the page here as well.
- `repositories.txt`: the repositories, in the order they depend on one another.
- `.github/workflows/sync.yml`: when `SUITE_VERSION` changes on `main`, tells each repository in turn
  (`repository_dispatch`, event `suite-version`), waiting for its tag before the next: each one's
  `sync-version.yml` sets `VERSION`, moves its dependencies, builds, tests, tags and releases. It needs the
  secret `SUITE_DISPATCH_TOKEN` (a token that can write to the suite's repositories; made by the user,
  set with `scripts/set-secret.sh --suite SUITE_DISPATCH_TOKEN`).
- `scripts/rename-organization.sh <new>`: after renaming the GitHub organization (or moving the
  repositories), points every local repository at it; commits nothing. The organization is written only
  where it can't be derived: `organization` in each Package.swift, casks, catalog and documentation.
- `scripts/each.sh <command>`: runs a command in every local repository (`~/GitHub/paul-amour/suite/<repo>`).
- `scripts/release-certificate.sh`: makes, once, "Suite Release Signing": its private half straight into
  every app repository's `release` environment, its public half into each local repository's
  `Support/release-certificate.cer`, to commit there.
- `scripts/update-key.sh`: makes, once, the update key: its private half straight into every app
  repository's `release` environment (`UPDATE_PRIVATE_KEY`), its public half into each local repository's
  `Support/update-public-key.txt`, to commit there. Neither private half is kept on this Mac.
- `scripts/set-secret.sh [--suite] NAME`: a secret read from the standard input, in every app repository's
  `release` environment (for instance `HOMEBREW_TAP_TOKEN`, which lets the release workflows update the
  casks), or in this repository with `--suite`.

## The suite

This repository is part of Love Suite, one repository per app under `github.com/love-suite`:
`suite-core` (the shared library), `suite-files` (the file layer of the apps handling files),
`suite-guard`, `suite-desktop` (the desktop), `suite-explorer`, `suite-bar` (the Dock), `suite-viewer`,
`suite-clipboard`, `suite-settings` (the settings), `suite-awake` (keeping the Mac awake), `suite-launcher`, `suite-bindings`,
`suite-ai-organizer`; `homebrew-tap` (the tap `love-suite/tap`, one cask per app) and `suite` (the
front page, the suite's version, the scripts that act on every repository). Locally they sit side by side
in `~/GitHub/paul-amour/suite/`.

## Conventions (the same in every repository of the suite)

- The user writes in French and expects answers in French; everything in the code stays in English: code,
  comments, tests, docs, commit messages. Do not add co-author trailers.
- No "…" in menu items, buttons or messages: the user wants none, anywhere.
- Behaviour follows Windows unless Apple's design is asked for.
- Swift Package Manager, `swift-tools-version:5.9`, macOS 13+. Tests use Swift Testing (`import Testing`).
- Toolchain: swiftly, Swift 6.4.2 (`.swift-version`, git-ignored). If `swift test` complains about a
  missing toolchain: `swiftly use 6.4.2`.
- AppKit for windows that need fine control; SwiftUI is allowed for small panels (settings, pickers).
- No private APIs and no system modifications (SIP stays on).
- Git: one worktree per feature under `.worktrees/` (git-ignored), one branch per change
  (`feat/<feature>`, `fix/<area>/<what>`), merged into `main` one by one; `main` stays stable.
- Versions are `AA.Y`, then `AA.Y.Z` for a fix (`VERSION`, tag `vVERSION`: 27.1, then 27.1.1; SwiftPM reads
  `v27.1` as 27.1.0): `AA` is the latest macOS in production (27), `AA.Y` is the same in every repository of
  the suite so the apps work together, `Z` is this repository's own. A change of `AA.Y` is made in `suite`
  and reaches every repository. While a version is being prepared, `VERSION` doesn't move (27.1 now):
  development builds are `VERSION-dev.N`, N the commits since `VERSION` was set, merges aside, from 1 (`make-app.sh`),
  and a change another repository needs gets a development tag, `vVERSION-dev.N`, which releases nothing.
  Dependencies on other repositories of the suite (`suite-core`, `suite-files`, `suite-guard`, settings
  libraries) use
  `.upToNextMinor(from: "27.1.0-dev.1")` (the latest development tag, then the release);
  `Package.resolved` is committed. Tags are never moved once pushed. The build number (`CFBundleVersion`,
  which the updater compares) stays the number of commits.
- Changing two repositories at once: `swift package edit <Package> --path ../<repository>` points at the
  neighbour's working copy until its tag exists, `swift package unedit` goes back. Never committed.
- What two apps need lives in `suite-core` (file code in `suite-files`); an app's own code never goes into another app's repository, and
  an app exposes only its settings, as `<App>Settings`, for Suite Settings.
- Do not run commands that delete user data. Trash instead of delete.
- No code converting saved settings at launch. Before the first release nothing needs converting (the
  developer's own settings don't count): rename freely. Between released versions, a change to saved
  settings is a `SettingsMigration` (suite-core) for the version that brought it, given to the app's
  `SuiteUpdater`, which runs it once after the update.
