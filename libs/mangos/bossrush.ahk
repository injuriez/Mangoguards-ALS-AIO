; Boss Rush Macro Configuration
; This file contains all boss rush-specific setup and functionality

; Global variables for Boss Rush macro
global BossRushMaps := ["Grail Rush", "Titan Rush", "Godly Rush"]

BossRushSetupUI(gui, x, y) {
    ; Boss Rush doesn't need additional UI elements as options are in main dropdown
    ; This is a placeholder for future boss rush specific UI
}

BossRushShowUI() {
    LogMessage("Boss Rush mode selected - options displayed in main dropdown", "info")
}

BossRushHideUI() {
    ; Nothing to hide for Boss Rush
}

BossRushLoadSettings() {
    settingsFile := A_ScriptDir . "\libs\settings\bossrush\BossRush.txt"
    if (FileExist(settingsFile)) {
        try {
            savedBossRush := FileRead(settingsFile)
            ; Boss Rush selection is handled in main dropdown
        } catch {
            LogMessage("Error loading boss rush settings", "warning")
        }
    }
}

BossRushSaveSettings(selectedRush) {
    try {
        FileOpen(A_ScriptDir . "\libs\settings\bossrush\BossRush.txt", "w", "UTF-8").Write(selectedRush)
        LogMessage("Saved boss rush: " . selectedRush, "info")
    } catch {
        LogMessage("Error saving boss rush", "error")
    }
}

BossRushStartMacro() {
    LogMessage("Starting Boss Rush macro", "info")
    ; Add boss rush macro logic here
}

BossRushStopMacro() {
    LogMessage("Stopping Boss Rush macro", "info")
    ; Add boss rush stop logic here
}

StartBossRushMacro(selectedMap, selectedBossRush := "Grail Rush") {
    global X1, Y1, X2, Y2
    
    LogMessage("Starting Boss Rush macro for: " . selectedMap . " (Type: " . selectedBossRush . ")", "info")
    
    ; Navigate to Boss Rush area 
    Sleep(1000)
    BetterClick(40, 394)  ; Clicks teleport button
    Sleep(300)
    MouseMove(407, 297)  ; Hovers over teleport menu
    
    ; Click on Boss Rush section (you'll need to determine actual coordinates)
    BetterClick(501, 350)  ; Placeholder coordinates for Boss Rush teleport option
    Sleep(500)
    BetterClick(642, 127)  ; Close teleport menu
    
    ; Move to Boss Rush area
    LogMessage("Moving to Boss Rush area...", "info")
    SendInput("{w down}")
    Sleep(1500)  ; Move forward towards Boss Rush area
    SendInput("{w up}")
    
    Sleep(1000)
    
    ; Wait for Boss Rush selection interface
    LogMessage("Looking for Boss Rush selection interface...", "info")
    
    ; Use a loop to detect Boss Rush interface (you'll need to define BossRushText)
    ; For now, using a generic approach
    loop {
        Sleep(1000)
        LogMessage("Waiting for Boss Rush interface to load...", "debug")
        
        ; Placeholder: Check if we've reached Boss Rush area
        ; You'll need to define specific FindText patterns for Boss Rush detection
        ; For now, proceed after a delay
        if (A_Index > 10) {  ; Wait max 10 seconds
            LogMessage("Proceeding with Boss Rush selection after timeout", "info")
            break
        }
    }
    
    ; Handle specific Boss Rush types
    switch (selectedBossRush) {
        case "Grail Rush":
            LogMessage("Starting Grail Rush", "info")
            ; Add specific coordinates for Grail Rush selection
            BetterClick(400, 200)  ; Placeholder coordinates
            Sleep(500)
            
        case "Titan Rush":
            LogMessage("Starting Titan Rush", "info")
            ; Add specific coordinates for Titan Rush selection
            BetterClick(400, 250)  ; Placeholder coordinates
            Sleep(500)
            
        case "Godly Rush":
            LogMessage("Starting Godly Rush", "info")
            ; Add specific coordinates for Godly Rush selection
            BetterClick(400, 300)  ; Placeholder coordinates
            Sleep(500)
            
        default:
            LogMessage("Unknown Boss Rush type: " . selectedBossRush . ", defaulting to Grail Rush", "warning")
            BetterClick(400, 200)  ; Default to Grail Rush coordinates
            Sleep(500)
    }
    
    ; Click start button for Boss Rush
    Sleep(1000)
    BetterClick(722, 508)  ; Start button (similar to other modes)
    ; Wait for character to load and start MainTerminal
    LogMessage("Boss Rush started, waiting for character to load...", "info")
    MainTerminal()
}

HandleBossRushMap(MapName, selectedBossRush := "Grail Rush") {
    LogMessage("Handling Boss Rush map: " . MapName . " (Type: " . selectedBossRush . ")", "info")
    ; Note: MapName might be redundant if selectedBossRush dictates the map.
    ; The StartBossRushMacro already navigates to the general Boss Rush area.
    ; This function will handle the selection of the specific rush type.

    switch (selectedBossRush) {
        case "Grail Rush":
            LogMessage("Selecting Grail Rush...", "info")
            BetterClick(400, 200)  ; Placeholder coordinates from StartBossRushMacro
            Sleep(500)
        case "Titan Rush":
            LogMessage("Selecting Titan Rush...", "info")
            BetterClick(400, 250)  ; Placeholder coordinates
            Sleep(500)
        case "Godly Rush":
            LogMessage("Selecting Godly Rush...", "info")
            BetterClick(400, 300)  ; Placeholder coordinates
            Sleep(500)
        default:
            LogMessage("Unknown Boss Rush type: " . selectedBossRush . ", defaulting to Grail Rush", "warning")
            BetterClick(400, 200)  ; Default to Grail Rush
            Sleep(500)
    }
    
    ; Click start button for Boss Rush
    Sleep(1000)
    BetterClick(722, 508)  ; Start button (consistent with other modes)
    LogMessage("Boss Rush (" . selectedBossRush . ") selected and attempting to start.", "info")
    MainTerminal() ; Assuming MainTerminal is called after starting
}
