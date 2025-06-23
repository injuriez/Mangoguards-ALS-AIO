#include tech.ahk
#include ..\webhook.ahk
#Include .\movement\EnableClickToMove.ahk
#Include ..\mangos\essence.ahk
#Include ..\mangos\raids.ahk
#Include ..\mangos\dungeon.ahk
#Include ..\mangos\Portals.ahk
#Include ..\mangos\story.ahk
global configFile := A_ScriptDir . "\libs\UIPARTS\vanguards_config.txt"
global unitSlots := Map()
global robloxX1 := 0, robloxY1 := 0, robloxX2 := 0, robloxY2 := 0
global robloxWidth := 0, robloxHeight := 0
global SkipStartButton := "false"

; Initialize Roblox window coordinates on script start
InitializeRobloxWindow()
; Helper function to create a range for loops
range(start, end) {
    arr := []
    Loop end - start + 1 {
        arr.Push(start + A_Index - 1)
    }
    return arr
}

; New click function for unit placement
ClickV4(x, y, delay := 100) {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    Sleep(delay)
    wiggle()
    Click()
}

; Simple click function for upgrades without wiggle
SimpleClick(x, y, delay := 100) {
    MouseMove(x, y)
    Sleep(delay)
    Click()
}

wiggle() {
    MouseMove(1, 1, 5, "R")
    Sleep(30)
    MouseMove(-1, -1, 5, "R")
}



; Function to initialize Roblox window coordinates on script start
InitializeRobloxWindow() {
    if (!GetRobloxWindow()) {
        LogMessage("Warning: Roblox window not found during initialization. Using screen dimensions as fallback.")
    } else {
        LogMessage("Roblox window detected: Position (" . robloxX1 . ", " . robloxY1 . ") Size: " . robloxWidth . "x" . robloxHeight)
    }
}

; Function to get Roblox window coordinates
GetRobloxWindow() {
    global robloxX1, robloxY1, robloxX2, robloxY2, robloxWidth, robloxHeight
    
    ; Try to find Roblox window by different possible titles
    robloxWindows := ["Roblox", "RobloxPlayerBeta", "ahk_exe RobloxPlayerBeta.exe", "ahk_class WINDOWSCLIENT"]
    
    for windowTitle in robloxWindows {
        if (WinExist(windowTitle)) {
            WinGetPos(&winX, &winY, &winWidth, &winHeight, windowTitle)
            robloxX1 := winX
            robloxY1 := winY
            robloxX2 := winX + winWidth
            robloxY2 := winY + winHeight
            robloxWidth := winWidth
            robloxHeight := winHeight
            return true
        }
    }
    
    ; If no Roblox window found, use screen dimensions as fallback
    robloxX1 := 0
    robloxY1 := 0
    robloxX2 := A_ScreenWidth
    robloxY2 := A_ScreenHeight
    robloxWidth := A_ScreenWidth
    robloxHeight := A_ScreenHeight
    return false
}


LoadInUnits() {
    global unitSlots, configFile
    LogMessage("Loading unit configuration...")

    unitSlots.Clear()

    if (!FileExist(configFile)) {
        MsgBox("Config file not found: " . configFile)
        return false
    }
    
    try {
        fileContent := FileRead(configFile)
        lines := StrSplit(fileContent, "`n")

        for line in lines {
            line := Trim(line)
            if (line == "" || SubStr(line, 1, 2) == "//")
                continue

            parts := StrSplit(line, ":")
            if (parts.Length < 7)
                continue

            slotName := parts[1]
            placement := Integer(parts[2])  ; Use Integer() for better error handling
            slotNumber := Integer(parts[3])  ; Use Integer() for better error handling
            unitName := parts[4]  ; Add unit name
            priority := Integer(parts[5])  ; Use Integer() for better error handling
            autoSkill := parts[6]  ; Add auto skill field (was upgrade)

            coordsData := ""
            for i, p in parts {
                if (i >= 7) {
                    if (i > 7)
                        coordsData .= ":"
                    coordsData .= p
                }
            }            coordinates := []
            coordParts := StrSplit(coordsData, "|")

            if (coordParts.Length >= 2) {
                ; Handle the case where coordinates and upgrade data are mixed with semicolons
                ; Format: 358,253|1:1;412,257|1:1;461,257|1:1;0,0|1:1;0,0|1:1|0
                
                if InStr(coordsData, ";") {
                    ; Split by semicolons to get each coordinate+upgrade pair
                    coordUpgradePairs := StrSplit(coordsData, ";")
                    
                    for i, pair in coordUpgradePairs {
                        pair := Trim(pair)
                        if (pair == "" || pair == "0" || pair == "0|0")
                            continue
                            
                        ; Split each pair by pipe to separate coordinate from upgrade
                        pairParts := StrSplit(pair, "|")
                        if (pairParts.Length >= 2) {
                            coordStr := Trim(pairParts[1])
                            upgradeData := Trim(pairParts[2])
                            
                            ; Skip if coordinate is 0,0
                            if (coordStr == "0,0" || coordStr == "0")
                                continue
                                
                            if InStr(coordStr, ",") {
                                coords := StrSplit(coordStr, ",")
                                if coords.Length >= 2 {
                                    try {
                                        coordX := Integer(Trim(coords[1]))
                                        coordY := Integer(Trim(coords[2]))
                                        
                                        ; Skip if coordinates are 0,0
                                        if (coordX == 0 && coordY == 0)
                                            continue
                                        
                                        ; Parse upgrade data
                                        upgradeLevel := upgradeData
                                        upgradePriority := "1"
                                        
                                        if InStr(upgradeData, ":") {
                                            upParts := StrSplit(upgradeData, ":")
                                            upgradeLevel := upParts[1]
                                            upgradePriority := upParts[2]
                                        }
                                        
                                        coordUpgrade := (upgradeLevel ~= "i)^max$") ? "max" : Integer(upgradeLevel)
                                        coordPrio := Integer(upgradePriority)
                                        coordinates.Push({x: coordX, y: coordY, upgrade: coordUpgrade, upgradePriority: coordPrio})
                                        
                                        LogMessage("Parsed coordinate: " . coordX . "," . coordY . " with upgrade " . coordUpgrade . " for " . slotName)
                                    } catch Error as e {
                                        LogMessage("Warning: Could not parse coordinate pair '" . pair . "' for " . slotName . ": " . e.Message)
                                        continue
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ; Handle single coordinate case: coordinate|upgrade
                    coordStr := Trim(coordParts[1])
                    upgradeData := Trim(coordParts[2])
                    
                    if (coordStr != "0,0" && coordStr != "0" && InStr(coordStr, ",")) {
                        coords := StrSplit(coordStr, ",")
                        if coords.Length >= 2 {
                            try {
                                coordX := Integer(Trim(coords[1]))
                                coordY := Integer(Trim(coords[2]))
                                
                                if (coordX != 0 || coordY != 0) {
                                    ; Parse upgrade data
                                    upgradeLevel := upgradeData
                                    upgradePriority := "1"
                                    
                                    if InStr(upgradeData, ":") {
                                        upParts := StrSplit(upgradeData, ":")
                                        upgradeLevel := upParts[1]
                                        upgradePriority := upParts[2]
                                    }
                                    
                                    coordUpgrade := (upgradeLevel ~= "i)^max$") ? "max" : Integer(upgradeLevel)
                                    coordPrio := Integer(upgradePriority)
                                    coordinates.Push({x: coordX, y: coordY, upgrade: coordUpgrade, upgradePriority: coordPrio})
                                }
                            } catch Error as e {
                                LogMessage("Warning: Could not parse single coordinate '" . coordStr . "' for " . slotName . ": " . e.Message)
                            }
                        }
                    }
                }
            }

            unitSlots[slotName] := {
                placement: placement,
                slotNumber: slotNumber,
                unitName: unitName,
                priority: priority,
                autoSkill: autoSkill,  ; Add auto skill to the slot data
                coordinates: coordinates
            }
            
            ; Debug log to show loaded auto skill
            LogMessage("Loaded slot " . slotName . " with auto skill: " . autoSkill)
        }

        LogMessage("Loaded " . unitSlots.Count . " unit slots")
        return true
    } catch Error as e {
        MsgBox("Error loading config file: " . e.Message)
        return false
    }
}


; Function to sort slots by priority (lower numbers = higher priority)
CompareSlotsByPriority(slotA, slotB, *) {
    ; slotA and slotB are the elements from slotArray,
    ; i.e., objects like {name: "SLOT1", data: {priority: P, ...}}
    pA := slotA.data.priority
    pB := slotB.data.priority

    if (pA < pB)
        return -1  ; slotA comes first
    if (pA > pB)
        return 1   ; slotB comes first
    return 0       ; order doesn't matter or preserve original
}

; Upgrade function with FindText verification - verifies upgrade level visually before moving to next unit
UpgradeUnit(x, y, upgradeLevel, delay := 100, unitslot := "") {
    global X1 := 120 
    global Y1 := 200
    global X2 := 270
    global Y2 := 800
   
    
    if (upgradeLevel == "0" || upgradeLevel == 0)
        return true  ; No upgrade needed
    
    LogMessage("Upgrading " . unitslot . " at (" . x . ", " . y . ") to level " . upgradeLevel)
    
    ; Click on the unit to select it first
    ClickV4(x, y, 50)
    Sleep(800)
    
    if (upgradeLevel == "max" || upgradeLevel == "MAX") {
        ; Upgrade to maximum level - check for MaxUnit pattern
        LogMessage("Starting continuous upgrades for max level on " . unitslot)
        
        loop {
            ; Check game status before each upgrade attempt
            gameResult := GameStatus()
            if (gameResult == "won" || gameResult == "lost") {
                LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
                Sleep(3000)
                MainTerminal()
                return
            }
            
            ; Check if MaxUnit pattern is found
            if (FindText(&foundX, &foundY, X1, Y1, X2, Y2, 0, 0, MaxUnit)) {
                LogMessage("Max upgrade level detected for " . unitslot . " - upgrade complete")
                return true
            }
            
            ; Click on the unit to ensure it's selected
            ClickV4(x, y, 50)
            Sleep(500)
            
            ; Press upgrade key
            SendInput("t")
            Sleep(delay)
            
            LogMessage("Upgrading " . unitslot . " (max level)")
        }
    } else {
        ; Upgrade to specific level - use FindText to verify target level
        upgradeCount := Integer(upgradeLevel)
        if (upgradeCount > 0 && upgradeCount <= 13) {
            LogMessage("Starting continuous upgrades to level " . upgradeCount . " for " . unitslot)            ; Get the appropriate FindText pattern for target level
            targetPattern := GetUpgradePattern(upgradeCount)
            if (targetPattern == "") {
                LogMessage("ERROR: No FindText pattern available for level " . upgradeCount . " - skipping unit " . unitslot)
                return false
            }            LogMessage("DEBUG: Using upgrade pattern for level " . upgradeCount . ": " . StrLen(targetPattern) . " characters")
            
            loop {
                ; Check game status before each upgrade attempt
                gameResult := GameStatus()
                if (gameResult == "won" || gameResult == "lost") {
                    LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
                    Sleep(3000)
                    MainTerminal()
                    return
                }
                
                ; Check if target upgrade level is found
                LogMessage("DEBUG: Checking for upgrade level " . upgradeCount . " pattern for " . unitslot)
                if (FindText(&foundX, &foundY, X1, Y1, X2, Y2, 0, 0, targetPattern)) {
                    LogMessage("Target upgrade level " . upgradeCount . " detected for " . unitslot . " at (" . foundX . ", " . foundY . ") - upgrade complete")
                    return true
                }
                
                ; Click on the unit to ensure it's selected
                BetterClick(x, y)
                Sleep(500)
                
                ; Press upgrade key
                SendInput("t")
                Sleep(delay)
                
                LogMessage("Upgrading " . unitslot . " - attempting to reach level " . upgradeCount . " (current attempt)")
            }
        }
        return true
    }
}

; Helper function to get the appropriate FindText pattern for upgrade level
GetUpgradePattern(level) {
    global Upgrade1, Upgrade2, Upgrade3, Upgrade4, Upgrade5, Upgrade6, Upgrade7
    global Upgrade8, Upgrade9, Upgrade10, Upgrade11, Upgrade12, Upgrade13
    
    switch level {
        case 1: return Upgrade1
        case 2: return Upgrade2
        case 3: return Upgrade3
        case 4: return Upgrade4
        case 5: return Upgrade5
        case 6: return Upgrade6
        case 7: return Upgrade7
        case 8: return Upgrade8
        case 9: return Upgrade9
        case 10: return Upgrade10
        case 11: return Upgrade11
        case 12: return Upgrade12
        case 13: return Upgrade13
        default: return ""
    }
}




GameStatus() {
    won := "|<>*104$44.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzszzzsyDWDzzwD3s3zzzVkQDzzzsQ73zzzy61kX4DzkU8Mk1zw82640Dz081V01zs20sEsTy0UC4C7zUQ7V3Vzw71sEsTz3kS4C7zsyDX7VzyTXslwzzzzzzzzzzzzzzzzzzzzzzy"
    Disconnected := "|<>*125$75.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzbzzzzzzlz7zzsTzzzzzyDkzzz3zyDzzzly7zzsTzlzzzyDkzzz3zyDzzzly7zz8TzUDzzyDkWDU3V81kDzly40w0M00A0zyDkU30204107zly48MsEUlsszy7kXX72C6D07zkyAQMsFkls0zz31V3224C77zzs0Q0Q0k1kM1zzU7U7U70D1U7zz1wPzAyNwS1zzzzXzzzzzzzzzzzwTzzzzzzzzzzzXzzzzzzzzzzzwTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    RetryText := "|<>*124$37.0000000000000000000T00000Ts7U0086GM0043zDzw28l12v14E009UUF9XUkE84nkE9W29gM4t1am83zzzvA0F76FY00000q00000C1"
    Defeat := "|<>*61$75.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzkzzzzzzy0Dzzw3zzzznzk0TzzUzzzzwDy01zzsTzzzzVzksDzz3zzzzwDy7Uw3k3UTl70Dky7040M0s0E1y7kk0U206020Dkz6760ksk0M3y7kkssS7673Vzky6073k0lsQDy7Vk1sS0C73Vzk0C7z3kzk0Q7y03k0sS0703kTk0z073s0s0S3y0Tw1wTUDl7sTzzzzzzzzzzzzzzzzzzzzzzzzzU"
    PortalButtonText := "|<>*122$93.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzjzzk3zzzzzzzzzDtzzw0TzzzzzzzztzDzz7UkEFUw7VU261zzsw000A7UM00EUDzz7U2210sb44D8VzzwwsEEA7Yw0VtYDzzk70EFVw7VUD40ezz6v76CDkwyBwkU7zzzzzzzzzjzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    
    ; check which gamemode this is
    categoryFile := A_ScriptDir . "\libs\settings\Category.txt"
    gameCategory := ""
    if (FileExist(categoryFile)) {
        try {
            gameCategory := FileRead(categoryFile)
            gameCategory := Trim(gameCategory) 
        }
    }
    
    if (FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, won)) {
        LogMessage("Game won!")
        UpdateWLDisplay("win")
      
        try {
            global Wins, Losses, TotalRuns
            SendWebhookWithResult("won", Wins, Losses, TotalRuns)
            LogMessage("Win webhook sent successfully")
        } catch as e {
            LogMessage("Failed to send win webhook: " . e.Message, "error")
        }
          if (gameCategory == "Raids") {
            BetterClick(531, 462)  ; Clicks reset
        } else if (gameCategory == "Dungeon") {
            BetterClick(480, 460)
        } else if (gameCategory == "Essence") {

            BetterClick(480, 460)   ; Clicks reset
        } else if (gameCategory == "Survival") {
            BetterClick(480, 460) 
        } else if (gameCategory == "Legend Stages") {
            BetterClick(531, 462)       
        } else if (gameCategory == "Story") {
            BetterClick(531, 462)
        }
        
        if (FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, RetryText)) {
            LogMessage("Retrying game...")
            BetterClick(X, Y)  ; Clicks retry
        } 
         ; Wait for reset to complete
        Sleep(1000)  ; Wait for reset to complete
        return "won"   
     } else if (FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, Defeat)) {
        LogMessage("Game lost!")
        UpdateWLDisplay("loss")

          ; Send webhook notification for loss
        try {
            global Wins, Losses, TotalRuns
            SendWebhookWithResult("lost", Wins, Losses, TotalRuns)
            LogMessage("Loss webhook sent successfully")
        } catch as e {
            LogMessage("Failed to send loss webhook: " . e.Message, "error")
        }          if (gameCategory == "Raids") {
            BetterClick(482, 460)  ; Clicks reset        } else if (gameCategory == "Dungeon") {
            BetterClick(480, 460)
        } else if (gameCategory == "Essence") {
            BetterClick(480, 460)
        } else if (gameCategory == "Survival") {
            BetterClick(480, 460)
        } else if (gameCategory == "Legend Stages") {
            BetterClick(480, 460)  ; Clicks reset
        } else if (gameCategory == "Portals") {
            BetterClick(484, 464)  ; Clicks on the portal map
            
            ; Read portal settings from files
            selectedTier := "1" ; Default tier
            portalTierFile := A_ScriptDir . "\libs\settings\portals\PortalTier.txt"
            if (FileExist(portalTierFile)) {
                _pt := Trim(FileRead(portalTierFile))
                if (_pt != "") 
                    selectedTier := _pt
            }
            
            ; Get portal element setting
            selectedElement := "Fire" ; Default element
            portalElementFile := A_ScriptDir . "\libs\settings\portals\PortalElement.txt"
            if (FileExist(portalElementFile)) {
                _pe := Trim(FileRead(portalElementFile))
                if (_pe != "") 
                    selectedElement := _pe
            }
            
            ; Call HandlePortalMap with proper parameters (FirstTry = false since this is after a loss)
            HandlePortalMap("Summer Laguna", selectedTier, selectedElement, false, false)
        } else if (gameCategory == "Story") {
            BetterClick(480, 460)  ; Clicks reset
        }
        
        return "lost"
    } else if (gameCategory == "Portals" && FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, PortalButtonText)) {
        LogMessage("Portal reward button found! Selecting reward portals...")
        LogMessage("Game won!")
        UpdateWLDisplay("win")
          ; Send webhook notification for win
        try {
            global Wins, Losses, TotalRuns
            SendWebhookWithResult("won", Wins, Losses, TotalRuns)
            LogMessage("Win webhook sent successfully")
        } catch as e {
            LogMessage("Failed to send win webhook: " . e.Message, "error")
        }
        SelectRewardPortals()
        return "portal_reward"
    } else if (FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, Disconnected)) {
        LogMessage("Game Has Been Disconnected, Retrying...")
            UpdateWLDisplay("disconnect")  ; Add this line to count the disconnect
        BetterClick(790, 162) ; closes the update logs so it doesn't interfere with the mango
        ; load in all the configs again
        Difficulty := FileRead(A_ScriptDir . "\libs\settings\Difficulty.txt")
        MapName := FileRead(A_ScriptDir . "\libs\settings\Map.txt")
        if (gameCategory == "Raids") {
            StartRaidMacro(MapName)
        } else if (gameCategory == "Dungeon") {
            StartDungeonMacro(MapName)
        } else if (gameCategory == "Essence") {
            EssenceStartMacro(MapName, Difficulty)
        } else if (gameCategory == "Story") {
            StartStoryMacro(MapName, "1")
        }

        return "disconnected"
    }
    
    ; Return empty string if game is still in progress
    return ""
}

PlaceDownUnits() {
    ; Get current Roblox window coordinates
    GetRobloxWindow()
    
    VerifyText := "|<>*67$33.zzzzzzzDnzzztyTzzz0UDzzsGYzzz2IbzzsKlzzzzzzzzzzzzzzzzzzzz07zzz007zzk00Tzs000zy0003zk000Tw0001z00007s0000z0Dzk7k1020S080E3k1020S080E3k1020STs0Tnnz03yTTs0Trvz03yzTs0TrtzzzwzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
    
    ; Create array of slots
    slotArray := []
    for slotName, slotData in unitSlots {
        if (slotData.placement == 0)  ; Skip if placement is not set
            continue
        ; Push an object containing the name and the data for sorting
        slotArray.Push({name: slotName, data: slotData})
    }
    
    ; Sort by priority (ascending - lower numbers first) using a custom sorting loop
    if (slotArray.Length > 1) {
        for i, slotA in slotArray {
            for j, slotB in slotArray {
                if (CompareSlotsByPriority(slotA, slotB) < 0) {
                    temp := slotArray[i]
                    slotArray[i] := slotArray[j]
                    slotArray[j] := temp
                }
            }
        }
    }
    
    ; Place units in priority order
    for slotInfo in slotArray { ; slotInfo is now the object {name: ..., data: ...}
        slotData := slotInfo.data ; Extract the original slotData    
    
    
        
        
        ; Check game status before placing each slot
        gameResult := GameStatus()
        if (gameResult == "won") {
            LogMessage("Game won! Stopping unit placement.")
            return true
        }
        
        ; Skip placing if coordinates are empty
        if (slotData.coordinates.Length == 0)
            continue
              
        ; Simulate placing down units at the specified coordinates
        for i, coord in slotData.coordinates {
            x := coord.x
            y := coord.y            ; Check game status before placing each unit


            if (x == 0 && y == 0) {
                LogMessage("Skipping unit placement at (0, 0) for slot " . slotData.slotNumber)
                continue  ; Skip if coordinates are (0, 0)
            }

            gameResult := GameStatus()
            if (gameResult == "won" || gameResult == "lost") {
                LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
                Sleep(3000)
                MainTerminal()
                return
            }
            
            LogMessage("Placing slot " . slotData.slotNumber . " at (" . x . ", " . y . ")")
            
            ; Keep trying until unit is placed and verified
            loop {                ; Check game status during placement attempts
                gameResult := GameStatus()
                if (gameResult == "won" || gameResult == "lost") {
                    LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
                    Sleep(3000)
                    MainTerminal()
                    return
                }
                  ; Place the unit
                SendInput("{" . slotData.slotNumber . "}")  ; Selects the Slot
                ClickV4(x, y, 100)  ; Use ClickV4 for unit placement
                Sleep(900)  ; Wait a bit before checking
                    ; Check if the unit was placed using FindText
                found := FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, VerifyText)
                if (found) {
                    LogMessage("Unit placed and verified!")
                    SendInput("{" . slotData.slotNumber . "}")  ; unequipes the slot
                    
                    ; Check game status after placement
                    gameResult := GameStatus()
                    if (gameResult == "won" || gameResult == "lost") {
                        LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
                        Sleep(3000)
                        MainTerminal()
                        return
                    }
                    
                    break  ; Unit placed successfully, move to next coordinate
                } else {
                    LogMessage("Unit not detected, retrying placement...")
                    Sleep(500)  ; Wait before retry
                }
            }
        }
    }
    return false  ; Placement completed without winning
}

UpgradeUnits() {
    ; Create array of all units with their upgrade priorities
    upgradeArray := []
    
    for slotName, slotData in unitSlots {
        if (slotData.placement == 0 || slotData.coordinates.Length == 0)
            continue  ; Skip if placement is not set or no coordinates
          for coord in slotData.coordinates {
            ; Use coordinate-specific upgrade level and priority if available
            if (coord.x == 0 && coord.y == 0) {
                LogMessage("Skipping upgrade for " . slotName . " - coordinates are 0, 0")
                continue
            }
            
            coordUpgrade := coord.HasOwnProp("upgrade") ? coord.upgrade : slotData.upgrade
            coordUpgradePriority := coord.HasOwnProp("upgradePriority") ? coord.upgradePriority : "1"
            
            ; Only add units that need upgrading (skip upgrade level 0)
            if (coordUpgrade && coordUpgrade != "0" && coordUpgrade != 0 && coordUpgrade != "") {
                upgradeArray.Push({
                    x: coord.x,
                    y: coord.y,
                    upgrade: coordUpgrade,
                    priority: Integer(coordUpgradePriority),
                    slotName: slotName
                })
                LogMessage("Added unit for upgrade: " . slotName . " at (" . coord.x . ", " . coord.y . ") level " . coordUpgrade . " priority " . coordUpgradePriority)
            } else {
                LogMessage("Skipping unit with upgrade level " . coordUpgrade . ": " . slotName . " at (" . coord.x . ", " . coord.y . ")")
            }
        }
    }
      ; Sort by upgrade priority (lower numbers = higher priority)
    if (upgradeArray.Length > 1) {
        ; Simple bubble sort by priority
        for i in range(1, upgradeArray.Length - 1) {
            for j in range(1, upgradeArray.Length - i) {
                if (upgradeArray[j].priority > upgradeArray[j + 1].priority) {
                    ; Swap elements
                    temp := upgradeArray[j]
                    upgradeArray[j] := upgradeArray[j + 1]
                    upgradeArray[j + 1] := temp
                }
            }
        }
    }
    
    ; Upgrade units in priority order
    for unitInfo in upgradeArray {
        LogMessage("Upgrading " . unitInfo.slotName . " at (" . unitInfo.x . ", " . unitInfo.y . ") to level " . unitInfo.upgrade . " (priority " . unitInfo.priority . ")")
          ; Check game status before each upgrade
        gameResult := GameStatus()
        if (gameResult == "won" || gameResult == "lost") {
            LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
            Sleep(3000)
            MainTerminal()
            return
        }
        
        UpgradeUnit(unitInfo.x, unitInfo.y, unitInfo.upgrade, 100, unitInfo.slotName)
          ; Check game status after upgrade
        gameResult := GameStatus()
        if (gameResult == "won" || gameResult == "lost") {
            LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
            Sleep(3000)
            MainTerminal()
            return
        }
    }
    
    return false
}

MainTerminal() {
    global SkipStartButton

    Story := FileRead(A_ScriptDir . "\libs\settings\story\Story.txt")
    ; First Step LETS check if we got disconnected from the game (little safety measure)
    Disconnected := "|<>*103$70.00000000000000000000000000000S00000DUy007w07001z7w00ts0z006Csk033U7Q00MP300AC0Mk01VgDz3kzzVny66kzyz3zy7zyMP3zz0Dzk7ztVg83s0s20Q3q6kU703001U7MP20A080E40RVw8EkUU1Vklq7kXV70C6C07MC2C4Q0sMM0Rk0M0k0U1Vlzn01U30206107C0C0S0A0Q60QS3sbw9sHsw3kzzXyzzzzzzy0zaDVztzntzk00Ms0000000001XU0000000007y0000000000Dk0000000000A00000000000000000002"
    Loaded2 := "|<>*121$34.000000000000000001k0000Dz01s1VY04U46Tzn0Ekzy6DV208Ty6E0nzu9ADDzVW4wTyDAPtzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
    Loaded := "|<>*122$37.00000000000000000007000007zU0w066E0G023DztU133zsMDkV04DzsN03DzxAa7bzy68Hlzz7aBwzzzzzzzzzzzzzzzzzzzzzzzzzz"
    
    ; Refresh Roblox window coordinates
    GetRobloxWindow()    ; Check if we should skip the start button
    if (SkipStartButton == "true") {
        LogMessage("SkipStartButton is true - loading units directly without waiting for start button")
        if (!LoadInUnits()) {
            LogMessage("Failed to load units config - aborting placement")
            return
        }
        
        ; Still check for disconnection while skipping start button
        loop {
            if (FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, Disconnected)) {
                LogMessage("Game Has Been Disconnected, Retrying...")
                UpdateWLDisplay("disconnect")  ; Add this line to count the disconnect

                BetterClick(790, 162) ; closes the update logs so it doesn't interfere with the mango
                ; load in all the configs again
                Difficulty := FileRead(A_ScriptDir . "\libs\settings\Difficulty.txt")
                Maps := FileRead(A_ScriptDir . "\libs\settings\Map.txt")
                
                categoryFile := A_ScriptDir . "\libs\settings\Category.txt"
                
                gameCategory := ""
                if (FileExist(categoryFile)) {
                    try {
                        gameCategory := FileRead(categoryFile)
                        gameCategory := Trim(gameCategory)  ; Remove any whitespace/newlines
                    }
                }
                
                if (gameCategory == "Raids") {
                    StartRaidMacro(Maps)
                } else if (gameCategory == "Dungeon") {
                    StartDungeonMacro(Maps)
                } else if (gameCategory == "Essence") {
                    EssenceStartMacro(Maps, Difficulty)
                } else if (gameCategory == "Survival") {
                    StartSurvivalMacro(Maps)
                }
                return
            } else {
                break

            }
            
            ; Small delay to prevent excessive CPU usage
            Sleep(100)
        }    } else {
        loop {
            if FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, Loaded) {
                if (!LoadInUnits()) {
                    LogMessage("Failed to load units config - aborting placement")
                    return
                }
                LogMessage("Found the start button")
                categoryFile := A_ScriptDir . "\libs\settings\Category.txt"
                gameCategory := ""
                gameCategory := FileRead(categoryFile)
                if gameCategory == "Dungeon" {
                      ZoomTech(false)
                } else if gameCategory == "Raids" {
                    SkipStartButton := "true"
                    ZoomTech(false)
                } else if gameCategory == "Essence" {
                    SkipStartButton := "true"
                    ZoomTech(false)
                } else if gameCategory == "Survival" {
                    SkipStartButton := "true"
                    SurvivalMap := FileRead(A_ScriptDir . "\libs\settings\survival\Survival.txt")
                    SurvivalMap := Trim(SurvivalMap)
                    if (SurvivalMap == "Hell Invasion") {
                        SendInput("{W Down}") 
                        Sleep(5000)  ; Wait for the map to load
                        SendInput("{W Up}")  ; Press W and Up to zoom out

                        ZoomTech(false)
                    } else if (SurvivalMap == "Villan Invasion") {
                        ZoomTech(false)
                        ChangeMovement("true") ; changes to click to move
                        Sleep(2000)  ; Wait for the map to load
                        BetterClick(936, 409, "Right") 
                        Sleep(7000)  ; Wait for the click to register
                        BetterClick(499, 555, "Right") ; Clicks the start button
                        Sleep(7000)  ; Wait for the game to start
                        BetterClick(498, 564, "Right") ; Clicks the start button again
                        Sleep(2000)  ; Wait for the game to start
                        ChangeMovement("false") ; changes back to WASD movement                    } else if (SurvivalMap == "Holy Invasion") {
                        ZoomTech(false)
                    }                } else if gameCategory == "Legend Stages" {
                    SkipStartButton := "true"
                    ZoomTech(false)
                } else if (gameCategory == "Portals") {
                    SkipStartButton := "false"
                    ZoomTech(false)
                } else if (gameCategory == "Story") {
                    SkipStartButton := "true"
                    ; Read the map setting for Story
                    Maps := FileRead(A_ScriptDir . "\libs\settings\Map.txt")
                    ; Pass Maps variable directly to StoryMovement without trimming
                    StoryMovement(Maps)
                    ZoomTech(false)
                }                BetterClick(449, 594) ; Clicks start
                break
            } else if (FindText(&X, &Y, 494-150000, 674-150000, 494+150000, 674+150000, 0, 0, Loaded2)) {
                if (!LoadInUnits()) {
                    LogMessage("Failed to load units config - aborting placement")
                    return
                }
                LogMessage("Found the start button")
                categoryFile := A_ScriptDir . "\libs\settings\Category.txt"
                gameCategory := ""
                gameCategory := FileRead(categoryFile)
                if gameCategory == "Dungeon" {
                      ZoomTech(false)
                } else if gameCategory == "Raids" {
                    SkipStartButton := "true"
                    ZoomTech(false)
                } else if gameCategory == "Essence" {
                    SkipStartButton := "true"
                    ZoomTech(false)
                } else if gameCategory == "Survival" {
                    SkipStartButton := "true"
                    SurvivalMap := FileRead(A_ScriptDir . "\libs\settings\survival\Survival.txt")
                    SurvivalMap := Trim(SurvivalMap)
                    if (SurvivalMap == "Hell Invasion") {
                        SendInput("{W Down}") 
                        Sleep(5000)  ; Wait for the map to load
                        SendInput("{W Up}")  ; Press W and Up to zoom out

                        ZoomTech(false)
                    } else if (SurvivalMap == "Villan Invasion") {
                        ZoomTech(false)
                        ChangeMovement("true") ; changes to click to move
                        Sleep(2000)  ; Wait for the map to load
                        BetterClick(936, 409, "Right") 
                        Sleep(7000)  ; Wait for the click to register
                        BetterClick(499, 555, "Right") ; Clicks the start button
                        Sleep(7000)  ; Wait for the game to start
                        BetterClick(498, 564, "Right") ; Clicks the start button again
                        Sleep(2000)  ; Wait for the game to start
                        ChangeMovement("false") ; changes back to WASD movement
                    } else if (SurvivalMap == "Holy Invasion") {
                        ZoomTech(false)

                    }                } else if gameCategory == "Legend Stages" {
                    SkipStartButton := "true"
                    ZoomTech(false)
                } else if (gameCategory == "Portals") {
                    SkipStartButton := "false"
                    ZoomTech(false)
                } else if (gameCategory == "Story") {
                    SkipStartButton := "true"
                    ; Read the map setting for Story
                    Maps := FileRead(A_ScriptDir . "\libs\settings\Map.txt")
                    ; Pass Maps variable directly to StoryMovement without trimming
                    StoryMovement(Maps)
                    ZoomTech(false)
                }
                BetterClick(449, 594) ; Clicks start
                break
            }
            
            
            else if (FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, Disconnected)) {
                LogMessage("Game Has Been Disconnected, Retrying...")
                UpdateWLDisplay("disconnect")  ; Add this line to count the disconnect

                BetterClick(790, 162) ; closes the update logs so it doesn't interfere with the mango
                ; load in all the configs again
                Difficulty := FileRead(A_ScriptDir . "\libs\settings\Difficulty.txt")
                Maps := FileRead(A_ScriptDir . "\libs\settings\Map.txt")
                
                categoryFile := A_ScriptDir . "\libs\settings\Category.txt"
                gameCategory := ""
                if (FileExist(categoryFile)) {
                    try {
                        gameCategory := FileRead(categoryFile)
                        gameCategory := Trim(gameCategory)  ; Remove any whitespace/newlines
                    }
                }
                  if (gameCategory == "Raids") {
                    StartRaidMacro(Maps)
                } else if (gameCategory == "Dungeon") {
                    StartDungeonMacro(Maps)
                } else if (gameCategory == "Essence") {
                    EssenceStartMacro(Maps, Difficulty)
                } else if (gameCategory == "Story") {
                    StartStoryMacro(Maps, "1")
                }
                return
            } else {
                LogMessage("Waiting for the start button to appear...")
                Sleep(1000)  ; Wait before checking again
            } 
        }
    }
    
    Sleep(500) ; Wait for the units to load
    
    LogMessage("Units loaded - Starting placement...")
    
    PlaceDownUnits()    LogMessage("Placement complete - Starting upgrades...")
    
    UpgradeUnits()
    
    LogMessage("Upgrades complete - Activating auto skills...")
    
    ActivateAutoSkills()
    
    LogMessage("All operations complete!")

    ; Monitor for game end status and restart when game finishes
    loop {
        Sleep(1000)  ; Keep the script running to allow for further actions
        gameResult := GameStatus()
        if (gameResult == "won" || gameResult == "lost") {
            LogMessage("Game ended with result: " . gameResult )
            Sleep(3000)  ; Wait 3 seconds before restarting
            MainTerminal()  ; Restart the terminal
            return  ; Exit current instance
        } else if (Story == "Infinite") {
            static lastMoveTime := A_TickCount
            
            ; If 10 seconds passed since last movement, do random movement
            if (A_TickCount - lastMoveTime > 10000) {
                ; Get random coordinates within Roblox window
                randX := Random(robloxX1 + 50, robloxX2 - 50)
                randY := Random(robloxY1 + 50, robloxY2 - 50)
                
                ; Move mouse slightly to prevent disconnect
                MouseMove(randX, randY)
                wiggle()  ; Use the existing wiggle function
                
                LogMessage("Performing anti-disconnect mouse movement")
                lastMoveTime := A_TickCount  ; Reset timer
            }
        }
    } 
}

; Upgrade pattern definitions for visual verification
Upgrade1:="|<>*48$7.zzySD5msQDw"
Upgrade2:="|<>*52$7.zzzyC39tks7zz"
Upgrade3:="|<>*49$7.zzzyC3lskALy"
Upgrade4:="|<>*51$6.zzd991tszzU"
Upgrade5:="|<>*49$6.zzlVXVUUzU"
Upgrade6:="|<>*53$7.zzzzD77VEA4"
Upgrade7:="|<>*52$7.zzzy7Xttwyry"
Upgrade8:="|<>*52$6.zzzzX3331WzzU"
Upgrade9:="|<>*55$8.zzzXkwDWsgG"
Upgrade10:="|<>*49$9.zzzzyFU44ka0mDzzw"
Upgrade11:="|<>*47$17.zzzzzzzzvz9bw30s40t83m57YDzzs"
Upgrade12:="|<>*50$11.zzzzzzzwXk3UbaP0r0DzzzU"
Upgrade13:="|<>*48$9.zzzzwX08laA0YLzzw"
MaxUnit:="|<>*122$72.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzjzwwzzxtzzzz7zsszzstzzzz7zsEUAss60AA0Ds000ss00800Ds041wsEEl00Dxw41wk00t10DxwU0y260s80TxykzzCTWwAATzzzzzyzbzzzzzzzzzzzDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"



F9::Reload

; Function to activate auto skills for placed units
ActivateAutoSkills() {
    LogMessage("Starting auto skill activation...")
    
    for slotName, slotData in unitSlots {
        if (slotData.placement == 0 || slotData.coordinates.Length == 0)
            continue  ; Skip if placement is not set or no coordinates
        
        ; Skip if no auto skill is set or it's set to 'none'
        if (!slotData.HasOwnProp("autoSkill") || slotData.autoSkill == "none" || slotData.autoSkill == "")
            continue
        
        ; Check game status before activating skills
        gameResult := GameStatus()
        if (gameResult == "won" || gameResult == "lost") {
            LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
            Sleep(3000)
            MainTerminal()
            return
        }
        
        ; Activate auto skill for each coordinate of this slot
        for coord in slotData.coordinates {
            if (coord.x == 0 && coord.y == 0) {
                LogMessage("Skipping auto skill for " . slotName . " - coordinates are 0, 0")
                continue  ; Skip if coordinates are (0, 0)
            }
            
            LogMessage("Activating auto skill '" . slotData.autoSkill . "' for " . slotName . " at (" . coord.x . ", " . coord.y . ")")
            
            ; Click on the unit to select it
            ClickV4(coord.x, coord.y, 50)
            Sleep(300)
              ; Send the appropriate key based on auto skill type
            switch slotData.autoSkill {
                case "ichigo":
                    BetterClick(408, 327)  
                    LogMessage("Activated Ichigo skill for " . slotName)
                    Sleep(500)  ; Give more time for skill activation
                case "gilgamesh_nuke":
                    BetterClick(354, 341)  
                    LogMessage("Activated Gilgamesh Nuke for " . slotName)
                    Sleep(500)  ; Give more time for skill activation                case "idol_concert":
                    concertValue := "|<>*136$47.0000000000000000000000000000000000000000000000000000000000000001s0006007w000S00QTzzzi00kzzzzC03D4AF4Q06QV32Rs3yE224tzzy8YW9nzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"
                    if (FindText(&X, &Y, robloxX1, robloxY1, robloxX2, robloxY2, 0, 0, concertValue)) {
                        BetterClick(407, 335)  ; Clicks the Idol Concert button
                        LogMessage("Activated Idol Concert for " . slotName)
                    } else {
                        LogMessage("Idol Concert button not found for " . slotName)
                    }
                    Sleep(500)  ; Give more time for skill activation
                case "gojo_unlimited_void":
                    BetterClick(410, 341) 
                    LogMessage("Activated Gojo: Unlimited Void for " . slotName)
                    Sleep(500)  ; Give more time for skill activation
                default:
                    LogMessage("Unknown auto skill type: " . slotData.autoSkill . " for " . slotName)
            }
            
            Sleep(300)  ; Delay between skill activations
            
            ; Check game status after skill activation
            gameResult := GameStatus()
            if (gameResult == "won" || gameResult == "lost") {
                LogMessage("Game ended with result: " . gameResult . ". Restarting MainTerminal in 3 seconds...")
                Sleep(3000)
                MainTerminal()
                return
            }
        }
    }
    
    LogMessage("Auto skill activation completed")
    return false
}