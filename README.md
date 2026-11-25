# Love Suite

Apps for macOS that bring the Finder and the Dock closer to Windows, each in a repository of its own:

| App | What it does | Install |
|---|---|---|
| [Explorer](https://github.com/love-suite/suite-explorer) | A file manager in the spirit of Windows Explorer, with Finder kept out of the way | `brew install --cask love-suite/tap/explorer` |
| [Desktop](https://github.com/love-suite/suite-desktop) | The desktop in place of Finder's: free placement or a grid, stacks, Explorer's menus and shortcuts | `brew install --cask love-suite/tap/desktop` |
| [Bar](https://github.com/love-suite/suite-bar) | A Dock in place of the system one: pinned and running apps, Downloads, minimized windows, the Trash | `brew install --cask love-suite/tap/bar` |
| [Viewer](https://github.com/love-suite/suite-viewer) | The picture and PDF viewer, going through a folder in Explorer's order | `brew install --cask love-suite/tap/viewer` |
| [Clipboard](https://github.com/love-suite/suite-clipboard) | Windows' clipboard history: hold ⌘V for your latest copies | `brew install --cask love-suite/tap/clipboard` |
| [Awake](https://github.com/love-suite/suite-awake) | Keeps the Mac awake, for a while or until stopped, even with the lid closed | `brew install --cask love-suite/tap/awake` |
| [Suite Settings](https://github.com/love-suite/suite-settings) | The settings of every app, and settings profiles | `brew install --cask love-suite/tap/settings` |
| [Suite Guard](https://github.com/love-suite/suite-guard) | Puts the system Dock, Finder's desktop and Spotlight's clipboard history back should an app that hid them vanish | installed with Desktop, Bar, Clipboard and Awake |

Shared code: [suite-core](https://github.com/love-suite/suite-core) (every app) and [suite-files](https://github.com/love-suite/suite-files) (the apps handling files). The Homebrew tap:
[homebrew-tap](https://github.com/love-suite/homebrew-tap).

Every app of a version of the suite shares its `AA.Y` (27.1: macOS 27, the suite's first release); fixes
are each app's own (27.1.1). Each app updates itself from its own releases.

Until 2026-11-22 the suite was one repository; each app's repository keeps its part of that history.
