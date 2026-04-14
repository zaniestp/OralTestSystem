@echo off
:: ═══════════════════════════════════════════════════════════════════
::  Reading Activity Player — Kiosk Launcher
::  Launch.bat
::
::  Starts Microsoft Edge in true kiosk mode.
::  - No tab bar, address bar, back button, or any browser chrome
::  - All keyboard shortcuts and mouse gestures disabled by Edge
::  - Extensions and developer tools blocked
::  - Only Ctrl+Alt+Del can end the session
::  - No popup asking to restore crashed session
::
::  USAGE: Double-click Launch.bat
::         Or right-click → Run as administrator (recommended)
:: ═══════════════════════════════════════════════════════════════════

title Reading Activity — Kiosk Mode

:: ── Resolve the absolute path to index.html ─────────────────────
:: %~dp0 is the folder containing this .bat file
set "APP_DIR=%~dp0"
:: Remove trailing backslash
if "%APP_DIR:~-1%"=="\" set "APP_DIR=%APP_DIR:~0,-1%"

:: Convert backslashes to forward slashes for the file:// URL
set "FILE_URL=file:///%APP_DIR:\=/%/index.html"

:: ── Locate Microsoft Edge ────────────────────────────────────────
set "EDGE="
if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" (
    set "EDGE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
)
if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" (
    set "EDGE=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
)
if exist "%LocalAppData%\Microsoft\Edge\Application\msedge.exe" (
    set "EDGE=%LocalAppData%\Microsoft\Edge\Application\msedge.exe"
)

if "%EDGE%"=="" (
    echo.
    echo  ERROR: Microsoft Edge could not be found.
    echo  Please ensure Edge is installed on this computer.
    echo.
    pause
    exit /b 1
)

:: ── Kill any existing Edge session cleanly ───────────────────────
taskkill /f /im msedge.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: ── Launch Edge in kiosk mode ────────────────────────────────────
::
::  --kiosk                      True kiosk mode — removes ALL browser UI
::  --edge-kiosk-type=fullscreen Edge-specific: fullscreen kiosk type
::  --kiosk-idle-timeout-minutes=0  Disable idle logout
::  --no-first-run               Skip first-run experience
::  --disable-extensions         No extensions can interfere
::  --disable-infobars           No "Edge is not your default browser" bar
::  --disable-session-crashed-bubble  No "restore pages" popup
::  --disable-features=...       Disable Edge-specific UI panels
::  --no-default-browser-check   Suppress default browser prompt
::  --disable-background-networking  No background requests
::  --disable-sync               No Microsoft account sync prompts
::  --user-data-dir              Isolated profile so no saved sessions bleed in
::
start "" "%EDGE%" ^
  --kiosk "%FILE_URL%" ^
  --edge-kiosk-type=fullscreen ^
  --kiosk-idle-timeout-minutes=0 ^
  --no-first-run ^
  --disable-extensions ^
  --disable-infobars ^
  --disable-session-crashed-bubble ^
  --disable-features=Translate,EdgeCollect,EdgeShoppingAssistant,msEdgeSidebarV2,HubsSidebarLayout,EdgeBingChatSidebarEnabled ^
  --no-default-browser-check ^
  --disable-background-networking ^
  --disable-sync ^
  --user-data-dir="%TEMP%\ReadingActivityKiosk"

:: ── Exit this window immediately ─────────────────────────────────
exit /b 0
