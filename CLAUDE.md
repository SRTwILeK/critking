# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Crit King** is a World of Warcraft addon (Unreal-Tournament-style "announcer" sounds) that tracks the
player's critical hits and killing blows in combat and plays a voice line / prints an escalating message
(`Head shot!` → `Ownage!`) as streaks grow. It also keeps lifetime crit/kill counters and fires "achievement"
sounds at crit milestones.

There is **no build, lint, or test tooling** — this is pure WoW Lua loaded by the game client. "Running" it
means copying the folder into `World of Warcraft/_classic_/Interface/AddOns/CritKing/` and reloading the UI
(`/reload`) in-game. `## Interface: 20502` targets WoW Classic (TBC 2.5.x); the combat-log parsing assumes
that API era.

## Layout

- `CritKing.toc` — addon manifest. Declares the load file, `## Interface` version, and
  `## SavedVariablesPerCharacter: CritKingVars` (per-character persistence).
- `CritKing.lua` — core addon: events, combat-log parsing, counters, the on-screen display
  **banner** (`CritKing.Banner`, a movable/animated frame), and slash commands.
- `CritKingOptions.lua` — the Interface Options panel (`CritKing.CreateOptionsPanel` / `OpenOptions`),
  registered on the game's AddOns options page and opened with `/ck options`.
- `sounds/*.ogg` — announcer voice clips, referenced by hardcoded in-game paths
  (`Interface\Addons\CritKing\sounds\<name>.ogg`).
- `logo.tga` — the addon-list icon (`## IconTexture` in the `.toc`); a 64×64 **uncompressed** TGA converted
  from `logo.png` (the PNG source is repo-only and excluded from the package by `build.sh`).
- `Libs/` — embedded third-party libraries loaded before `CritKing.lua`: `LibStub`, `CallbackHandler-1.0`,
  and `LibSharedMedia-3.0` (used to source the font list; see below).

## Architecture

Everything hangs off the global `CritKing` table (used as a namespace/pseudo-class). Flow:

1. A hidden `Frame` (`f`, bottom of `CritKing.lua`) registers four events and routes them all to
   `CritKing.OnEvent`:
   - `VARIABLES_LOADED` → captures `UnitGUID("player")` into `CritKing.PlayerGUID` and initializes saved vars.
   - `COMBAT_LOG_EVENT_UNFILTERED` → forwards `CombatLogGetCurrentEventInfo()` to `CritKing.OnCombatLog`.
   - `PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED` (enter/leave combat) → `CritKing.ResetStat()` clears the
     per-fight streak counters.
2. `OnCombatLog` filters to events where `sourceGUID == CritKing.PlayerGUID`, then:
   - `PARTY_KILL` → increments `KillNum` streak → `OnKill()`.
   - a `critical` hit (from `SWING_DAMAGE` / `SPELL_DAMAGE`) → increments `CritNum` streak → `OnCrit()`.
   - a non-crit hit → resets the crit streak **only if** `CritKingVars.ResetOnNormalHit` is set.
3. `OnCrit` / `OnKill` do three things: bump the lifetime counter in `CritKingVars.Stat.Sum`, show the streak
   message on the display banner (`CritKing.Banner.Show`) + chat (gated on `CritKingVars.Display`), and
   `PlaySoundFile` the matching clip (gated on `CritKingVars.Sound.Crit` / `.Kill`).

### Display banner (`CritKing.Banner`)

The on-screen text is a single reusable frame (`CritKingBannerFrame`) built once in `CritKing.Banner.Create`
during `VARIABLES_LOADED`. It carries one `FontString` animated by a shared `AnimationGroup` (a translation +
fade); `CritKing.Banner.Show(msg)` sets the offset from `CritKingVars.Frame.Animation` and replays it.
Appearance/position come from `CritKingVars.Frame` (`Font`, `FontSize`, `Color` {r,g,b}, `Animation`, `Locked`,
`Point`/`RelPoint`/`X`/`Y`) and are pushed onto the frame by `ApplyFont` / `ApplyColor` / `ApplyPosition` /
`ApplyLock`. When unlocked the frame
shows a title + background and is draggable; `OnDragStop` persists the new anchor. The animation option list
lives in `CritKing.Animations`; `CritKing.AnimName` maps a saved key back to its label.

Fonts come from **LibSharedMedia-3.0** when it loaded (`CritKing.LSM`): `CritKing.GetFontList()` returns the
LSM font list (which already includes the built-ins plus any media packs), falling back to the hardcoded
`CritKing.Fonts` table if the lib is missing. `CritKing.FontName` reverse-maps a saved font *path* to its
display name via `LSM:HashTable("font")`. Note the saved value in `CritKingVars.Frame.Font` is always a font
**path** (what `SetFont` needs), not an LSM key — so it works with or without the library.

### Two counter concepts — don't conflate them

- **Streak counters** (`CritKing.CritNum`, `CritKing.KillNum`) are transient, index into the message/sound
  arrays, and reset every fight (or on a normal hit). Streaks are clamped by `MaxCrit`/`MaxKill` so they never
  index past the arrays.
- **Lifetime totals** (`CritKingVars.Stat.Sum.Crit` / `.Kill`) persist across sessions and drive achievement
  milestones. `CritKing.Sum.Crit` is a keyed table (`'10'`, `'1000'`, …) that `AchCrit` looks up by total.

### Saved-variable migration

`CritKingVars` is the persisted table. On load, if it's `nil` it's seeded from `CritKingVarsDefault`;
otherwise `CritKingLoadVar` **recursively backfills any missing keys** from the defaults. When you add a new
setting, add it to `CritKingVarsDefault` and it will be migrated into existing characters' saved data
automatically — don't read a new field without a default or old saves will error.

## User interface (slash commands)

Registered as `/ck` (`SLASH_CRK_CMD1`, dispatched via `CritKing.OnCommand`). `/ck help` lists them:
`display on|off`, `normal on|off`, `critsound on|off`, `killsound on|off`, `sound on|off`,
`ach critsound on|off`, `options` (opens the settings panel; `config` is an alias), `show settings`,
`fullreset`, and bare `/ck` prints max damage / crit / kill stats.
Commands are matched by exact lowercased string, so a new subcommand needs its own `string.lower(args) == "..."`
branch.

## Gotchas

- Sound paths in the `*sounds` tables are hardcoded strings that must exactly match filenames in `sounds/`;
  a typo silently fails at `PlaySoundFile` with no error.
- Message/sound array lengths must stay in sync with the `MaxCrit` (23) / `MaxKill` (21) clamps; off-by-one
  here silently plays the wrong line or nils out.
- After editing Lua you must `/reload` in-game to see changes; there's no hot reload.
