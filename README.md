# TransmogSetHide

A lightweight World of Warcraft addon that lets you hide and unhide Transmog Sets directly in the **native Blizzard Wardrobe UI** — no custom frame, no replacements.

## Features

- **Right-click** any set → Hide / Unhide
- Hidden sets are completely removed from the list (not just greyed out)
- **Show Hidden** checkbox next to the search box to temporarily reveal hidden sets (shown at 40% opacity)
- Hovering a hidden set appends a red hint to the existing tooltip
- Settings saved **account-wide** — shared across every character on your Battle.net account
- Keyed by **set ID**, not name — renaming a set preserves its hidden state

## Usage

### Hide a set
1. Open the Wardrobe (`Shift+P`) and go to the **Sets** tab
2. Right-click any set → **Hide Set**

### Unhide a set
1. Check **Show Hidden** (next to the search box) — hidden sets appear dimmed
2. Right-click the dimmed set → **Unhide Set**
3. Uncheck **Show Hidden** to return to the filtered view

## Installation

1. Download and unzip
2. Copy the `TransmogSetHide` folder to:
   ```
   World of Warcraft/_retail_/Interface/AddOns/
   ```
3. Log in or `/reload`

## Account-Wide Storage

Hidden sets are stored in `SavedVariables` (not `SavedVariablesPerCharacter`), which means the list is shared across **all characters on the same Battle.net account**. The key used is the numeric set ID returned by the game API, so it survives set renames.

## Compatibility

| Field | Value |
|---|---|
| Interface | 12.0.5+ |
| Requires | Blizzard_Collections (loads automatically) |

## Localization

| Locale | Status |
|---|---|
| enUS | Complete |
| zhCN | Complete |

Pull requests for additional locales are welcome.

## License

MIT
