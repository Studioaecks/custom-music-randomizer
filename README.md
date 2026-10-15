# Custom Music Randomizer

**Drop your own music into context folders and Gen1Recomp randomly plays the right tracks at the right times.**

No ROM assets, no streaming complexity — just local files and the engine’s `music.select` hook.

![Badge](https://img.shields.io/badge/Gen1Recomp-Compatible-brightgreen) ![Category](https://img.shields.io/badge/Category-AUDIO-blue)

## Features

- **Context folders** — Separate directories for battle, overworld, gym, forest, cave, indoor, water, trainer, wild, jingle, and title.
- **Random selection** — When the engine requests a song, the mod picks randomly from the matching category.
- **Smart fallback** — If a category is empty, the original soundtrack plays (toggleable).
- **Volume control** — Scale custom music relative to the game’s volume.
- **Works alongside existing packs** — Optional dependency on MusicReplacementMod / DarioMelo packs; your folders take priority when present.
- **Zero assets shipped** — You supply the music.

## Folder Structure

Place audio files (`.ogg`, `.mp3`, `.wav`, `.flac`) inside the mod folder:

```
assets/music/
├── battle/      # wild + trainer battles
├── trainer/     # trainer battles (falls back to battle)
├── wild/        # wild battles
├── overworld/   # routes, towns
├── gym/
├── forest/
├── cave/
├── indoor/      # centers, marts, houses
├── water/
├── jingle/      # heal, evolution, fanfares
└── title/
```

The mod scans on game ready and on first song request.

## Installation

1. Download the release zip (or clone this repo).
2. In Gen1Recomp: **MODS → Import mod .zip**.
3. Enable **Custom Music Randomizer**.
4. Add your tracks to the folders above (extract the zip or edit the installed mod folder).
5. Restart or reload mods.

## Options

Under **MODS → Custom Music Randomizer**:

- **ENABLE CUSTOM MUSIC** — Master toggle
- **SHUFFLE WITHIN CATEGORY** — Random pick each time (default on)
- **FALL BACK TO ORIGINAL** — Use vanilla/other-mod music when a folder is empty
- **VOLUME SCALE** — 0.2–1.5 multiplier

## How It Works

Hooks `music.select` (the single choke point for every song choice in Gen1Recomp) and `music.volume`.  
Category is decided from `ctx.reason`, `ctx.mapId`, `ctx.battleKind`, and surfing/bike flags.  
Compatible with Gen 1 and Gen 2 games.

## Limitations & Future

- Local files only (YouTube/podcast URL streaming is not implemented — LÖVE audio prefers local sources).
- Track registration uses the public `music` registry; some edge cases may still play the original if the engine rejects a synthetic id. Feedback welcome.
- No automatic download of remote playlists.

## Credits

Built for the Gen1Recomp modding API. Inspired by community soundtrack packs (MusicReplacementMod, DarioMelo FRLG/HGSS/LGPE) and the official Audio Authoring / Tutorial 09 docs.

Enjoy your personal soundtrack.
