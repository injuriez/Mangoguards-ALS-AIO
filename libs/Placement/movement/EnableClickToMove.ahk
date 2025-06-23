



ChangeMovement(TurnOn := "true") {
    ; Open the settings menu

   

    if (TurnOn == "true") {
         SendInput("{Escape}")
    Sleep(1000)

    ; Click on the arrows

    BetterClick(350, 93) ; Clicks settings
    Sleep(500)
    BetterClick(873, 267) ; Presses the arrow once
    Sleep(500)
    BetterClick(873, 267) ; Presses the arrow again
    Sleep(500)

    ; closes the ui
    SendInput("{Escape}")

    } else {
        SendInput("{Escape}")
    Sleep(1000)

    ; Click on the arrows

    BetterClick(350, 93) ; Clicks settings
    Sleep(500)
    BetterClick(435, 257) ; Presses the arrow once
    Sleep(500)
    BetterClick(435, 257) ; Presses the arrow again
    Sleep(500)

    ; closes the ui
    SendInput("{Escape}")
    }



    
}

