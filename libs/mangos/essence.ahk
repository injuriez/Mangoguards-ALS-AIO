; Essence Macro Configuration
; This file contains all essence-specific setup and functionality

; Global variables for Essence macro
global EssenceMaps := ["Fire", "Water", "Light", "Dark", "Nature"]
global EssenceDifficulties := ["Normal", "Nightmare", "Purgatory", "Insanity"]
global EssenceDifficultyLabel := ""
global EssenceDifficultyDropDown := ""

EssenceSetupUI(gui, x, y) {
    global EssenceDifficultyLabel, EssenceDifficultyDropDown, EssenceDifficulties
    
    ; Setup UI elements specific to Essence
    EssenceDifficultyLabel := gui.Add("Text", "x" . x . " y" . y . " w80 h15 cFFFFFF", "Difficulty:")
    EssenceDifficultyDropDown := gui.Add("DropDownList", "x" . x . " y" . (y + 20) . " w120 cFFFFFF -E0x200 +Theme", EssenceDifficulties)
    EssenceDifficultyDropDown.SetFont("s9 Bold", "Segoe UI")
    EssenceDifficultyDropDown.OnEvent("Change", EssenceSaveSettings)
    
    ; Initially hide elements
    EssenceDifficultyLabel.Visible := false
    EssenceDifficultyDropDown.Visible := false
}

EssenceShowUI() {
    global EssenceDifficultyLabel, EssenceDifficultyDropDown
    
    EssenceDifficultyLabel.Visible := true
    EssenceDifficultyDropDown.Visible := true
    EssenceLoadSettings()
    LogMessage("Essence UI elements shown", "info")
}

EssenceHideUI() {
    global EssenceDifficultyLabel, EssenceDifficultyDropDown
    
    EssenceDifficultyLabel.Visible := false
    EssenceDifficultyDropDown.Visible := false
}

EssenceLoadSettings() {
    global EssenceDifficultyDropDown
    
    settingsFile := A_ScriptDir . "\libs\settings\Difficulty.txt"
    if (FileExist(settingsFile)) {
        try {
            savedDifficulty := FileRead(settingsFile)
            if (savedDifficulty != "" && EssenceDifficultyDropDown) {
                ; Find and select the saved difficulty
                loop EssenceDifficultyDropDown.Length {
                    if (EssenceDifficultyDropDown.GetText(A_Index) == savedDifficulty) {
                        EssenceDifficultyDropDown.Choose(A_Index)
                        break
                    }
                }
            }        } catch {
            LogMessage("Error loading essence settings", "warning")
        }
    }
}

EssenceSaveSettings(*) {
    global EssenceDifficultyDropDown
    
    if (EssenceDifficultyDropDown) {
        selectedDifficulty := EssenceDifficultyDropDown.Text
        try {
            FileOpen(A_ScriptDir . "\libs\settings\Difficulty.txt", "w", "UTF-8").Write(selectedDifficulty)
            LogMessage("Saved essence difficulty: " . selectedDifficulty, "info")
        } catch {
            LogMessage("Error saving essence difficulty", "error")
        }
    }
}

EssenceStartMacro(selectedMap, selectedDifficulty := "Normal") {
    Inessence := "|<>*135$104.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzjzzzzzzzzzzzxzzk0lzzzzzzzzzzzyDzw04Tzzzzzzzz7zzXzz017zzzzzzzzlzzszzk0lzzzzzzzzwTzyDzwTwTzzzzzzzy0zzXzz7z7kC8sy1l70D2Mzzk3ls1U070A0k3U2Dzw0wQ0M00U3060k0Xzz0D776448skllw8Mzzlzlk1XXU0AQAT76DzwTwQ0Mss037X7llXzz7z77yCC8zlskw8Mzzk0kE3XXW0QSA7063zw0A60Mssk37XVs1Uzz03nkDDDC1ntyTaSTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy"
    global X1, Y1, X2, Y2
    
    LogMessage("Starting Essence macro for: " . selectedMap . " (Difficulty: " . selectedDifficulty . ")", "info")
    
    ; Different navigation for essence farming
    Sleep(1000)
    BetterClick(40, 394)  ; Clicks teleport button
    Sleep(300)
    MouseMove(407, 297)  ; Hovers over teleport menu
   
    BetterClick(495, 383)  ; Click on essence section (placeholder coordinates)
    Sleep(500)
    BetterClick(642, 127)  ; Close teleport menu
    
    ; Move to essence area (different movement pattern)
    LogMessage("Sending W key down...", "debug")
    SendInput("{w down}")
    Sleep(1000)  ; Extended W movement duration to make it very visible
    LogMessage("Sending W key up...", "debug") 
    SendInput("{w up}")
    LogMessage("W movement completed, starting A movement (left)...", "info")
    Sleep(1000)
    LogMessage("Sending A key down...", "debug")
    SendInput("{a down}")
    Sleep(2938)
    LogMessage("Sending A key up...", "debug")
    SendInput("{a up}")
    LogMessage("A movement completed.", "info")

    loop {
        if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Inessence)) {
            LogMessage("Successfully detected essence selection screen!", "info")
            LogMessage("Loading Selected Essence Map: " . selectedMap, "info")
            SelectEssence(selectedMap)
            ; detect which essences are available to farm

            break
        } else {
            LogMessage("Essence selection not found, retrying navigation...", "warning")
            Sleep(2000)
            
            ; Retry the same sequence using Inessence
            BetterClick(810, 165) ;closes ui from other stuff
            Sleep(500)
            BetterClick(793, 165) ;closes ui from other stuff
            Sleep(500)
            BetterClick(837, 507) ;closes ui from other stuf
            Sleep(1000)
            BetterClick(40, 394)
            Sleep(300)
            MouseMove(407, 297)
            BetterClick(495, 383)  ; Click on essence section (placeholder coordinates)
            Sleep(500)
            BetterClick(642, 127)
            ; Retry walking movement
            MoveCamera()

            Sleep(1000)
            Send("{w down}")
            Sleep(1000)  ; Extended retry W movement duration to make it very visible
            Send("{w up}")
            Sleep(1000)
            Send("{a down}")
            Sleep(2938)
            Send("{a up}")
            
            ; Continue loop to check Inessence again
        }
    }    ; Look for essence selection interface
    MangoLookForMap(selectedMap, selectedDifficulty)
}

EssenceStopMacro() {
    LogMessage("Stopping Essence macro", "info")
    ; Add essence stop logic here
}

SelectEssence(essence){
    ; Override global coordinates with fixed coordinates for essence pixel search ONLY
    global X1 := 200  ; Relative to positioned window
    global Y1 := 200
    global X2 := 1000
    global Y2 := 700

    LogMessage("SelectEssence called for: " . essence, "info")
    LogMessage("Using essence coordinates: " . X1 . "," . Y1 . " to " . X2 . "," . Y2, "info")

    switch (essence)
    {        case "Water":
            ; Using Pixel function: Pixel(color, x1, y1, addx1, addy1, variation)
            ; Search for water color using fixed coordinates
            if Pixel(0x2094DC, X1, Y1, X2, Y2, 10) {
                BetterClick(foundX, foundY)  ; Click on the water essence

            } else {
                MsgBox("Water essence not found.")
            }        case "Light":
            if Pixel(0x2094DC, X1, Y1, X2, Y2, 10) {
                MouseMove(foundX, foundY)
                BetterClick(foundX, foundY)  ; Click on the light essence

            } else {
                MsgBox("Light essence not found.")
            }        case "Dark":
                  Text:="|<>*37$43.zzzrzzvttznzztwMztzzwyQEY732TD00111DbU44X4btYm2HaHw2N09sAz3hYCy6TzzzzzzzzzzzzzzzzzzzzzU"

                  if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Text)) {
                    BetterClick(X, Y)  ; Click on the dark essence
                  }              case "Nature":
            if Pixel(0x8CC24E, X1, Y1, X2, Y2, 10) {
                MouseMove(foundX, foundY)
                BetterClick(foundX, foundY)  ; Click on the nature essence

            } else {
                MsgBox("Nature essence not found.")
            }          case "Fire":
             if Pixel(0xE9540E, X1, Y1, X2, Y2, 10) {
                MouseMove(foundX, foundY)
                BetterClick(foundX, foundY)  ; Click on the fire essence

            } else {
                MsgBox("Fire essence not found.")
            }
        default: 
            MsgBox("Unknown essence type: " . essence)
            return
    }
}

; Handle the Essence map selection based on the map name
HandleEssenceMap(MapName, selectedDifficulty) {
    BetterClick(309, 207)  ; hovers over scrollbar
    Sleep(1000)

    switch (MapName) {
        case "Fire":
            BetterClick(239, 212)
            SetupEssenceMap(MapName, selectedDifficulty)
            
        case "Water":
            BetterClick(243, 256)
            SetupEssenceMap(MapName, selectedDifficulty)
            
        case "Light":
            BetterClick(245, 307)
            SetupEssenceMap(MapName, selectedDifficulty)
            
        case "Dark":
            BetterClick(236, 352)
            SetupEssenceMap(MapName, selectedDifficulty)
            
        case "Nature":
            BetterClick(240, 398)
            SetupEssenceMap(MapName, selectedDifficulty)
            
        default:
            LogMessage("Unknown Essence map: " . MapName, "error")
    }
}

; Setup the essence map with proper difficulty selection
SetupEssenceMap(MapName, selectedDifficulty) {
    LogMessage("Setting up Essence map: " . MapName . " with difficulty: " . selectedDifficulty, "info")
    
    ; Click to select map
    BetterClick(420, 300)
    Sleep(500)
    
    ; Select difficulty based on parameter
    switch (selectedDifficulty) {
        case "Normal":
            BetterClick(233, 345)
        case "Nightmare":
            BetterClick(347, 345)
        case "Purgatory":
            BetterClick(466, 345)
        case "Insanity":
            BetterClick(578, 345)
        default:
            LogMessage("Unknown difficulty: " . selectedDifficulty . ", using Normal", "warning")
            BetterClick(233, 345)  ; Default to Normal
    }
    
    Sleep(500)
    BetterClick(420, 420)  ; Start button
}

; Implements the essence-specific map search functionality
EssenceLookForMap(selectedMap, selectedDifficulty) {
    LogMessage("Looking for Essence map: " . selectedMap . " with difficulty: " . selectedDifficulty, "info")
    
    ; First call the shared manager implementation to setup coordinates
    MangoLookForMap(selectedMap, selectedDifficulty)
    
    ; Perform map selection based on the map name
    SelectEssence(selectedMap)
    
    ; Apply difficulty settings
    Sleep(500)
    
    ; Set difficulty based on parameter
    switch (selectedDifficulty) {
        case "Normal":
            BetterClick(233, 345)
        case "Nightmare":
            BetterClick(347, 345)
        case "Purgatory":
            BetterClick(466, 345)
        case "Insanity":
            BetterClick(578, 345)
        default:
            LogMessage("Unknown difficulty: " . selectedDifficulty . ", using Normal", "warning")
            BetterClick(233, 345)  ; Default to Normal
    }
    
    ; Start the essence run
    Sleep(500)
    BetterClick(420, 420)  ; Start button
}
