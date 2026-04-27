# TransmogSetHide — Project Memory

This file gives any AI assistant immediate context about this project.

## What This Is

A World of Warcraft addon (12.0.5+) that hides/unhides Transmog Sets inside the **native Blizzard Wardrobe UI** (`WardrobeCollectionFrame.SetsCollectionFrame`). It does not replace or wrap Blizzard's UI — it hooks into it.

## File Layout

```
TransmogSetHide/
├── TransmogSetHide.toc       # Metadata, SavedVariables declaration, load order
├── Core.lua                  # All addon logic
├── Locales/
│   ├── enUS.lua              # Creates addonTable.L, sets default English strings
│   ├── zhCN.lua              # Overrides strings when GetLocale() == "zhCN"
│   ├── enUS.po               # gettext source (human-readable)
│   └── enUS.mo               # gettext compiled binary (msgfmt output)
├── README.md                 # English user-facing documentation
└── MEMORY.md                 # This file
```

## Architecture

### SavedVariables (account-wide)

```lua
TransmogSetHideDB = {
    showHidden = false,          -- bool: reveal hidden sets in the list
    hidden = {
        [setID] = true,          -- numeric Blizzard set ID as key
    }
}
```

`## SavedVariables` in the .toc is shared across all characters on the same Battle.net account. Keys are numeric set IDs (not names), so renaming a set does not break the hidden state.

### Core flow

1. `ADDON_LOADED` (own addon) → `InitDB()` — initialises SavedVariables
2. `ADDON_LOADED` (Blizzard_Collections) → `InitBlizzardCollections()` — hooks the Wardrobe
3. If Blizzard_Collections is already loaded (`/reload`) → `C_Timer.After(0, InitBlizzardCollections)`

### Hooks

| Hook | Purpose |
|---|---|
| `ScrollBoxListMixin.Event.OnAcquiredFrame` | Right-click menu, tooltip hint, alpha dim for hidden sets |
| `hooksecurefunc(SetsFrame, "UpdateSets", …)` | Removes hidden entries from DataProvider when `showHidden` is false |

### UI

A `UICheckButtonTemplate` checkbox is anchored to the right of `SetsFrame.SearchBox`. Checking it sets `DB.showHidden = true` and calls `SetsFrame:UpdateSets()`.

## Key Decisions

- **Native UI only** — inspired by BetterWardrobe but works in the stock Wardrobe frame
- **Set ID as key** — survives set renames
- **Account-wide** via `## SavedVariables`, no extra API needed
- **No taint risk** — uses `hooksecurefunc` and `HookScript`, never replaces Blizzard functions
