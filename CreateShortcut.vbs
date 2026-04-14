' ═══════════════════════════════════════════════════════════════════
'  CreateShortcut.vbs
'  Reading Activity Player — Shortcut Creator
'
'  Double-click this file to create two shortcuts:
'    1. On your Desktop
'    2. In this app folder (Reading Activity.lnk)
'
'  The shortcut launches Edge directly in kiosk mode.
'  No PowerShell, no batch file, no execution policy issues.
'
'  Run this ONCE on the lesson computer to install the shortcuts.
'  After that, just double-click "Reading Activity.lnk" to launch.
' ═══════════════════════════════════════════════════════════════════

Option Explicit

Dim oShell, oFSO, oSysEnv
Dim EdgeExe, AppDir, IndexPath, FileUrl
Dim KioskArgs, KioskProfile
Dim oLink, DesktopPath, ShortcutName

Set oShell  = CreateObject("WScript.Shell")
Set oFSO    = CreateObject("Scripting.FileSystemObject")
Set oSysEnv = oShell.Environment("PROCESS")

' ── Resolve paths ─────────────────────────────────────────────────
AppDir    = oFSO.GetParentFolderName(WScript.ScriptFullName)
IndexPath = AppDir & "\index.html"

If Not oFSO.FileExists(IndexPath) Then
    MsgBox "ERROR: index.html not found in:" & vbCrLf & AppDir & vbCrLf & vbCrLf & _
           "Please make sure CreateShortcut.vbs is in the reading-app folder.", _
           vbCritical, "Reading Activity - Error"
    WScript.Quit 1
End If

' Build file:// URL (replace backslashes with forward slashes)
FileUrl = "file:///" & Replace(IndexPath, "\", "/")
' Encode spaces if any
FileUrl = Replace(FileUrl, " ", "%20")

' ── Find Edge ─────────────────────────────────────────────────────
Dim EdgeCandidates(2)
EdgeCandidates(0) = oSysEnv("ProgramFiles")           & "\Microsoft\Edge\Application\msedge.exe"
EdgeCandidates(1) = oSysEnv("ProgramFiles(x86)")      & "\Microsoft\Edge\Application\msedge.exe"
EdgeCandidates(2) = oSysEnv("LOCALAPPDATA")            & "\Microsoft\Edge\Application\msedge.exe"

EdgeExe = ""
Dim i
For i = 0 To 2
    If oFSO.FileExists(EdgeCandidates(i)) Then
        EdgeExe = EdgeCandidates(i)
        Exit For
    End If
Next

If EdgeExe = "" Then
    MsgBox "ERROR: Microsoft Edge not found on this computer." & vbCrLf & vbCrLf & _
           "Please install Edge from https://microsoft.com/edge and try again.", _
           vbCritical, "Reading Activity - Error"
    WScript.Quit 1
End If

' ── Build kiosk arguments ──────────────────────────────────────────
KioskProfile = oSysEnv("TEMP") & "\ReadingActivityKiosk"

KioskArgs = "--kiosk=""" & FileUrl & """" & _
            " --edge-kiosk-type=fullscreen" & _
            " --kiosk-idle-timeout-minutes=0" & _
            " --no-first-run" & _
            " --disable-extensions" & _
            " --disable-infobars" & _
            " --disable-session-crashed-bubble" & _
            " --no-default-browser-check" & _
            " --disable-background-networking" & _
            " --disable-sync" & _
            " --disable-translate" & _
            " --autoplay-policy=no-user-gesture-required" & _
            " --disable-features=Translate,EdgeCollect,EdgeShoppingAssistant,msEdgeSidebarV2,HubsSidebarLayout,EdgeBingChatSidebarEnabled,EdgeCopilot" & _
            " --user-data-dir=""" & KioskProfile & """"

ShortcutName = "Reading Activity.lnk"

' ── Create shortcut on Desktop ────────────────────────────────────
DesktopPath = oShell.SpecialFolders("Desktop")

Dim DesktopLnk
DesktopLnk = DesktopPath & "\" & ShortcutName

Set oLink = oShell.CreateShortcut(DesktopLnk)
oLink.TargetPath       = EdgeExe
oLink.Arguments        = KioskArgs
oLink.WorkingDirectory = AppDir
oLink.Description      = "Reading Activity Player - Kiosk Mode"
oLink.IconLocation     = EdgeExe & ",0"
oLink.WindowStyle      = 3   ' Maximised window on launch
oLink.Save

' ── Create shortcut in app folder too ────────────────────────────
Dim AppLnk
AppLnk = AppDir & "\" & ShortcutName

Set oLink = oShell.CreateShortcut(AppLnk)
oLink.TargetPath       = EdgeExe
oLink.Arguments        = KioskArgs
oLink.WorkingDirectory = AppDir
oLink.Description      = "Reading Activity Player - Kiosk Mode"
oLink.IconLocation     = EdgeExe & ",0"
oLink.WindowStyle      = 3
oLink.Save

' ── Done ──────────────────────────────────────────────────────────
MsgBox "Shortcuts created successfully!" & vbCrLf & vbCrLf & _
       "1.  Desktop -> " & ShortcutName & vbCrLf & _
       "2.  App folder -> " & ShortcutName & vbCrLf & vbCrLf & _
       "Double-click either shortcut to launch the Reading Activity" & vbCrLf & _
       "in full kiosk mode." & vbCrLf & vbCrLf & _
       "To exit kiosk:  Ctrl + Alt + Del -> Task Manager -> End Task (msedge.exe)", _
       vbInformation, "Reading Activity - Shortcuts Created"

WScript.Quit 0
