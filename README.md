# MD Save

MD Save is a tiny macOS app for quickly saving Markdown notes into an Obsidian vault.

It solves a simple problem: you have a long piece of Markdown text and want to save it into your vault without opening Terminal, creating a file manually, or thinking about filenames.

## What It Does

- Lets you choose your own Obsidian vault folder.
- Provides a simple window with:
  - a file topic field
  - a large Markdown text area
  - a Paste Clipboard button
  - a Save button
  - Command+S support
- Saves notes as:

```text
YYMMDD_topic.md
```

Example:

```text
260607_product_strategy.md
```

If the filename already exists, MD Save creates a unique name such as:

```text
260607_product_strategy_2.md
```

## Input and Output

Input:

- Your chosen Obsidian vault folder
- A short file topic
- Markdown text typed or pasted into the app

Output:

- One local `.md` file inside the selected vault folder

MD Save does not upload, sync, analyze, or send your note content anywhere.

## Privacy

MD Save is local-only.

- No network calls
- No telemetry
- No AI API calls
- No bundled personal vault path
- No access to your notes except the folder you choose

The selected vault path is stored locally in macOS `UserDefaults` for the app, so you do not have to choose it every time.

## Requirements

- macOS 13 or later
- Xcode Command Line Tools for building from source

## Build

```bash
./scripts/build.sh
```

The built app will be created at:

```text
build/MD Save.app
```

The build script:

- compiles the Swift/AppKit source
- generates a macOS `.icns` from `assets/AppIcon.png`
- ad-hoc signs the app for local use

## Test Without Touching Your Vault

Use a temporary folder:

```bash
tmpdir="$(mktemp -d)"
MDSAVE_VAULT="$tmpdir" "build/MD Save.app/Contents/MacOS/MDSave" --self-test
find "$tmpdir" -type f -maxdepth 1 -print
```

## Install

After building, move the app wherever you like, for example:

```bash
cp -R "build/MD Save.app" ~/Applications/
```

On first launch, choose your Obsidian vault folder.

## License

MIT
