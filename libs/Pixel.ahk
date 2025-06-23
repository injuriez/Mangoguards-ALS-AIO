#Requires AutoHotkey v2.0

Pixel(color, x1, y1, addx1, addy1, variation) {
    global foundX, foundY
    try {
        if PixelSearch(&foundX, &foundY, x1, y1, x1 + addx1, y1 + addy1, color, variation) {
            return [foundX, foundY] AND true
        }
        return false
    } catch Error as e {
        MsgBox("Error in Pixel: " e.Message)
        return false
    }
}