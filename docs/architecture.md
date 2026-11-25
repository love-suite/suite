# Architecture of Love Suite

How the suite is organised, and why. Decided with the user on 2026-11-24. Parts marked
**(to build)** describe where the suite is going, not what the code does today; the last section lists
what has to change to get there.

## Principles

1. **Progressive enhancement.** Opened for the first time, every app behaves as macOS does, as the user
   has configured it: Finder's desktop and windows, the Dock, their settings. Every behaviour that differs
   from macOS is a setting, off by default, that the user turns on in their profile (Suite Settings).
   Defaults are read from the user's own macOS settings (Finder showing file extensions, the Dock's size
   and position, the desktop's icon positions), never assumed.
2. **Roles.** macOS gives each job to one of its apps; the suite offers another app for some of these
   jobs, and the user chooses, in their profile, which app holds each role (see "Roles" below).
3. **Each app works alone.** An app does its own role and nothing else. When it needs another role, it
   asks who holds it and talks to that app, or to macOS's own app when the role is macOS's. No app
   assumes another app of the suite is installed, running or chosen.
4. **Code goes only where it is used.** `suite-core` holds what every app needs. Code that only some
   apps share lives in a library repository of its own (a capability library), which only those apps
   depend on. An app's own code never goes into another app's repository, and an app exposes only its
   settings library (`<App>Settings`), which Suite Settings reads.
5. **Built for the long term.** When a sound design and a cheaper one compete, the sound one is chosen,
   its cost stated.

## Roles

| Role | macOS | Suite |
|---|---|---|
| Desktop | Finder | Desktop |
| File windows, "Show in Finder" | Finder | Explorer |
| Dock | Dock | Bar |
| Clipboard history | Spotlight (its clipboard results) | Clipboard |
| App launcher | none (Launchpad is gone in macOS 27) | Launcher |
| Picture and PDF viewing | Preview | Viewer |
| Keyboard shortcuts | System Settings | Bindings |

- Each role is a setting of the profile, macOS's app by default. Suite Settings shows and changes them.
- `SuiteApps` (`suite-core`) answers "who holds this role" **(to build: today it answers whether an app
  is installed and turned on)**.
- An app holding a role takes over only that role. Desktop hides Finder's desktop, and nothing else;
  Explorer keeps Finder closed and handles "Show in Finder" only while it holds the file windows role.
  With Desktop chosen and Finder kept for windows, Finder runs without its desktop, and a folder opened
  on the desktop opens in Finder.
- Suite Guard puts macOS's app back in its role should the suite's app vanish (a crash, a forced quit):
  Finder's desktop, the system Dock, Spotlight's clipboard history.
- While a suite app holds a role, the Suite Settings Agent covers, in System Settings, the macOS settings
  of that role, with a button opening the app's own settings.

## Repositories and libraries

```
suite-core          every app: updates (SuiteUpdater, feed, signature), versions, settings
                    migrations, profiles, where settings live, messages between apps, roles
suite-files         file apps only (Explorer, Desktop, Bar)
    SuiteFilesCore      what a file is, what a folder holds, the rules of each operation (UI-free,
                        tested): loading folders, aliases, cloud state, transfers and their
                        conflicts, the Trash and where items came from, properties, icon library,
                        keyboard shortcuts, sorting
    SuiteFilesUI        the file views, each with a macOS look by default and its variants: icons,
                        names, selection, thumbnails, sync badges, the drag ghost, Quick Look,
                        Properties, Change Icon, inline renaming, drops
suite-guard         DockGuard, FinderGuard, SpotlightGuard, Suite Guard.app
suite-<app>         one per app: its settings library, its UI-free core, the app
suite               this repository: version, catalog, scripts acting on every repository
homebrew-tap        one cask per app (the tap love-suite/tap)
```

Every repository is on GitHub under the organization `love-suite`. Its name is written only where it can't
be derived (`organization` in each `Package.swift`, casks, catalog, documentation); workflows use the
repository's owner, and `make-app.sh` and `publish.sh` read it from `GITHUB_REPOSITORY` or the `origin`
remote. `scripts/rename-organization.sh` (this repository) updates the rest after a rename.

### The file layer

The desktop, the windows and Bar share one file layer, `suite-files`, which only they depend on.
Display is shared code (a program cannot draw in another's window); each app does its file operations
itself by the same rules; Undo is one journal every file app reads and writes, Cut a mark on the
system pasteboard, and the apps send each other a message when one needs another. A background service
owning every operation was considered and set aside. Where data about files is kept (Finder's
`.DS_Store`, extended attributes, our settings) is decided there too. In depth:
[files](5-internals/files.md).

## Settings and profiles

- Each app's settings are its settings library (`<App>Settings`), in its own defaults domain
  (`local.suite.<app>`), read by Suite Settings, which shows them all.
- A profile holds every app's settings and the roles. Loading a profile is how the user moves from
  macOS's behaviour to theirs.
- A setting's default is macOS's behaviour, read from the user's macOS settings where macOS has one.
  A key never written is read with that default, in every app that reads it.
- Saved settings are converted only between released versions, by a `SettingsMigration` given to the
  app's `SuiteUpdater`.

## Releases

- Each app repository releases itself: its release workflow builds, signs the app with the release
  certificate and `update.json` with the update key, publishes the release and updates its cask.
- The release certificate and the update key's private halves are secrets of the organization, shared
  with the app repositories **(to set up: today each repository has a copy in its own `release`
  environment)**. Adding an app means giving its repository access to them; the keys never change, so
  installed apps keep accepting updates. On GitHub's free plan organization secrets reach public
  repositories only: an app repository is published before its first release.

## From today to there

Done: the repositories are under `love-suite`; `suite-files` holds the file code of Explorer and
`suite-core` (Bar's drops go through it); `suite-desktop` holds Desktop.app (`local.suite.desktop`, cask
`desktop`), with the desktop's history from `suite-explorer`; Explorer has no desktop any more; Suite
Guard, Suite Settings, this repository, the tap and each repository's brief follow.

Still to do:

1. The release keys become organization secrets (today each app repository has a copy in its own
   `release` environment).
2. Defaults follow macOS: Explorer no longer takes Finder's place at first launch (`UseExplorer` is true
   by default today), and every other default is checked against the principle.
3. Roles in `suite-core` and Suite Settings; Explorer's handling of Finder split by role.
