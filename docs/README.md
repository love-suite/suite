# Love Suite: technical documents

How the suite is organised and how its apps work, from the simplest level to the most detailed. Each
level assumes the ones before it. Diagrams are in Mermaid, which GitHub draws.

Pages describe what the `main` branches do today. What is planned but not built is marked
**(to build)**; work waiting on a branch is listed apart, in each app's "Waiting on branches".

## Level 1: the big picture

- [What the suite is](1-overview.md): the apps, the roles they can take from macOS, progressive
  enhancement.

## Level 2: the apps together

- [How the apps work together](2-working-together.md): start-up, settings reaching an app, profiles,
  Suite Guard, updates.

## Level 3: each app

| App | Role | Page |
|---|---|---|
| Explorer | file windows | [explorer.md](3-apps/explorer.md) |
| Desktop | the desktop | [desktop.md](3-apps/desktop.md) |
| Bar | the Dock | [bar.md](3-apps/bar.md) |
| Viewer | pictures and PDFs | [viewer.md](3-apps/viewer.md) |
| Clipboard | clipboard history | [clipboard.md](3-apps/clipboard.md) |
| Launcher | app launcher | [launcher.md](3-apps/launcher.md) |
| Bindings | keyboard shortcuts | [bindings.md](3-apps/bindings.md) |
| Suite Settings | every app's settings, profiles, covers in System Settings | [suite-settings.md](3-apps/suite-settings.md) |
| Suite Guard | puts Finder's desktop, the Dock and Spotlight's clipboard history back | [suite-guard.md](3-apps/suite-guard.md) |
| AI Organizer | not adapted yet | [ai-organizer.md](3-apps/ai-organizer.md) |

## Level 4: the code

- [Repositories, libraries and building](4-code.md): what depends on what, the layers inside a
  repository, tools, versions, branches.

## Level 5: mechanisms in depth

- [Messages between apps](5-internals/messages.md)
- [Settings and profiles](5-internals/settings-and-profiles.md)
- [Updates and releases](5-internals/updates-and-releases.md)
- [Finder and the Dock](5-internals/finder-and-dock.md): hiding, restoring, Suite Guard (and Spotlight's clipboard history)
- [The Trash](5-internals/trash.md): its folders, Restore, the Suite Trash root helper
- [Files](5-internals/files.md): the file layer shared by Explorer, Desktop and Bar (suite-files)

## Decisions

- [Architecture](architecture.md): the principles, the decisions, and the road from today to there.
