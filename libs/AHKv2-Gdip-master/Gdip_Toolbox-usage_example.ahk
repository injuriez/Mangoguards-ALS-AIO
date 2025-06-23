#include Gdip_Toolbox.ahk

color := GetPixelColorBuffered(120,130)
MsgBox("Color of pixel at 120x130 (BGR): " Format("0x{:06X}", color))

rect := DrawRectangle(120, 130, 222, 333, 12345678, 0.5)
MsgBox("Click ok to destroy rectangle")
rect.Destroy()
