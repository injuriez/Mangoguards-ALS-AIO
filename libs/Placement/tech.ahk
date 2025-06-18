#Requires AutoHotkey v2.0
BetterClick(x, y, LR := "Left") {
    ; Use Window coordinates to match main script coordinate mode
    CoordMode("Mouse", "Window")
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(50)
}

ZoomTech(start := true) {
    ; Store current mouse position
    MouseGetPos(&currentX, &currentY)
    
    Send "{Tab}"
    BetterClick(408, 247)
    
    ; Remove the relative mouse movements that cause camera rotation
    ; MouseMove(0, 1, 0, "R")  ; This line causes unwanted camera movement
    
    Scroll(20, "WheelUp", 75)
    Sleep(500)
    
    MouseMove(197, 350)  ; Move back to the tech button
    Sleep(500)
    
    Scroll(20, "WheelDown", 75)
    
    ; Restore mouse to original position to prevent camera drift
    MouseMove(currentX, currentY)
    
    Sleep(500)
    if start {
        BetterClick(361, 542)
    }
}

Scroll(times, direction, delay) {
    if (times < 1) {
        MsgBox("Invalid number of times")
        return
    }
    if (direction != "WheelUp" and direction != "WheelDown") {
        MsgBox("Invalid direction")
        return
    }
    if (delay < 0) {
        MsgBox("Invalid delay")
        return
    }
    loop times {
        Send("{" direction "}")
        Sleep(delay)
    }
}
F12::ZoomTech("true")
F8::Reload