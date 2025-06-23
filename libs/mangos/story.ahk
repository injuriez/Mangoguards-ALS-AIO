; Story Macro Configuration
; This file contains all story-specific setup and functionality

; Global variables for Story macro
global StoryMaps := ["Hog Town", "Hollow Night Palace", "Firefighters Base", "Demon Skull Village (Broken)",  "Shibuya", "Abandoned Cathedral", "Ruined Morioh", "Soul Society", "Thriller Bark", "Dragon Heaven", "Giants District", "Ryuudou Temple", "Snowy Village", "Rain Village", "Oni Island", "Unknown Planet", "Oasis", "Harge Forest", "Babylon", "Shinjuku", "Train Station"]
global StoryStages := ["1", "2", "3", "4", "5", "6", "Infinite"]
global StoryLabel := ""
global StoryDropDown := ""

StorySetupUI(gui, x, y) {
    global StoryLabel, StoryDropDown, StoryStages
    
    ; Setup UI elements specific to Story
    StoryLabel := gui.Add("Text", "x" . x . " y" . y . " w80 h15 cFFFFFF", "Story Stage:")
    StoryDropDown := gui.Add("DropDownList", "x" . x . " y" . (y + 20) . " w80 cFFFFFF -E0x200 +Theme", StoryStages)
    StoryDropDown.SetFont("s10 Bold", "Segoe UI")
    StoryDropDown.OnEvent("Change", StorySaveSettings)
    
    ; Initially hide elements
    StoryLabel.Visible := false
    StoryDropDown.Visible := false
}

StoryShowUI() {
    global StoryLabel, StoryDropDown
    
    StoryLabel.Visible := true
    StoryDropDown.Visible := true
    StoryLoadSettings()
}

StoryHideUI() {
    global StoryLabel, StoryDropDown
    
    StoryLabel.Visible := false
    StoryDropDown.Visible := false
}

StoryLoadSettings() {
    global StoryDropDown
    
    settingsFile := A_ScriptDir . "\libs\settings\story\Story.txt"
    if (FileExist(settingsFile)) {
        try {
            savedStage := FileRead(settingsFile)
            if (savedStage != "" && StoryDropDown) {
                ; Find and select the saved stage
                loop StoryDropDown.Length {
                    if (StoryDropDown.GetText(A_Index) == savedStage) {
                        StoryDropDown.Choose(A_Index)
                        break
                    }
                }
            }
        } catch {
            return
        }
    }
}

StorySaveSettings(*) {
    global StoryDropDown
    
    if (StoryDropDown && StoryDropDown.Text != "") {
        try {
            FileOpen(A_ScriptDir . "\libs\settings\story\Story.txt", "w", "UTF-8").Write(StoryDropDown.Text)
        } catch as err {
            LogMessage("Error saving story stage: " . err.Message, "error")
        }
    }
}
StartStoryMacro(mapName, storyStage := "1") {
    global X1, Y1, X2, Y2
    StoryMode := "|<>*148$65.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzkTzzzzzzzzz0SDzzzzzzzw0QTzzzzzzzstszzzzzzzzlzUDzzzzzzzVy0S3l6T7zz0Q0s3U8SDzz0A1U30MsTzzUQT72DklzzzssyD4Tk3zzvllwS8zkDzzXXXsslzUTzz071k1XzVzzz0T3k77zXzzzXzbsSTyDzzzzzzzzzwTzzzzzzzzztzzzzzzzzzzXzzzzzzzzzzjzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
    
    
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
            HandleStoryMap(mapName, storyStage)
            break
        } else {
            LogMessage("Failed to enter legend stages selection. Retrying...", "warning")

            CloseUI("Legend Stages")  ; Close any open UI to avoid interference
            
         
            
            
        }
    }
}
; Main story macro functions


StopStoryMacro() {
    LogMessage("Story macro stopped", "info")
    ; Add any story-specific cleanup here
}

; Handle story map selection
HandleStoryMap(mapName, storyStage := "1") {
    switch (mapName) {
        case "Hog Town":
            LogMessage("Selected Hog Town Story Stage", "info")
            BetterClick(230, 210)  ; Click on Hog Town (first map in the list)
            StoryStagesSetup(mapName, storyStage)
        
        case "Hollow Night Palace":
            LogMessage("Selected Hollow Night Palace Story Stage", "info")
            BetterClick(242, 258)  ; Click on Hollow Night Palace
            StoryStagesSetup(mapName, storyStage)

        case "Firefighters Base":
            LogMessage("Selected Firefighters Base Story Stage", "info")
            BetterClick(240, 340)  ; Click on Firefighters Base
            StoryStagesSetup(mapName, storyStage)

        case "Demon Skull Village":
            LogMessage("Selected Demon Skull Village Story Stage", "info")
            BetterClick(240, 336)  ; Click on Demon Skull Village
            StoryStagesSetup(mapName, storyStage)

        case "Abandoned Cathedral":
            LogMessage("Selected Abandoned Cathedral Story Stage", "info")
            BetterClick(239, 432)  ; Click on Abandoned Cathedral
            StoryStagesSetup(mapName, storyStage)


        case "Giants District":
            LogMessage("Selected Giants District Story Stage", "info")
            BetterClick(309, 203)  ; Click on Giants District
            Sleep(2000)  ; Wait for the map to load
            SendInput("{WheelDown 3}")  ; Scroll down to find the stage
            Sleep(2000)
            BetterClick(240, 380)  ; Click on Giants District
                        StoryStagesSetup(mapName, storyStage)


        case "Soul Society":
            BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Soul Society Story Stage", "info")
            SendInput("{WheelDown}")  ; Scroll down to find the stage
            sleep(3000)
            BetterClick(241, 389)  ; Click on Soul Society
            StoryStagesSetup(mapName, storyStage)

        case "Dragon Heaven":
            BetterClick(309, 203)
            Sleep(2000)
            LogMessage("Selected Dragon Heaven Story Stage", "info")
            SendInput("{WheelDown}")  ; Scroll down to find the stage
            Sleep(2000)
            BetterClick(237, 337)  ; Click on Dragon Heaven
            StoryStagesSetup(mapName, storyStage)
            
        case "Shibuya":
            LogMessage("Selected Shibuya Story Stage", "info")
            BetterClick(239, 388)  
            StoryStagesSetup(mapName, storyStage)
            
        case "Ruined Morioh":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Ruined Morioh Story Stage", "info")
            SendInput("{WheelDown}")  ; Scroll down to find the stage
                        Sleep(1000)            BetterClick(238, 343) 
            StoryStagesSetup(mapName, storyStage)
            

        case "Thriller Bark":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Thriller Bark Story Stage", "info")
            SendInput("{WheelDown}") 
                        Sleep(1000)   
                                 BetterClick(242, 434) 
            StoryStagesSetup(mapName, storyStage)
            
        case "Ryuudou Temple":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Ryuudou Temple Story Stage", "info")
            SendInput("{WheelDown 2}") 
                        Sleep(1000)            BetterClick(242, 382) 
            StoryStagesSetup(mapName, storyStage)
            
        case "Snowy Village":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Snowy Village Story Stage", "info")
            SendInput("{WheelDown 2}") 
                        Sleep(1000)            BetterClick(241, 434) 
            StoryStagesSetup(mapName, storyStage)

        case "Rain Village":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Rain Village Story Stage", "info")
            SendInput("{WheelDown 3}") 
                        Sleep(1000)            BetterClick(239, 336) 
            StoryStagesSetup(mapName, storyStage)

        case "Oni Island":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Oni Island Story Stage", "info")
            SendInput("{WheelDown 3}") 
                        Sleep(1000)

            BetterClick(238, 425) 
            StoryStagesSetup(mapName, storyStage)
          
        case "Unknown Planet":
             BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Unknown Planet Story Stage", "info")
            SendInput("{WheelDown 4}") 
                        Sleep(1000)

            BetterClick(234, 336)  
            StoryStagesSetup(mapName, storyStage)
        
        case "Oasis":
            BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Oasis Story Stage", "info")
            SendInput("{WheelDown 4}")
                        Sleep(1000)

            BetterClick(240, 379) 
            StoryStagesSetup(mapName, storyStage)

        case "Harge Forest":
            BetterClick(309, 203)
            Sleep(1000)
            LogMessage("Selected Harge Forest Story Stage", "info")
            SendInput("{WheelDown 4}")
                        Sleep(1000)

            BetterClick(239, 424)
            StoryStagesSetup(mapName, storyStage)

        case "Babylon":
            LogMessage("Selected Babylon Story Stage", "info")
            Sleep(1000)
             SendInput("{WheelDown 5}")
                         Sleep(1000)

            BetterClick(243, 348)  
            StoryStagesSetup(mapName, storyStage)

        case "Shinjuku":
            LogMessage("Selected Shinjuku Story Stage", "info")
            Sleep(1000)
             SendInput("{WheelDown 5}")
                         Sleep(1000)

            BetterClick(238, 387)  
            StoryStagesSetup(mapName, storyStage)
        

        case "Train Station":
            LogMessage("Selected Train Station Story Stage", "info")
            Sleep(1000)
             SendInput("{WheelDown 5}")
                         Sleep(1000)

            BetterClick(240, 434) 
            StoryStagesSetup(mapName, storyStage)
        default:
            LogMessage("Unknown story map: " . mapName, "error")
    }
}



StoryStagesSetup(mapName, storyStage) {
    global StoryMaps, StoryStages
    
    switch (storyStage) {
        case "1":
            LogMessage("Setting up Story Stage 1 for map: " . mapName, "info")
            BetterClick(398, 207)  ; Clicks on the map for Stage 1
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
            
        case "2":
            LogMessage("Setting up Story Stage 2 for map: " . mapName, "info")
            BetterClick(434, 205)  ; Clicks on the map for Stage 2
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
            
        case "3":
            LogMessage("Setting up Story Stage 3 for map: " . mapName, "info")
            BetterClick(469, 206)  ; Clicks on the map for Stage 3
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
            
        case "4":
            LogMessage("Setting up Story Stage 4 for map: " . mapName, "info")
            BetterClick(505, 203)
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
            
        case "5":
            LogMessage("Setting up Story Stage 5 for map: " . mapName, "info")
            BetterClick(542, 204) 
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
            
        case "6":
            LogMessage("Setting up Story Stage 6 for map: " . mapName, "info")
            BetterClick(575, 207)
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
            
            
        case "Infinite":
            LogMessage("Setting up Infinite Story Stage for map: " . mapName, "info")
            BetterClick(608,  206)
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(724, 478)  ; Click the start button
            MainTerminal()
            
        default:
            LogMessage("Unknown story stage: " . storyStage, "error")


    }
}

StoryMovement(mapName) {
    switch (mapName) {
        case "Hog Town":
            LogMessage("Executing Hog Town movement", "info")
            SendInput("{S down}")
            Sleep(3000)  ; Hold S for 3 seconds to move
            SendInput("{S up}")
            return
        case "Hollow Night Palace":
            ; Walking Movement Script Generated by AHK

Sleep(750)
Send("{w down}")
Sleep(453)
Send("{w up}")
Sleep(704)
Send("{d down}")
Sleep(5906)
Send("{d up}")
Sleep(765)
Send("{w down}")
Sleep(844)
Send("{w up}")
return
        case "Firefighters Base":
            LogMessage("Executing Firefighters Base movement", "info")
            ; Walking Movement Script Generated by AHK

Sleep(984)
Send("{w down}")
Sleep(1328)
Send("{w up}")
Sleep(547)
Send("{a down}")
Sleep(563)
Send("{a up}")
Sleep(515)
Send("{w down}")
Sleep(1657)
Send("{w up}")
Sleep(531)
Send("{d down}")
Sleep(781)
Send("{d up}")
Sleep(672)
Send("{w down}")
Sleep(1578)
Send("{w up}")
Sleep(250)
Send("{a down}")
Sleep(1719)
Send("{a up}")

            return
        case "Demon Skull Village":
            LogMessage("Executing Demon Skull Village movement", "info")
            ; Walking Movement Script Generated by AHK

Sleep(1297)
Send("{s down}")
Sleep(735)
Send("{s up}")
Sleep(406)
Send("{d down}")
Sleep(672)
Send("{d up}")
Sleep(406)
Send("{s down}")
Sleep(266)
Send("{s up}")
Sleep(390)
Send("{d down}")
Sleep(891)
Send("{d up}")
Sleep(156)
Send("{s down}")
Sleep(281)
Send("{s up}")
Sleep(375)
Send("{d down}")
Sleep(469)
Send("{d up}")
return
        case "Abandoned Cathedral":
            LogMessage("Executing Abandoned Cathedral movement", "info")
            ; Walking Movement Script Generated by AHK

Sleep(938)
Send("{a down}")
Sleep(1031)
Send("{a up}")
Sleep(531)
Send("{w down}")
Sleep(2656)
Send("{w up}")
Sleep(375)
Send("{a down}")
Sleep(953)
Send("{a up}")
Sleep(313)
Send("{w down}")
Sleep(2312)
Send("{w up}")
Sleep(282)
Send("{a down}")
Sleep(328)
Send("{a up}")
Sleep(453)
Send("{w down}")
Sleep(1937)
Send("{w up}")
return

            ; Walking Movement Script Generated by AHK
        case "Soul Society":
            LogMessage("Executing Soul Society movement", "info")
            Sleep(1000)
            ; Walking Movement Script Generated by AHK

Sleep(937)
Send("{d down}")
Sleep(1110)
Send("{d up}")
Sleep(453)
Send("{s down}")
Sleep(3906)
Send("{s up}")
Sleep(313)
Send("{a down}")
Sleep(1531)
Send("{a up}")
Sleep(1656)
Send("{a down}")
Sleep(47)
Send("{a up}")
return
        case "Dragon Heaven":
            LogMessage("Executing Dragon Heaven movement", "info")
            ; Walking Movement Script Generated by AHK

Sleep(750)
Send("{d down}")
Sleep(1719)
Send("{d up}")
Sleep(656)
Send("{d down}")
Sleep(8375)
Send("{d up}")
return

        default:
            LogMessage("No movement defined for map: " . mapName, "info")
            return
    }
}
