<#
    Download YouTube videos at full resolution (Windows / PowerShell).

    Usage:
      1. Put one YouTube URL per line in  urls.txt  (next to this script).
         Lines starting with # are ignored.
      2. Right-click this file -> "Run with PowerShell",
         OR open PowerShell in this folder and run:  .\download.ps1

    Videos are saved into the .\downloads folder at the highest available
    resolution (video + audio merged by ffmpeg).
#>

$ErrorActionPreference = "Stop"

# --- locate ourselves so the script works from any directory ---------------
$Dir  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Urls = Join-Path $Dir "urls.txt"
$Out  = Join-Path $Dir "downloads"

function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

# --- make sure yt-dlp is installed -----------------------------------------
if (-not (Have "yt-dlp")) {
    Write-Host "yt-dlp not found - installing..."
    if (Have "winget") {
        winget install --id yt-dlp.yt-dlp -e --accept-package-agreements --accept-source-agreements
    } elseif (Have "pip") {
        pip install --user yt-dlp
    } else {
        Write-Host "Could not auto-install yt-dlp. Install it from https://github.com/yt-dlp/yt-dlp/releases (yt-dlp.exe) and put it in this folder, then re-run."
        exit 1
    }
    # winget may not refresh PATH in this session - refresh it
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# --- make sure ffmpeg is present (needed to merge best video + best audio) --
if (-not (Have "ffmpeg")) {
    Write-Host "ffmpeg not found - installing (needed to merge audio + video)..."
    if (Have "winget") {
        winget install --id Gyan.FFmpeg -e --accept-package-agreements --accept-source-agreements
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Host "WARNING: ffmpeg not found and winget unavailable. High-res downloads may fail to merge."
        Write-Host "Install ffmpeg from https://www.gyan.dev/ffmpeg/builds/ and add it to PATH."
    }
}

# --- check the URL list exists ---------------------------------------------
if (-not (Test-Path $Urls)) {
    Write-Host "No urls.txt found. Creating a template at: $Urls"
    @"
# Paste one YouTube URL per line. Lines starting with # are ignored.
# Example:
# https://www.youtube.com/watch?v=dQw4w9WgXcQ
"@ | Set-Content -Encoding UTF8 $Urls
    Write-Host "Edit urls.txt, add your links, then run this script again."
    exit 0
}

New-Item -ItemType Directory -Force -Path $Out | Out-Null

# --- download --------------------------------------------------------------
# -f: best video + best audio, falling back to best single file
# --merge-output-format mp4: produce a normal .mp4 when possible
# -i: keep going if one video fails
# --download-archive: skip anything already downloaded on re-runs
& yt-dlp `
    -a "$Urls" `
    -f "bv*+ba/b" `
    --merge-output-format mp4 `
    --no-playlist `
    -i `
    -o "$Out\%(title)s [%(id)s].%(ext)s" `
    --download-archive (Join-Path $Dir ".downloaded.txt") `
    --embed-metadata `
    --embed-thumbnail `
    --no-overwrites

Write-Host ""
Write-Host "Done. Files are in: $Out"
