#include Gdip_All.ahk

; Creates always on top window with current screen making impression as if screen froze
; Argument 'shouldFreeze' value 1: freeze, 0: unfreeze, -1: unfreeze all (if frozen more than once)
ScreenFreeze(shouldFreeze:=1) {
	static freezeCounter:=0, frozenWindow:=""
	static raster := 0x40000000 + 0x00CC0020	; to capture layered windows too

	switch shouldFreeze {
		case -2: ; Unfreeze everything
			if (freezeCounter > 0) {
				frozenWindow.Hide()
			}
			freezeCounter := 0
			return

		case -1: ; Refresh frozen picture
			if (freezeCounter < 1) {
				return
			}
			frozenWindow.Hide()

		case 0:	; Unfreeze one level
			if (freezeCounter < 1) {
				return
			}
			freezeCounter -= 1
			if (freezeCounter < 1) {
				frozenWindow.Hide()
			}
			return

		case 1:	; Increase freeze level
			freezeCounter += 1
			if (freezeCounter > 1) {
				return
			}

		default:
			throw Error("Wrong argument value: " shouldFreeze)
	}

	pToken := Gdip_Startup()
    pBitmap := Gdip_BitmapFromScreen(0 "|" 0 "|" A_ScreenWidth "|" A_ScreenHeight, raster)

	if (!frozenWindow) {
		frozenWindow := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
	}


	hbm := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    Gdip_DisposeImage(pBitmap)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	frozenWindow.Show("NA")
	UpdateLayeredWindow(frozenWindow.hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)

	SelectObject(hdc, obm)

	DeleteObject(hbm)
	DeleteDC(hdc)
    Gdip_Shutdown(pToken)

	frozenWindow.Opt("+OwnDialogs")
	return frozenWindow
}

ScreenUnfreeze(shouldFreeze:=0) {
	return ScreenFreeze(shouldFreeze)
}

; Draws colored rectangle (with optional transparency)
; Use `returnValue.Destroy()` to destroy the rectangle (AHK Gui object)
DrawRectangle(x1, y1, x2, y2, color, alpha:=1, &parentWindow:="") {
	if (parentWindow && !parentWindow.HasProp("hwnd")) {
		throw Error("The 'parentWindow' argument needs to have proper 'hwnd' property (for example a Gui object has it). Skip this value to create one.")
	}

	pToken := Gdip_Startup()

	w := x2 - x1 + 1
	h := y2 - y1 + 1

	if (!parentWindow) {
		parentWindow := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
		parentWindow.Show("NA")
	}

	hdc := CreateCompatibleDC()
	hbm := CreateDIBSection(w, h)
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	pBrush := Gdip_BrushCreateSolid((floor(alpha * 0xFF) << 24) | color)
	Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
	Gdip_DeleteBrush(pBrush)

	UpdateLayeredWindow(parentWindow.hwnd, hdc, x1, y1, w, h)
	SelectObject(hdc, obm)

	DeleteObject(hbm)
	DeleteDC(hdc)
	Gdip_DeleteGraphics(G)

	Gdip_Shutdown(pToken)

	return parentWindow
}

; Draws colored rectangle (with optional transparency)
; Use `returnValue.Destroy()` to destroy the rectangle (AHK Gui object)
DrawCircle(x, y, radius, color, alpha:=1, &parentWindow:="") {
	if (parentWindow && !parentWindow.HasProp("hwnd")) {
		throw Error("The 'parentWindow' argument needs to have proper 'hwnd' property (for example a Gui object has it). Skip this value to create one.")
	}

	pToken := Gdip_Startup()
	x1 := x - radius + 1
	y1 := y - radius + 1

	w := radius * 2 - 1
	h := radius * 2 - 1

	if (!parentWindow) {
		parentWindow := Gui("-Caption +Disabled +E0x80000 -LastFound +AlwaysOnTop +ToolWindow -OwnDialogs")
		parentWindow.Show("NA")
	}

	hdc := CreateCompatibleDC()
	hbm := CreateDIBSection(w, h)
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	pBrush := Gdip_BrushCreateSolid((floor(alpha * 0xFF) << 24) | color)
	; pBrush := Gdip_BrushCreateHatch((floor(alpha * 0xFF) << 24) | color, 0x7F1155FF, 4)	; Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle:=0)
	Gdip_FillEllipse(G, pBrush, 0, 0, w, h)
	; Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
	Gdip_DeleteBrush(pBrush)

	UpdateLayeredWindow(parentWindow.hwnd, hdc, x1, y1, w, h)
	SelectObject(hdc, obm)

	DeleteObject(hbm)
	DeleteDC(hdc)
	Gdip_DeleteGraphics(G)

	Gdip_Shutdown(pToken)

	return parentWindow
}

DrawTemporaryCircle(x, y, radius, color, alpha, time) {
	circleWindow := DrawCircle(x, y, radius, color, alpha)
	SetTimer(DestroyCircle, -time)

	DestroyCircle() {
		circleWindow.Destroy()
	}
}


; Draws colored rectangle (with optional transparency), a slow version without Gdip use
; Use `returnValue.Destroy()` to destroy the rectangle (AHK Gui object)
DrawRectangleSlow(x1, y1, x2, y2, color, alpha:=1) {
	global CoordText

	w := x2 - x1 + 1
	h := y2 - y1 + 1
	myGui := Gui("-Caption +E0x80000 +AlwaysOnTop +ToolWindow -DPIScale +LastFound +OwnDialogs")
	myGui.BackColor := color
	WinSetTransparent(round(255*alpha), myGui)
	myGui.Show()
	myGui.Move(x1, y1, w, h)

	return myGui
}

; Gets pixel color using screen buffer which refreshes on specified time period (150 ms by default)
GetPixelColorBuffered(x, y, refreshRate:=150, waitForUpdate:=false) {
	static isBufferReady:=false, myDC:=0, screenX, screenY
	static lastUpdateTick := 0

	timeRemaining := lastUpdateTick + refreshRate - A_TickCount

	if (timeRemaining <= 0 || waitForUpdate) {
		if (waitForUpdate && timeRemaining > 0) {
			sleep timeRemaining
		}
		UpdateScreenBuffer(0)
		lastUpdateTick := A_TickCount
	}

	return GetPixelColorFromBuffer()

	GetPixelColorFromBuffer() {
		if (!IsInteger(x) || !IsInteger(y)) {
			throw Error("Wrong parameter types: x=" x ", y=" y)
		}

		; check if there is a valid data buffer
		if (!isBufferReady) {
			Start := A_TickCount
			while (!isBufferReady) {
				Sleep 10
				if (A_TickCount - Start > 5000) {   ; time out if data is not ready after 5 seconds
					return -3
				}
			}
		}
		return DllCall("GetPixel", "Uint", myDC, "int", x - screenX, "int", y - screenY)
	}

	; Default window handle is NULL (entire screen)
	UpdateScreenBuffer(windowHandle:=0) {
		static oldObject := 0, hBuffer := 0
		static screenWOld := 0, screenHOld := 0

		; get screen dimensions
		screenX := SysGet(76)
		screenY := SysGet(77)
		screenW := SysGet(78)
		screenH := SysGet(79)
		isBufferReady := 0

		; determine whether the old buffer can be reused
		bufferInvalid := screenW != screenWOld || screenH != screenHOld || myDC == 0 || hBuffer == 0
		screenWOld := screenW
		screenHOld := screenH
		if (bufferInvalid) {
			; cleanly discard the old buffer
			DllCall("SelectObject", "Uint", myDC, "Uint", oldObject)
			DllCall("DeleteDC", "Uint", myDC)
			DllCall("DeleteObject", "Uint", hBuffer)

			; create a new empty buffer
			myDC := CreateCompatibleDC(0)
			hBuffer := CreateDIBSection(screenW, screenH, myDC)
			oldObject := DllCall("SelectObject", "Uint", myDC, "Uint", hBuffer)
		}
		screenDC := DllCall("GetDC", "Uint", windowHandle)

		; retrieve the whole screen into the newly created buffer
		DllCall("BitBlt", "Uint", myDC, "int", 0, "int", 0, "int", screenW, "int", screenH, "Uint", screenDC, "int", screenX, "int", screenY, "Uint", 0x40000000 | 0x00CC0020)

		; important: release the DC of the screen
		DllCall("ReleaseDC", "Uint", windowHandle, "Uint", screenDC)
		isBufferReady := 1
	}
}
