# YouTube Full-Resolution Download Script

A small script to download YouTube videos at the highest available resolution
(video + audio merged with ffmpeg), ideal for grabbing background / wallpaper clips.

There are two versions:

- **`download.ps1`** — Windows (PowerShell)
- **`download.sh`** — macOS / Linux (Bash)

Both read links from `urls.txt` and save to a `downloads/` folder.

---

## Windows

1. **Add your links.** Open `urls.txt` in Notepad and paste one YouTube URL per
   line (e.g. `https://www.youtube.com/watch?v=...`). Lines starting with `#`
   are ignored.

2. **Run the script.** Easiest way:
   - Open the folder in File Explorer.
   - Click the address bar, type `powershell`, and press Enter (opens PowerShell
     in this folder).
   - Paste this and press Enter:

     ```powershell
     .\download.ps1
     ```

   If you get a security warning about running scripts, run this once first in
   the same window, then run the script again:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

   (That allows scripts for this one window only.)

The first run auto-installs `yt-dlp` and `ffmpeg` via `winget` (built into
Windows 10/11). Videos download to the `downloads` folder.

---

## macOS / Linux

1. Add one YouTube URL per line to `urls.txt`.
2. Run:

   ```bash
   ./download.sh
   ```

The first run auto-installs `yt-dlp` if missing (requires Homebrew on macOS).

---

## Notes

- Re-running skips anything already downloaded (tracked in `.downloaded.txt`).
- `ffmpeg` is required to merge the best video and audio streams into one file.
- Many YouTube clips are copyrighted even when freely viewable — check licensing
  before using downloaded footage publicly.
