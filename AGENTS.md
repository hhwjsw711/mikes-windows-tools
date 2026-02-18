# Agent guidance — mikes-windows-tools

Instructions for AI agents (Cursor, etc.) working in this repo.

---

## Repo purpose

Personal Windows productivity tools for Mike. Each tool lives in its own
subfolder. `install.ps1` wires everything into `C:\dev\tools` (which is on
PATH) via thin stub `.bat` files or `.lnk` shortcuts.

---

## Key rules

- **Never put source files directly in `C:\dev\tools`.** All logic belongs in
  this repo under the appropriate tool subfolder. `C:\dev\tools` only ever
  gets auto-generated stubs from `install.ps1`.
- **Large binaries stay in `C:\dev\tools`**, not here. Never commit `.exe` or
  `.dll` files. They are gitignored.
- **Test before committing.** Run the actual script/tool to verify it works.
  For `.ps1` scripts, run them directly with PowerShell. For `.vbs` launchers,
  run via `wscript.exe`. Check exit codes.
- **No console windows for GUI/taskbar tools.** Use the `.vbs` launcher pattern
  (see `scale-monitor4\scale-monitor4.vbs`) which calls `wscript.exe` with
  window style 0. Never launch PowerShell from a taskbar shortcut without a
  `.vbs` wrapper — it causes a CMD window to flash.
- **ASCII encoding for `.bat` files.** Always write bat files with
  `-Encoding ASCII` in PowerShell, or avoid non-ASCII characters entirely.
  Em dashes and curly quotes in string literals will cause parse errors.
- **Re-run `install.ps1` after adding a new tool.** Editing an existing tool
  never requires reinstall — stubs point at the live repo files.

---

## Adding a CLI tool

1. `mkdir <name>` in the repo root
2. Write `<name>\<name>.bat` (or `.ps1`) with the full logic
3. If the tool needs `ffmpeg.exe`, `faster-whisper-xxl.exe`, or other large
   binaries that live in `C:\dev\tools`, accept `EXEDIR` as an env var
   and fall back: `if not defined EXEDIR set "EXEDIR=%~dp0"`
4. Add a `Write-BatStub` call in `install.ps1`
5. Run `install.ps1`
6. Smoke-test: open a new terminal and call the command by name
7. Commit

## Adding a taskbar / GUI tool

1. `mkdir <name>` in the repo root
2. Write `<name>\<name>.ps1` with WinForms or notification logic
3. Copy `scale-monitor4\scale-monitor4.vbs` as `<name>\<name>.vbs` and update
   the filename reference inside it
4. Add a shortcut block in `install.ps1` (see the `scale-monitor4` section)
5. Run `install.ps1`
6. Test via `wscript.exe "C:\dev\me\mikes-windows-tools\<name>\<name>.vbs"`
7. Right-click the generated `.lnk` in `C:\dev\tools` → Pin to taskbar
8. Commit

---

## Editing an existing tool

1. Edit the file in this repo directly (e.g. `scale-monitor4\scale-monitor4.ps1`)
2. Test it: run via `wscript.exe` (GUI) or directly with PowerShell (CLI)
3. Commit — no reinstall needed

---

## File structure

```
mikes-windows-tools\
├── AGENTS.md                  ← you are here
├── README.md
├── install.ps1                ← generates stubs; re-run when adding tools
├── .gitignore
├── all-hands\
│   └── all-hands.bat
├── backup-phone\
│   ├── backup-phone.bat
│   └── backup-phone.ps1
├── removebg\
│   └── removebg.bat
├── scale-monitor4\
│   ├── scale-monitor4.ps1     ← WinForms popup UI + registry toggle
│   ├── scale-monitor4.vbs     ← silent launcher (no window flash)
│   └── scale-monitor4.bat     ← thin bat wrapper (not used directly)
└── transcribe\
    └── transcribe.bat         ← uses %EXEDIR% for ffmpeg / whisper paths
```

---

## Important paths

| Path | What it is |
|---|---|
| `C:\dev\me\mikes-windows-tools\` | This repo |
| `C:\dev\tools\` | On PATH; holds stubs + large exe binaries |
| `C:\dev\tools\ffmpeg.exe` | Used by transcribe |
| `C:\dev\tools\faster-whisper-xxl.exe` | Used by transcribe |
| `C:\dev\tools\_models\` | Whisper model files |

---

## scale-monitor4 specifics

- Monitor: HG584T05, "Display 4", AMD Radeon Graphics
- Registry key: `HKCU:\Control Panel\Desktop\PerMonitorSettings\RTK8405_0C_07E9_97^C9A428C8B2686559443005CCA2CE3E2E`
- `DpiValue = 4` → 200% scaling (normal use)
- `DpiValue = 7` → 300% scaling (filming)
- The script modifies the registry then broadcasts `WM_SETTINGCHANGE` +
  calls `ChangeDisplaySettingsEx("\\.\DISPLAY4", CDS_RESET)` to apply live

---

## PowerShell tips for this repo

```powershell
# Run a ps1 directly for testing
powershell -NoProfile -ExecutionPolicy Bypass -File .\scale-monitor4\scale-monitor4.ps1

# Run a tool via its vbs launcher (same as taskbar click)
wscript.exe ".\scale-monitor4\scale-monitor4.vbs"

# Re-run install after adding a tool
powershell -ExecutionPolicy Bypass -File .\install.ps1

# Check what's in c:\dev\tools (should only be stubs + exes)
Get-ChildItem C:\dev\tools\*.bat | Select-Object Name, Length
```
