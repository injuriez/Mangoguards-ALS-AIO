#Requires AutoHotkey v2.0
; MangoGuards Webhook Editor Launcher
; Launches the Python-based webhook editor with HTML interface

LaunchWebhookEditor() {
    ; Get the directory of this script
    scriptDir := A_ScriptDir
    pythonScript := scriptDir . "\libs\UIPARTS\webhook_editor.py"
    
    ; Check if Python script exists
    if !FileExist(pythonScript) {
        MsgBox("Error: Webhook editor not found at:`n" . pythonScript, "MangoGuards", "Icon!")
        return
    }
    
    ; Try to run with python
    try {
        ; First try 'python' command
        RunWait('python "' . pythonScript . '"', , "Hide")
    } catch {
        try {
            ; If that fails, try 'py' command
            RunWait('py "' . pythonScript . '"', , "Hide")
        } catch {
            try {
                ; If that fails, try 'python3' command
                RunWait('python3 "' . pythonScript . '"', , "Hide")
            } catch {
                ; If all fail, show error message
                MsgBox("Error: Python not found or not in PATH.`n`nTo use the Webhook Editor, please:`n1. Install Python from python.org`n2. Add Python to your system PATH`n3. Install required packages: pip install webview requests", "Python Not Found", "Icon!")
            }
        }
    }
}

; Export the function so it can be called from other scripts
; This allows the main ALS.ahk to call LaunchWebhookEditor()
