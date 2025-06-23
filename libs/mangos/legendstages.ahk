; Legend Stages Macro Configuration
; This file contains all legend stages-specific setup and functionality

; Global variables for Legend Stages macro
global LegendStagesMaps := ["Shibuya", "Ruined Morioh", "Thriller Bark", "Ryuudou Temple", "Snowy Village", "Rain Village", "Oni Island", "Unknown Planet", "Oasis", "Harge Forest", "Babylon", "Shinjuku", "Train Station"]
global LegendStages := ["1", "2", "3", "4", "5", "6", "Infinite"]
global LegendStageLabel := ""
global LegendStageDropDown := ""

LegendStagesSetupUI(gui, x, y) {
    global LegendStageLabel, LegendStageDropDown, LegendStages
      ; Setup UI elements specific to Legend Stages
    LegendStageLabel := gui.Add("Text", "x" . x . " y" . y . " w80 h15 cFFFFFF", "Legend Stage:")
    LegendStageDropDown := gui.Add("DropDownList", "x" . x . " y" . (y + 20) . " w80 cFFFFFF -E0x200 +Theme", LegendStages)
    LegendStageDropDown.SetFont("s10 Bold", "Segoe UI")
    LegendStageDropDown.OnEvent("Change", LegendStagesSaveSettings)
    
    ; Initially hide elements
    LegendStageLabel.Visible := false
    LegendStageDropDown.Visible := false
}

LegendStagesShowUI() {
    global LegendStageLabel, LegendStageDropDown
    
    LegendStageLabel.Visible := true
    LegendStageDropDown.Visible := true
    LegendStagesLoadSettings()
}

LegendStagesHideUI() {
    global LegendStageLabel, LegendStageDropDown
    
    LegendStageLabel.Visible := false
    LegendStageDropDown.Visible := false
}

LegendStagesLoadSettings() {
    global LegendStageDropDown
    
    settingsFile := A_ScriptDir . "\libs\settings\legendstages\LegendStage.txt"
    if (FileExist(settingsFile)) {
        try {
            savedStage := FileRead(settingsFile)
            if (savedStage != "" && LegendStageDropDown) {
                ; Find and select the saved stage
                loop LegendStageDropDown.Length {
                    if (LegendStageDropDown.GetText(A_Index) == savedStage) {
                        LegendStageDropDown.Choose(A_Index)
                        break
                    }
                }            }
        } catch {
            return
        }
    }
}

LegendStagesSaveSettings(*) {
    global LegendStageDropDown
    
    if (LegendStageDropDown) {
        selectedStage := LegendStageDropDown.Text
        try {
            FileOpen(A_ScriptDir . "\libs\settings\legendstages\LegendStage.txt", "w", "UTF-8").Write(selectedStage)
            LogMessage("Saved legend stage: " . selectedStage, "info")
        } catch {
            LogMessage("Error saving legend stage", "error")
        }
    }
}

LegendStagesStartMacro() {
    global LegendStageDropDown
    
    stage := LegendStageDropDown ? LegendStageDropDown.Text : "1"
    LogMessage("Starting Legend Stages macro with stage: " . stage, "info")
    ; Add legend stages macro logic here
}

LegendStagesStopMacro() {
    LogMessage("Stopping Legend Stages macro", "info")
    ; Add legend stages stop logic here
}

LegendStagesSetupStage(mapName := "", selectedLegendStage := "1") {
    LogMessage("Setting up Legend Stage: " . selectedLegendStage . " for map: " . mapName, "info")
    
    Switch (selectedLegendStage) {
        case "1":
            BetterClick(728, 207)  ; Click on Stage 1
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
        case "2":
            BetterClick(763, 206)  ; Click on Stage 2
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
        case "3":
            BetterClick(799, 204)  ; Click on Stage 3
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
        default:
            LogMessage("Unknown legend stage: " . selectedLegendStage . ", defaulting to Stage 1", "warning")
    }
}

HandleLegendStagesMap(MapName, selectedLegendStage := "1") {
    LogMessage("Handling legend stages map: " . MapName . " (Stage " . selectedLegendStage . ")", "info")
    BetterClick(309, 203)  ; moves to the scrollbar just in case we need to scroll down
    
    switch (MapName) {
        case "Shibuya":
            LogMessage("Selected Shibuya Legend Stage", "info")
            BetterClick(239, 388)  
            LegendStagesSetupStage(MapName, selectedLegendStage)
            
        case "Ruined Morioh":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Ruined Morioh Legend Stage", "info")
            SendInput("{WheelDown}")  ; Scroll down to find the stage
                        Sleep(1000)            BetterClick(238, 343) 
            LegendStagesSetupStage(MapName, selectedLegendStage)
            

        case "Thriller Bark":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Thriller Bark Legend Stage", "info")
            SendInput("{WheelDown}") 
                        Sleep(1000)            BetterClick(242, 434) 
            LegendStagesSetupStage(MapName, selectedLegendStage)
            
        case "Ryuudou Temple":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Ryuudou Temple Legend Stage", "info")
            SendInput("{WheelDown 2}") 
                        Sleep(1000)            BetterClick(242, 382) 
            LegendStagesSetupStage(MapName, selectedLegendStage)
            
        case "Snowy Village":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Snowy Village Legend Stage", "info")
            SendInput("{WheelDown 2}") 
                        Sleep(1000)            BetterClick(241, 434) 
            LegendStagesSetupStage(MapName, selectedLegendStage)

        case "Rain Village":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Rain Village Legend Stage", "info")
            SendInput("{WheelDown 3}") 
                        Sleep(1000)            BetterClick(239, 336) 
            LegendStagesSetupStage(MapName, selectedLegendStage)

        case "Oni Island":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Oni Island Legend Stage", "info")
            SendInput("{WheelDown 3}") 
                        Sleep(1000)

            BetterClick(238, 425) 
            LegendStagesSetupStage(MapName, selectedLegendStage)
          
        case "Unknown Planet":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Unknown Planet Legend Stage", "info")
            SendInput("{WheelDown 4}") 
                        Sleep(1000)

            BetterClick(234, 336)  
            LegendStagesSetupStage(MapName, selectedLegendStage)
        
        case "Oasis":
            BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Oasis Legend Stage", "info")
            SendInput("{WheelDown 4}")
                        Sleep(1000)

            BetterClick(240, 379) 
            LegendStagesSetupStage(MapName, selectedLegendStage)

        case "Harge Forest":
            BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Harge Forest Legend Stage", "info")
            SendInput("{WheelDown 4}")
                        Sleep(1000)

            BetterClick(239, 424)
            LegendStagesSetupStage(MapName, selectedLegendStage)

        case "Babylon":
            LogMessage("Selected Babylon Legend Stage", "info")
            Sleep(1000)
             SendInput("{WheelDown 5}")
                         Sleep(1000)

            BetterClick(243, 348)  
            LegendStagesSetupStage(MapName, selectedLegendStage)

        case "Shinjuku":
            LogMessage("Selected Shinjuku Legend Stage", "info")
            Sleep(1000)
             SendInput("{WheelDown 5}")
                         Sleep(1000)

            BetterClick(238, 387)  
            LegendStagesSetupStage(MapName, selectedLegendStage)
        

        case "Train Station":
            LogMessage("Selected Train Station Legend Stage", "info")
            Sleep(1000)
             SendInput("{WheelDown 5}")
                         Sleep(1000)

            BetterClick(240, 434) 
            LegendStagesSetupStage(MapName, selectedLegendStage)
        default:
            LogMessage("Unknown legend stages map: " . MapName, "error")
    }
}

StartLegendStagesMacro(selectedMap, selectedLegendStage) {
    global X1, Y1, X2, Y2
    StoryMode := "|<>*148$65.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzkTzzzzzzzzz0SDzzzzzzzw0QTzzzzzzzstszzzzzzzzlzUDzzzzzzzVy0S3l6T7zz0Q0s3U8SDzz0A1U30MsTzzUQT72DklzzzssyD4Tk3zzvllwS8zkDzzXXXsslzUTzz071k1XzVzzz0T3k77zXzzzXzbsSTyDzzzzzzzzzwTzzzzzzzzztzzzzzzzzzzXzzzzzzzzzzjzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
    
    LogMessage("Starting Legend Stages macro for: " . selectedMap . " (Stage " . selectedLegendStage . ")", "info")
    
    ; Navigate to Legend Stages area (similar to other macros)
    Sleep(2000)
    BetterClick(40, 394)  ; Clicks teleport button
    Sleep(300)
    MouseMove(407, 297)  ; Hovers over the teleport menu
    Sleep(1000)
    BetterClick(492, 382)  ; Click on the Story & Infinity section (will need to adjust for legend stages)
    Sleep(500)
    BetterClick(642, 127)  ; Close the teleport menu
    Sleep(500)
    
    ; Move to legend stages area with improved reliability
    LogMessage("Moving to legend stages area (holding A key)...", "info")
    
    ; Ensure all keys are released first
    SendInput("{A up}")
    Sleep(100)
    
    ; Hold A key with better timing
    SendInput("{A down}")
    Sleep(5000)  ; Hold A for 5 seconds
    SendInput("{A up}")
    
    LogMessage("Movement completed, checking for legend stages selection screen...", "info")
      ; Wait for legend stages selection screen
    loop {
        if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, StoryMode)) {
            LogMessage("Successfully entered the legend stages selection!", "info")
            MangoLookForMap(selectedMap, "", selectedLegendStage)
            break
        } else {
            LogMessage("Failed to enter legend stages selection. Retrying...", "warning")

            CloseUI("Legend Stages")  ; Close any open UI to avoid interference
            
         
            
            
        }
    }
}
