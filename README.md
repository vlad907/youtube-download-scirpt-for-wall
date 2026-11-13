# YouTube Full-Resolution Download Script

A small Bash script to download YouTube videos at the highest available
resolution (video + audio merged with ffmpeg), ideal for grabbing background /
wallpaper clips.

## Usage

1. Add one YouTube URL per line to `urls.txt` (lines starting with `#` are ignored).
2. Run:

   ```bash
   ./download.sh
   ```

The first run auto-installs `yt-dlp` if it's missing (requires Homebrew on macOS).
`ffmpeg` is needed to merge the best video and audio streams.

Files are saved into a `downloads/` folder (git-ignored). Re-running skips
anything already downloaded.

## Notes

Many YouTube clips are copyrighted even when freely viewable — check licensing
before using downloaded footage publicly.
