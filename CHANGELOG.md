# Changelog

All notable changes to **Crit King** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1] - 2026-07-21

Major update: a fully customizable on-screen display and an in-game options panel.

### Added
- **On-screen display banner** — crit/kill messages now appear on a dedicated,
  animated frame instead of the default UI error text.
- **Options panel** registered on the game's AddOns settings page, opened with
  `/ck options` (alias `/ck config`). Works on both the modern `Settings` API
  and the legacy `InterfaceOptions` API.
- **Lock / unlock** the display frame: while unlocked it shows a title bar and
  can be dragged, and its position is saved per character.
- **Font selection** powered by an embedded **LibSharedMedia-3.0**, so every
  font registered by any installed addon is available (with a built-in font
  list as a fallback when the library is absent).
- **Font size** slider.
- **Text color** picker.
- **Text animations**: float up, float down, slide left, slide right, fade in
  place, or static.
- A **Test message** button in the options panel to preview the display.
- **Addon-list icon** (`logo.tga`) shown next to Crit King in the AddOns list.
- Embedded libraries: `LibStub`, `CallbackHandler-1.0`, `LibSharedMedia-3.0`.

### Fixed
- Font size changes not taking effect until the font was also switched, caused
  by `SetFont` ignoring a size-only change when the font file is unchanged.

### Changed
- New per-character saved settings under `CritKingVars.Frame` (lock state,
  font, size, color, animation, and saved position); existing characters are
  migrated automatically.

## [1.0.1] - 2026-07-21

### Added
- `build.sh` to package the addon into a CurseForge-ready zip.
- Project description and logo.

### Fixed
- Combat-log parsing bugs and support for WoW Classic TBC 2.5.4.

### Changed
- Cleaned up on-screen and chat messages.

## [0.5.1] - 2021-12-25

### Added
- Lifetime critical-hit counter and crit-milestone "achievement" sounds.

### Changed
- Refactored settings handling and saved-variable loading/migration.

### Fixed
- Various Lua errors.

## [0.5] - 2021-12-04

### Added
- Initial tracked release: announcer sounds and escalating on-screen messages
  for critical-hit and killing-blow streaks, lifetime statistics, and slash
  commands to toggle sounds on or off.
