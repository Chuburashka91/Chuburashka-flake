# Default wallpapers

Eight original 1920×1080 images, two per palette:

| Palette | Files |
|---|---|
| `unit3` | `unit3-01.png`, `unit3-02.png` |
| `gaming` | `gaming-01.png`, `gaming-02.png` |
| `space` | `space-01.png`, `space-02.png` |
| `mimimi` | `mimimi-01.png`, `mimimi-02.png` |

`others/nixos.png` is a compatibility fallback for the old
`~/Pictures/wallpapers/others/nixos.png` path used by `waypaper.nix`.

## Where they end up

`install.sh` copies them (without overwriting existing files) to:

```
~/Pictures/wallpapers/unit3/
~/Pictures/wallpapers/gaming/
~/Pictures/wallpapers/space/
~/Pictures/wallpapers/mimimi/
~/Pictures/wallpapers/others/
```

Home Manager activation (`unit3Wallpapers`) does the same on a fresh install
where the target user does not exist yet during `install.sh`, so the runtime
scripts always have at least one image per style.

## License

Generated for this repository and released under CC0 1.0 Universal; see
`LICENSE` in this directory. No attribution required.
