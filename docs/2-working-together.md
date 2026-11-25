# Level 2: how the apps work together

This page follows the apps while they run: who starts whom, how a setting reaches an app, what happens
when an app stops by accident, how the apps update. Each mechanism is described in depth at
[level 5](README.md#level-5-mechanisms-in-depth).

A few macOS words first:

- **Agent app** (`LSUIElement`): an app with no Dock icon and no menu bar of its own unless it shows a
  window. Explorer (while no window is open), Bar, Clipboard, Launcher, Bindings, Suite Guard and the
  Suite Settings Agent are agent apps; Desktop is a regular app, which Bar doesn't show.
- **Defaults domain**: where an app's settings are kept, one property list per app in
  `~/Library/Preferences` (`local.suite.bar.plist` for Bar). Any app can read another's by its name.
- **Distributed notification**: a message one app posts and every app listening receives, with a small
  payload and no reply. The suite's apps tell one another about changes this way.
- **Launch agent**: a small program that `launchd`, the system's process manager, starts and restarts
  for the user, described by a file in `~/Library/LaunchAgents`.

## Start-up today

No app starts another. Desktop, Bar and Clipboard each start at login through a login item of their own
(`SMAppService`), Suite Settings registers its agent, and Explorer opens when a folder is opened.

```mermaid
sequenceDiagram
    participant U as Login
    participant D as Desktop
    participant B as Bar
    participant C as Clipboard
    participant A as Suite Settings Agent
    participant G as Suite Guard
    participant F as Finder
    U->>D: login item
    D->>F: hide Finder's desktop (Finder keeps its windows)
    D->>G: load the guard while something is hidden
    U->>B: login item, while turned on
    B->>B: turned on? show, hide the system Dock
    B->>G: load the guard while the system Dock is hidden
    U->>C: login item
    C->>C: turn Spotlight's clipboard history off
    C->>G: load the guard while it is off
    U->>A: login item
    A->>A: cover, in System Settings, what a running app takes over
```

Explorer, opened for a folder, keeps Finder closed while Desktop hides Finder's desktop, and puts it back
when it quits. Each app checks for updates on its own feed. **(to build)** With progressive enhancement
nothing is hidden or started until the user turns it on in their profile.

## A setting changes

Each app keeps its settings in its own defaults domain and exposes them as a small library
(`BarSettings`, `ClipboardSettings`, `DesktopSettings`, `ExplorerSettings`). Suite Settings depends on these libraries,
writes the settings, then tells the app.

```mermaid
sequenceDiagram
    participant U as User
    participant M as Suite Settings
    participant D as Bar's defaults, local.suite.bar
    participant B as Bar
    U->>M: Settings, Bar tab: turn Bar on
    M->>D: write BarSettings
    M-->>B: distributed notification: apply settings
    B->>D: read the settings again
    B->>B: show, hide the system Dock
    Note over M,B: Bar not running and just turned on: Suite Settings starts it
```

Explorer works the same way for its own settings (`ExplorerLink`), Desktop with `DesktopMessage`,
Clipboard with `ClipboardMessage`.

## Profiles

A profile is every app's settings saved together under a name, on this Mac or in iCloud Drive, with the
version of each app that saved it. Loading a profile writes the settings back and tells every app; an
app finding settings from an older version converts them first, with the migrations its update brought.

## When an app stops by accident

Hiding Finder's desktop or the system Dock, or turning off Spotlight's clipboard history, changes macOS
settings that stay changed if the app that changed them crashes. Suite Guard is there for that.

```mermaid
stateDiagram-v2
    [*] --> Idle: nothing hidden, the guard is not loaded
    Idle --> Watching: an app hides Finder's desktop or the Dock, or turns off Spotlight's history (launch agent loaded)
    Watching --> Watching: the app that hid it is running
    Watching --> Restoring: the app is gone (15 s, 90 s after login)
    Restoring --> Idle: Finder's desktop, the Dock and Spotlight's history put back as they were
    Watching --> Idle: the app shows them again itself (turned off, switched to Finder)
```

By hand, the same is done by `Desktop --restore-finder` (Finder's desktop), `Bar --restore-bar` (the
system Dock) and `Explorer --restore-finder` (starts Finder and asks Bar for the Dock).

## Updates

Every app updates itself from its own GitHub releases, apart from the others:

```mermaid
flowchart LR
    A["App running"] --> B["Reads update.json<br/>from its latest release"]
    B --> C{"Newer build,<br/>signature valid?"}
    C -- no --> A
    C -- yes --> D["Downloads, asks<br/>or not (setting)"]
    D --> E["Waits until it isn't in use"]
    E --> F["Installs; the new copy<br/>takes over from the old one"]
    F --> G["First launch of a new version:<br/>converts its saved settings"]
```

The signature is checked against the update key's public half, written into the app when it is built:
an app accepts only updates signed with the suite's key.

## Where to read next

- [Level 3: each app](README.md#level-3-each-app)
- [Level 5: messages between apps](5-internals/messages.md),
  [settings and profiles](5-internals/settings-and-profiles.md),
  [updates and releases](5-internals/updates-and-releases.md),
  [Finder and the Dock](5-internals/finder-and-dock.md)
