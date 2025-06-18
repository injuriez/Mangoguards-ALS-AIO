; Mango Manager - Coordinates all macro types
; This file manages the different macro types and their interactions

#Include raids.ahk
#Include dungeon.ahk
#Include survival.ahk
#Include essence.ahk
#Include bossrush.ahk
#Include legendstages.ahk
#Include Portals.ahk
; Global variables for manager
global CurrentMacro := ""
global MangoMaps := Map()

; Initialize the manager system
MangoManagerInitialize(gui) {
    ; Initialize MangoMaps structure using global arrays from each macro file
    MangoMaps["Raids"] := RaidsMaps
    MangoMaps["Dungeon"] := DungeonMaps  
    MangoMaps["Survival"] := SurvivalMaps
    MangoMaps["Essence"] := EssenceMaps
    MangoMaps["Boss Rush (WIP)"] := BossRushMaps
    MangoMaps["Legend Stages"] := LegendStagesMaps
    ; For Portals, we only use "Summer Laguna" so create a simple array here
    MangoMaps["Portals"] := ["Summer Laguna"]
    
    ; Setup UI for all macro types
    MangoManagerSetupAllUI(gui)
    
    LogMessage("MangoManager initialized with " . MangoMaps.Count . " macro types", "info")
}

MangoManagerSetupAllUI(gui) {
    ; Setup UI for each macro type at the same position (they'll be shown/hidden as needed)
    uiX := 1250
    uiY := 255
      SetupRaidsUI(gui, uiX, uiY)       ; Renamed from RaidsSetupUI
    SetupDungeonUI(gui, uiX, uiY)     ; Renamed from DungeonSetupUI
    SetupSurvivalUI(gui, uiX, uiY)    ; Renamed from SurvivalSetupUI
    EssenceSetupUI(gui, uiX, uiY)
    BossRushSetupUI(gui, uiX, uiY)
    LegendStagesSetupUI(gui, uiX, uiY)
    SetupPortalsUI(gui, uiX, uiY)
}

MangoManagerSwitchToMacro(macroType) {
    global CurrentMacro
    
    LogMessage("Switching to macro type: " . macroType, "info")
    
    ; Hide current macro UI
    if (CurrentMacro != "") {
        switch CurrentMacro {
            case "Raids":
                HideRaidsUI()           ; Renamed from RaidsHideUI
            case "Dungeon":
                HideDungeonUI()         ; Renamed from DungeonHideUI
            case "Survival":
                HideSurvivalUI()        ; Renamed from SurvivalHideUI            case "Essence":
                EssenceHideUI()
            case "Boss Rush (WIP)":
                BossRushHideUI()
            case "Legend Stages":
                LegendStagesHideUI()
            case "Portals":
                HidePortalsUI()
        }
    }
    
    ; Show new macro UI
    switch macroType {
        case "Raids":
            ShowRaidsUI()           ; Renamed from RaidsShowUI
        case "Dungeon":
            ShowDungeonUI()         ; Renamed from DungeonShowUI
        case "Survival":
            ShowSurvivalUI()        ; Renamed from SurvivalShowUI
        case "Essence":
            EssenceShowUI()
        case "Boss Rush (WIP)":            BossRushShowUI()
        case "Legend Stages":
            LegendStagesShowUI()
        case "Portals":
            ShowPortalsUI()
        default:
            LogMessage("Unknown macro type: " . macroType, "error")
            return
    }
      CurrentMacro := macroType
    
    ; Clear PortalBlacklist.txt whenever user switches to Portals macro
    if (macroType = "Portals") {
        try {
            blacklistFile := A_ScriptDir . "\libs\settings\PortalBlacklist.txt"
            FileOpen(blacklistFile, "w", "UTF-8").Write("")  ; Clear the file
            LogMessage("Cleared PortalBlacklist.txt file when switching to Portals macro", "info")
        } catch as err {
            LogMessage("Error clearing PortalBlacklist.txt: " . err.Message, "warning")
        }
    }
    
    LogMessage("Successfully switched to " . macroType . " macro", "info")
}

MangoManagerGetMaps(macroType) {
    global MangoMaps
    
    if (MangoMaps.Has(macroType)) {
        return MangoMaps[macroType]
    }
    return []
}

MangoManagerStartCurrentMacro() {
    global CurrentMacro, A_ScriptDir

    selectedMap := ""
    mapFile := A_ScriptDir . "\libs\settings\Map.txt" ; Corrected path
    if (FileExist(mapFile)) {
        selectedMap := Trim(FileRead(mapFile))
    }
    if (selectedMap == "") {
        LogMessage("MangoManagerStartCurrentMacro: Map not selected or file empty.", "warning")
        ; It might be better to return or ensure map is always available before calling specific macros
    }

    if (CurrentMacro != "") {
        switch CurrentMacro {
            case "Raids":
                if (selectedMap != "") {
                    StartRaidMacro(selectedMap)
                } else {
                    LogMessage("Raids: Map not selected to start macro.", "error")
                }
            case "Dungeon":
                if (selectedMap != "") {
                    StartDungeonMacro(selectedMap)
                } else {
                    LogMessage("Dungeon: Map not selected to start macro.", "error")
                }         
            case "Survival":      
                if (selectedMap != "") {
                    StartSurvivalMacro(selectedMap)
                } else {
                    LogMessage("Survival: Map not selected to start macro.", "error")
                }
            case "Essence":
                selectedDifficulty := "Normal" ; Default
                difficultyFile := A_ScriptDir . "\\libs\\settings\\Difficulty.txt" ; Corrected path
                if (FileExist(difficultyFile)) {
                    _diff := Trim(FileRead(difficultyFile))
                    if (_diff != "") 
                        selectedDifficulty := _diff
                }
                if (selectedMap != "") {
                    EssenceStartMacro(selectedMap, selectedDifficulty)
                } else {
                    LogMessage("Essence: Map not selected to start macro.", "error")
                }            
            case "Boss Rush (WIP)":
                selectedBossRush := "" ; Default, should be read from BossRush.txt
                bossRushFile := A_ScriptDir . "\libs\settings\BossRush.txt" ; Corrected path
                if (FileExist(bossRushFile)) {
                    _br := Trim(FileRead(bossRushFile))
                    if (_br != "") 
                        selectedBossRush := _br
                }
                if (selectedMap != "" && selectedBossRush != "") {
                    StartBossRushMacro(selectedMap, selectedBossRush)
                } else {
                    LogMessage("Boss Rush: Map or Type not selected to start macro.", "error")
                }        
            case "Legend Stages":
                selectedLegendStage := "1" ; Default
                legendStageFile := A_ScriptDir . "\libs\settings\LegendStage.txt" ; Corrected path
                if (FileExist(legendStageFile)) {
                    _ls := Trim(FileRead(legendStageFile))
                    if (_ls != "") 
                        selectedLegendStage := _ls
                }
                if (selectedMap != "") {
                    StartLegendStagesMacro(selectedMap, selectedLegendStage)
                } else {
                    LogMessage("Legend Stages: Map not selected to start macro.", "error")
                }            case "Portals":                ; Get portal tier setting (map is fixed to Summer Laguna)
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
                
                ; Start the portal macro (blacklist settings are now loaded in the PortalBlacklistLoadSettings function)
                StartPortalMacro(selectedTier, selectedElement)
        }
    } else {
        LogMessage("No macro selected to start", "warning")
    }
}
; This is a shared function for all macro types
; The LookForMap implementation in manager.ahk should be used as the main implementation
; while macro-specific implementations should call this one
MangoLookForMap(MapName, selectedDifficulty := "", selectedLegendStage := "") {
    ; Search the entire Roblox window for map detection
    ; Get the actual Roblox window dimensions with screen coordinates
    global X1, Y1, X2, Y2  ; Declare as global to update the global variables
    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
    if WinExist(RobloxWindow) {
        WinGetPos(&RblxX, &RblxY, &RblxW, &RblxH, RobloxWindow)
        ; Use full Roblox window coordinates for FindText (screen coordinates)
        X1 := RblxX
        Y1 := RblxY  
        X2 := RblxX + RblxW
        Y2 := RblxY + RblxH
    } else {
        ; Fallback coordinates if Roblox not found
        X1 := 0
        Y1 := 0
        X2 := 1920
        Y2 := 1080
        LogMessage("Roblox window not found, using fallback coordinates", "warning")
    }
      ; Determine which category the map belongs to
    global MangoMaps
    selectedCategory := ""
    
    for category, maps in MangoMaps {
        for map in maps {
            if (map == MapName) {
                selectedCategory := category
                break
            }
        }
        if (selectedCategory != "")
            break
    }    ; Handle different categories
    switch (selectedCategory) {
        case "Raids":
            HandleRaidMap(MapName)
        case "Dungeon":
            HandleDungeonMap(MapName)
        case "Essence":
            HandleEssenceMap(MapName, selectedDifficulty)
        case "Survival":
            HandleSurvivalMap(MapName)
        case "Legend Stages":
            HandleLegendStagesMap(MapName, selectedLegendStage)
        default:
            LogMessage("Unknown map category for: " . MapName, "error")
    }
}


MangoManagerStopCurrentMacro() {
    global CurrentMacro
      if (CurrentMacro != "") {
        switch CurrentMacro {
            case "Raids":
                StopRaidsMacro()         ; Correct name from raids.ahk
            case "Dungeon":
                StopDungeonMacro()
            case "Survival":
                StopSurvivalMacro()     ; Assuming this is the correct name
            case "Essence":
                EssenceStopMacro()
            case "Boss Rush (WIP)":
                BossRushStopMacro()
            case "Legend Stages":
                LegendStagesStopMacro() ; Correct name from legendstages.ahk
            case "Portals":
                StopPortalsMacro()
        }
    } else {
        LogMessage("No macro running to stop", "warning")
    }
}

MangoManagerLoadAllSettings() {
    ; Load settings for all macro types
    LoadNumberSelection()         ; Renamed from RaidsLoadSettings
    LoadDungeonCurseSelection()   ; Renamed from DungeonLoadSettings
    LoadSurvivalCurseSelection()  ; Renamed from SurvivalLoadSettings
    EssenceLoadSettings()
    BossRushLoadSettings()
    LegendStagesLoadSettings()
    PortalTierLoadSettings()      ; Load portal tier settings
    PortalElementLoadSettings()   ; Load portal element settings
    PortalBlacklistLoadSettings() ; Load portal blacklist settings
}

MangoManagerGetCurrentMacroInfo() {
    global CurrentMacro
    
    if (CurrentMacro == "") {
        return "No macro selected"
    }
    
    return "Current macro: " . CurrentMacro
}
