#Requires AutoHotkey v2.0
#Include ../../FindText.ahk

; Define search coordinates for easy reference
SearchX1 := 149
SearchY1 := 138
SearchX2 := 591
SearchY2 := 325

bleh() {
    Story := "|<>*151$67.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzsDzzzzzzzzzs3lzzzzzzzzs0szzzzzzzzwQwTzzzzzzzyDw3zzzzzzzz3w0w7WAyDzzUC0Q1k4D7zzs1UQ0M373zzz0syC4TVXzzzwQT7WDs1zzzSCDXl7y1zzz777llXz0zzzU3ks0lzkzzzs3sS0szwTzzz7zDkwzwTzzzzzzzzzyDzzzzzzzzzzDzzzzzzzzzz7zzzzzzzzzzrzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"

    if (FindText(&X, &Y, 183, 202, 383, 271, 0, 0, Story)) {
        MsgBox("Tower Limit found at coordinates: " X ", " Y, "Tower Limit Detected", 64)

    } else {
        MsgBox("Survival not found", "Survival Check", 48)
    }
}

PreviewSearchArea() {
    ; Create a GUI to show the search area coordinates
    PreviewGui := Gui("+AlwaysOnTop +ToolWindow", "FindText Search Area Preview")
    PreviewGui.SetFont("s12")
    
    ; Add coordinate information
    PreviewGui.Add("Text", "w300 Center", "FindText Search Area Coordinates")
    PreviewGui.Add("Text", "w300 Center Section", "")
    
    PreviewGui.Add("Text", "w100", "Top-Left:")
    PreviewGui.Add("Text", "x+10 yp w100", "X: " SearchX1 "  Y: " SearchY1)
    
    PreviewGui.Add("Text", "xm w100", "Bottom-Right:")
    PreviewGui.Add("Text", "x+10 yp w100", "X: " SearchX2 "  Y: " SearchY2)
    
    PreviewGui.Add("Text", "xm w100", "Width:")
    PreviewGui.Add("Text", "x+10 yp w100", (SearchX2 - SearchX1) " pixels")
    
    PreviewGui.Add("Text", "xm w100", "Height:")
    PreviewGui.Add("Text", "x+10 yp w100", (SearchY2 - SearchY1) " pixels")
    
    PreviewGui.Add("Text", "xm w300 Center Section", "")
    
    ; Add buttons
    PreviewGui.Add("Button", "w80 h30", "Show Area").OnEvent("Click", (*) => ShowSearchArea())
    PreviewGui.Add("Button", "x+10 yp w80 h30", "Close").OnEvent("Click", (*) => PreviewGui.Close())
    
    ; Show the preview GUI
    PreviewGui.Show()
}

ShowSearchArea() {
    ; Create a transparent overlay to highlight the search area
    OverlayGui := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x20", "Search Area Overlay")
    OverlayGui.BackColor := "Red"
    WinSetTransparent(100, OverlayGui)  ; Semi-transparent red overlay
    
    ; Position and size the overlay to match search area
    Width := SearchX2 - SearchX1
    Height := SearchY2 - SearchY1
    OverlayGui.Show("x" SearchX1 " y" SearchY1 " w" Width " h" Height " NoActivate")
    
    ; Show a message box with instructions
    Result := MsgBox("Red overlay shows the FindText search area`n`n" .
                     "Coordinates: (" SearchX1 ", " SearchY1 ") to (" SearchX2 ", " SearchY2 ")`n" .
                     "Size: " Width "x" Height " pixels`n`n" .
                     "Click OK to close overlay", "Search Area Preview", 64)
    
    ; Close the overlay when user clicks OK
    OverlayGui.Close()
}
; Hotkey assignments
F8::PreviewSearchArea()  ; Press F8 to preview search area coordinates and show overlay
F9::bleh()               ; Press F9 to run the FindText search
