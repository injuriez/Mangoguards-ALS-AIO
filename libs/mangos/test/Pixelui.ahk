#Requires AutoHotkey v2.0

; Include the Pixel module
#Include ..\..\..\libs\Pixel.ahk

; Global variables
global foundX := 0
global foundY := 0
global lastFoundX := 0
global lastFoundY := 0
global PixelUI := ""
global ColorEdit := ""
global X1Edit := ""
global Y1Edit := ""
global AddXEdit := ""
global AddYEdit := ""
global VariationEdit := ""
global ResultText := ""
global StatusText := ""

; Create the main Pixel UI
CreatePixelUI() {
    global PixelUI, ColorEdit, X1Edit, Y1Edit, AddXEdit, AddYEdit, VariationEdit, ResultText, StatusText
    
    ; Create the main GUI
    PixelUI := Gui("+Resize -MaximizeBox", "Pixel Finder Tool")
    PixelUI.BackColor := 0x1A1A1A
    PixelUI.MarginX := 20
    PixelUI.MarginY := 20
    
    ; Title
    TitleText := PixelUI.Add("Text", "x20 y20 w460 h30 c0xFFFFFF Center", "🎯 Pixel Color Finder")
    TitleText.SetFont("s14 Bold", "Segoe UI")
    
    ; Instructions
    PixelUI.Add("Text", "x20 y60 w460 h20 c0xA0A0A0", "Enter color in hex format (e.g., 0xFF0000 for red) and search area coordinates:")
    
    ; Color input
    PixelUI.Add("Text", "x20 y90 w100 h20 c0xFFFFFF", "Color (Hex):")
    ColorEdit := PixelUI.Add("Edit", "x130 y90 w150 h25 Background0x2A2A2A c0xFFFFFF", "0xFF0000")
    ColorEdit.SetFont("s10", "Segoe UI")
    
    ; Search area inputs
    PixelUI.Add("Text", "x20 y125 w100 h20 c0xFFFFFF", "Start X:")
    X1Edit := PixelUI.Add("Edit", "x130 y125 w80 h25 Background0x2A2A2A c0xFFFFFF", "0")
    X1Edit.SetFont("s10", "Segoe UI")
    
    PixelUI.Add("Text", "x220 y125 w100 h20 c0xFFFFFF", "Start Y:")
    Y1Edit := PixelUI.Add("Edit", "x330 y125 w80 h25 Background0x2A2A2A c0xFFFFFF", "0")
    Y1Edit.SetFont("s10", "Segoe UI")
    
    PixelUI.Add("Text", "x20 y160 w100 h20 c0xFFFFFF", "Width:")
    AddXEdit := PixelUI.Add("Edit", "x130 y160 w80 h25 Background0x2A2A2A c0xFFFFFF", "1920")
    AddXEdit.SetFont("s10", "Segoe UI")
    
    PixelUI.Add("Text", "x220 y160 w100 h20 c0xFFFFFF", "Height:")
    AddYEdit := PixelUI.Add("Edit", "x330 y160 w80 h25 Background0x2A2A2A c0xFFFFFF", "1080")
    AddYEdit.SetFont("s10", "Segoe UI")
    
    PixelUI.Add("Text", "x20 y195 w100 h20 c0xFFFFFF", "Variation:")
    VariationEdit := PixelUI.Add("Edit", "x130 y195 w80 h25 Background0x2A2A2A c0xFFFFFF", "0")
    VariationEdit.SetFont("s10", "Segoe UI")
    
    ; Variation help text
    PixelUI.Add("Text", "x220 y195 w200 h20 c0xA0A0A0", "(0 = exact match, higher = more tolerance)")
    
    ; Search button
    SearchBtn := PixelUI.Add("Button", "x20 y230 w150 h35 Background0x4CAF50", "🔍 Search for Pixel")
    SearchBtn.SetFont("s10 Bold c0xFFFFFF", "Segoe UI")
    SearchBtn.OnEvent("Click", SearchPixel)
    
    ; Get mouse position button
    MouseBtn := PixelUI.Add("Button", "x180 y230 w150 h35 Background0x2196F3", "📍 Get Mouse Position")
    MouseBtn.SetFont("s10 Bold c0xFFFFFF", "Segoe UI")
    MouseBtn.OnEvent("Click", GetMousePosition)
      ; Clear button
    ClearBtn := PixelUI.Add("Button", "x340 y230 w100 h35 Background0xFF9800", "🗑️ Clear")
    ClearBtn.SetFont("s10 Bold c0xFFFFFF", "Segoe UI")
    ClearBtn.OnEvent("Click", ClearResults)
    
    ; Go to pixel button
    GoToBtn := PixelUI.Add("Button", "x450 y230 w100 h35 Background0x9C27B0", "📍 Go to Pixel")
    GoToBtn.SetFont("s10 Bold c0xFFFFFF", "Segoe UI")
    GoToBtn.OnEvent("Click", GoToPixel)
    
    ; Status text
    StatusText := PixelUI.Add("Text", "x20 y280 w460 h20 c0xFFFFFF", "Status: Ready to search")
    StatusText.SetFont("s10", "Segoe UI")
    
    ; Results section
    PixelUI.Add("Text", "x20 y310 w100 h20 c0xFFFFFF", "Results:")
    ResultText := PixelUI.Add("Edit", "x20 y335 w460 h120 +Multi +ReadOnly -E0x200 +VScroll Background0x2A2A2A c0xFFFFFF", "No search performed yet...")
    ResultText.SetFont("s9", "Consolas")
      ; Hotkey instructions
    PixelUI.Add("Text", "x20 y470 w460 h40 c0xA0A0A0", "Hotkeys: F1 = Search | F2 = Get Mouse Pos | F3 = Clear | F4 = Go to Pixel | Escape = Close")
    
    ; Event handlers
    PixelUI.OnEvent("Close", ClosePixelUI)
    
    ; Set up hotkeys
    HotKey("F1", SearchPixel, "On")
    HotKey("F2", GetMousePosition, "On")
    HotKey("F3", ClearResults, "On")
    HotKey("F4", GoToPixel, "On")
    HotKey("Escape", ClosePixelUI, "On")
    
    ; Show the GUI
    PixelUI.Show("w500 h520")
}

; Search for pixel function
SearchPixel(*) {
    global ColorEdit, X1Edit, Y1Edit, AddXEdit, AddYEdit, VariationEdit, ResultText, StatusText, foundX, foundY
    
    try {
        ; Get values from inputs
        colorStr := Trim(ColorEdit.Text)
        x1 := Integer(Trim(X1Edit.Text))
        y1 := Integer(Trim(Y1Edit.Text))
        addx := Integer(Trim(AddXEdit.Text))
        addy := Integer(Trim(AddYEdit.Text))
        variation := Integer(Trim(VariationEdit.Text))
        
        ; Validate color format
        if (!RegExMatch(colorStr, "^0x[0-9A-Fa-f]{6}$")) {
            StatusText.Text := "Status: Error - Invalid color format! Use 0xRRGGBB (e.g., 0xFF0000)"
            StatusText.Opt("c0xFF4444")
            return
        }
        
        ; Convert color string to number
        color := Integer(colorStr)
        
        ; Update status
        StatusText.Text := "Status: Searching for color " . colorStr . "..."
        StatusText.Opt("c0xFFFF00")
        
        ; Perform the search
        startTime := A_TickCount
        result := Pixel(color, x1, y1, addx, addy, variation)
        endTime := A_TickCount
        searchTime := endTime - startTime
        
        ; Format results
        currentTime := FormatTime(A_Now, "HH:mm:ss")
          if (result) {
            ; Pixel found - store coordinates for GoToPixel function
            lastFoundX := foundX
            lastFoundY := foundY
            
            StatusText.Text := "Status: Pixel found at (" . foundX . ", " . foundY . ")"
            StatusText.Opt("c0x00FF00")
            
            ; Get the actual color at found position
            actualColor := PixelGetColor(foundX, foundY)
            
            resultString := "[" . currentTime . "] FOUND PIXEL`n"
            resultString .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
            resultString .= "Search Color:  " . colorStr . "`n"
            resultString .= "Found at:      (" . foundX . ", " . foundY . ")`n"
            resultString .= "Actual Color:  0x" . Format("{:06X}", actualColor) . "`n"
            resultString .= "Search Area:   (" . x1 . ", " . y1 . ") to (" . (x1 + addx) . ", " . (y1 + addy) . ")`n"
            resultString .= "Variation:     " . variation . "`n"
            resultString .= "Search Time:   " . searchTime . " ms`n"
            resultString .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n`n"
            
        } else {
            ; Pixel not found
            StatusText.Text := "Status: Pixel not found in search area"
            StatusText.Opt("c0xFF4444")
            
            resultString := "[" . currentTime . "] PIXEL NOT FOUND`n"
            resultString .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
            resultString .= "Search Color:  " . colorStr . "`n"
            resultString .= "Search Area:   (" . x1 . ", " . y1 . ") to (" . (x1 + addx) . ", " . (y1 + addy) . ")`n"
            resultString .= "Variation:     " . variation . "`n"
            resultString .= "Search Time:   " . searchTime . " ms`n"
            resultString .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n`n"
        }
        
        ; Add to results (prepend to show latest first)
        currentResults := ResultText.Text
        if (currentResults == "No search performed yet...") {
            ResultText.Text := resultString
        } else {
            ResultText.Text := resultString . currentResults
        }
        
        ; Copy coordinates to clipboard if found
        if (result) {
            A_Clipboard := foundX . "," . foundY
            StatusText.Text := StatusText.Text . " (Coordinates copied to clipboard)"
        }
        
    } catch Error as e {
        StatusText.Text := "Status: Error - " . e.Message
        StatusText.Opt("c0xFF4444")
    }
}

; Get mouse position function
GetMousePosition(*) {
    global ResultText, StatusText
    
    ; Get current mouse position
    MouseGetPos(&mouseX, &mouseY)
    
    ; Get color at mouse position
    mouseColor := PixelGetColor(mouseX, mouseY)
    
    ; Update status
    StatusText.Text := "Status: Mouse position captured"
    StatusText.Opt("c0x00FF00")
    
    ; Format results
    currentTime := FormatTime(A_Now, "HH:mm:ss")
    resultString := "[" . currentTime . "] MOUSE POSITION`n"
    resultString .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
    resultString .= "Position:      (" . mouseX . ", " . mouseY . ")`n"
    resultString .= "Color:         0x" . Format("{:06X}", mouseColor) . "`n"
    resultString .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n`n"
    
    ; Add to results
    currentResults := ResultText.Text
    if (currentResults == "No search performed yet...") {
        ResultText.Text := resultString
    } else {
        ResultText.Text := resultString . currentResults
    }
    
    ; Copy position and color to clipboard
    A_Clipboard := mouseX . "," . mouseY . " (Color: 0x" . Format("{:06X}", mouseColor) . ")"
    StatusText.Text := StatusText.Text . " (Info copied to clipboard)"
}

; Go to pixel function
GoToPixel(*) {
    global StatusText, lastFoundX, lastFoundY
    
    ; Check if we have stored coordinates
    if (!IsSet(lastFoundX) || !IsSet(lastFoundY)) {
        StatusText.Text := "Status: No pixel found yet. Search for a pixel first!"
        StatusText.Opt("c0xFF0000")
        return
    }
    
    ; Move mouse to the stored coordinates
    try {
        MouseMove(lastFoundX, lastFoundY, 0)
        StatusText.Text := "Status: Mouse moved to pixel (" . lastFoundX . ", " . lastFoundY . ")"
        StatusText.Opt("c0x00FF00")
    } catch Error as e {
        StatusText.Text := "Status: Error moving mouse - " . e.Message
        StatusText.Opt("c0xFF0000")
    }
}

; Clear results function
ClearResults(*) {
    global ResultText, StatusText, lastFoundX, lastFoundY
    
    ResultText.Text := "No search performed yet..."
    StatusText.Text := "Status: Results cleared"
    StatusText.Opt("c0xFFFFFF")
    
    ; Clear stored coordinates
    lastFoundX := ""
    lastFoundY := ""
}

; Close UI function
ClosePixelUI(*) {
    global PixelUI
      ; Clean up hotkeys
    try {
        HotKey("F1", "Off")
        HotKey("F2", "Off") 
        HotKey("F3", "Off")
        HotKey("F4", "Off")
        HotKey("Escape", "Off")
    } catch {
        ; Ignore errors when disabling hotkeys
    }
    
    ; Close the GUI
    if (PixelUI) {
        PixelUI.Destroy()
        PixelUI := ""
    }
    
    ExitApp()
}

; Main execution
CreatePixelUI()


