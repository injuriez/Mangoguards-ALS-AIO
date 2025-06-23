#Requires AutoHotkey v2

; This script launches the Python version of the Unit Manager
; This allows the compiled ALS.exe to run the unit manager through this AHK launcher

try {
    ; Path to the Python unit manager
    pythonUnitManagerPath := A_ScriptDir . "\unit_manager.py"
    
    ; Check if the Python file exists
    if (!FileExist(pythonUnitManagerPath)) {
        MsgBox("Error: Python Unit Manager not found at: " . pythonUnitManagerPath, "Unit Manager Error", "Icon!")
        ExitApp()
    }
    
    ; Launch the Python unit manager
    Run("python `"" . pythonUnitManagerPath . "`"", A_ScriptDir, "Hide")
    
    ; Exit this launcher script after starting Python version
    ExitApp()
    
} catch as err {
    MsgBox("Error launching Python Unit Manager: " . err.Message . "`n`nMake sure Python is installed and accessible from command line.", "Unit Manager Error", "Icon!")
    ExitApp()
}