; Dungeon Macro Configuration
; This file contains all dungeon-specific setup and functionality

; Dungeon Maps
DungeonMaps := ["Monarch Dungeon", "Devil Dungeon"]

; Dungeon Curses
DungeonCurses := ["Dull", "Nullify", "Blitz", "Regeneration", "Bankrupt", "Sluggish", "Endurance", "Weakened", "Equilibrium", "godless"]
DungeonSelectedCurses := []

; Dungeon UI Elements (will be created by main ALS.ahk)
global DungeonCurseLabel
global DungeonCurseDropDown
global DungeonClearCursesBtn

; Setup UI elements for Dungeon
SetupDungeonUI(gui, x, y) {
    global DungeonCurseLabel, DungeonCurseDropDown, DungeonClearCursesBtn
    
    DungeonCurseLabel := gui.Add("Text", "x" . x . " y" . y . " w80 h15 cFFFFFF", "Curses:")
    DungeonCurseDropDown := gui.Add("DropDownList", "x" . x . " y" . (y + 20) . " w140 cFFFFFF -E0x200 +Theme", DungeonCurses)
    DungeonCurseDropDown.SetFont("s9 Bold", "Segoe UI")
    DungeonCurseDropDown.OnEvent("Change", ToggleDungeonCurse)
    
    DungeonClearCursesBtn := gui.Add("Button", "x" . (x + 145) . " y" . (y + 20) . " w30 h20", "Clear")
    DungeonClearCursesBtn.SetFont("s7", "Segoe UI")
    DungeonClearCursesBtn.OnEvent("Click", ClearDungeonCurses)
    
    ; Initially hide elements
    DungeonCurseLabel.Visible := false
    DungeonCurseDropDown.Visible := false
    DungeonClearCursesBtn.Visible := false
}

; Show Dungeon UI
ShowDungeonUI() {
    global DungeonCurseLabel, DungeonCurseDropDown, DungeonClearCursesBtn
    DungeonCurseLabel.Visible := true
    DungeonCurseDropDown.Visible := true
    DungeonClearCursesBtn.Visible := true
    UpdateDungeonCurseDropdownDisplay()
    LoadDungeonCurseSelection()
    LogMessage("Dungeon UI elements shown", "info")
}

; Hide Dungeon UI
HideDungeonUI() {
    global DungeonCurseLabel, DungeonCurseDropDown, DungeonClearCursesBtn
    DungeonCurseLabel.Visible := false
    DungeonCurseDropDown.Visible := false
    DungeonClearCursesBtn.Visible := false
}

; Toggle curse selection for dungeon
ToggleDungeonCurse(*) {
    global DungeonCurseDropDown, DungeonSelectedCurses, DungeonCurses
    
    selectedText := DungeonCurseDropDown.Text
    baseCurseName := StrReplace(selectedText, "✅ ", "")
    
    ; Check if curse is already selected
    isSelected := false
    removeIndex := 0
    for index, curse in DungeonSelectedCurses {
        if (curse == baseCurseName) {
            isSelected := true
            removeIndex := index
            break
        }
    }
    
    if (isSelected) {
        DungeonSelectedCurses.RemoveAt(removeIndex)
        LogMessage("Removed dungeon curse: " . baseCurseName, "info")
    } else {
        DungeonSelectedCurses.Push(baseCurseName)
        LogMessage("Added dungeon curse: " . baseCurseName, "info")
    }
    
    UpdateDungeonCurseDropdownDisplay()
    SaveDungeonCurseSelection()
}

; Clear all dungeon curses
ClearDungeonCurses(*) {
    global DungeonSelectedCurses
    DungeonSelectedCurses := []
    UpdateDungeonCurseDropdownDisplay()
    SaveDungeonCurseSelection()
    LogMessage("All dungeon curses cleared", "info")
}

; Update dungeon curse dropdown display
UpdateDungeonCurseDropdownDisplay() {
    global DungeonCurseDropDown, DungeonSelectedCurses, DungeonCurses
    
    if (!DungeonCurseDropDown) {
        return
    }
    
    currentSelection := DungeonCurseDropDown.Text
    currentIndex := 0
    
    DungeonCurseDropDown.Delete()
    
    newOptions := []
    for index, curse in DungeonCurses {
        isSelected := false
        for selectedCurse in DungeonSelectedCurses {
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
    
    DungeonCurseDropDown.Add(newOptions)
    
    if (currentIndex > 0) {
        DungeonCurseDropDown.Choose(currentIndex)
    }
    
    LogMessage("Dungeon curse dropdown updated with " . newOptions.Length . " options", "info")
}

; Load dungeon curse selection
LoadDungeonCurseSelection() {
    global DungeonSelectedCurses
    
    settingsFile := A_ScriptDir . "\libs\settings\Curse.txt"
    if (FileExist(settingsFile)) {
        try {
            savedCurses := FileRead(settingsFile)
            if (savedCurses != "") {
                DungeonSelectedCurses := StrSplit(savedCurses, "|")
                UpdateDungeonCurseDropdownDisplay()
                LogMessage("Loaded " . DungeonSelectedCurses.Length . " dungeon curses", "info")
            }
        } catch {
            DungeonSelectedCurses := []
            LogMessage("Error reading dungeon curse file", "warning")
            UpdateDungeonCurseDropdownDisplay()
        }
    } else {
        DungeonSelectedCurses := []
        UpdateDungeonCurseDropdownDisplay()
    }
}

; Save dungeon curse selection
SaveDungeonCurseSelection() {
    global DungeonSelectedCurses
    
    curseText := ""
    for index, curse in DungeonSelectedCurses {
        if (index > 1) {
            curseText .= "|"
        }
        curseText .= curse
    }
    
    try {
        FileOpen(A_ScriptDir . "\libs\settings\Curse.txt", "w", "UTF-8").Write(curseText)
        LogMessage("Saved dungeon curses: " . curseText, "info")
    } catch {
        LogMessage("Error saving dungeon curses", "error")
    }
}

; Start Dungeon macro
StartDungeonMacro(selectedMap) {
    global X1, Y1, X2, Y2, DungeonText
    
    ; Define the DungeonText variable for this macro type
    DungeonText := "|<>*111$80.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzPzzzzzzzzzUTzYby1zzzzzzs3zx9zUDzzzzzyA0QGFsks22223X024sSA400000sk01D7X1110116A0UHlskEM00ENk88aQT0UC01UCQD7Rb7kw3gAQPjzzzzzzzzz3zzzzzzzzzzzzlzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"
      LogMessage("Starting Dungeon macro for: " . selectedMap, "info")
      ; Different navigation for dungeons - no raids teleport needed
    Sleep(2000)
    BetterClick(40, 394)  ; Clicks teleport button
    Sleep(300)
    MouseMove(407, 297)  ; Hovers over the teleport menu
    BetterClick(666, 296)  
    SendInput("{WheelDown 2}")  ; Scroll down

   
    Sleep(1000)
    BetterClick(501, 418)  ; Click on the raid maps section
    Sleep(500)    BetterClick(642, 127)  ; Close the teleport menu
      ; Ensure Roblox window is active before sending keys
    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
    if WinExist(RobloxWindow) {
        WinActivate(RobloxWindow)
        Sleep(500)  ; Wait for window to become active
    }      Sleep(1000)
    SendInput("{w down}")
    Sleep(1000)  ; Extended W movement duration to make it very visible
    SendInput("{w up}")
    Sleep(1000)
    SendInput("{a down}")
    Sleep(2938)
    SendInput("{a up}")
      ; Wait for dungeon selection screen using DungeonText
    loop {
        if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, DungeonText)) {
            LogMessage("Successfully detected dungeon selection screen!", "info")
            Sleep(1000)
               FindCurses()

            MangoLookForMap(selectedMap, "")
            break
        } else {
            LogMessage("Failed to detect dungeon selection screen, retrying...", "warning")
            Sleep(2000)
                       ; Retry the same sequence using DungeonText
            BetterClick(810, 165) ;closes ui from other stuff
            Sleep(500)
            BetterClick(793, 165) ;closes ui from other stuff
            Sleep(500)
            BetterClick(837, 507) ;closes ui from other stuff

            Sleep(1000)
            BetterClick(40, 394)
            Sleep(300)
            MouseMove(407, 297)
            SendInput("{WheelDown 2}")
            
            Sleep(1000)
            BetterClick(501, 418)
            Sleep(500)
            BetterClick(642, 127)
              ; Retry walking movement
               MoveCamera()
            Sleep(1000)
            SendInput("{w down}")
            Sleep(1000)  ; Extended retry W movement duration to make it very visible
            SendInput("{w up}")
            Sleep(1000)
            SendInput("{a down}")
            Sleep(2938)
            SendInput("{a up}")
            
            ; Continue loop to check DungeonText again
        }
    }
}


; Stop Dungeon macro
StopDungeonMacro() {
    LogMessage("Stopping Dungeon macro", "info")
    ; Add dungeon stop logic here
}

; Helper function to join array elements
JoinArray(arr, separator) {
    result := ""
    for index, value in arr {
        if (index > 1) {
            result .= separator
        }
        result .= value
    }
    return result
}

HandleDungeonMap(MapName) {
    LogMessage("Handling dungeon map: " . MapName, "info")
        Loaded := "|<>*141$33.000000600003zk0S0km02E66OZn0XVzwA6480VUwn2CM6aHPn0kl3O87DAPNbzzzzzzzzzzzzzzzzzzzzzw"

    switch (MapName) {
        case "Monarch Dungeon":
            ; Select Monarch Dungeon
            BetterClick(566, 162)  ; selects monarch dungeon
            Sleep(500)  ; Wait for the selection to register
            BetterClick(389, 499)  ; press select
            Sleep(500)  ; Wait for the selection to register
            BetterClick(727, 480)  ; Click start button
            LogMessage("Selected Monarch Dungeon", "info")
            MainTerminal()
            
        case "Devil Dungeon":
            ; Select Devil Dungeon
            BetterClick(273, 163)  ; selects devil dungeon
            Sleep(500)  ; Wait for the selection to register
            BetterClick(389, 499)  ; press select
            Sleep(500)  ; Wait for the selection to register
            BetterClick(727, 480)  ; Click start button
            LogMessage("Selected Devil Dungeon", "info")
            ; lets wait for the characterr to load into the match
            MainTerminal()
        
                
        default:
            LogMessage("Unknown dungeon map: " . MapName, "error")
    }
    
    ; For dungeons, no stage selection needed, just start the map
    Sleep(1000)
    BetterClick(722, 508)  ; Click start button
}



FindCurses() {
    global SelectedCurses, BaseCurses
    ; Note: CurseDropDown is now managed by DungeonMacro class

    BetterClick(259, 190) ; clicks devil dungeon
    Sleep(1000)  ; Wait for the curses menu to load
    
    for index, curses in SelectedCurses {

         BetterClick(795, 335)  ; Clicks scrollbar
        Sleep(1000)  ; Wait for the curses menu to load       
            switch curses {
            case "Dull":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Dull curse found, applying...", "info")
                BetterClick(676, 281)  ; Clicks the Dull curse button
                
            case "Nullify":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Nullify curse found, applying...", "info")
                BetterClick(691, 355)  ; Clicks the Nullify curse button
                
            case "Blitz":
                SendInput("{WheelUp 10}")  
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Blitz curse found, applying...", "info")
                BetterClick(673, 435)  ; Clicks the Blitz curse button
                
            case "Regeneration":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Regeneration curse found, applying...", "info")
                BetterClick(678, 504)  ; Clicks the Regeneration curse button
                
            case "Bankrupt":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                SendInput("{WheelDown 1}")  ; Scroll down to reveal more curses
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Bankrupt curse found, applying...", "info")
                BetterClick(670, 449)  ; Clicks the Bankrupt curse button
                
            case "Sluggish":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                SendInput("{WheelDown 1}")  ; Scroll down to reveal more curses
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Sluggish curse found, applying...", "info")
                BetterClick(679, 505)  ; Clicks the Sluggish curse button
                
            case "Endurance":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                SendInput("{WheelDown 2}")
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Endurance curse found, applying...", "info")
                BetterClick(682, 458)  ; Clicks the Endurance curse button
                
            case "Weakened":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                SendInput("{WheelDown 3}")  ; Scroll down to reveal more curses
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Weakened curse found, applying...", "info")
                BetterClick(673, 405)  ; Clicks the Weakened curse button
                
            case "Equilibrium":
                SendInput("{WheelUp 10}") 
                Sleep(1000)  ; Wait for scroll to complete
                SendInput("{WheelDown 3}")  ; Scroll down to reveal more curses
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("Equilibrium curse found, applying...", "info")
                BetterClick(684, 491)  ; Clicks the Equilibrium curse button
                
            case "godless":
                SendInput("{WheelUp 10}")  ; Reset scroll position
                Sleep(1000)  ; Wait for scroll to complete
                SendInput("{WheelDown 6}")  ; Scroll down more to reach godless curse
                Sleep(1000)  ; Wait for scroll to complete
                LogMessage("godless curse found, applying...", "info")                BetterClick(686, 485)  ; Clicks the godless curse button (further down)
                
            default:
                LogMessage("Unknown curse: " . curses, "warning")
        }
    }    LogMessage("All selected curses applied successfully!", "success")
}
