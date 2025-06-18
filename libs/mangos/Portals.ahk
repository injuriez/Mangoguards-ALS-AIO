#Requires AutoHotkey v2.0

; Portals Macro Configuration
; This file contains portal-specific setup and functionality

; Define portal tiers and elements (using only Summer Laguna as the fixed map)
global PortalTiers := ["1", "2", "3", "4", "5", "6", "7"]
global PortalElements := ["Fire", "Light", "Dark", "Nature", "Water", "I Do Not Care"]
global PortalBlacklist := ["Barebones", "Flight", "High Cost", "No Hit", "Tower Limit", "Short Range", "Speedy", "Immunity", "None"]  ; Added "None" back to the list
global SelectedBlacklist := []  ; Simple array to store selected blacklist items
                        
global TierLabel := ""
global TierDropDown := ""
global ElementLabel := ""
global ElementDropDown := ""
global BlacklistLabel := ""
global BlacklistDropDown := ""
global BlacklistDisplayText := []  ; Array to store display text with checkmarks

; Setup UI elements for Portals
SetupPortalsUI(gui, x, y) {
    global TierLabel, TierDropDown, PortalTiers, ElementLabel, ElementDropDown, PortalElements
    global BlacklistLabel, BlacklistDropDown, PortalBlacklist, BlacklistDisplayText
    
    ; Set up element selection next to Select Macros dropdown (at y=225 in ALS.ahk)
    ElementLabel := gui.Add("Text", "x1230 y205 w100 h15 cFFFFFF", "Select Element:")
    ElementDropDown := gui.Add("DropDownList", "x1230 y225 w120 cFFFFFF -E0x200 +Theme", PortalElements)
    ElementDropDown.SetFont("s9 Bold", "Segoe UI")    ElementDropDown.OnEvent("Change", PortalElementSaveSettings)
    
    BlacklistLabel := gui.Add("Text", "x1360 y205 w120 h15 cFFFFFF", "Blacklist Filters:")
    
    BlacklistDisplayText := []
    for item in PortalBlacklist {
        if (item = "None") {
            BlacklistDisplayText.Push("✓ " . item)
        } else {
            BlacklistDisplayText.Push("  " . item)
        }
    }
    
    BlacklistDropDown := gui.Add("DropDownList", "x1360 y225 w90 cFFFFFF -E0x200 +Theme", BlacklistDisplayText)
    BlacklistDropDown.SetFont("s9 Bold", "Segoe UI")
    BlacklistDropDown.OnEvent("Change", OnBlacklistDropDownChange)
    BlacklistDropDown.OnEvent("Focus", OnBlacklistDropDownFocus)
    BlacklistDropDown.Choose(PortalBlacklist.Length)
    
    SetTimer(ForceCheckUIState, 250)
    
    ; Set up tier selection next to Select Option dropdown (at y=275 in ALS.ahk)
    TierLabel := gui.Add("Text", "x1230 y255 w80 h15 cFFFFFF", "Portal Tier:")
    TierDropDown := gui.Add("DropDownList", "x1230 y275 w120 cFFFFFF -E0x200 +Theme", PortalTiers)
    TierDropDown.SetFont("s9 Bold", "Segoe UI")
    TierDropDown.OnEvent("Change", PortalTierSaveSettings)    ; Initially hide all elements
    TierLabel.Visible := false
    TierDropDown.Visible := false
    ElementLabel.Visible := false
    ElementDropDown.Visible := false
    BlacklistLabel.Visible := false
    BlacklistDropDown.Visible := false
}

ShowPortalsUI() {
    global TierLabel, TierDropDown, ElementLabel, ElementDropDown, BlacklistLabel, BlacklistDropDown
    
    ; Show all portal UI elements
    TierLabel.Visible := true
    TierDropDown.Visible := true
    ElementLabel.Visible := true
    ElementDropDown.Visible := true
    BlacklistLabel.Visible := true
    BlacklistDropDown.Visible := true
    
    ; Load saved settings
    PortalTierLoadSettings()
    PortalElementLoadSettings()
    PortalBlacklistLoadSettings()  ; Re-enabled - load blacklist from file and update UI

}

HidePortalsUI() {
    global TierLabel, TierDropDown, ElementLabel, ElementDropDown, BlacklistLabel, BlacklistDropDown
    
    TierLabel.Visible := false
    TierDropDown.Visible := false
    ElementLabel.Visible := false
    ElementDropDown.Visible := false
    BlacklistLabel.Visible := false
    BlacklistDropDown.Visible := false
}

; No map selection is needed as we're only using Summer Laguna

PortalTierLoadSettings() {
    global TierDropDown
    
    ; Load the tier selection for portals
    tierFile := A_ScriptDir . "\libs\settings\PortalTier.txt"
    if (FileExist(tierFile)) {
        try {
            savedTier := FileRead(tierFile)
            if (savedTier != "" && TierDropDown) {
                ; Find and select the saved tier
                loop TierDropDown.Length {
                    if (TierDropDown.GetText(A_Index) == savedTier) {
                        TierDropDown.Choose(A_Index)
                        break
                    }
                }
            }
        } catch {
            LogMessage("Error loading portal tier settings", "warning")
        }
    }
}

PortalTierSaveSettings(*) {
    global TierDropDown
      if (TierDropDown) {
        selectedTier := TierDropDown.Text
        try {
            FileOpen(A_ScriptDir . "\libs\settings\PortalTier.txt", "w", "UTF-8").Write(selectedTier)
        } catch {
            LogMessage("Error saving portal tier", "error")
        }
    }
}

PortalElementLoadSettings() {
    global ElementDropDown
    
    ; Load the element selection for portals
    elementFile := A_ScriptDir . "\libs\settings\PortalElement.txt"
    if (FileExist(elementFile)) {
        try {
            savedElement := FileRead(elementFile)
            if (savedElement != "" && ElementDropDown) {            ; Find and select the saved element
                loop PortalElements.Length {
                    if (ElementDropDown.GetText(A_Index) == savedElement) {
                        ElementDropDown.Choose(A_Index)
                        break
                    }
                }
            }
        } catch {
            LogMessage("Error loading portal element settings", "warning")
        }
    } else {
        ; Default to Fire if no setting exists
        ElementDropDown.Choose(1)
    }
}

PortalElementSaveSettings(*) {
    global ElementDropDown
      if (ElementDropDown) {
        selectedElement := ElementDropDown.Text
        try {
            FileOpen(A_ScriptDir . "\libs\settings\PortalElement.txt", "w", "UTF-8").Write(selectedElement)
        } catch {
            LogMessage("Error saving portal element", "error")
        }
    }
}

PortalBlacklistLoadSettings() {
    global BlacklistDropDown, SelectedBlacklist, BlacklistDisplayText, PortalBlacklist
    
    ; Load the blacklist selection for portals
    blacklistFile := A_ScriptDir . "\libs\settings\PortalBlacklist.txt"
    
    LogMessage("DEBUG: Loading blacklist from file: " . blacklistFile, "debug")
    
    if (FileExist(blacklistFile)) {
        try {
            fileContent := Trim(FileRead(blacklistFile))
            LogMessage("DEBUG: Raw file contents: '" . fileContent . "' (length: " . StrLen(fileContent) . ")", "debug")
            
            ; Initialize all items as unchecked
            BlacklistDisplayText := []
            for item in PortalBlacklist {
                BlacklistDisplayText.Push("  " . item)
            }
            
            ; Check if the saved setting is "None" or empty
            if (fileContent = "None" || fileContent = "") {
                SelectedBlacklist := ["None"]
                ; Mark "None" as checked
                for i, item in PortalBlacklist {
                    if (item = "None") {
                        BlacklistDisplayText[i] := "✓ " . item
                        break
                    }
                }
            } else {
                ; Split by lines instead of commas
                savedItems := StrSplit(fileContent, "`n")
                
                ; Clean up each item (trim whitespace)
                cleanItems := []
                for item in savedItems {
                    cleanItem := Trim(item)
                    if (cleanItem != "") {
                        cleanItems.Push(cleanItem)
                    }
                }
                
                
                if (cleanItems.Length = 0) {
                    SelectedBlacklist := ["None"]
                    ; Mark "None" as checked
                    for i, item in PortalBlacklist {
                        if (item = "None") {
                            BlacklistDisplayText[i] := "✓ " . item
                            break
                        }
                    }
                } else {
                    SelectedBlacklist := cleanItems
                    
                    ; Debug: Show each item in the array
                    for i, item in savedItems {
                        LogMessage("  [" . i . "] = '" . item . "' (length: " . StrLen(item) . ")", "debug")
                    }
                    
                    ; Mark each saved item as checked
                    for savedItem in savedItems {
                        savedItem := Trim(savedItem)  ; Remove any extra whitespace
                        for i, item in PortalBlacklist {
                            if (item = savedItem) {
                                BlacklistDisplayText[i] := "✓ " . item
                                break
                            }
                        }
                    }
                }
            }
        } catch {
            LogMessage("Error loading portal blacklist settings, using default", "warning")
            ; Default to "None"
            SelectedBlacklist := ["None"]
            BlacklistDisplayText := []
            for i, item in PortalBlacklist {
                if (item = "None") {
                    BlacklistDisplayText.Push("✓ " . item)
                } else {
                    BlacklistDisplayText.Push("  " . item)
                }
            }
        }
    } else {
        ; Default to "None" if no setting exists
        SelectedBlacklist := ["None"]
        BlacklistDisplayText := []
        for i, item in PortalBlacklist {
            if (item = "None") {
                BlacklistDisplayText.Push("✓ " . item)
            } else {
                BlacklistDisplayText.Push("  " . item)
            }
        }
    }
    
    ; Update the dropdown display
    if (BlacklistDropDown) {
        BlacklistDropDown.Delete()
        for text in BlacklistDisplayText {
            BlacklistDropDown.Add([text])
        }        ; Select the first checked item or "None"
        for i, text in BlacklistDisplayText {
            if (SubStr(text, 1, 1) = "✓") {
                BlacklistDropDown.Choose(i)
                break
            }
        }}
}

PortalBlacklistSaveSettings(*) {
    global BlacklistDisplayText, PortalBlacklist
    
    try {
        blacklistFile := A_ScriptDir . "\libs\settings\PortalBlacklist.txt"
        FileOpen(blacklistFile, "w", "UTF-8").Write("")
        
        currentSelections := []
        
        for i, displayText in BlacklistDisplayText {
            if (SubStr(displayText, 1, 1) = "✓") {
                itemName := Trim(StrReplace(displayText, "✓", ""))
                if (itemName != "None") {
                    currentSelections.Push(itemName)
                }
            }
        }
        
        if (currentSelections.Length > 0) {
            content := ""
            for i, item in currentSelections {
                content .= item . (i < currentSelections.Length ? "`n" : "")
            }
            
            content := RTrim(content, "`n")
            FileOpen(blacklistFile, "w", "UTF-8").Write(content)
            
            displayList := ""
            for i, item in currentSelections {
                displayList .= (i > 1 ? ", " : "") . item
            }
        }
        
        global SelectedBlacklist := currentSelections.Length > 0 ? currentSelections : ["None"]
        
    } catch as err {
        LogMessage("Error saving blacklist settings: " . err.Message, "error")
    }
}

; Direct function to read blacklist from file without UI interference
GetCurrentBlacklistFilters() {
    blacklistFile := A_ScriptDir . "\libs\settings\PortalBlacklist.txt"
    
    if (!FileExist(blacklistFile)) {
        return ["None"]
    }
    
    try {
        fileContent := Trim(FileRead(blacklistFile))
        if (fileContent = "" || fileContent = "None") {
            return ["None"]
        }
        
        ; Split by lines instead of commas
        items := StrSplit(fileContent, "`n")
        cleanItems := []
        for item in items {
            cleanItem := Trim(item)
            if (cleanItem != "") {
                cleanItems.Push(cleanItem)
            }
        }
        
        return cleanItems.Length > 0 ? cleanItems : ["None"]
    } catch {
        return ["None"]
    }
}

StartPortalMacro(selectedTier := "1", selectedElement := "Fire") {
    ; Always use "Summer Laguna" as the fixed map
    selectedMap := "Summer Laguna"
    
    ; Get blacklist filters - LOAD FIRST before any checks
    global SelectedBlacklist
    
    ; Force reload blacklist settings to ensure we have the latest data
    LogMessage("Loading blacklist settings from file...", "debug")
    PortalBlacklistLoadSettings()
    
    ; Debug: Show what's actually in SelectedBlacklist AFTER loading
    debugList := ""
    for i, item in SelectedBlacklist {
        debugList .= (i > 1 ? ", " : "") . item
    }
    
    ; Check if "None" is among selected filters - NOW this should be accurate
    hasNone := false
    for item in SelectedBlacklist {
        if (item = "None") {
            hasNone := true
            break
        }
    }
    
    

    ; Format the log message depending on selected filters
    blacklistMessage := "None"
    if (!hasNone && SelectedBlacklist.Length > 0) {
        blacklistMessage := ""
        for i, filter in SelectedBlacklist {
            blacklistMessage .= (i > 1 ? ", " : "") . filter
        }
    }
    
    ; Log start of macro with appropriate details
    if (selectedElement = "I Do Not Care") {
        if (hasNone || SelectedBlacklist.Length = 0) {
            LogMessage("Starting Portals macro for Map: " . selectedMap . ", Tier: " . selectedTier . ", Element: Any (I Do Not Care), Blacklist: None", "info")
        } else {
            LogMessage("Starting Portals macro for Map: " . selectedMap . ", Tier: " . selectedTier . ", Element: Any (I Do Not Care), Blacklist Filters: " . blacklistMessage, "info")
        }
    } else {
        if (hasNone || SelectedBlacklist.Length = 0) {
            LogMessage("Starting Portals macro for Map: " . selectedMap . ", Tier: " . selectedTier . ", Element: " . selectedElement . ", Blacklist: None", "info")
        } else {
            LogMessage("Starting Portals macro for Map: " . selectedMap . ", Tier: " . selectedTier . ", Element: " . selectedElement . ", Blacklist Filters: " . blacklistMessage, "info")
        }
    }
    
    if (selectedTier = "") {
        LogMessage("No portal tier selected, using default: 1", "warning")
        selectedTier := "1"
    }
    
    if (selectedElement = "") {
        LogMessage("No portal element selected, using default: Fire", "warning")
        selectedElement := "Fire"
    }
    
    ; Navigate to the Portals inventory
    try {
        ; Click on Items tab
        BetterClick(104, 328)  ; Click on Items
        Sleep(500)
        BetterClick(189, 232)  ; Click on Portals
        Sleep(1000)
        
        ; IMPORTANT: Always pass the hasNone parameter regardless of element filter
        ; This ensures blacklist filtering is always performed even with "I Do Not Care" element filter
        LogMessage("Passing hasNone=" . hasNone . " to HandlePortalMap regardless of element filter", "debug")
        
        ; Implement portal selection and usage based on fixed map (Summer Laguna), tier, element, and blacklist filters
        result := HandlePortalMap(selectedMap, selectedTier, selectedElement, hasNone)
        
        if (!result) {
            LogMessage("Failed to handle portal map selection", "error")
            return false
        }
        
        return true
    } catch as err {
        LogMessage("Error in StartPortalMacro: " . err.Message, "error")
        return false
    }
}

StopPortalsMacro() {
    LogMessage("Stopping Portals macro", "info")
    
    try {
        ; Add proper cleanup logic here
        ; For example, close any portal dialogs that might be open
        ; Press ESC key to close dialogs
        Send("{Escape}")
        Sleep(500)
        
        ; Return to the main game screen
        BetterClick(400, 300)  ; Click somewhere neutral on the screen
        Sleep(500)
        
        LogMessage("Portal macro stopped successfully", "info")
        return true
    } catch as err {
        LogMessage("Error stopping Portal macro: " . err.Message, "error")
        return false
    }
}

HandlePortalMap(portalMap, portalTier, portalElement := "Fire", hasNone := false, FirstTry := true) {
    global X1 := 200  ; Relative to positioned window
    global Y1 := 200
    global X2 := 1000
    global Y2 := 800
    
    ; Tier pattern definitions
    Tier1 := "|<>*130$10.zzzzzyTly7yTtzbyTts"
    Tier2 := "|<>*56$11.zzzzVz1wnxbyDlz0z1zzk"
    Tier3 := "|<>*43$10.zzzzzkz1xbwTltbkT3zzU"
    Tier4 := "|<>*102$10.zzzzztDYyHlD0y3zDwzzzy"
    Tier5 := "|<>*80$12.zzzzwDwDwzsDwDzbsDwDzzU"
    
    ; Map pattern definition
    SummerValue := "|<>*132$87.zzzzzzzzzzzzzkTzzzzzzzzzXzzzzkzzzzzzyzyzzzzy7zzzzzzbzzzzzzXrOHGQMQz3VRdsS4m00103bkM3863s6E8111wwmMN4WSmnN/83TraH/BYnkEP9N9Py6311gkT73P/NXTkMQABr3zzzzzzzzzztzzzzzzzzzzzzzsTzzzU"
    
    ; Element pattern definitions
    Fire := "|<>*35$24.0000TzzzTzzzTzzzTzzzTzvzTztzTzszTzkzTlkTTlUTTl0TTU0TTU0zTUMzTktzTk3zQs7bQST7Q1k7S00TTw7zTzzzTzzz0000U"
    Water := "|<>*29$25.0000DzzzbzzznUzztVrvwlVwyMUSDC03DbN0TnYE3tl3lwwQESS607D003bw01nr86Nzw7Aza1aTs1rDy3nbzknnzy3tzzzwzzzyU"
    Dark := "|<>*23$24.0000TzzzTzzzTzzzTzzzTzzjTzYDTu0DTk0DTk0zTE3zT02TT00TT00TT00TT00zT00zTW1zTlnzTsbzTyDzTzzzTzzzTzzz0000U"
    Nature := "|<>*36$24.TzzzTzzzTzzzTszzTwDzTw7zTw7zTw3zTw3zTw3zTs1bTw37Tw27MwE7Q0s7Q0k7Q0E7S007T0kDTUwTTvzzTzzzTzzz0000U"
    Light := "|<>*82$23.0001zzzzzzzzzzzzs3zyD1zwA3zs1Xzc3XzMD7ykCDx0ATs8Mzls1zXw1zXsDzU0TzU0zzUCzzzTzzzzzzzzzzzzk"
    
    ; Blacklist pattern definitions - these would need to be created based on the actual visual patterns in the game
    BarebonesPattern := "|<>*117$56.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzvzzzzz0zzwzzzzzkDzzDzzzzwW08EMEMMz80444046Tn331AAA1Xw24tEMH9OTVli6DCq6Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"  ; Placeholder pattern
    FlightPattern := "|<>*117$29.zzzzzzzzzzzzzzzzzzzzvTvzU4zbn1DzDa2H2244Y46Nt9dYnsMH8rmsqtzzdzzzz7zzzzzzzzzzzs"   
    HighCostPattern := "|<>*115$52.zzzzzzzzzzvzTzzzzyQDtzkzzbtnzby3zyTW323nwAEy0887DUHbtkaaQyN6Tb32NsAB8zRiBjktlnzzozzzzzzzz7zzzzzs"  
    NoHitPattern := "|<>*118$34.zzzzzzzzzzzzzzzzzzzzzrz6TwsNwNznbbkYD44D80Q0NwUNnVbn4DCqDiNyvQzzzzzzzzzzzzzzzzzs"      
    TowerLimitPattern := "|<>*121$65.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzxzw1zzzznnznDzDzzzzbzzyTyMGG4DD818TwUE98ySE2NzvAUEHwwYYnzr31nrxxdBXzjDPVjsPPPbzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw" ; Placeholder pattern
    ShortRangePattern := "|<>*120$64.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzzzzzzzzzkbzzbUzzzzyOTzyS1zzzzssA8EtY0AADkUU3bU00UYzuMMSS2MMO3sBYBstYBYAzlqtrnrMqskzzzzzzzzznzzzzzzzzzwTzzzzzzzzzzzzzzzzzzzzzzU" ; Placeholder pattern
    SpeedyPattern := "|<>*116$43.zzzzzzzzzzzzzzzzzzzzzzzzzzyzzsTzzzDzsjzzzbzwQ6660nz22221/zwB11AVzUUmmkMzsssMQQzzxzzzyTzyzzzzTzzzzzzzzzzzzzzw"     ; Placeholder pattern
    ImmunityPattern := "|<>*116$48.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzzDzzzztbzDzzzzzbz8109U90n8109U9aL9999VVa7999A1VX7hhhiBhnDzzzzzzzDzzzzzzzTzzzzzzzzU"   ; Placeholder pattern
      PortalButtonText := "|<>*122$93.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzjzzk3zzzzzzzzzDtzzw0TzzzzzzzztzDzz7UkEFUw7VU261zzsw000A7UM00EUDzz7U2210sb44D8VzzwwsEEA7Yw0VtYDzzk70EFVw7VUD40ezz6v76CDkwyBwkU7zzzzzzzzzjzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"    ; Use the hasNone parameter that was passed to this function - don't recalculate it!
    ; hasNone was already determined correctly in StartPortalMacro after loading the blacklist
      ; Format blacklist filters for logging
    blacklistMessage := "None"
    if (!hasNone && SelectedBlacklist.Length > 0) {
        blacklistMessage := ""
        for i, filter in SelectedBlacklist {
            blacklistMessage .= (i > 1 ? ", " : "") . filter
        }
    }
    
    if (portalTier = "") {
        LogMessage("Invalid portal tier specified", "error")
        return false
    }
    
    if (portalElement = "") {
        portalElement := "Fire"
    }
    
    VisiblePortals := 0
    MaxVisiblePortals := 20 
    PortalYOffset := 0  
    PortalInvetoryCords := [
        {x: 316, y: 269}, 
        {x: 391, y: 272},
        {x: 461, y: 271},
        {x: 533, y: 271},
        {x: 607, y: 273},
    ]    ; Portal filtering logic based on map, tier, element, and blacklist filters
    if (portalElement = "I Do Not Care") {
        LogMessage("Searching for " . portalMap . " Tier " . portalTier . " portal (any element)", "info")
    } else {
        LogMessage("Searching for " . portalMap . " Tier " . portalTier . " " . portalElement . " portal", "info")
    }
    Sleep(1000)
    if (!FirstTry) {
       
        MouseGetPos(&centerX, &centerY)
        radius := 50 
        
  
        Loop 20 {
            angle := A_Index * 18 
            newX := centerX + radius * Cos(angle * 0.017453) 
            newY := centerY + radius * Sin(angle * 0.017453)
            MouseMove(newX, newY, 2) 
            Sleep(25)  
        }
        
        ; Return to center
        MouseMove(centerX, centerY, 2)
    }

    BetterClick(374, 202)  
    Sleep(500)
    for i, char in StrSplit(portalMap) {
        SendInput(char)
        Sleep(50) 
    }
    ; clicks on the search bar 
    ; BetterClick(374, 202)  ; Click on the search bar
    ; Sleep(500)
    ; ; Type the map name character by character with delays
    ; for i, char in StrSplit(portalMap) {
    ;     SendInput(char)
    ;     Sleep(50)  ; 50ms delay between characters
    ; }

    Sleep(500)
  
    while true {
        for portal in PortalInvetoryCords {            ; Click on the portal in inventory
            BetterClick(portal.x, portal.y + PortalYOffset)
            Sleep(200)
            
            ; Anti-Sell Mode Check - detect if sell mode button appears
            SellModePattern := "|<>*121$72.000000000000103w70001k00Ds7yDU0Tzs00QQ4G8U0E2800MDwG8vjE1TrslDwHszzyDzzzkw4Hs4NyC88DsA4Hs6FyS88Dy04Hsm3yS08zv0CHwX3yT0QzsA6Fw77yTMAzwS6NwDbzTQBzzzzzzzDzzzzzzzzzzzDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
            if (FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, SellModePattern)) {
                BetterClick(333, 546)  ; Click to dismiss sell mode
                Sleep(300)
                
                ; Force scroll to continue checking
                BetterClick(649, 297)  ; Click on the scroll bar
                SendInput("{WheelDown 2}")
                Sleep(300)
                  ; Reset counters and continue
                PortalYOffset := 0
                VisiblePortals := 0
                continue  ; Skip to next portal iteration
            }
            
            ; Increment visible portals counter for each portal slot checked
            VisiblePortals += 1
              switch portalMap {
                case "Summer Laguna":
                    ; Only check for Summer Laguna portals
                    if FindText(&X, &Y, 725, 316, 822, 334, 0, 0, SummerValue) {
                        foundElement := false
                        switch portalElement {
                            case "Fire":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Fire)) {
                                    LogMessage("Found Fire element", "info")
                                    foundElement := true
                                }
                            case "Water":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Water)) {
                                    LogMessage("Found Water element", "info")
                                    foundElement := true
                                }                            case "Dark":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Dark)) {
                                    foundElement := true
                                }
                            case "Nature":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Nature)) {
                                    foundElement := true
                                }
                            case "Light":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Light)) {
                                    foundElement := true
                                }
                            case "I Do Not Care":
                                foundElement := true
                            default:
                                foundElement := true
                        }                        ; If element doesn't match, continue to next portal
                        if (!foundElement) {
                            continue
                        }
                        
                        Sleep(300)  ; Wait for portal details to load
                        
                        ; Clear the blacklist file first, then populate it with current UI selections
                        blacklistedModifiers := []
                        blacklistFile := A_ScriptDir . "\libs\settings\PortalBlacklist.txt"
                          ; Clear the file first
                        try {
                            FileOpen(blacklistFile, "w", "UTF-8").Write("")
                        } catch as err {
                            LogMessage("Error clearing blacklist file: " . err.Message, "warning")
                        }
                        
                        ; Get current selections from UI and write them to the file
                        try {
                            global BlacklistDisplayText, PortalBlacklist
                            currentSelections := []
                            
                            ; Check each display item for checkmarks
                            for i, displayText in BlacklistDisplayText {
                                if (SubStr(displayText, 1, 1) = "✓") {
                                    ; Extract the item name (remove checkmark and spaces)
                                    itemName := Trim(StrReplace(displayText, "✓", ""))
                                    if (itemName != "None") {  ; Don't add "None" to blacklist
                                        currentSelections.Push(itemName)
                                    }
                                }
                            }
                            
                            ; Write selected blacklist items to file
                            if (currentSelections.Length > 0) {
                                content := ""
                                for i, item in currentSelections {
                                    content .= item . (i < currentSelections.Length ? "`n" : "")
                                }                                content := RTrim(content, "`n")
                                FileOpen(blacklistFile, "w", "UTF-8").Write(content)
                                blacklistedModifiers := currentSelections
                            } else {
                                ; No blacklisted modifiers selected
                            }
                        } catch as err {
                            LogMessage("Error processing UI blacklist selections: " . err.Message, "warning")
                        }                        
                        if (blacklistedModifiers.Length > 0) {
                            ; Modifiers are blacklisted - will check for allowed ones
                        } else {
                            ; No blacklisted modifiers - all portals allowed
                        }
                        
                        ; Define all modifier patterns with their FindText patterns
                        modifierPatterns := Map()
                        modifierPatterns["Barebones"] := BarebonesPattern
                        modifierPatterns["Flight"] := FlightPattern  
                        modifierPatterns["High Cost"] := HighCostPattern
                        modifierPatterns["No Hit"] := NoHitPattern
                        modifierPatterns["Tower Limit"] := TowerLimitPattern
                        modifierPatterns["Short Range"] := ShortRangePattern
                        modifierPatterns["Speedy"] := SpeedyPattern
                        modifierPatterns["Immunity"] := ImmunityPattern
                        
                        ; Check if this portal has any allowed modifiers (much faster than checking blacklisted ones)
                        hasAllowedModifier := false
                        foundModifier := ""
                        
                        ; Only check for modifiers if there are blacklisted ones, otherwise accept all
                        if (blacklistedModifiers.Length > 0) {
                            ; Create list of allowed modifiers (non-blacklisted)
                            allowedModifiers := []
                            for modifierName, pattern in modifierPatterns {
                                isBlacklisted := false
                                for blacklisted in blacklistedModifiers {
                                    if (modifierName = blacklisted) {
                                        isBlacklisted := true
                                        break
                                    }
                                }
                                if (!isBlacklisted) {
                                    allowedModifiers.Push(modifierName)
                                }                            }
                            
                            ; Search for allowed modifiers - if we find one, accept the portal
                            for allowedModifier in allowedModifiers {
                                pattern := modifierPatterns[allowedModifier]
                                if (FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, pattern)) {
                                    hasAllowedModifier := true
                                    foundModifier := allowedModifier
                                    break
                                }
                                Sleep(25)  ; Small delay between scans
                            }
                            
                            ; If no whitelisted modifier found, reject the portal
                            if (!hasAllowedModifier) {
                                hasAllowedModifier := false
                                foundModifier := "No Whitelisted Modifiers"
                            }
                        } else {
                            hasAllowedModifier := true
                            foundModifier := "All Allowed"
                        }                        
                        ; If portal doesn't have allowed modifiers, skip it
                        if (!hasAllowedModifier) {
                            continue
                        }
                        
                        LogMessage("Portal found with " . foundModifier . " - entering game", "success")                        ; Now check tier
                        switch portalTier {
                            case "1":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Tier1)) {
                                    MouseGetPos(&MouseX, &MouseY)
                                    BetterClick(MouseX, MouseY)  
                                    Sleep(500)  ; Wait for the click to register
                                    BetterClick(755, 538)  ; Clicks spawn portal
                                    Sleep(1000)  ; Wait for the click to register
                                    if FirstTry {
                                        BetterClick(83, 469) 
                                    } else {
                                        BetterClick(442, 376) 
                                    }
                                     ; Clicks Start Now
                                    MainTerminal()
                                                     
                                    return true
                                }
                            case "2":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Tier2)) {
                                    MouseGetPos(&MouseX, &MouseY)
                                    BetterClick(MouseX, MouseY)  
                                    Sleep(500)  ; Wait for the click to register
                                    BetterClick(755, 538)  ; Clicks spawn portal
                                    Sleep(1000)  ; Wait for the click to register
                                     if FirstTry {
                                        BetterClick(83, 469) 
                                    } else {
                                        BetterClick(442, 376) 
                                    }
                                    MainTerminal()
                                    break
                                }                 
                           case "3":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Tier3)) {
                                    MouseGetPos(&MouseX, &MouseY)
                                    BetterClick(MouseX, MouseY)  
                                    Sleep(500)  ; Wait for the click to register
                                    BetterClick(755, 538)  ; Clicks spawn portal
                                    Sleep(1000)  ; Wait for the click to register
                                     if FirstTry {
                                        BetterClick(83, 469) 
                                    } else {
                                        BetterClick(442, 376) 
                                    }
                                    MainTerminal()
                                    break
                                }
                            case "4":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Tier4)) {
                                    MouseGetPos(&MouseX, &MouseY)
                                    BetterClick(MouseX, MouseY)  
                                    Sleep(500)  ; Wait for the click to register
                                    BetterClick(755, 538)  ; Clicks spawn portal
                                    Sleep(1000)  ; Wait for the click to register
                                     if FirstTry {
                                        BetterClick(83, 469) 
                                    } else {
                                        BetterClick(442, 376) 
                                    }
                                    MainTerminal()
                                    break
                                }
                            case "5":
                                if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Tier5)) {
                                    MouseGetPos(&MouseX, &MouseY)
                                    BetterClick(MouseX, MouseY)  
                                    Sleep(500)  ; Wait for the click to register
                                    BetterClick(755, 538)  ; Clicks spawn portal
                                    Sleep(1000)  ; Wait for the click to register
                                    if FirstTry {
                                        BetterClick(83, 469) 
                                    } else {
                                        BetterClick(442, 376) 
                                    }
                                    MainTerminal()
                                    break
                                }                            case "6":
                                ; Tier 6 implementation needed
                            case "7":
                                ; Tier 7 implementation needed
                            default:
                                LogMessage("Unknown portal tier: " . portalTier, "error")
                                return false
                        }
                    } ; Close the Summer Laguna if statement
                default:
                    LogMessage("Unsupported portal map: " . portalMap, "error")
                    return false
            }LogMessage("Checking if portal is " . portalMap . " tier " . portalTier, "info")
              ; You could add a sleep here to check visual confirmation, or use OCR to read portal info
            Sleep(500)
            
            ; Check if we need to scroll after processing this portal
            if (VisiblePortals >= MaxVisiblePortals) {
                LogMessage("Reached maximum visible portals, scrolling down", "info")
                ; Add logic to scroll down
                ; For example:
                BetterClick(649, 297)  ; Click on the scroll bar
                SendInput("{WheelDown 2}")

                Sleep(300)
                  ; Reset the Y offset after scrolling to start checking from the top row again
                PortalYOffset := 0
                VisiblePortals := 0  ; Also reset the visible portal count
            }
        }
        PortalYOffset += 70  ; Move down for the next row of portals
    }
}




SelectRewardPortals() {
    global X1, Y1, X2, Y2
    Fire := "|<>*35$24.0000TzzzTzzzTzzzTzzzTzvzTztzTzszTzkzTlkTTlUTTl0TTU0TTU0zTUMzTktzTk3zQs7bQST7Q1k7S00TTw7zTzzzTzzz0000U"
    Water := "|<>*29$25.0000DzzzbzzznUzztVrvwlVwyMUSDC03DbN0TnYE3tl3lwwQESS607D003bw01nr86Nzw7Aza1aTs1rDy3nbzknnzy3tzzzwzzzyU"
    Dark := "|<>*23$24.0000TzzzTzzzTzzzTzzzTzzjTzYDTu0DTk0DTk0zTE3zT02TT00TT00TT00TT00zT00zTW1zTlnzTsbzTyDzTzzzTzzzTzzz0000U"
    Nature := "|<>*36$24.TzzzTzzzTzzzTszzTwDzTw7zTw7zTw3zTw3zTw3zTs1bTw37Tw27MwE7Q0s7Q0k7Q0E7S007T0kDTUwTTvzzTzzzTzzz0000U"
    Light := "|<>*82$23.0001zzzzzzzzzzzzs3zyD1zwA3zs1Xzc3XzMD7ykCDx0ATs8Mzls1zXw1zXsDzU0TzU0zzUCzzzTzzzzzzzzzzzzk"

    ; Three portal positions for reward selection
    ThreePortals := [
        {x: 289, y: 333},
        {x: 499, y: 343},
        {x: 706, y: 350}
    ]

    LogMessage("Selecting reward portal from 3 options...", "info")
    
    ; Get the current blacklist to avoid selecting blacklisted portals
    blacklistedModifiers := []
    blacklistFile := A_ScriptDir . "\libs\settings\PortalBlacklist.txt"
    if (FileExist(blacklistFile)) {
        try {
            fileContent := Trim(FileRead(blacklistFile))
            if (fileContent != "" && fileContent != "None") {
                blacklistedModifiers := StrSplit(fileContent, "`n")
                ; Clean up items
                cleanItems := []
                for item in blacklistedModifiers {
                    cleanItem := Trim(item)
                    if (cleanItem != "") {
                        cleanItems.Push(cleanItem)
                    }
                }
                blacklistedModifiers := cleanItems
            }
        } catch {
            LogMessage("Error reading blacklist for reward selection", "warning")
        }
    }

    ; Define modifier patterns (same as in HandlePortalMap)
    modifierPatterns := Map()
    modifierPatterns["Barebones"] := "|<>*117$56.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzvzzzzz0zzwzzzzzkDzzDzzzzwW08EMEMMz80444046Tn331AAA1Xw24tEMH9OTVli6DCq6Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"
    modifierPatterns["Flight"] := "|<>*117$29.zzzzzzzzzzzzzzzzzzzzvTvzU4zbn1DzDa2H2244Y46Nt9dYnsMH8rmsqtzzdzzzz7zzzzzzzzzzzs"
    modifierPatterns["High Cost"] := "|<>*115$52.zzzzzzzzzzvzTzzzzyQDtzkzzbtnzby3zyTW323nwAEy0887DUHbtkaaQyN6Tb32NsAB8zRiBjktlnzzozzzzzzzz7zzzzzs"
    modifierPatterns["No Hit"] := "|<>*118$34.zzzzzzzzzzzzzzzzzzzzzrz6TwsNwNznbbkYD44D80Q0NwUNnVbn4DCqDiNyvQzzzzzzzzzzzzzzzzzs"
    modifierPatterns["Tower Limit"] := "|<>*121$65.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzxzw1zzzznnznDzDzzzzbzzyTyMGG4DD818TwUE98ySE2NzvAUEHwwYYnzr31nrxxdBXzjDPVjsPPPbzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    modifierPatterns["Short Range"] := "|<>*120$64.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzzzzzzzzzkbzzbUzzzzyOTzyS1zzzzssA8EtY0AADkUU3bU00UYzuMMSS2MMO3sBYBstYBYAzlqtrnrMqskzzzzzzzzznzzzzzzzzzwTzzzzzzzzzzzzzzzzzzzzzzU"
    modifierPatterns["Speedy"] := "|<>*116$43.zzzzzzzzzzzzzzzzzzzzzzzzzzyzzsTzzzDzsjzzzbzwQ6660nz22221/zwB11AVzUUmmkMzsssMQQzzxzzzyTzyzzzzTzzzzzzzzzzzzzzw"
    modifierPatterns["Immunity"] := "|<>*116$48.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzzDzzzztbzDzzzzzbz8109U90n8109U9aL9999VVa7999A1VX7hhhiBhnDzzzzzzzDzzzzzzzTzzzzzzzzU"

    ; Try to select the first portal without blacklisted modifiers
    for portal in ThreePortals {
        LogMessage("Checking reward portal at position " . portal.x . ", " . portal.y, "debug")
        
        ; Click on the portal to see its details
        BetterClick(portal.x, portal.y)
        Sleep(800)  ; Wait for portal details to load
        
        ; Check if this reward portal has any allowed modifiers (optimized approach)
        hasAllowedModifier := false
        foundModifier := ""
          if (blacklistedModifiers.Length > 0) {
            ; Create list of allowed modifiers (non-blacklisted)
            allowedModifiers := []
            for modifierName, pattern in modifierPatterns {
                isBlacklisted := false
                for blacklisted in blacklistedModifiers {
                    if (modifierName = blacklisted) {
                        isBlacklisted := true
                        break
                    }
                }
                if (!isBlacklisted) {
                    allowedModifiers.Push(modifierName)
                }
            }
            
            ; Search for any allowed modifier - if we find one, accept the portal
            for allowedModifier in allowedModifiers {
                pattern := modifierPatterns[allowedModifier]
                if (FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, pattern)) {
                    LogMessage("Reward portal has allowed modifier '" . allowedModifier . "'", "success")
                    hasAllowedModifier := true
                    foundModifier := allowedModifier
                    break
                }
            }
            
            ; If no allowed modifier found, check if it has blacklisted ones or is clean
            if (!hasAllowedModifier) {
                hasBlacklistedModifier := false
                for blacklisted in blacklistedModifiers {
                    if (modifierPatterns.Has(blacklisted)) {
                        pattern := modifierPatterns[blacklisted]
                        if (FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, pattern)) {
                            LogMessage("Reward portal has blacklisted modifier '" . blacklisted . "' - skipping", "warning")
                            hasBlacklistedModifier := true
                            break
                        }
                    }
                }
                ; If no blacklisted modifier found, it's a clean portal - accept it
                if (!hasBlacklistedModifier) {
                    hasAllowedModifier := true
                    foundModifier := "Clean Portal"
                    LogMessage("Reward portal is clean (no modifiers) - accepting", "success")
                }
            }
        } else {
            hasAllowedModifier := true
            foundModifier := "All Allowed"
            LogMessage("No blacklist configured - accepting reward portal", "info")
        }        ; If this portal has allowed modifiers, select it
        if (hasAllowedModifier) {
            LogMessage("Selected reward portal at position " . portal.x . ", " . portal.y . " (modifier: " . foundModifier . ")", "info")
            BetterClick(portal.x, portal.y)  ; Click again to confirm selection
            BetterClick(500, 487)  ; Clicks Confirm portal
            
            ; Start searching for portals in-game
            BetterClick(484, 464)  ; Clicks on the portal map
            SearchForPortal()
            return true
        }
    }
    
    ; If all portals have blacklisted modifiers, select a random one
    LogMessage("All reward portals have blacklisted modifiers, selecting random portal", "warning")
    randomIndex := Random(1, ThreePortals.Length)
    selectedPortal := ThreePortals[randomIndex]
    LogMessage("Randomly selected portal " . randomIndex . " at position " . selectedPortal.x . ", " . selectedPortal.y, "info")
    BetterClick(selectedPortal.x, selectedPortal.y)
    BetterClick(500, 487)  ; Clicks Confirm portal
            
            ; Start searching for portals in-game
            BetterClick(484, 464)  ; Clicks on the portal map

    
    ; Start searching for portals in-game
    SearchForPortal()
    return true
}

; Handle DropDownList change events to toggle checkmarks
OnBlacklistDropDownChange(ctrl, *) {
    global BlacklistDropDown, BlacklistDisplayText, PortalBlacklist, SelectedBlacklist
    
    EnsureSelectedBlacklistValid()
    
    selectedIndex := BlacklistDropDown.Value
    selectedDisplayText := BlacklistDisplayText[selectedIndex]
    selectedItem := Trim(StrReplace(StrReplace(selectedDisplayText, "✓ ", ""), "  ", ""))
    selectionChanged := false
      ; If "None" is selected, clear all other selections
    if (selectedItem = "None") {
        ; Clear all selections and select only "None"
        for i, item in PortalBlacklist {
            if (item = "None") {
                BlacklistDisplayText[i] := "✓ " . item
            } else {
                BlacklistDisplayText[i] := "  " . item
            }
        }
        SelectedBlacklist := ["None"]
        selectionChanged := true
    } else {        ; Toggle the selected item
        isCurrentlyChecked := SubStr(BlacklistDisplayText[selectedIndex], 1, 1) = "✓"
        LogMessage("Toggle logic - Item: '" . selectedItem . "', Currently checked: " . isCurrentlyChecked, "debug")
          if (isCurrentlyChecked) {
            ; Item is checked, uncheck it
            LogMessage("Unchecking item: '" . selectedItem . "'", "debug")
            BlacklistDisplayText[selectedIndex] := "  " . selectedItem
            
            ; Ensure SelectedBlacklist is an array
            if (!IsObject(SelectedBlacklist) || !SelectedBlacklist.HasMethod("Length")) {
                SelectedBlacklist := ["None"]
            }
              ; Remove from SelectedBlacklist
            for i, item in SelectedBlacklist {
                if (item = selectedItem) {
                    SelectedBlacklist.RemoveAt(i)
                    selectionChanged := true
                    LogMessage("Removed '" . selectedItem . "' from SelectedBlacklist, selectionChanged = true", "debug")
                    break
                }
            }        } else {
            BlacklistDisplayText[selectedIndex] := "✓ " . selectedItem
            
            if (!IsObject(SelectedBlacklist) || !SelectedBlacklist.HasMethod("Length")) {
                SelectedBlacklist := ["None"]
            }
            
            for i, item in SelectedBlacklist {
                if (item = "None") {
                    SelectedBlacklist.RemoveAt(i)
                    break
                }
            }
            
            for i, item in PortalBlacklist {
                if (item = "None") {
                    BlacklistDisplayText[i] := "  " . item
                    break
                }
            }
            
            SelectedBlacklist.Push(selectedItem)
            selectionChanged := true
        }
        
        if (SelectedBlacklist.Length = 0) {
            for i, item in PortalBlacklist {
                if (item = "None") {
                    BlacklistDisplayText[i] := "✓ " . item
                    SelectedBlacklist := ["None"]
                    selectionChanged := true
                    break
                }
            }
        }
    }    BlacklistDropDown.Delete()
    for text in BlacklistDisplayText {
        BlacklistDropDown.Add([text])
    }
    BlacklistDropDown.Choose(selectedIndex)
    
    if (selectionChanged) {
        PortalBlacklistSaveSettings()
    }
}

; Global variable to track last known UI state
global LastUIState := ""

ForceCheckUIState() {
    global BlacklistDisplayText, LastUIState
    
    if (!BlacklistDisplayText || BlacklistDisplayText.Length = 0) {
        return
    }
    
    currentUIState := ""
    for i, displayText in BlacklistDisplayText {
        currentUIState .= displayText . "|"
    }
    
    if (currentUIState != LastUIState) {
        LastUIState := currentUIState
        PortalBlacklistSaveSettings()
    }
}

OnBlacklistDropDownFocus(ctrl, *) {
    SetTimer(() => OnBlacklistDropDownChange(ctrl), -100)
}

EnsureSelectedBlacklistValid() {
    global SelectedBlacklist
    ; Simplified validation - just check if it's an object with a Length property
    if (!IsObject(SelectedBlacklist) || !SelectedBlacklist.HasProp("Length")) {
        SelectedBlacklist := ["None"]
        return false  ; Indicates it was reset
    }
    return true  ; Indicates it was already valid
}

SearchForPortal() {
    LogMessage("Starting search for next portal in inventory...", "info")
    
    ; Wait a moment for the game to load after portal confirmation
    Sleep(2000)
    
    ; Click the specified coordinates for in-game portal searching
    BetterClick(484, 464)
    LogMessage("Clicked portal search button at (534, 547)", "info")
    
    ; Get current portal settings
    portalTierFile := A_ScriptDir . "\libs\settings\PortalTier.txt"
    selectedTier := "1" ; Default tier
    if (FileExist(portalTierFile)) {
        _pt := Trim(FileRead(portalTierFile))
        if (_pt != "") 
            selectedTier := _pt
    }
    
    ; Get portal element setting
    portalElementFile := A_ScriptDir . "\libs\settings\PortalElement.txt"
    selectedElement := "Fire" ; Default element
    if (FileExist(portalElementFile)) {
        _pe := Trim(FileRead(portalElementFile))
        if (_pe != "") 
            selectedElement := _pe
    }

    LogMessage("Searching for next Summer Laguna portal - Tier: " . selectedTier . ", Element: " . selectedElement, "info")
    
    ; Use the existing HandlePortalMap function - it already does everything we need
    ; Just get blacklist status first
    global SelectedBlacklist
    PortalBlacklistLoadSettings()
    
    hasNone := false
    for item in SelectedBlacklist {
        if (item = "None") {
            hasNone := true
            break
        }
    }
    
    ; Call HandlePortalMap to find and spawn the next portal
    result := HandlePortalMap("Summer Laguna", selectedTier, selectedElement, hasNone, FirstTry := false)
    
    if (result) {
        ; Run MainTerminal again to continue the cycle
        LogMessage("Next portal found and spawned, running MainTerminal again...", "info")
        MainTerminal()
    } else {
        LogMessage("No suitable portal found in inventory", "warning")
    }      return result
}


