; Survival Macro Configuration
; This file contains all survival-specific setup and functionality

; Survival Maps
SurvivalMaps := ["Hell Invasion", "Holy Invasion", "Villan Invasion"]

; Define SurvivalText for FindText usage
global SurvivalText := "|<>*142$93.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000k0000000000000000000001k00000000000000001U000007k000000000000003t000DzVU0000000000000DUD07zXk0000000000001nkn0Dzlz0000000000003ztn0nwTzU000000000007ztn0lwTz0000000000000DDlkTbnw0000000000001zT7kTblU0000000000003zD7UDbk00000000000007y77UTzU000000000000Dw3DUD7U000000000001znDnUn3k000000000003zlCDUnDU000000000007zkQTblU0000000000000D0CT7k00000000000001U0Dzk000000000000030077000000000000000000000000000000000000000000000000000000"
SurvivalSelectedCurses := []

; Survival UI Elements (will be created by main ALS.ahk)
global SurvivalCurseLabel
global SurvivalCurseDropDown
global SurvivalClearCursesBtn

; Setup UI elements for Survival
SetupSurvivalUI(gui, x, y) {
    global SurvivalCurseLabel, SurvivalCurseDropDown, SurvivalClearCursesBtn
    
    SurvivalCurseLabel := gui.Add("Text", "x" . x . " y" . y . " w80 h15 cFFFFFF", "Curses:")
    SurvivalCurseDropDown := gui.Add("DropDownList", "x" . x . " y" . (y + 20) . " w140 cFFFFFF -E0x200 +Theme", SurvivalCurses)
    SurvivalCurseDropDown.SetFont("s9 Bold", "Segoe UI")
    SurvivalCurseDropDown.OnEvent("Change", ToggleSurvivalCurse)
    
    SurvivalClearCursesBtn := gui.Add("Button", "x" . (x + 145) . " y" . (y + 20) . " w30 h20", "Clear")
    SurvivalClearCursesBtn.SetFont("s7", "Segoe UI")
    SurvivalClearCursesBtn.OnEvent("Click", ClearSurvivalCurses)
    
    ; Initially hide elements
    SurvivalCurseLabel.Visible := false
    SurvivalCurseDropDown.Visible := false
    SurvivalClearCursesBtn.Visible := false
}

; Show Survival UI
ShowSurvivalUI() {
    global SurvivalCurseLabel, SurvivalCurseDropDown, SurvivalClearCursesBtn
    SurvivalCurseLabel.Visible := true
    SurvivalCurseDropDown.Visible := true
    SurvivalClearCursesBtn.Visible := true
    UpdateSurvivalCurseDropdownDisplay()
    LoadSurvivalCurseSelection()
    LogMessage("Survival UI elements shown", "info")
}

; Hide Survival UI
HideSurvivalUI() {
    global SurvivalCurseLabel, SurvivalCurseDropDown, SurvivalClearCursesBtn
    SurvivalCurseLabel.Visible := false
    SurvivalCurseDropDown.Visible := false
    SurvivalClearCursesBtn.Visible := false
}

; Toggle curse selection for survival
ToggleSurvivalCurse(*) {
    global SurvivalCurseDropDown, SurvivalSelectedCurses, SurvivalCurses
    static isUpdating := false
    
    ; Prevent recursive calls
    if (isUpdating) {
        return
    }
    
    isUpdating := true
    
    selectedText := SurvivalCurseDropDown.Text
    baseCurseName := StrReplace(selectedText, "✅ ", "")
    
    ; Check if curse is already selected
    isSelected := false
    removeIndex := 0
    for index, curse in SurvivalSelectedCurses {
        if (curse == baseCurseName) {
            isSelected := true
            removeIndex := index
            break
        }
    }
    
    if (isSelected) {
        SurvivalSelectedCurses.RemoveAt(removeIndex)
        LogMessage("Removed survival curse: " . baseCurseName, "info")
    } else {
        SurvivalSelectedCurses.Push(baseCurseName)
        LogMessage("Added survival curse: " . baseCurseName, "info")
    }
    
    UpdateSurvivalCurseDropdownDisplay()
    SaveSurvivalCurseSelection()
    
    isUpdating := false
}

; Clear all survival curses
ClearSurvivalCurses(*) {
    global SurvivalSelectedCurses
    SurvivalSelectedCurses := []
    UpdateSurvivalCurseDropdownDisplay()
    SaveSurvivalCurseSelection()
    LogMessage("All survival curses cleared", "info")
}

; Update survival curse dropdown display
UpdateSurvivalCurseDropdownDisplay() {
    global SurvivalCurseDropDown, SurvivalSelectedCurses, SurvivalCurses
    static isUpdating := false
    
    if (!SurvivalCurseDropDown || isUpdating) {
        return
    }
    
    isUpdating := true
    
    currentSelection := SurvivalCurseDropDown.Text
    currentIndex := 0
    
    SurvivalCurseDropDown.Delete()
    
    newOptions := []
    for index, curse in SurvivalCurses {
        isSelected := false
        for selectedCurse in SurvivalSelectedCurses {
            if (selectedCurse == curse) {
                isSelected := true
                break
            }
        }
        if (isSelected) {
            newOptions.Push("✅ " . curse)
            if (currentSelection == curse || currentSelection == "✅ " . curse) {
                currentIndex := index
            }
        } else {
            newOptions.Push(curse)
            if (currentSelection == curse || currentSelection == "✅ " . curse) {
                currentIndex := index
            }
        }
    }
    
    SurvivalCurseDropDown.Add(newOptions)
    
    if (currentIndex > 0) {
        SurvivalCurseDropDown.Choose(currentIndex)
    }
    
    isUpdating := false
    
    LogMessage("Survival curse dropdown updated with " . newOptions.Length . " options", "info")
}

; Load survival curse selection
LoadSurvivalCurseSelection() {
    global SurvivalSelectedCurses
    
    settingsFile := A_ScriptDir . "\libs\settings\SurvivalCurse.txt"
    if (FileExist(settingsFile)) {
        try {
            savedCurses := FileRead(settingsFile)
            if (savedCurses != "") {
                SurvivalSelectedCurses := StrSplit(savedCurses, "|")
                UpdateSurvivalCurseDropdownDisplay()
                LogMessage("Loaded " . SurvivalSelectedCurses.Length . " survival curses", "info")
            }
        } catch {
            SurvivalSelectedCurses := []
            LogMessage("Error reading survival curse file", "warning")
            UpdateSurvivalCurseDropdownDisplay()
        }
    } else {
        SurvivalSelectedCurses := []
        UpdateSurvivalCurseDropdownDisplay()
    }
}

; Save survival curse selection
SaveSurvivalCurseSelection() {
    global SurvivalSelectedCurses
    
    curseText := ""
    for index, curse in SurvivalSelectedCurses {
        if (index > 1) {
            curseText .= "|"
        }
        curseText .= curse
    }
    
    try {
        FileOpen(A_ScriptDir . "\libs\settings\SurvivalCurse.txt", "w", "UTF-8").Write(curseText)
        LogMessage("Saved survival curses: " . curseText, "info")
    } catch {
        LogMessage("Error saving survival curses", "error")
    }
}

; Start Survival macro
StartSurvivalMacro(selectedMap) {
    global X1, Y1, X2, Y2
    SurvivalText := "|<>*129$90.0000000000000000000000000000000000000070000Q007s00000TU001y00Ty00000Nk001X00sD00000Mk001X00k3U0000Mk001X01U3wTzzXsz3nzX01V7zzzzrzzbzzX01XzzzzzzszzzzX01Uz7X4NyMnww1X01U7730Ew8VsM0X00k3730MQMksk0X00s3733sMMkkkUX01z3737w8ssFlkX01bX736A0ss1llXU1XX23661sw3kVXk1U303671sy3k1Uk1k7U3633sq7s1Uk0sDlb61bsnDQNlk0Tyzzy1zTnyDzzk07sDzw0yDVw3zzU000000000000000000000000000000000000000000000000000000000000000000000000000U"
    
    LogMessage("Starting Survival macro for: " . selectedMap, "info")
    
    ; Ensure window is active before proceeding
    if !WinActive("Roblox") {
        LogMessage("Roblox window not active, attempting to activate...", "warning")
        WinActivate("Roblox")
        Sleep(1000)
        if !WinActive("Roblox") {
            return
        }
    }
    
    ; Navigate to Survival area
    Sleep(2000)
    BetterClick(40, 394)  ; Clicks teleport button
    Sleep(300)
    MouseMove(407, 297)  ; Hovers over the teleport menu
    BetterClick(666, 296)  ; Click on the scroll bar
    SendInput("{WheelDown 2}")  ; Scroll down

    Sleep(1000)
    BetterClick(501, 460)  ; Click on the survival section (adjusted coordinates)
    Sleep(500)
    BetterClick(642, 127)  ; Close the teleport menu
    Sleep(500)
    
    ; Move to survival area with improved reliability
    Sleep(1000)
    LogMessage("Moving to survival area (holding D key)...", "info")
    
    ; Ensure all keys are released first
    SendInput("{D up}")
    Sleep(100)
    
    ; Hold D key with better timing
    SendInput("{D down}")
    Sleep(5000)  ; Hold D for 5 seconds
    SendInput("{D up}")
    
    LogMessage("Movement completed, checking for survival selection screen...", "info")
    
    ; Wait for survival selection screen
    loop {
        if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, SurvivalText)) {
            LogMessage("Successfully entered the survival selection!", "info")
            
            HandleSurvivalMap(selectedMap)
            break
        } else {
            LogMessage("Failed to enter survival selection. Retrying...", "warning")
            
            ; Ensure all keys are released before retry
          
            Sleep(500)
            
            Sleep(2000)
            ; Retry the same sequence
            BetterClick(810, 165) ;closes ui from other stuff
            Sleep(500)
            BetterClick(793, 165) ;closes ui from other stuff
            Sleep(500)
            BetterClick(837, 507) ;closes ui from other stuff

            Sleep(1000)
            BetterClick(40, 394)
            Sleep(300)
            MouseMove(407, 297)
            BetterClick(717, 354)  ; Click on the scroll bar
            SendInput("{WheelDown 2}")
        
            Sleep(1000)
            BetterClick(501, 418)
            Sleep(500)
            BetterClick(642, 127)
            
            ; Retry walking movement with window focus check
            if !WinActive("Roblox") {
                WinActivate("Roblox")
                Sleep(1000)
            }

            MoveCamera()
            Sleep(1000)
            LogMessage("Camera movement completed, starting retry movement (holding D)...", "info")
            Sleep(1000)
            
            ; Ensure key is released before pressing
            SendInput("{D up}")
            Sleep(100)
            SendInput("{D down}")
            Sleep(2938)         
            SendInput("{D up}")
            
            LogMessage("Retry movement completed", "info")
        }
    }
}

HandleSurvivalMap(MapName) {
    global X1, Y1, X2, Y2, SurvivalText ; Ensure SurvivalText is defined or passed
    LogMessage("Handling survival map: " . MapName, "info")

    ; This function will contain the logic to select the specific survival map
    ; based on the MapName.

    LogMessage("Looking for map: " . MapName . " in Survival interface...", "info")

    ; The StartSurvivalMacro already has a loop that calls HandleSurvivalMap
    ; once the SurvivalText is found. So this function can directly proceed
    ; with the map-specific clicks.

    switch (MapName) {
        case "Hell Invasion":
            LogMessage("Selecting Hell Invasion...", "info")
            BetterClick(235, 209) ; Placeholder: Click Hell Invasion
            FindSurvivalCurses()
            Sleep(500)
            BetterClick(389, 499) ; Click Select
            Sleep(500)
            BetterClick(727, 480) ; Click Start
            MainTerminal()
        case "Holy Invasion":
            LogMessage("Selecting Holy Invasion...", "info")
            
            BetterClick(235, 250) ; Placeholder: Click Holy Invasion
            FindSurvivalCurses()
            Sleep(500)
            BetterClick(389, 499) ; Click Select
            Sleep(500)
            BetterClick(727, 480) ; Click Start
            MainTerminal()
        case "Villan Invasion":
            LogMessage("Selecting Villan Invasion...", "info")
            BetterClick(235, 291) ; Placeholder: Click Villan Invasion
            FindSurvivalCurses()
            Sleep(500)
            BetterClick(389, 499) ; Click Select
            Sleep(500)
            BetterClick(727, 480) ; Click Start
            MainTerminal()
        default:
            LogMessage("Unknown survival map: " . MapName, "error")
    }
}

StopSurvivalMacro() {
    LogMessage("Stopping Survival macro", "info")
    ; Add survival stop logic here
}
FindSurvivalCurses(){
    global SurvivalCurses := ["Powerless", "Bankrupt", "Sluggish", "Weakness", "True Boss Fight", "No one leaves alive"]
    global SurvivalSelectedCurses, SurvivalCurses, SurvivalCurseDropDown

    LogMessage("Applying selected survival curses...", "info")
    Sleep(1000)  ; Wait for the curses menu to load
    
    ; Check if there are any selected curses
    if (SurvivalSelectedCurses.Length = 0) {
        LogMessage("No survival curses selected, skipping curse application", "info")
        return
    }
    
    for index, curses in SurvivalSelectedCurses {

         BetterClick(795, 335)  ; Clicks scrollbar
        Sleep(1000)  ; Wait for the curses menu to load       
            switch curses {
            case "Powerless":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Powerless curse found, applying...", "info")
                BetterClick(673, 258)  ; Clicks the Dull curse button
                
            case "Bankrupt":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Bankrupt curse found, applying...", "info")
                BetterClick(666, 348)  ; Clicks the Nullify curse button
                
            case "Sluggish":
                SendInput("{WheelUp 10}")  
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Sluggish curse found, applying...", "info")
                BetterClick(674, 414)  ; Clicks the Blitz curse button
                
            case "Weakness":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Weakness curse found, applying...", "info")
                BetterClick(670, 481)  ; Clicks the Regeneration curse button
                
            case "True Boss Fight":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                SendInput("{WheelDown 1}")  ; Scroll down to reveal more curses
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("True Boss Fight curse found, applying...", "info")
                BetterClick(671, 424)  ; Clicks the Bankrupt curse button
                  case "No one leaves alive":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                SendInput("{WheelDown 1}")  ; Scroll down to reveal more curses
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("No one leaves alive curse found, applying...", "info")
                BetterClick(671, 504)  ; Clicks the Sluggish curse button
                
        
                
            default:
                LogMessage("Unknown curse: " . curses, "warning")
        }
    }

    LogMessage("All selected curses applied successfully!", "success")
}