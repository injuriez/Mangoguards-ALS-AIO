; Raids Macro Configuration
; This file contains all raid-specific setup and functionality

; Raids Maps - declared as global for manager access
global RaidsMaps := ["Marines Fort", "Hell City", "Snowy Capital", "Leaf Village", "Wanderneich", "Central City", "Giants District (Town)", "Flying Island", "U-18", "Flower Garden", "Ancient Dungeon", "Shinjuku Crater", "Valhalla Arena", "Frozen Planet"]

; Raids UI Elements (will be created by main ALS.ahk)
global StageLabel
global NumberDropDown

; Setup UI elements for Raids
SetupRaidsUI(gui, x, y) {
    global StageLabel, NumberDropDown
    
    StageLabel := gui.Add("Text", "x" . x . " y" . y . " w80 h15 cFFFFFF", "Stage:")
    NumberDropDown := gui.Add("DropDownList", "x" . x . " y" . (y + 20) . " w80 cFFFFFF -E0x200 +Theme", ["1", "2", "3", "4", "5", "6"])
    NumberDropDown.SetFont("s10 Bold", "Segoe UI")
    NumberDropDown.OnEvent("Change", SaveNumberSelection)
    
    ; Initially hide elements
    StageLabel.Visible := false
    NumberDropDown.Visible := false
}

; Show Raids UI
ShowRaidsUI() {
    global StageLabel, NumberDropDown
    StageLabel.Visible := true
    NumberDropDown.Visible := true
    LoadNumberSelection()
}

; Hide Raids UI
HideRaidsUI() {
    global StageLabel, NumberDropDown
    StageLabel.Visible := false
    NumberDropDown.Visible := false
}

; Save number selection for raids
SaveNumberSelection(*) {
    global NumberDropDown
    if (NumberDropDown) {
        try {
            FileOpen(A_ScriptDir . "\libs\settings\raids\Number.txt", "w", "UTF-8").Write(NumberDropDown.Text)
        } catch {
            ; Error saving raid stage
        }
    }
}

; Load saved number selection for raids
LoadNumberSelection() {
    global NumberDropDown
    numberFile := A_ScriptDir . "\libs\settings\raids\Number.txt"
    if (FileExist(numberFile)) {
        try {
            savedNumber := FileRead(numberFile)
            ; Find the index of the saved number in the dropdown list
            for index, value in ["1", "2", "3", "4", "5", "6"] {
                if (value == savedNumber) {
                    NumberDropDown.Choose(index)
                    break
                }
            }
        } catch {
            ; If there's an error reading the file, default to "1"
            NumberDropDown.Choose(1)
        }
    } else {
        ; If no saved file exists, default to "1"
        NumberDropDown.Choose(1)
    }
}


StartRaidMacro(selectedMap) {
    global X1, Y1, X2, Y2, SelectText
    SelectText := "|<>*134$58.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxztzzzk7zzXz3zzz07zyDwDzzw0Dzszkzzzk0zzzz3zzz7XzyTYDzzwSD2Ms0kDzlss0XU20zz0302A08nzw0A8MlkVzzk1llX720zz0376AQQ3zwSA8MkVy7zlsk1XU68Tz7XU6C0M3zyzDaNyNkTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"

    Sleep(2000)
    BetterClick(40, 394)  ; Clicks teleport button 
    Sleep(1000)
    BetterClick(666, 296)  ; scroll bar
    Sleep(1000)  ; Wait for menu to fully appear
    SendInput("{WheelDown 2}")  ; Scroll down

    Sleep(1000)
    
    BetterClick(501, 418)  ; Click on the raid maps section
    Sleep(500)
    BetterClick(642, 127)  ; Close the teleport menu
    Sleep(500)
    
    ; Move to raid area with improved reliability
    
    ; Ensure all keys are released first
    SendInput("{A up}")
    Sleep(100)
    
    ; Hold A key with better timing
    SendInput("{A down}")
    Sleep(5000)  ; Hold A key to walk forward
    SendInput("{A up}")
    
    ; Wait for raid selection screen
    loop {
        if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, SelectText)) {
            MangoLookForMap(selectedMap)
            break
        } else {
            Sleep(500)
            Sleep(2000)
            ; Retry the same sequence with improved scrolling
            closeUI("Raids")
        }
    }
}

; Stop Raids macro
StopRaidsMacro() {
    ; Add raid stop logic here
}


HandleRaidMap(MapName){
    BetterClick(309, 207)  ; hovers over scrollbar
    Sleep(1000)

    switch (MapName) {
        case "Marines Fort":
            BetterClick(239, 212)
            SetupMap(MapName)
            
        case "Hell City":
            BetterClick(243, 256)
            SetupMap(MapName)
            
        case "Snowy Capital":
            BetterClick(238, 302)
            SetupMap(MapName)
            
        case "Leaf Village":
            BetterClick(237, 347)
            SetupMap(MapName)
            
        case "Wanderneich":
            BetterClick(242, 390)
            SetupMap(MapName)

        case "Central City":
            BetterClick(239, 433)
            SetupMap(MapName)

        case "Giants District (Town)":
            ; scroll down a tiny bit
            BetterClick(243, 209)
            SendInput("{WheelDown}")
            Sleep(500)
            BetterClick(236, 342)
            SetupMap(MapName)
          
        case "Flying Island":
             BetterClick(243, 209)
            SendInput("{WheelDown}")
            Sleep(500)
            BetterClick(234, 388)
            SetupMap(MapName)
        
          
         

        case "U-18":
            BetterClick(243, 209)
            SendInput("{WheelDown}")
            Sleep(500)
            BetterClick(247, 435)
            SetupMap(MapName)

        case "Flower Garden":
            SendInput("{WheelDown 2}")
            Sleep(2000)
            BetterClick(239, 340)
            SetupMap(MapName)

        case "Ancient Dungeon":
            SendInput("{WheelDown 2}")
            Sleep(2000)
            BetterClick(239, 386)
            SetupMap(MapName)

        case "Shinjuku Crater":
            SendInput("{WheelDown 2}")
            Sleep(2000)
            BetterClick(235, 426)
            SetupMap(MapName)

        case "Valhalla Arena":
            SendInput("{WheelDown 3}")
            Sleep(2000)

            BetterClick(241, 384)
            SetupMap(MapName)

        case "Frozen Planet": 
            BetterClick(243, 209)
            SendInput("{WheelDown 5}")
            Sleep(500)
            BetterClick(235, 435)
            SetupMap(MapName)
              default:
            ; Unknown raid map
    }
}
