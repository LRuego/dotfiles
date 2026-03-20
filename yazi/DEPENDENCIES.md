# Yazi Plugin Dependencies

CLI tools required by installed Yazi plugins.

---

## ouch.yazi
- **`ouch`** — archive tool used for extracting and compressing files, and for previewing archive contents
  ```
  sudo pacman -S ouch
  ```

## recycle-bin.yazi
- **`trash-cli`** — moves files to trash instead of permanently deleting them
  ```
  sudo pacman -S trash-cli
  ```

## mediainfo.yazi
- **`mediainfo`** — extracts media metadata for audio, video, and image files
  ```
  sudo pacman -S mediainfo
  ```
- **`imagemagick`** *(optional)* — renders image/video thumbnails in the preview panel
  ```
  sudo pacman -S imagemagick
  ```
- **`ffmpeg`** *(optional)* — used alongside imagemagick for video thumbnails
  ```
  sudo pacman -S ffmpeg
  ```

## rich-preview.yazi
- **`rich-cli`** — renders markdown, JSON, and other files with syntax highlighting in preview
  ```
  paru -S rich-cli
  ```

## starship.yazi
- **`starship`** — renders a starship-style status bar inside Yazi using your existing starship config
  ```
  sudo pacman -S starship
  ```

---

## Plugins with no CLI dependencies
- smart-enter
- git.yazi
- pref-by-location
- restore.yazi
- jump-to-char
- full-border
