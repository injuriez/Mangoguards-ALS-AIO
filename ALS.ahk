#Requires Autohotkey v2

; Global startup check variable - initialize early to prevent timing issues
global StartupUpdateCheckDone := false

; #Include libs\Winter\Namek\lobby.ahk  ; Commented out until file exists
#Include %A_ScriptDir%\libs\webhook.ahk
#Include %A_ScriptDir%\libs\Placement\movement\module.ahk
#Include %A_ScriptDir%\libs\FindText.ahk
#Include %A_ScriptDir%\libs\Pixel.ahk
#Include %A_ScriptDir%\libs\Placement\main.ahk
#Include %A_ScriptDir%\libs\Placement\tech.ahk
#Include %A_ScriptDir%\libs\mangos\manager.ahk
#Include %A_ScriptDir%\libs\mangos\Portals.ahk
CoordMode("Mouse", "Window")  ; Set mouse coordinate      
global isLoadingSettings := false

global ActivityLogText
global isPaused := false
global Wins := 0
global Losses := 0
global Disconnects := 0
global TotalRuns := 0
global foundX := 0
global foundY := 0

; Global curse variables
global SelectedCurses := []
global BaseCurses := ["Dull", "Nullify", "Blitz", "Regeneration", "Bankrupt", "Sluggish", "Endurance", "Weakened", "Equilibrium", "godless"]
global Survival
Curses := ["Powerless", "Bankrupt", "Sluggish", "Weakness", "True Boss Fight", "No one leaves alive"]



global X1 := 0
global Y1 := 0  
global X2 := 1920  
global Y2 := 1080 



global REPO_OWNER := "injuriez"  
global REPO_NAME := "Mangoguards-ALS-AIO"        
global CURRENT_VERSION := "v1.0.5"       


; Global mango maps structure
global MangoMaps := Map()
global MangoDropDown
global DropDownList2


myGui := Gui("+AlwaysOnTop -Caption", "Mango")
myGui.BackColor := "0x111111"

; Initialize the modular mango system
MangoManagerInitialize(myGui)


ui := myGui.Add("Progress", "c0x7e4141 x0 y30 h700 w1000", 100)
WinSetTransColor("0x7e4141 255", myGui)
myGui.SetFont("s10", "Segoe UI")



ActivityLogGroupBox := myGui.Add("GroupBox", "x1010 y570 w450 h160 cFFFFFF", "📜 Activity Log")
ActivityLogGroupBox.SetFont("s10 Bold", "Segoe UI")
ActivityLogText := myGui.Add("Edit", "x1020 y590 w270 h120 +Multi +ReadOnly -E0x200 -Border -VScroll", "Macro Launched")
ActivityLogText.SetFont("s9", "Segoe UI")
ActivityLogText.Opt("+Background" . "0x111113" . " c" . "FFFFFF")

KeybindsGroupBox := myGui.Add("GroupBox", "x1010 y30 w220 h150 cFFFFFF", "⌨️ Keybinds")
KeybindsGroupBox.SetFont("s10 Bold", "Segoe UI")
KeybindsText := myGui.Add("Text", "x1020 y45 w200 h90 cFFFFFF", " F1 - Fix Roblox Position `n F2 - Start Macro `n F3 - Stop Macro `n F4 - Pause/Unpause `n F5 - Get Coordinates `n F6 - Test Movement")
KeybindsText.SetFont("s9", "Segoe UI")

; Raid Maps section (under keybinds)
RaidMapsGroupBox := myGui.Add("GroupBox", "x1010 y180 w450 h150 cFFFFFF", "🗺️ Macros")
RaidMapsGroupBox.SetFont("s10 Bold", "Segoe UI")

; Utility Buttons section (right side, where raid maps used to be)
UtilityGroupBox := myGui.Add("GroupBox", "x1240 y30 w220 h150 cFFFFFF", "🔧 Utilities")
UtilityGroupBox.SetFont("s10 Bold", "Segoe UI")

; Settings Button
ButtonUtilSettings := myGui.Add("Text", "x1250 y50 w200 h25 +Center +0x200 cFFFFFF Background0xee6531", "⚙️ Settings")
ButtonUtilSettings.SetFont("s9 Bold", "Segoe UI")
ButtonUtilSettings.OnEvent("Click", OpenSettings)

; Check for Updates Button  
ButtonUpdates := myGui.Add("Text", "x1250 y85 w200 h25 +Center +0x200 cFFFFFF Background0x4CAF50", "🔄 Check for Updates")
ButtonUpdates.SetFont("s9 Bold", "Segoe UI")
ButtonUpdates.OnEvent("Click", CheckForUpdates)

; Guide Button
ButtonGuide := myGui.Add("Text", "x1250 y120 w200 h25 +Center +0x200 cFFFFFF Background0x2196F3", "📚 Guide")
ButtonGuide.SetFont("s9 Bold", "Segoe UI")
ButtonGuide.OnEvent("Click", OpenGuide)

; Hierarchical "Mango" System - Category Selection (inside Macros groupbox)
myGui.Add("Text", "x1020 y205 w120 h15 cFFFFFF", "Select Macros:")
MangoDropDown := myGui.Add("DropDownList", "x1020 y225 w200 cFFFFFF -E0x200 +Theme", [
    "Raids",
    "Dungeon", 
    "Essence",
    "Boss Rush (WIP)",
    "Survival",
    "Legend Stages",
    "Portals",
    "Story"

])
MangoDropDown.SetFont("s9 Bold", "Segoe UI")
MangoDropDown.OnEvent("Change", OnMangoChange)

; Map Selection (populated based on category selection)
myGui.Add("Text", "x1020 y255 w120 h15 cFFFFFF", "Select Option:")
DropDownList2 := myGui.Add("DropDownList", "x1020 y275 w200 cFFFFFF -E0x200 +Theme", ["Select a category first..."])
DropDownList2.OnEvent("Change", SaveSelection)

; Number dropdown under the map selection (only visible for Raids)
; UI elements are now handled by individual macro classes in MangoManager

; Note: All macro-specific UI elements (Stage, Difficulty, Curse, Legend Stage) 
; are now created and managed by their respective macro classes

; Initially all macro UI elements are hidden by default

; Boss Rush controls removed - now using main dropdown
isLoadingSettings := true

; Load saved category selection
LoadCategorySelection()

; Load saved map selection  
LoadMapSelection()

; Note: Individual macro settings are now loaded by MangoManager when switching modes
; Use MangoManagerLoadAllSettings() instead of individual calls
MangoManagerLoadAllSettings()
isLoadingSettings := false

SaveSelection(*) {
    global DropDownList2, MangoDropDown
    FileOpen(A_ScriptDir . "\libs\settings\Map.txt", "w", "UTF-8").Write(DropDownList2.Text) ; Overwrite the file with the new selection
      ; If Boss Rush is selected, also save to BossRush.txt
    if (MangoDropDown.Text == "Boss Rush (WIP)") {
        SaveBossRushSelection()
    }
      ; If Survival is selected, also save to Survival.txt
    if (MangoDropDown.Text == "Survival") {
        FileOpen(A_ScriptDir . "\libs\settings\survival\Survival.txt", "w", "UTF-8").Write(DropDownList2.Text)
    }
}

SaveCategorySelection(*) {
    global MangoDropDown
    FileOpen(A_ScriptDir . "\libs\settings\Category.txt", "w", "UTF-8").Write(MangoDropDown.Text) ; Save the selected category
}

; Note: Individual save functions (SaveNumberSelection, SaveDifficultySelection, etc.) 
; are now handled by their respective macro classes

SaveBossRushSelection(*) {
    global DropDownList2
    FileOpen(A_ScriptDir . "\libs\settings\bossrush\BossRush.txt", "w", "UTF-8").Write(DropDownList2.Text) ; Save the selected boss rush type from main dropdown
}

; Note: Individual load functions (LoadNumberSelection, LoadDifficultySelection, etc.)
; are now handled by their respective macro classes

LoadCategorySelection() {
    global MangoDropDown, isLoadingSettings
    categoryFile := A_ScriptDir . "\libs\settings\Category.txt"
    if (FileExist(categoryFile)) {
        try {
            savedCategory := FileRead(categoryFile)            ; Find the index of the saved category in the dropdown list
            for index, value in ["Raids", "Dungeon", "Essence", "Boss Rush (WIP)", "Survival", "Legend Stages"] {
                if (value == savedCategory) {
                    MangoDropDown.Choose(index)
                    ; Manually trigger OnMangoChange while loading flag is true
                    ; This populates the map dropdown without auto-selecting
                    OnMangoChange()
                    break
                }
            }
        } catch {
            ; If there's an error reading the file, don't select anything
        }
    }    ; If no saved file exists, don't select anything
}

; Set fonts for dropdown lists
DropDownList2.SetFont("s10 Bold", "Segoe UI")
DropDownList2.Opt("+Background0x222222")

; Note: Individual dropdown fonts are now set by their respective macro classes

; Statistics section (positioned under both Keybinds and Raid Maps)
StatisticsGroupBox := myGui.Add("GroupBox", "x1010 y330 w450 h90 cFFFFFF", "📊 Statistics")
StatisticsGroupBox.SetFont("s10 Bold", "Segoe UI")
WLText := myGui.Add("Text", "x1020 y350 w430 h15 cFFFFFF", "⚔️ W/L: 0/0")
WLText.SetFont("s10 Bold", "Segoe UI")
DisconnectText := myGui.Add("Text", "x1020 y370 w430 h15 cFFFFFF", "🛜 Disconnects: 0")
DisconnectText.SetFont("s10 Bold", "Segoe UI")
TotalRunsText := myGui.Add("Text", "x1020 y390 w430 h15 cFFFFFF", "🏃‍♂️‍➡️ Total Runs: 0")
TotalRunsText.SetFont("s10 Bold", "Segoe UI")

BACKGROND := myGui.Add("Text", "x-16 y0 w1300 h25 Background2A2A2A", "") ; Full width background
fakebackground := myGui.Add("Text", "x-16 y0 w1500 h25 Background2A2A2A", "") ; Make width shorter to not overlap with close button
; topbar ----------------------------------
minimizeButton := myGui.Add("Picture", "x1410 y3 w23 h20 0x6 +BackgroundTrans", A_ScriptDir . "\libs\UIPARTS\Images\mini.png")
minimizeButton.OnEvent("Click", (*) => myGui.Minimize()) ; Minimize the GUI
closeButton := myGui.Add("Picture", "x1440 y3 w23 h20 0x6 +BackgroundTrans", A_ScriptDir . "\libs\UIPARTS\Images\close.png")
closeButton.OnEvent("Click", ExitHandler)


; Add a proper exit handler function
ExitHandler(*) {
    LogMessage("Application closing...")
    Sleep(200)  ; Give a moment for the log to update
    ExitApp()   ; Completely terminate the script
}
MangoLogo := myGui.Add("Picture", "x3 y-1 w35 h25 0x6 +BackgroundTrans", A_ScriptDir . "\libs\UIPARTS\Images\mango.png")
BACKGROND_TEXT := myGui.Add("Text", "x40 y-1 w250 h25 +BackgroundTrans cFFFFFF", "MangoGuards | " . CURRENT_VERSION)
BACKGROND_TEXT.SetFont("s14 Bold", "Karla")
BACKGROND.OnEvent("Click", DragWindow)
MangoLogo.OnEvent("Click", DragWindow)
BACKGROND_TEXT.OnEvent("Click", DragWindow)
DragWindow(*) {
    PostMessage(0xA1, 2,,, myGui)  
}
; ----------------------------------

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Mango"
myGui.Show("w1470 h735") 

; Automatically check for updates on startup
CheckForUpdatesOnStartup()


UpdateWLDisplay(result := "") {
    global Wins, Losses, Disconnects, TotalRuns, WLText, DisconnectText, TotalRunsText
    
    ; Update statistics based on game result
    if (result == "win") {
        Wins++
        TotalRuns++
        LogMessage("Game won! Total wins: " . Wins, "success")
    } else if (result == "loss") {
        Losses++
        TotalRuns++
        LogMessage("Game lost! Total losses: " . Losses, "warning")
    } else if (result == "disconnect") {
        Disconnects++
        TotalRuns++
        LogMessage("Disconnected! Total disconnects: " . Disconnects, "error")
    }
    
    ; Update the display with current statistics
    WLText.Value := "⚔️ W/L: " Wins "/" Losses
    DisconnectText.Value := "🔌 Disconnects: " Disconnects
    TotalRunsText.Value := "🏃 Total Runs: " TotalRuns
}

LogMessage(message, type := "info") {
    global ActivityLogText
    
    ; Check if ActivityLogText is initialized before trying to use it
    if (!IsSet(ActivityLogText) || !ActivityLogText) {
        ; If GUI is not ready, just return silently or output to console for debugging
        ; OutputDebug("[" . StrUpper(type) . "] " . message)
        return
    }
    
    ; Format the message with prefix and timestamp
    formattedTime := FormatTime(A_Now, "HH:mm:ss")
    
    ; Format with prefix
    prefix := "[" . StrUpper(type) . "] "
    formattedMessage := prefix . message
    
    ; Get current text
    currentText := ActivityLogText.Text
    
    ; Add new message at the beginning with spacing
    if (currentText != "") {
        ; Add the new message with spacing
        ActivityLogText.Text := formattedMessage . "`r`n`r`n" . currentText
    } else {
        ActivityLogText.Text := formattedMessage
    }
    
    ; Update the control to show bold text
    ActivityLogText.SetFont("s9 Bold", "Consolas")
}
OpenSettings(*) {
    Settingsui := Gui("+AlwaysOnTop") 
    Settingsui.Title := "Settings"
    Settingsui.BackColor := "0x111113"  ; Match main GUI background
    
    ; Row 1: Webhook and Placement buttons side by side
    DiscordWebhook := Settingsui.Add("Text", "x20 y20 w100 h30 +Center +0x200 cFFFFFF Background0xee6531", "Webhook")
    DiscordWebhook.SetFont("s10 Bold", "Segoe UI")
    DiscordWebhook.OnEvent("Click", OpenWebhookEditor)
    
    SlotMaker := Settingsui.Add("Text", "x130 y20 w100 h30 +Center +0x200 cFFFFFF Background0xee6531", "Placement")
    SlotMaker.SetFont("s10 Bold", "Segoe UI")
    SlotMaker.OnEvent("Click", OpenUnitManager)

    ; Row 2: Close button centered
    CloseButton := Settingsui.Add("Text", "x85 y70 w80 h30 +Center +0x200 cFFFFFF Background0xee6531", "Close")
    CloseButton.SetFont("s10 Bold", "Segoe UI")
    CloseButton.OnEvent("Click", (*) => Settingsui.Destroy())
    
    ; Show the settings GUI with adjusted dimensions for flex layout
    Settingsui.Show("w250 h120")
}

OpenHotkeySettings(*) {
    HotkeyUI := Gui("+AlwaysOnTop")
    HotkeyUI.Title := "Hotkey Settings"
    HotkeyUI.BackColor := "0x111113"
    
    HotkeyUI.SetFont("s10", "Segoe UI")
    HotkeyUI.Add("Text", "x10 y10 w300 cFFFFFF", "Current Hotkeys:")
    HotkeyUI.Add("Text", "x10 y35 w300 cFFFFFF", "F1 - Fix Roblox Position")
    HotkeyUI.Add("Text", "x10 y55 w300 cFFFFFF", "F2 - Start Macro")
    HotkeyUI.Add("Text", "x10 y75 w300 cFFFFFF", "F3 - Stop/Reload Macro")
    HotkeyUI.Add("Text", "x10 y95 w300 cFFFFFF", "F4 - Pause/Unpause Macro") 
    HotkeyUI.Add("Text", "x10 y115 w300 cFFFFFF", "F5 - Debug Unit Placement")
       HotkeyUI.Add("Text", "x10 y125 w300 cFFFFFF", "To change hotkeys, edit the script directly.")
      closeButton := HotkeyUI.Add("Text", "x110 y160 w80 h30 +Center +0x200 cFFFFFF Background0xee6531", "Close")
    closeButton.SetFont("s10 Bold", "Segoe UI")
    closeButton.OnEvent("Click", (*) => HotkeyUI.Destroy())
    
    HotkeyUI.Show("w320 h200")
}

OpenWebhookEditor(*) {
    try {
        ; Check if Webhook Editor is already open
        if WinExist("MangoGuards Webhook Editor") {
            WinActivate("MangoGuards Webhook Editor")
            return
        }
        
        ; Create the webhook editor GUI
        CreateWebhookEditorGUI()
    } catch as err {
        LogMessage("Error opening Webhook Editor: " . err.Message, "error")
        MsgBox("Error opening Webhook Editor: " . err.Message)
    }
}

OpenUnitManager(*) {
    try {
        ; First check if Unit Manager is already running
        if WinExist("MangoGuards (Custom Placement)") {
            WinActivate("MangoGuards (Custom Placement)")
            return
        }
        
        ; Simple approach - just run the executable directly
        unitManagerExe := A_ScriptDir . "\libs\UIPARTS\unitmanager.ahk"
        
        ; Log that we're launching the unit manager
        LogMessage("Opening Unit Placement Manager...", "info")
        
        ; Check if the executable exists
        if (!FileExist(unitManagerExe)) {
            LogMessage("Unit Manager executable not found: " . unitManagerExe, "error")
            MsgBox("Error: Unit Manager executable not found at: " . unitManagerExe)
            return
        }
        
        ; Simply run the executable
        Run('"' . unitManagerExe . '"')
        LogMessage("Unit Manager launched successfully", "info")
        
    } catch as err {
        LogMessage("Error opening Unit Manager: " . err.Message, "error")
        MsgBox("Error opening Unit Manager: " . err.Message)
    }
}

start() {
    ; Use coordinates from FixPositions() function - they cover the exact Roblox window
    ; If FixPositions() hasn't been called, use default values
    global X1, Y1, X2, Y2
    if (!X1) {
        global X1 := 0
        global Y1 := 0  
        global X2 := 1000
        global Y2 := 700
    }

    UnitsText := "|<>*134$37.zw00DzzzUTrzzzsRzzzbbwnzznXztzztlHc8Tws0Y4DyQWHCDzaH9b3zk9YlVzwCnQkxzzzzzwzzzzzzzzzzzzs"
    ChatOpen := "|<>*142$13.000000001zyzz00000z0zk01"

    if FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, ChatOpen) {
        LogMessage("Chat is open. Closing it...", "info")
        BetterClick(138, 28)  ; Clicks outside the chat to close it
        Sleep(500)
    }
    global isPaused
    
    ; Check if the macro is already running
    if (!isPaused) {
        LogMessage("Starting macro using MangoManager...", "info")
        
        ; Use MangoManager to start the current macro
        MangoManagerStartCurrentMacro()
    } else {
        LogMessage("Macro is paused. Press F4 to unpause.", "warning")
    }
}


MoveCamera() {
    Send("{Right down}")
    Sleep 800
    Send("{Right up}")
}







SetupMap(mapName := "") {
    number := FileOpen(A_ScriptDir . "\libs\settings\raids\Number.txt", "r", "UTF-8") 
    Stage := number.Read()
    
    Switch (Stage) {
        case "1":
            BetterClick(388, 205)  ; Click on Stage 1
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(722, 508)  ; Click the start button
            RobloxCharacterMove(mapName)
        case "2":
            BetterClick(340, 244)  ; Click on Stage 2
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(722, 508)  ; Click the start button
            RobloxCharacterMove(mapName)
        case "3":
            BetterClick(339, 282)  ; Click on Stage 3
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(722, 508)  ; Click the start button
            RobloxCharacterMove(mapName)
        case "4":
            BetterClick(342, 317)  ; Click on Stage 4
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(722, 508)  ; Click the start button
            RobloxCharacterMove(mapName)
        case "5":
            BetterClick(339, 354)  ; Click on Stage 5
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(722, 508)  ; Click the start button
            RobloxCharacterMove(mapName)
        case "6":
            BetterClick(339, 393)  ; Click on Stage 6
            Sleep(500)  ; Wait for the stage to load
            BetterClick(499, 490)  ; Click on select button
            Sleep(1000)  ; Wait for the select button to be ready
            BetterClick(722, 508)  ; Click the start button
            RobloxCharacterMove(mapName)
        default:
            LogMessage("Unknown stage: " . Stage, "error")
    }

}
; These maps that are in the list require the user to move to a different spot

RobloxCharacterMove(MapName := "") {
    Loaded := "|<>*122$37.00000000000000000007000007zU0w066E0G023DztU133zsMDkV04DzsN03DzxAa7bzy68Hlzz7aBwzzzzzzzzzzzzzzzzzzzzzzzzzz"

    switch (MapName) {
        case "Central City":
            LogMessage("Central City requires specific character movement.", "info")
            loop {
                if FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Loaded) {
                    LogMessage("Character is loaded in Central City.", "info")
                    ZoomTech(false)  ; Disable camera zoom for Central City
                    Sleep(500)
                    LogMessage("Moving...", "info")
                    CentralCity()  ; Call Central City specific movement function
                    MainTerminal()  ; Call the main terminal function after moving
                    
                    break
                } else {
                    LogMessage("Waiting for character to load in Central City...", "warning")
                    Sleep(1000)  ; Wait before retrying
                }
            }

        case "U-18":
            LogMessage("U-18 requires specific character movement.", "info")
            loop {
                if FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Loaded) {
                    LogMessage("Character is loaded in U-18.", "info")
                    ZoomTech(false)  ; Disable camera zoom for Central City

                    Sleep(500)
                    LogMessage("Moving...", "info")
                    U18Movement()  ; Call U-18 specific movement function
                    MainTerminal()  ; Call the main terminal function after moving
                    break
                } else {
                    LogMessage("Waiting for character to load in U-18...", "warning")
                    Sleep(1000)  ; Wait before retrying
                }
            }

        default:
            loop {
                if FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Loaded) {
                    LogMessage("Character is loaded in " . MapName, "info")
                    ; ZoomTech(false)  ; Disable camera zoom for the current map

                    Sleep(500)
                    LogMessage("Moving...", "info")
                    MainTerminal()
                    break
                } else {
                    LogMessage("Waiting for character to load in " . MapName, "warning")
                    Sleep(1000)  ; Wait before retrying
                }
            }
    }
}


F2:: {
    start()
}
F3::Reload
F1::FixPositions()
F4::PauseMacro()
F5::MainTerminal()


TestMovement() {
    LogMessage("Testing movement keys...", "info")
    
    ; Ensure Roblox window is active
    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
    if WinExist(RobloxWindow) {
        WinActivate(RobloxWindow)
        Sleep(500)
        LogMessage("Roblox window activated for testing", "debug")
    }
      LogMessage("Testing W key (forward movement) for 3 seconds...", "info")
    SendInput("{w down}")
    Sleep(3000)
    SendInput("{w up}")
    LogMessage("W key test completed", "info")
    
    Sleep(1000)
    
    LogMessage("Testing A key (left movement) for 3 seconds...", "info")
    SendInput("{a down}")
    Sleep(3000)
    SendInput("{a up}")
    LogMessage("A key test completed", "info")
}
PauseMacro() {
    global isPaused
    isPaused := !isPaused  ; Toggle the pause state
    if (isPaused) {
        Pause(true)  ; Pause the script
        LogMessage("Macro paused.")
    } else {
        Pause(false)  ; Resume the script
        LogMessage("Macro unpaused.")
    }
}


FixPositions() {
    ; Position Roblox window inside the progress bar area
    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
    
    ; Position GUI first
    myGui.Show("x50 y50")
    
    if !WinExist(RobloxWindow) {
        LogMessage("Roblox window not found!", "warning")
        Sleep(1000)
        return false
    } else {
        ; Remove Roblox window title bar
        RemoveWindowTitleBar(RobloxWindow)
        
        ; Get GUI position
        WinGetPos(&GuiX, &GuiY, &GuiW, &GuiH, myGui)
        
        ; Get actual progress bar position and dimensions dynamically
        ui.GetPos(&ProgX, &ProgY, &ProgW, &ProgH)
        
        ; Position Roblox window to fit perfectly inside the progress bar
        ; No need to account for title bar since we removed it
        RobloxX := GuiX + ProgX
        RobloxY := GuiY + ProgY
        RobloxW := ProgW
        RobloxH := ProgH
          WinActivate(RobloxWindow)
        WaitForRobloxReady(RobloxX, RobloxY, RobloxW, RobloxH)

        return true
    }
}

RemoveWindowTitleBar(WindowTitle) {
    ; Get window handle
    hwnd := WinExist(WindowTitle)
    if (!hwnd) {
        LogMessage("Window not found for title bar removal", "warning")
        return false
    }
    
    ; Get current window style
    currentStyle := DllCall("GetWindowLong", "Ptr", hwnd, "Int", -16, "UInt")
    
    ; Remove title bar, borders, and system menu (WS_CAPTION | WS_THICKFRAME | WS_SYSMENU)
    ; WS_CAPTION = 0x00C00000, WS_THICKFRAME = 0x00040000, WS_SYSMENU = 0x00080000
    newStyle := currentStyle & ~(0x00C00000 | 0x00040000 | 0x00080000)
    
    ; Apply new style
    DllCall("SetWindowLong", "Ptr", hwnd, "Int", -16, "UInt", newStyle)
      ; Force window to redraw with new style
    DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0027)
    
    return true
}
WaitForRobloxReady(x := 0, y := 0, w := 1016, h := 638) {
    robloxWin := WinExist("ahk_exe RobloxPlayerBeta.exe")
    if !WinExist(robloxWin) {
        LogMessage("Waiting for Roblox window...", "warning")
        Sleep(1000)
        return
    }

    WinGetPos(&currX, &currY, &currW, &currH, robloxWin)
      ; Only move if position is different (avoid unnecessary repositioning)
    if (currX != x || currY != y || currW != w || currH != h) {
        WinMove(x, y, w, h, robloxWin)
    }
    
    Sleep(100)  ; Short delay to ensure window is properly positioned
}

GetRobloxCoordinates() {
    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
      if WinExist(RobloxWindow) {
        WinGetPos(&RblxX, &RblxY, &RblxW, &RblxH, RobloxWindow)
        
        ; Update global coordinates to match exact window (screen coordinates)
        global X1 := RblxX
        global Y1 := RblxY
        global X2 := RblxX + RblxW  
        global Y2 := RblxY + RblxH
        
        return {X: RblxX, Y: RblxY, Width: RblxW, Height: RblxH}
    } else {
        LogMessage("Roblox window not found!", "error")
        return false
    }
}

; Map categorization structure for hierarchical selection


OnMangoChange(*) {
    global MangoDropDown, DropDownList2, isLoadingSettings
    
    selectedMango := MangoDropDown.Text
    
    ; Save the selected category only if not loading settings
    if (!isLoadingSettings) {
        SaveCategorySelection()
    }
      ; Get maps from the manager
    maps := MangoManagerGetMaps(selectedMango)
    
    if (maps.Length > 0) {
        ; Clear and repopulate the map dropdown
        DropDownList2.Delete()
        DropDownList2.Add(maps)
        
        ; Only auto-select the first map if not loading settings from startup
        if (!isLoadingSettings) {
            DropDownList2.Choose(1)
            SaveSelection() ; Auto-save the selection
        }          ; Switch to the selected macro type using the manager
        MangoManagerSwitchToMacro(selectedMango)
    } else {
        LogMessage("No maps found for macro type: " . selectedMango, "warning")
    }
}

; Load saved map selection on startup
LoadMapSelection() {
    global DropDownList2, MangoDropDown, isLoadingSettings
    mapFile := A_ScriptDir . "\libs\settings\Map.txt"
    
    if (FileExist(mapFile)) {
        try {
            savedMap := FileRead(mapFile)
            ; Find which mango category contains this map using the manager
            currentMango := MangoDropDown.Text
            maps := MangoManagerGetMaps(currentMango)
            
            if (maps.Length > 0) {
                DropDownList2.Delete()
                DropDownList2.Add(maps)
                
                ; Select the saved map if it exists in current category
                for index, map in maps {
                    if (map == savedMap) {
                        DropDownList2.Choose(index)
                        return
                    }
                }
            }
        } catch {
            LogMessage("Error loading saved map", "warning")
        }
    }
}

CheckForUpdates(*) {
    try {
        ; Get latest release from GitHub API
        apiUrl := "https://api.github.com/repos/" . REPO_OWNER . "/" . REPO_NAME . "/releases/latest"
        
        ; Create HTTP request
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", apiUrl, false)
        whr.SetRequestHeader("User-Agent", "MangoGuards-AutoUpdater")
        whr.Send()
        
        if (whr.Status = 200) {
            ; Parse JSON response
            responseText := whr.ResponseText
            
            ; Extract version tag (simple regex approach)
            if (RegExMatch(responseText, '"tag_name":\s*"([^"]+)"', &match)) {
                latestVersion := match[1]
                  ; Extract download URL - only look for ZIP files (complete package)
                downloadUrl := ""
                
                ; Look for a .zip file (complete package)
                if (RegExMatch(responseText, '"browser_download_url":\s*"([^"]*\.zip[^"]*)"', &downloadMatch)) {
                    downloadUrl := downloadMatch[1]
                }
                
                ; Compare versions
                if (CompareVersions(CURRENT_VERSION, latestVersion) < 0) {
                    ; New version available
                    if (downloadUrl != "") {
                        updateMessage := "A new version (" . latestVersion . ") is available!`n`nCurrent version: " . CURRENT_VERSION . "`nLatest version: " . latestVersion . "`n`n"
                        updateMessage .= "This will download and replace all files in the current directory.`n`nWould you like to download and install it now?"
                        
                        result := MsgBox(updateMessage, "Update Available", "YesNo Iconi")
                        
                        if (result = "Yes") {
                            DownloadAndInstallUpdate(downloadUrl, latestVersion, "zip")
                        }
                    } else {
                        ; No ZIP file found, direct to releases page
                        result := MsgBox("A new version (" . latestVersion . ") is available!`n`nCurrent version: " . CURRENT_VERSION . "`nLatest version: " . latestVersion . "`n`nNo automatic download available. Would you like to open the releases page to download manually?", "Update Available", "YesNo Iconi")
                        
                        if (result = "Yes") {
                            Run("https://github.com/" . REPO_OWNER . "/" . REPO_NAME . "/releases/latest")
                        }
                    }
                } else {
                    ; Already up to date
                    MsgBox("You are running the latest version (" . CURRENT_VERSION . ")", "Up to Date", "Iconi")
                }
            } else {
                MsgBox("Unable to check for updates. Please check manually at:`nhttps://github.com/" . REPO_OWNER . "/" . REPO_NAME . "/releases", "Update Check Failed", "Iconx")
            }
        } else {
            MsgBox("Unable to connect to GitHub to check for updates.`nHTTP Status: " . whr.Status . "`n`nPlease check your internet connection or visit:`nhttps://github.com/" . REPO_OWNER . "/" . REPO_NAME . "/releases", "Connection Error", "Iconx")
        }
    } catch as err {
        MsgBox("Error checking for updates: " . err.Message . "`n`nPlease check manually at:`nhttps://github.com/" . REPO_OWNER . "/" . REPO_NAME . "/releases", "Update Error", "Iconx")
    }
}

; Compare two version strings (returns -1 if v1 < v2, 0 if equal, 1 if v1 > v2)
CompareVersions(v1, v2) {
    ; Remove 'v' prefix if present
    v1 := RegExReplace(v1, "^v", "")
    v2 := RegExReplace(v2, "^v", "")
    
    ; Split versions into parts
    v1Parts := StrSplit(v1, ".")
    v2Parts := StrSplit(v2, ".")
    
    ; Compare each part
    maxParts := Max(v1Parts.Length, v2Parts.Length)
    
    Loop maxParts {
        part1 := (A_Index <= v1Parts.Length) ? Integer(v1Parts[A_Index]) : 0
        part2 := (A_Index <= v2Parts.Length) ? Integer(v2Parts[A_Index]) : 0
        
        if (part1 < part2) {
            return -1
        } else if (part1 > part2) {
            return 1
        }
    }
    
    return 0  ; Versions are equal
}

; Download and install update
DownloadAndInstallUpdate(downloadUrl, version, downloadType := "zip") {
    try {
        ; Create temporary download path
        tempDir := A_Temp . "\MangoGuards_Update"
        DirCreate(tempDir)
        
        ; Generate filename for ZIP
        fileName := "MangoGuards_" . version . ".zip"
        if (RegExMatch(downloadUrl, "[^/]+\.zip$", &match)) {
            fileName := match[0]
        }
        
        downloadPath := tempDir . "\" . fileName
        
        ; Show progress dialog
        progressGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "Downloading Update")
        progressGui.BackColor := "0x111113"
        progressGui.Add("Text", "x20 y20 w300 h20 cFFFFFF Center", "Downloading " . version . "...")
        progressBar := progressGui.Add("Progress", "x20 y50 w300 h20 Background0x2A2A2A")
        statusText := progressGui.Add("Text", "x20 y80 w300 h20 cFFFFFF Center", "Starting download...")
        progressGui.Show("w340 h120")
        
        ; Download the file
        statusText.Text := "Connecting..."
        
        ; Use URLDownloadToFile for simple download
        result := DllCall("urlmon\URLDownloadToFile", "Ptr", 0, "Str", downloadUrl, "Str", downloadPath, "UInt", 0, "Ptr", 0)
        
        progressGui.Destroy()
        
        if (result = 0 && FileExist(downloadPath)) {
            ; Ask user to install now or later
            installResult := MsgBox("Download completed!`n`nThe update will extract all files and replace the current installation.`nThis will close the current application and restart with the new version.`n`nInstall now?", "Install Update", "YesNo Iconi")
            
            if (installResult = "Yes") {
                InstallZipUpdate(downloadPath, tempDir, version)
            } else {
                MsgBox("Update downloaded to:`n" . downloadPath . "`n`nExtract this file to your MangoGuards directory when you're ready to update.", "Download Complete", "Iconi")
            }
        } else {
            MsgBox("Failed to download the update.`nPlease download manually from:`nhttps://github.com/" . REPO_OWNER . "/" . REPO_NAME . "/releases", "Download Failed", "Iconx")
        }
    } catch as err {
        if (IsSet(progressGui)) {
            progressGui.Destroy()
        }
        MsgBox("Error downloading update: " . err.Message, "Download Error", "Iconx")
    }
}

; Install ZIP update (replace all files)
InstallZipUpdate(zipPath, tempDir, version) {
    try {
        ; Extract ZIP file
        extractDir := tempDir . "\extracted"
        DirCreate(extractDir)
        
        ; Try multiple extraction methods
        extractSuccess := false
        
        ; Method 1: PowerShell (Windows 10+)
        try {
            extractCommand := 'powershell -Command "Expand-Archive -Path \\"' . zipPath . '\\" -DestinationPath \\"' . extractDir . '\\" -Force"'
            RunWait(extractCommand, , "Hide")
            
            ; Check if extraction was successful
            if (DirExist(extractDir) && FileExist(extractDir . "\*")) {
                extractSuccess := true
            }
        } catch {
            ; PowerShell method failed, continue to next method
        }
        
        ; Method 2: Windows Shell.Application COM object (fallback)
        if (!extractSuccess) {
            try {
                shell := ComObject("Shell.Application")
                zip := shell.Namespace(zipPath)
                extractFolder := shell.Namespace(extractDir)
                
                if (zip && extractFolder) {
                    ; Extract all items (16 = overwrite without prompt)
                    extractFolder.CopyHere(zip.Items(), 16)
                    
                    ; Wait a bit for extraction to complete
                    Sleep(2000)
                    
                    ; Check if extraction was successful
                    if (DirExist(extractDir) && FileExist(extractDir . "\*")) {
                        extractSuccess := true
                    }
                }
            } catch {
                ; COM method also failed
            }
        }
        
        ; Method 3: Try to find any subdirectory in extracted folder (some zips have a root folder)
        if (extractSuccess) {
            ; Check if there's a subdirectory that contains the actual files
            loop Files, extractDir . "\*", "D" {
                if (FileExist(A_LoopFileFullPath . "\ALS.ahk") || FileExist(A_LoopFileFullPath . "\*.exe")) {
                    extractDir := A_LoopFileFullPath
                    break
                }
            }
        }
        
        if (!extractSuccess) {
            MsgBox("Failed to extract ZIP file. Please extract manually and copy files to:`n" . A_ScriptDir, "Extraction Failed", "Iconx")
            return
        }
        
        ; Create update script
        updateScript := tempDir . "\update_full.bat"
        currentDir := A_ScriptDir
        currentExe := A_IsCompiled ? A_ScriptFullPath : A_ScriptDir . "\ALS.exe"
        
        ; Create comprehensive batch script for full update
        batContent := "@echo off`n"
        batContent .= "echo Updating MangoGuards (Full Update)...`n"
        batContent .= "timeout /t 2 /nobreak > nul`n"
        batContent .= "taskkill /f /im `"" . StrReplace(currentExe, currentDir . "\", "") . "`" 2>nul`n"
        batContent .= "timeout /t 2 /nobreak > nul`n"
        
        ; Copy all files from extracted directory to current directory
        batContent .= "echo Copying new files...`n"
        batContent .= "xcopy /s /e /y `"" . extractDir . "\*`" `"" . currentDir . "\`"`n"
        
        ; Verify main executable exists and restart
        batContent .= "if exist `"" . currentExe . "`" (`n"
        batContent .= "    echo Update successful!`n"
        batContent .= "    timeout /t 1 /nobreak > nul`n"
        batContent .= "    start `"`" `"" . currentExe . "`"`n"
        batContent .= ") else (`n"
        batContent .= "    echo Update failed - executable not found!`n"
        batContent .= "    echo Please check the update files manually.`n"
        batContent .= "    pause`n"
        batContent .= ")`n"
        
        ; Cleanup
        batContent .= "timeout /t 3 /nobreak > nul`n"
        batContent .= "rmdir /s /q `"" . tempDir . "`" 2>nul`n"
        
        FileOpen(updateScript, "w").Write(batContent)
        
        ; Run update script and exit
        Run(updateScript, , "Hide")
        ExitApp()
        
    } catch as err {
        MsgBox("Error installing ZIP update: " . err.Message . "`n`nPlease download and extract manually from:`nhttps://github.com/" . REPO_OWNER . "/" . REPO_NAME . "/releases", "Installation Error", "Iconx")
    }
}

OpenGuide(*) {
    try {
        Run("https://www.notion.so/How-to-use-ALS-AIO-for-dummies-3fb32e999022411492d9f70f21ef9ceb?source=copy_link")
    } catch as err {
        MsgBox("Error opening guide: " . err.Message)
    }
}

; Note: All curse functions, survival selection functions, boss rush functions, and legend stage functions
; are now handled by individual macro files (raids.ahk, dungeon.ahk, survival.ahk, etc.)
; The OnMangoChange function coordinates switching between these modular systems.

; Global variables for webhook editor
global WebhookEditorGUI := ""
global WebhookURLEdit := ""
global StatusText := ""
global CurrentWebhookURL := ""

CreateWebhookEditorGUI() {
    global WebhookEditorGUI, WebhookURLEdit, StatusText
    
    ; Load current webhook URL from settings
    LoadWebhookURL()
    
    ; Create the GUI
    WebhookEditorGUI := Gui("+Resize -MaximizeBox", "MangoGuards Webhook Editor")
    WebhookEditorGUI.BackColor := 0x1A1A1A
    WebhookEditorGUI.MarginX := 20
    WebhookEditorGUI.MarginY := 20
    
    ; Title
    TitleText := WebhookEditorGUI.Add("Text", "x20 y20 w460 h30 c0xFFFFFF Center", "Discord Webhook Configuration")
    TitleText.SetFont("s14 Bold", "Segoe UI")

      ; Webhook URL Label
    WebhookEditorGUI.Add("Text", "x20 y70 w100 h20 c0xFFFFFF", "Webhook URL:")
    WebhookURLEdit := WebhookEditorGUI.Add("Edit", "x20 y95 w460 h25 Background0x2A2A2A c0xFFFFFF", CurrentWebhookURL)
    WebhookURLEdit.SetFont("s10", "Segoe UI")
    WebhookURLEdit.Name := "WebhookURLEdit"
    
    ; Instructions
    WebhookEditorGUI.Add("Text", "x20 y130 w460 h40 c0xA0A0A0", "Enter your Discord webhook URL above. Click Test to send a test message, or Apply to save the URL.")
    
    ; Status text
    StatusText := WebhookEditorGUI.Add("Text", "x20 y180 w460 h20 c0xFFFFFF", "Status: Ready")
    StatusText.Name := "StatusText"
    
    ; Buttons
    TestBtn := WebhookEditorGUI.Add("Button", "x20 y210 w100 h35 Background0xee6531", "Test Webhook")
    TestBtn.SetFont("s10 Bold c0xFFFFFF", "Segoe UI")
    TestBtn.OnEvent("Click", TestWebhook)
    
    ApplyBtn := WebhookEditorGUI.Add("Button", "x130 y210 w100 h35 Background0xee6531", "Apply & Save")
    ApplyBtn.SetFont("s10 Bold c0xFFFFFF", "Segoe UI")
    ApplyBtn.OnEvent("Click", ApplyWebhook)
    
    CloseBtn := WebhookEditorGUI.Add("Button", "x380 y210 w100 h35 Background0xee6531", "Close")
    CloseBtn.SetFont("s10 Bold c0xFFFFFF", "Segoe UI")
    CloseBtn.OnEvent("Click", CloseWebhookEditor)
    
    ; Event handlers
    WebhookEditorGUI.OnEvent("Close", CloseWebhookEditor)
      ; Show the GUI
    WebhookEditorGUI.Show("w500 h270")
}

LoadWebhookURL() {
    WebhookFile := A_ScriptDir . "\libs\settings\webhook.txt"
    try {
        if FileExist(WebhookFile) {
            CurrentWebhookURL := FileRead(WebhookFile)
            CurrentWebhookURL := Trim(CurrentWebhookURL)
        } else {
            CurrentWebhookURL := ""
        }
    } catch {
        CurrentWebhookURL := ""
    }
}

SaveWebhookURL(url) {
    WebhookFile := A_ScriptDir . "\libs\settings\webhook.txt"
    try {
        ; Ensure directory exists
        DirCreate(A_ScriptDir . "\libs\settings")
        
        ; Save the URL
        FileDelete(WebhookFile)
        FileAppend(url, WebhookFile)
        return true
    } catch {
        return false
    }
}

TestWebhook(*) {
    global WebhookURLEdit, StatusText
    
    ; Get the URL from the edit control
    webhookURL := WebhookURLEdit.Text
    
    ; Update status
    StatusText.Text := "Status: Testing webhook..."
    
    if (webhookURL = "") {
        StatusText.Text := "Status: Error - Please enter a webhook URL"
        StatusText.Opt("c0xFF4444")
        return
    }
    
    ; Validate URL format
    if (!RegExMatch(webhookURL, "https://discord\.com/api/webhooks/\d+/[\w-]+")) {
        StatusText.Text := "Status: Error - Invalid Discord webhook URL"
        StatusText.Opt("c0xFF4444")
        return
    }
    
    ; Create test message JSON directly
    testMessageJSON := '{'
    testMessageJSON .= '"content": "",'
    testMessageJSON .= '"embeds": [{'
    testMessageJSON .= '"title": "🥭 MangoGuards Test Message",'
    testMessageJSON .= '"description": "This is a test message from MangoGuards Webhook Editor!\\n\\nIf you see this, your webhook is working correctly.",'
    testMessageJSON .= '"color": 16760628,'
    testMessageJSON .= '"timestamp": "' . FormatTime(A_NowUTC, "yyyy-MM-ddTHH:mm:ss.000Z") . '",'
    testMessageJSON .= '"footer": {'
    testMessageJSON .= '"text": "MangoGuards | Test Message",'
    testMessageJSON .= '"icon_url": "https://cdn.discordapp.com/attachments/1342045511175376962/1342714291089969202/mango.png"'
    testMessageJSON .= '}'
    testMessageJSON .= '}]'
    testMessageJSON .= '}'
    
    ; Send the webhook
    try {
        ; Send HTTP request
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", webhookURL, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(testMessageJSON)
          if (whr.Status = 204) {
            StatusText.Text := "Status: Test message sent successfully! ✅"
            StatusText.Opt("c0x00FF00")
        } else {
            StatusText.Text := "Status: Error - HTTP " . whr.Status . " " . whr.StatusText
            StatusText.Opt("c0xFF4444")
        }    } catch as err {
        StatusText.Text := "Status: Error - " . err.Message
        StatusText.Opt("c0xFF4444")
    }
}

ApplyWebhook(*) {
    global WebhookURLEdit, StatusText
    
    ; Get the URL from the edit control
    webhookURL := WebhookURLEdit.Text
    
    ; Update status
    
    if (webhookURL = "") {
        StatusText.Text := "Status: Error - Please enter a webhook URL"
        StatusText.Opt("c0xFF4444")
        return
    }
    
    ; Validate URL format
    if (!RegExMatch(webhookURL, "https://discord\.com/api/webhooks/\d+/[\w-]+")) {
        StatusText.Text := "Status: Error - Invalid Discord webhook URL"
        StatusText.Opt("c0xFF4444")
        return
    }
      ; Save the webhook URL
    if (SaveWebhookURL(webhookURL)) {
        CurrentWebhookURL := webhookURL
        StatusText.Text := "Status: Webhook URL saved successfully! ✅"
        StatusText.Opt("c0x00FF00")
    } else {
        StatusText.Text := "Status: Error - Failed to save webhook URL"
        StatusText.Opt("c0xFF4444")
    }
}

CloseWebhookEditor(*) {
    try {
        if (WebhookEditorGUI) {
            WebhookEditorGUI.Destroy()
            WebhookEditorGUI := ""
        }
    } catch {
        ; Ignore errors on close
    }
}

; Simple JSON formatter for webhook messages
FormatWebhookJSON(obj) {
    json := "{"
    json .= '`"content`": `"' . obj.content . '`",'
    json .= '`"embeds`": [{'
    json .= '`"title`": `"' . obj.embeds[1].title . '`",'
    json .= '`"description`": `"' . obj.embeds[1].description . '`",'
    json .= '`"color`": ' . obj.embeds[1].color . ','
    json .= '`"timestamp`": `"' . obj.embeds[1].timestamp . '`",'
    json .= '`"footer`": {'
    json .= '`"text`": `"' . obj.embeds[1].footer.text . '`",'
    json .= '`"icon_url`": `"' . obj.embeds[1].footer.icon_url . '`"'
    json .= '}'
    json .= '}]'
    json .= "}"
    return json
}

; Automatic update check on startup (less intrusive than manual check)
CheckForUpdatesOnStartup() {
    ; Prevent multiple runs and disable timer immediately
    global StartupUpdateCheckDone
    
    ; Disable timer first thing to prevent multiple calls
    SetTimer(CheckForUpdatesOnStartup, 0)
    
    ; Only run once
    if (StartupUpdateCheckDone) {
        return
    }
    
    ; Set flag immediately to prevent race conditions
    StartupUpdateCheckDone := true
    
    try {
        ; Get latest release from GitHub API
        apiUrl := "https://api.github.com/repos/" . REPO_OWNER . "/" . REPO_NAME . "/releases/latest"
        
        ; Create HTTP request
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        
        ; Try to open the request - if this fails, skip the update check
        try {
            whr.Open("GET", apiUrl, false)
        } catch {
            return
        }
        
        ; Try to set user agent - if this fails, continue without it
        try {
            whr.SetRequestHeader("User-Agent", "MangoGuards-AutoUpdater")
        } catch {
            ; Continue without user agent if it fails
        }
        
        ; Try to send the request
        try {
            whr.Send()
        } catch {
            return
        }
          ; Check if we got a successful response
        try {
            status := whr.Status
        } catch {
            return
        }
        
        if (status = 200) {
            ; Parse JSON response
            responseText := whr.ResponseText                ; Extract version tag (simple regex approach)
                if (RegExMatch(responseText, '"tag_name":\s*"([^"]+)"', &match)) {
                    latestVersion := match[1]
                      ; Extract download URL - only look for ZIP files (complete package)
                    downloadUrl := ""
                    
                    ; Look for a .zip file (complete package)
                    if (RegExMatch(responseText, '"browser_download_url":\s*"([^"]*\.zip[^"]*)"', &downloadMatch)) {
                        downloadUrl := downloadMatch[1]
                    }
                    
                    ; Compare versions (only show dialog if update is available)
                    if (CompareVersions(CURRENT_VERSION, latestVersion) < 0) {
                        ; New version available - show update dialog
                        if (downloadUrl != "") {
                            updateMessage := "A new version (" . latestVersion . ") is available!`n`nCurrent version: " . CURRENT_VERSION . "`nLatest version: " . latestVersion . "`n`n"
                            updateMessage .= "This will download and replace all files in the current directory.`n`nWould you like to download and install it now?"
                            
                            result := MsgBox(updateMessage, "Update Available", "YesNo Iconi 4096")
                            
                            if (result = "Yes") {
                                DownloadAndInstallUpdate(downloadUrl, latestVersion, "zip")
                            }
                        } else {
                            ; No ZIP file found, direct to releases page
                            result := MsgBox("A new version (" . latestVersion . ") is available!`n`nCurrent version: " . CURRENT_VERSION . "`nLatest version: " . latestVersion . "`n`nNo automatic download available. Would you like to open the releases page to download manually?", "Update Available", "YesNo Iconi 4096")
                            
                            if (result = "Yes") {
                                Run("https://github.com/" . REPO_OWNER . "/" . REPO_NAME . "/releases/latest")
                            }
                        }
                    }
            }
        }
    } catch {
        ; Silently fail for startup check - no need to bother user
        return
    }
}

; Reset the startup update check flag (called on script reload)
ResetStartupUpdateCheck() {
    global StartupUpdateCheckDone
    StartupUpdateCheckDone := false
    ; Also ensure any pending timer is cleared
    SetTimer(CheckForUpdatesOnStartup, 0)
}

; Handle script exit/reload
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    ResetStartupUpdateCheck()
}

; Manual reset button for debugging (can be called from GUI if needed)
ResetUpdateCheckFlag() {
    global StartupUpdateCheckDone
    StartupUpdateCheckDone := false
    SetTimer(CheckForUpdatesOnStartup, 0)  ; Clear any pending timers
    MsgBox("Update check flag has been reset", "Debug", "Iconi")
}
