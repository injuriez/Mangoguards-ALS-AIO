#Requires AutoHotkey v2.0

; Global variables to store coordinates
global slot1Coords := Map()
global slot2Coords := Map()
global slot3Coords := Map()
global slot4Coords := Map()
global slot5Coords := Map()
global slot6Coords := Map()

global slot1UpgradeLevels := Map()
global slot2UpgradeLevels := Map()
global slot3UpgradeLevels := Map()
global slot4UpgradeLevels := Map()
global slot5UpgradeLevels := Map()
global slot6UpgradeLevels := Map()

global slot1Priority := 1
global slot2Priority := 2
global slot3Priority := 3
global slot4Priority := 4
global slot5Priority := 5
global slot6Priority := 6

myGui := Gui("+AlwaysOnTop -Caption +Border", "Mango") ; Remove caption and keep on top
myGui.BackColor := "0x111113"
myGui.SetFont("cFFFFFF")
myGui.SetFont("s10 Bold", "Karla")

; SLOT 1
BACKGROND := myGui.Add("Text", "x-16 y0 w1420 h23 Background1a1a1a", "")
fakebackground := myGui.Add("Text", "x-16 y0 w2000 h25 Background1a1a1a", "") ; Make width shorter to not overlap with close button


; topbar ----------------------------------
minimizeButton := myGui.Add("Picture", "x1600 y3 w20 h20 0x6 +BackgroundTrans", A_ScriptDir . "\Images\mini.png")
minimizeButton.OnEvent("Click", (*) => myGui.Minimize()) ; Minimize the GUI
closeButton := myGui.Add("Picture", "x1560 y3 w20 h20 0x6 +BackgroundTrans", A_ScriptDir . "\Images\close.png")
closeButton.OnEvent("Click", ExitHandler)
; Center the logo and text in the 1600px wide window
MangoLogo := myGui.Add("Picture", "x780 y-2 w29 h25 0x6 +BackgroundTrans", A_ScriptDir . "\mango.png")
BACKGROND_TEXT := myGui.Add("Text", "x800 y2 w120 h20 +BackgroundTrans +Center cFFFFFF", "MangoGuards (Custom Placement)")
BACKGROND_TEXT.SetFont("s10 Bold", "Karla")
ExitHandler(*) {
    myGui.Destroy()
    ExitApp
}
BACKGROND.OnEvent("Click", DragWindow)
MangoLogo.OnEvent("Click", DragWindow)
BACKGROND_TEXT.OnEvent("Click", DragWindow)
DragWindow(*) {
    PostMessage(0xA1, 2,,, myGui)  
}



; SLOT 1 (removed upgrade dropdown)
myGui.Add("GroupBox", "x48 y40 w228 h298", "SLOT 1")
myGui.Add("Text", "x56 y70 w120 h23 +0x200", "PLACEMENTS")
DropDownList2 := myGui.Add("DropDownList", "x56 y94 w209", ["1", "2", "3"])
DropDownList2.Choose(1)
myGui.Add("Text", "x56 y190 w120 h23 +0x200", "PRIORITY:")
PriorityList1 := myGui.Add("DropDownList", "x56 y214 w209", ["1", "2", "3", "4", "5", "6"])
PriorityList1.Choose(1)

myGui.Add("Text", "x56 y130 w80 h23 +0x200", "AUTO SKILL:")
SkillTypeList1 := myGui.Add("DropDownList", "x140 y130 w125", ["None", "SJW Arise", "Basic"])
SkillTypeList1.Choose(1)

CoordsStatus1 := myGui.Add("Text", "x56 y160 w208 h23 +0x200", "Coordinates: Not Set")
Buttoncords1 := myGui.Add("Button", "x56 y300 w208 h23", "Custom Coords")
Buttoncords1.OnEvent("Click", (*) => OpenCoordsUI(1, DropDownList2))

; SLOT 2 (removed upgrade dropdown)
myGui.Add("GroupBox", "x304 y40 w228 h298", "SLOT 2")
myGui.Add("Text", "x312 y70 w120 h23 +0x200", "PLACEMENTS")
DropDownList4 := myGui.Add("DropDownList", "x312 y94 w209", ["1", "2", "3"])
DropDownList4.Choose(1)

myGui.Add("Text", "x312 y190 w120 h23 +0x200", "PRIORITY:")
PriorityList2 := myGui.Add("DropDownList", "x312 y214 w209", ["1", "2", "3", "4", "5", "6"])
PriorityList2.Choose(2)
myGui.Add("Text", "x312 y130 w80 h23 +0x200", "AUTO SKILL:")
SkillTypeList2 := myGui.Add("DropDownList", "x396 y130 w125", ["None", "SJW Arise", "Basic"])
SkillTypeList2.Choose(1)
CoordsStatus2 := myGui.Add("Text", "x312 y160 w208 h23 +0x200", "Coordinates: Not Set")
Buttoncords2 := myGui.Add("Button", "x312 y300 w208 h23", "Custom Coords")
Buttoncords2.OnEvent("Click", (*) => OpenCoordsUI(2, DropDownList4))

; SLOT 3 (removed upgrade dropdown)
myGui.Add("GroupBox", "x560 y40 w228 h298", "SLOT 3")
myGui.Add("Text", "x568 y70 w120 h23 +0x200", "PLACEMENTS")
DropDownList6 := myGui.Add("DropDownList", "x568 y94 w209", ["1", "2", "3"])
DropDownList6.Choose(1)
myGui.Add("Text", "x568 y190 w120 h23 +0x200", "PRIORITY:")
PriorityList3 := myGui.Add("DropDownList", "x568 y214 w209", ["1", "2", "3", "4", "5", "6"])
PriorityList3.Choose(3)
myGui.Add("Text", "x568 y130 w80 h23 +0x200", "AUTO SKILL:")
SkillTypeList3 := myGui.Add("DropDownList", "x652 y130 w125", ["None", "SJW Arise", "Basic"])
SkillTypeList3.Choose(1)
CoordsStatus3 := myGui.Add("Text", "x568 y160 w208 h23 +0x200", "Coordinates: Not Set")
Buttoncords3 := myGui.Add("Button", "x568 y300 w208 h23", "Custom Coords")
Buttoncords3.OnEvent("Click", (*) => OpenCoordsUI(3, DropDownList6))

; SLOT 4 (removed upgrade dropdown)
myGui.Add("GroupBox", "x816 y40 w228 h298", "SLOT 4")
myGui.Add("Text", "x824 y70 w120 h23 +0x200", "PLACEMENTS")
DropDownList8 := myGui.Add("DropDownList", "x824 y94 w209", ["1", "2", "3"])
DropDownList8.Choose(1)
myGui.Add("Text", "x824 y190 w120 h23 +0x200", "PRIORITY:")
PriorityList4 := myGui.Add("DropDownList", "x824 y214 w209", ["1", "2", "3", "4", "5", "6"])
PriorityList4.Choose(4)
myGui.Add("Text", "x824 y130 w80 h23 +0x200", "AUTO SKILL:")
SkillTypeList4 := myGui.Add("DropDownList", "x908 y130 w125", ["None", "SJW Arise", "Basic"])
SkillTypeList4.Choose(1)
CoordsStatus4 := myGui.Add("Text", "x824 y160 w208 h23 +0x200", "Coordinates: Not Set")
Buttoncords4 := myGui.Add("Button", "x824 y300 w208 h23", "Custom Coords")
Buttoncords4.OnEvent("Click", (*) => OpenCoordsUI(4, DropDownList8))

; SLOT 5 (removed upgrade dropdown)
myGui.Add("GroupBox", "x1072 y40 w228 h298", "SLOT 5")
myGui.Add("Text", "x1080 y70 w120 h23 +0x200", "PLACEMENTS")
DropDownList10 := myGui.Add("DropDownList", "x1080 y94 w209", ["1", "2", "3"])
DropDownList10.Choose(1)
myGui.Add("Text", "x1080 y130 w80 h23 +0x200", "AUTO SKILL:")
SkillTypeList5 := myGui.Add("DropDownList", "x1164 y130 w125", ["None", "SJW Arise", "Basic"])
SkillTypeList5.Choose(1)

myGui.Add("Text", "x1080 y190 w120 h23 +0x200", "PRIORITY:")
PriorityList5 := myGui.Add("DropDownList", "x1080 y214 w209", ["1", "2", "3", "4", "5", "6"])
PriorityList5.Choose(5)
CoordsStatus5 := myGui.Add("Text", "x1080 y160 w208 h23 +0x200", "Coordinates: Not Set")
Buttoncords5 := myGui.Add("Button", "x1080 y300 w208 h23", "Custom Coords")
Buttoncords5.OnEvent("Click", (*) => OpenCoordsUI(5, DropDownList10))

; SLOT 6 (removed upgrade dropdown)
myGui.Add("GroupBox", "x1328 y40 w228 h298", "SLOT 6")
myGui.Add("Text", "x1336 y70 w120 h23 +0x200", "PLACEMENTS")
DropDownList12 := myGui.Add("DropDownList", "x1336 y94 w209", ["1", "2", "3"])
DropDownList12.Choose(1)
myGui.Add("Text", "x1336 y130 w80 h23 +0x200", "AUTO SKILL:")
SkillTypeList6 := myGui.Add("DropDownList", "x1420 y130 w125", ["None", "SJW Arise", "Basic"])
SkillTypeList6.Choose(1)
myGui.Add("Text", "x1336 y190 w120 h23 +0x200", "PRIORITY:")
PriorityList6 := myGui.Add("DropDownList", "x1336 y214 w209", ["1", "2", "3", "4", "5", "6"])
PriorityList6.Choose(6)
CoordsStatus6 := myGui.Add("Text", "x1336 y160 w208 h23 +0x200", "Coordinates: Not Set")
Buttoncords6 := myGui.Add("Button", "x1336 y300 w208 h23", "Custom Coords")
Buttoncords6.OnEvent("Click", (*) => OpenCoordsUI(6, DropDownList12))


SaveButton := myGui.Add("Button", "x690 y350 w180 h30", "Save Configuration")
SaveButton.OnEvent("Click", SaveConfig)

export := myGui.Add("Button", "x490 y350 w180 h30", "Export Config")
export.OnEvent("Click", ExportConfig)

Import := myGui.Add("Button", "x880 y350 w180 h30", "Import Config")
Import.OnEvent("Click", ImportConfig)

ManagePresets := myGui.Add("Button", "x690 y390 w180 h30", "Manage Presets")
ManagePresets.OnEvent("Click", ShowPresetsManager)

ShowPresetsManager(*) {
    presetsGui := Gui("+AlwaysOnTop", "Configuration Presets Manager")
    presetsGui.SetFont("s10", "Segoe UI")
    presetsGui.BackColor := "0x111113"
    presetsGui.SetFont("c000000")
    
    ; Create lists of configurations
    configsList := ""
    if (DirExist(A_ScriptDir "\configs")) {
        Loop Files, A_ScriptDir "\configs\*.txt" {
            configName := StrReplace(A_LoopFileName, ".txt")
            configsList .= configName "|"
        }
    }
    
    if (configsList = "")
        configsList := "No configs found"
        
    ; Add configuration list
    presetsGui.Add("Text", "x20 y20 w360 h25", "Available Configurations:")
    configsListBox := presetsGui.Add("ListBox", "x20 y50 w360 h200", StrSplit(configsList, "|"))
    
    ; Add buttons
    loadButton := presetsGui.Add("Button", "x20 y260 w110 h30", "Load")
    renameButton := presetsGui.Add("Button", "x140 y260 w110 h30", "Rename")
    deleteButton := presetsGui.Add("Button", "x260 y260 w110 h30", "Delete")
    closeButton := presetsGui.Add("Button", "x140 y300 w110 h30", "Close")
    
    ; Button event handlers
    loadButton.OnEvent("Click", LoadSelectedConfig)
    renameButton.OnEvent("Click", RenameSelectedConfig)
    deleteButton.OnEvent("Click", DeleteSelectedConfig)
    closeButton.OnEvent("Click", (*) => presetsGui.Destroy())
    
    ; Show GUI
    presetsGui.Show("w400 h340")
    
    LoadSelectedConfig(*) {
        selected := configsListBox.Text
        if (selected && selected != "No configs found") {
            configFile := A_ScriptDir "\configs\" selected ".txt"
            
            slot1Coords.Clear()
            slot2Coords.Clear()
            slot3Coords.Clear() 
            slot4Coords.Clear()
            slot5Coords.Clear()
            slot6Coords.Clear()
            
            slot1UpgradeLevels.Clear()
            slot2UpgradeLevels.Clear()
            slot3UpgradeLevels.Clear()
            slot4UpgradeLevels.Clear()
            slot5UpgradeLevels.Clear()
            slot6UpgradeLevels.Clear()
            
            if (LoadConfigFromFile(configFile)) {
                vanguardsConfigFile := A_ScriptDir "\vanguards_config.txt"
                
                try {
                    FileCopy(configFile, vanguardsConfigFile, 1) ; 1 = overwrite
                } catch as e {
                    MsgBox("Configuration loaded but failed to set as active: " e.Message)
                }
            } else {
                MsgBox("Failed to load configuration.")
            }
            
            presetsGui.Destroy()
        }
    }
    
    RenameSelectedConfig(*) {
        selected := configsListBox.Text
        if (selected && selected != "No configs found") {
            IB := InputBox("Enter new name for " selected ":", "Rename Configuration", "w300 h130")
            if (IB.Result = "Cancel" || IB.Value = "")
                return
            newName := IB.Value
            
            try {
                oldFile := A_ScriptDir "\configs\" selected ".txt"
                newFile := A_ScriptDir "\configs\" newName ".txt"
                FileMove(oldFile, newFile)
                presetsGui.Destroy()
                ShowPresetsManager()
            } catch as e {
                MsgBox("Error renaming file: " e.Message)
            }
        }
    }
    
    DeleteSelectedConfig(*) {
        selected := configsListBox.Text
        if (selected && selected != "No configs found") {
            FileDelete(A_ScriptDir "\configs\" selected ".txt")
            presetsGui.Destroy()
            ShowPresetsManager()
        }
    }
}

ExportConfig(*) {
    exportGui := Gui("+AlwaysOnTop", "Export Configuration")
    exportGui.SetFont("s10", "Segoe UI")
    exportGui.BackColor := "0x111113"
    exportGui.SetFont("cFFFFFF")
    
    ; Add map selection
    exportGui.Add("Text", "x20 y20 w100 h25", "Select Map:")
    mapDropdown := exportGui.Add("DropDownList", "x130 y20 w150", ["Namek", "Shibuya"])
    mapDropdown.Choose(1)
    
    ; Add position selection
    exportGui.Add("Text", "x20 y60 w100 h25", "Select Position:")
    posDropdown := exportGui.Add("DropDownList", "x130 y60 w150", ["start", "middle", "end"])
    posDropdown.Choose(1)
    
    ; Add custom name option
    exportGui.Add("Text", "x20 y100 w100 h25", "Custom Name:")
    customNameInput := exportGui.Add("Edit", "x130 y100 w150")
    customNameInput.SetFont("cBlack")  ; Set the text color to black for better visibility
    ; Add export to desktop option
    exportDesktopCheck := exportGui.Add("CheckBox", "x20 y140 w260 h25", "Also export to desktop")
    
    ; Add buttons
    exportButton := exportGui.Add("Button", "x70 y180 w100 h30", "Export")
    cancelButton := exportGui.Add("Button", "x180 y180 w100 h30", "Cancel")
    
    ; Button event handlers
    exportButton.OnEvent("Click", ExportConfigHandler)
    cancelButton.OnEvent("Click", (*) => exportGui.Destroy())
    
    ; Show GUI
    exportGui.Show("w300 h220")
    
    ExportConfigHandler(*) {
        map := mapDropdown.Text
        pos := posDropdown.Text
        custom := customNameInput.Text
        
        ; Determine config file name based on selections
        if (custom != "")
            configName := custom
        else
            configName := map "_" pos
        
        ; Create configs directory if it doesn't exist
        if (!DirExist(A_ScriptDir "\configs"))
            DirCreate(A_ScriptDir "\configs")
        
        ; Save to configs directory
        configFile := A_ScriptDir "\configs\" configName ".txt"
        
        ; Save the current configuration to the selected file
        if (SaveConfigToFile(configFile))
            MsgBox("Configuration saved as: " configName)
        else
            MsgBox("Failed to save configuration.")
        
        ; Export to desktop if checkbox is checked
        if (exportDesktopCheck.Value) {
            desktopFile := A_Desktop "\" configName ".txt"
            try {
                FileCopy(configFile, desktopFile, 1) ; 1 = overwrite
                MsgBox("Configuration also exported to desktop as: " configName ".txt")
            } catch as e {
                MsgBox("Error exporting to desktop: " . e.Message)
            }
        }
        
        exportGui.Destroy()
    }
}

ImportConfig(*) {
    ; Create a GUI for configuration import
    importGui := Gui("+AlwaysOnTop", "Import Configuration")
    importGui.SetFont("s10", "Segoe UI")
    importGui.BackColor := "0x111113"
    importGui.SetFont("cFFFFFF")
    
    ; Add instructions
    importGui.Add("Text", "x20 y20 w350 h40", "Select a configuration file to import. The file will be copied to your configs folder.")
    
    ; Add file selection field
    importGui.Add("Text", "x20 y70 w100 h25", "Config File:")
    filePathEdit := importGui.Add("Edit", "x130 y70 w250 h25 ReadOnly")
    filePathEdit.SetFont("cBlack")
    browseButton := importGui.Add("Button", "x390 y70 w80 h25", "Browse...")
    
    ; Add config name field
    importGui.Add("Text", "x20 y110 w100 h25", "Save As:")
    configNameEdit := importGui.Add("Edit", "x130 y110 w250 h25")
    configNameEdit.SetFont("cBlack")
    
    saveCurrentCheck := importGui.Add("CheckBox", "x20 y150 w350 h25 Checked", "Save current config before importing")
    
    ; Add buttons
    importButton := importGui.Add("Button", "x130 y190 w100 h30", "Import")
    cancelButton := importGui.Add("Button", "x240 y190 w100 h30", "Cancel")
    
    importButton.Enabled := false
    
    ; Button event handlers
    browseButton.OnEvent("Click", BrowseFile)
    importButton.OnEvent("Click", ImportConfigHandler)
    cancelButton.OnEvent("Click", (*) => importGui.Destroy())
    
    ; Show GUI
    importGui.Show("w490 h240")
    
    ; Browse for file function
    BrowseFile(*) {
        selectedFile := FileSelect("1", A_Desktop, "Select Configuration File", "Text Files (*.txt)")
        if (selectedFile) {
            filePathEdit.Value := selectedFile
            
            ; Auto-fill the save name based on the file name
            SplitPath(selectedFile, &fileName)
            configNameEdit.Value := StrReplace(fileName, ".txt")
            
            ; Enable import button
            importButton.Enabled := true
        }
    }
    
    ImportConfigHandler(*) {
        selectedFile := filePathEdit.Value
        configName := configNameEdit.Value
        
        ; Validate inputs
        if (selectedFile = "" || configName = "") {
            MsgBox("Please select a file and provide a name for the configuration.")
            return
        }
        
        ; Create configs directory if it doesn't exist
        if (!DirExist(A_ScriptDir "\configs"))
            DirCreate(A_ScriptDir "\configs")
        
        if (saveCurrentCheck.Value) {
            currentConfigName := configName "_previous"
            SaveConfigToFile(A_ScriptDir "\configs\" currentConfigName ".txt")
        }
        
        configFile := A_ScriptDir "\configs\" configName ".txt"
        try {
            FileCopy(selectedFile, configFile, 1) ; 1 = overwrite
        } catch as e {
            MsgBox("Error copying file: " e.Message)
            return
        }
        

        slot1Coords.Clear()
        slot2Coords.Clear()
        slot3Coords.Clear() 
        slot4Coords.Clear()
        slot5Coords.Clear()
        slot6Coords.Clear()
        
        slot1UpgradeLevels.Clear()
        slot2UpgradeLevels.Clear()
        slot3UpgradeLevels.Clear()
        slot4UpgradeLevels.Clear()
        slot5UpgradeLevels.Clear()
        slot6UpgradeLevels.Clear()
        
        ; Load the configuration from the file
        if (LoadConfigFromFile(configFile))
            MsgBox("Configuration imported successfully as: " configName)
        else
            MsgBox("Failed to import configuration. The file may be invalid or corrupted.")
        
        importGui.Destroy()
    }
}
SaveConfigToFile(filePath) {
    ; Get all values directly from the controls
    slot1Placements := DropDownList2.Text
    slot1SkillType := SkillTypeList1.Text
    slot1Priority := PriorityList1.Text
    
    slot2Placements := DropDownList4.Text
    slot2SkillType := SkillTypeList2.Text
    slot2Priority := PriorityList2.Text
    
    slot3Placements := DropDownList6.Text
    slot3SkillType := SkillTypeList3.Text
    slot3Priority := PriorityList3.Text
    
    slot4Placements := DropDownList8.Text
    slot4SkillType := SkillTypeList4.Text
    slot4Priority := PriorityList4.Text
    
    slot5Placements := DropDownList10.Text
    slot5SkillType := SkillTypeList5.Text
    slot5Priority := PriorityList5.Text
    
    slot6Placements := DropDownList12.Text
    slot6SkillType := SkillTypeList6.Text
    slot6Priority := PriorityList6.Text
    
    configText := ""
    
    AddSlotToConfig(slotNum, placements, skillType, priority, coordsMap, upgradesMap) {
        if (coordsMap.Count > 0) {
            configText .= "SLOT" . slotNum . ":1:" . placements . ":" . skillType . ":" . priority . ":"
            
            coordCount := 0
            for unitNum, coords in coordsMap {
                upgradeLevel := upgradesMap.Has(unitNum) ? upgradesMap[unitNum] : "1"
                configText .= coords . "|" . upgradeLevel
                coordCount++
                if (coordCount < coordsMap.Count)
                    configText .= ";"
            }
            
            configText .= "`r`n"
        }
    }
    
    ; Add each slot's configuration
    AddSlotToConfig(1, slot1Placements, slot1SkillType, slot1Priority, slot1Coords, slot1UpgradeLevels)
    AddSlotToConfig(2, slot2Placements, slot2SkillType, slot2Priority, slot2Coords, slot2UpgradeLevels)
    AddSlotToConfig(3, slot3Placements, slot3SkillType, slot3Priority, slot3Coords, slot3UpgradeLevels)
    AddSlotToConfig(4, slot4Placements, slot4SkillType, slot4Priority, slot4Coords, slot4UpgradeLevels)
    AddSlotToConfig(5, slot5Placements, slot5SkillType, slot5Priority, slot5Coords, slot5UpgradeLevels)
    AddSlotToConfig(6, slot6Placements, slot6SkillType, slot6Priority, slot6Coords, slot6UpgradeLevels)
    
    try {
        if (FileExist(filePath))
            FileDelete(filePath)
        FileAppend(configText, filePath, "UTF-8")
        return true
    } catch as e {
        MsgBox("Error saving configuration: " . e.Message)
        return false
    }
}


LoadConfigFromFile(configFile) {
    ; Check if config file exists
    if (!FileExist(configFile))
        return false
    
    ; Read the file
    try {
        fileContent := FileRead(configFile, "UTF-8")
    } catch as err {
        MsgBox("Error reading configuration file: " err.Message)
        return false
    }
    
    ; Split by lines
    slotConfigs := StrSplit(fileContent, "`n", "`r")
    
    ; Process each slot configuration
    for slotConfig in slotConfigs {
        ; Skip empty lines
        if (Trim(slotConfig) = "")
            continue
        
        ; Parse configuration for each slot
        parts := StrSplit(slotConfig, ":")
        if (parts.Length < 5)
            continue
            
        slotName := parts[1]
        upgrades := parts[2]  ; Keep for backward compatibility
        placements := parts[3]
        skillType := parts[4]  ; Now this is a skill type instead of boolean
        priority := parts[5]
        coordsStr := parts.Length >= 6 ? parts[6] : ""
        
        ; Ensure priority is a valid index (between 1-6)
        priorityNumber := Integer(priority)
        if (priorityNumber < 1 || priorityNumber > 6)
            priorityNumber := 1  ; Default to 1 if invalid
        
        ; For backwards compatibility - convert true/false to skill type
        if (skillType = "true")
            skillType := "Basic"
        else if (skillType = "false")
            skillType := "None"
        
        ; Apply configuration to the UI based on slot
        if (slotName = "SLOT1") {
            DropDownList2.Choose(placements)
            SkillTypeList1.Choose(GetSkillIndex(skillType))
            PriorityList1.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(1, coordsStr)
            UpdateCoordsStatus(1)
        } 
        else if (slotName = "SLOT2") {
            DropDownList4.Choose(placements)
            SkillTypeList2.Choose(GetSkillIndex(skillType))
            PriorityList2.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(2, coordsStr)
            UpdateCoordsStatus(2)
        }
        else if (slotName = "SLOT3") {
            DropDownList6.Choose(placements)
            SkillTypeList3.Choose(GetSkillIndex(skillType))
            PriorityList3.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(3, coordsStr)
            UpdateCoordsStatus(3)
        }
        else if (slotName = "SLOT4") {
            DropDownList8.Choose(placements)
            SkillTypeList4.Choose(GetSkillIndex(skillType))
            PriorityList4.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(4, coordsStr)
            UpdateCoordsStatus(4)
        }
        else if (slotName = "SLOT5") {
            DropDownList10.Choose(placements)
            SkillTypeList5.Choose(GetSkillIndex(skillType))
            PriorityList5.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(5, coordsStr)
            UpdateCoordsStatus(5)
        }
        else if (slotName = "SLOT6") {
            DropDownList12.Choose(placements)
            SkillTypeList6.Choose(GetSkillIndex(skillType))
            PriorityList6.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(6, coordsStr)
            UpdateCoordsStatus(6)
        }
    }
    
    return true
}

; Helper function to get skill index from skill type string
GetSkillIndex(skillType) {
    if (skillType = "None" || skillType = "false")
        return 1
    else if (skillType = "SJW Arise")
        return 2
    else if (skillType = "Basic" || skillType = "true")
        return 3
    else
        return 1  ; Default to None
}

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Vanguards Unit Customizer"
HWND_TOPMOST := -1
SWP_NOMOVE := 0x0002
SWP_NOSIZE := 0x0001
myGui.Show("w1600 h450")

; Call SetWindowPos to make the window super topmost
SetWindowPos(myGui.Hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE)

SetWindowPos(hwnd, hWndInsertAfter, X, Y, cx, cy, uFlags) {
    DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", hWndInsertAfter, 
             "Int", X, "Int", Y, "Int", cx, "Int", cy, "UInt", uFlags)
}
LoadSavedConfig()  

LoadSavedConfig() {
    configFile := A_ScriptDir "\vanguards_config.txt"
    
    ; Check if config file exists
    if (!FileExist(configFile))
        return false
    
    ; Read the file
    try {
        fileContent := FileRead(configFile, "UTF-8")
    } catch as err {
        MsgBox("Error reading configuration file: " err.Message)
        return false
    }
    

    slotConfigs := StrSplit(fileContent, "`n", "`r")
    

    for slotConfig in slotConfigs {
    
        if (Trim(slotConfig) = "")
            continue
        
      
        parts := StrSplit(slotConfig, ":")
        if (parts.Length < 5)
            continue
            
        slotName := parts[1]
        upgrades := parts[2]  
        placements := parts[3]
        skillType := parts[4] 
        priority := parts[5]
        coordsStr := parts.Length >= 6 ? parts[6] : ""
        
        ; Ensure priority is a valid index (between 1-6)
        priorityNumber := Integer(priority)
        if (priorityNumber < 1 || priorityNumber > 6)
            priorityNumber := 1  ; Default to 1 if invalid
        
        ; For backwards compatibility - convert true/false to skill type
        if (skillType = "true")
            skillType := "Basic"
        else if (skillType = "false")
            skillType := "None"
        
        ; Apply configuration to the UI based on slot
        if (slotName = "SLOT1") {
            DropDownList2.Choose(placements)
            SkillTypeList1.Choose(GetSkillIndex(skillType))
            PriorityList1.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(1, coordsStr)
            UpdateCoordsStatus(1)
        } 
        else if (slotName = "SLOT2") {
            DropDownList4.Choose(placements)
            SkillTypeList2.Choose(GetSkillIndex(skillType))
            PriorityList2.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(2, coordsStr)
            UpdateCoordsStatus(2)
        }
        else if (slotName = "SLOT3") {
            DropDownList6.Choose(placements)
            SkillTypeList3.Choose(GetSkillIndex(skillType))
            PriorityList3.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(3, coordsStr)
            UpdateCoordsStatus(3)
        }
        else if (slotName = "SLOT4") {
            DropDownList8.Choose(placements)
            SkillTypeList4.Choose(GetSkillIndex(skillType))
            PriorityList4.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(4, coordsStr)
            UpdateCoordsStatus(4)
        } 
        else if (slotName = "SLOT5") {
            DropDownList10.Choose(placements)
            SkillTypeList5.Choose(GetSkillIndex(skillType))
            PriorityList5.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(5, coordsStr)
            UpdateCoordsStatus(5)
        } 
        else if (slotName = "SLOT6") {
            DropDownList12.Choose(placements)
            SkillTypeList6.Choose(GetSkillIndex(skillType))
            PriorityList6.Choose(priorityNumber)
            
            ; Load coordinates
            ParseAndStoreCoordsForSlot(6, coordsStr)
            UpdateCoordsStatus(6)
        }
    }
    
    return true
}
ParseAndStoreCoordsForSlot(slotNumber, coordsStr) {
    if (coordsStr = "")
        return
        
    coordsList := StrSplit(coordsStr, ";")
    
    for index, coordUpgradePair in coordsList {
        parts := StrSplit(coordUpgradePair, "|")
        coords := parts[1]
        
        ; Store coordinates
        if (slotNumber = 1)
            slot1Coords[index] := coords
        else if (slotNumber = 2)
            slot2Coords[index] := coords
        else if (slotNumber = 3)
            slot3Coords[index] := coords
        else if (slotNumber = 4)
            slot4Coords[index] := coords
        else if (slotNumber = 5)
            slot5Coords[index] := coords
        else if (slotNumber = 6)
            slot6Coords[index] := coords
            
        ; If upgrade level is specified, store it
        if (parts.Length > 1) {
            upgradeLevel := parts[2]
            
            if (slotNumber = 1)
                slot1UpgradeLevels[index] := upgradeLevel
            else if (slotNumber = 2)
                slot2UpgradeLevels[index] := upgradeLevel
            else if (slotNumber = 3)
                slot3UpgradeLevels[index] := upgradeLevel
            else if (slotNumber = 4)
                slot4UpgradeLevels[index] := upgradeLevel
            else if (slotNumber = 5)
                slot5UpgradeLevels[index] := upgradeLevel
            else if (slotNumber = 6)
                slot6UpgradeLevels[index] := upgradeLevel
        }
    }
}


OpenCoordsUI(slotNumber, placementsDropDown) {
    numPlacements := Integer(placementsDropDown.Text)
    
    coordsGui := Gui("+Owner" myGui.Hwnd)
    coordsGui.Title := "Custom Coordinates for Slot " slotNumber
    
    unitButtons := []
    unitCoordTexts := []
    upgradeDropdowns := []
    
    coordsMap := slotNumber = 1 ? slot1Coords : 
    slotNumber = 2 ? slot2Coords : 
    slotNumber = 3 ? slot3Coords : 
    slotNumber = 4 ? slot4Coords :
    slotNumber = 5 ? slot5Coords : slot6Coords
    
    upgradesMap := slotNumber = 1 ? slot1UpgradeLevels : 
      slotNumber = 2 ? slot2UpgradeLevels : 
      slotNumber = 3 ? slot3UpgradeLevels : 
      slotNumber = 4 ? slot4UpgradeLevels :
      slotNumber = 5 ? slot5UpgradeLevels : slot6UpgradeLevels
    
    ; Add instructions
    coordsGui.Add("Text", "x20 y20 w450 h40", 
        "Click 'Set Coordinates' buttons and then click in the game window to set unit positions.")
    
    Loop numPlacements {
        index := A_Index

        baseY := 70 + (index-1) * 100
     
        coordsGui.Add("Text", "x20 y" baseY " w100 h23 +0x200", "Unit " index)
        
      
        coordText := coordsGui.Add("Text", "x130 y" baseY " w200 h23 +0x200", 
            coordsMap.Has(index) ? "Coordinates: " coordsMap[index] : "Coordinates: Not Set")
        unitCoordTexts.Push(coordText)
        

        unitButton := coordsGui.Add("Button", "x20 y" (baseY + 25) " w310 h30", "Set Coordinates for Unit " index)
        unitButtons.Push(unitButton)
        
   
        coordsGui.Add("Text", "x20 y" (baseY + 60) " w100 h23 +0x200", "Upgrades:")
        upgradeDropdown := coordsGui.Add("DropDownList", "x130 y" (baseY + 60) " w200", 
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "MAX"])
        
    
        if (upgradesMap.Has(index))
            upgradeDropdown.Choose(upgradesMap[index])
        else
            upgradeDropdown.Choose(1)
            
        upgradeDropdowns.Push(upgradeDropdown)
        
        unitIndex := index  
        unitButton.OnEvent("Click", GetCoordHandler.Bind(slotNumber, unitIndex, unitCoordTexts[unitIndex], 
            coordsGui, 0, &markers))
    }
    
    ; Add a save button
    doneButton := coordsGui.Add("Button", "x20 y" (baseY + 100) " w310 h30", "Done")
    doneButton.OnEvent("Click", DoneButtonHandler.Bind(slotNumber, coordsGui, upgradeDropdowns))
    
    coordsGui.Show("w350 h" (baseY + 150) " x300 y50")
}

DoneButtonHandler(slotNumber, coordsGui, upgradeDropdowns, *) {
    Loop upgradeDropdowns.Length {
        unitIndex := A_Index
        upgradeLevel := upgradeDropdowns[unitIndex].Text
        
        ; Store the upgrade level in a new Map
        if (slotNumber = 1) {
            if (!IsObject(slot1UpgradeLevels))
                global slot1UpgradeLevels := Map()
            slot1UpgradeLevels[unitIndex] := upgradeLevel
        }
        else if (slotNumber = 2) {
            if (!IsObject(slot2UpgradeLevels))
                global slot2UpgradeLevels := Map()
            slot2UpgradeLevels[unitIndex] := upgradeLevel
        }
        else if (slotNumber = 3) {
            if (!IsObject(slot3UpgradeLevels))
                global slot3UpgradeLevels := Map()
            slot3UpgradeLevels[unitIndex] := upgradeLevel
        }
        else if (slotNumber = 4) {
            if (!IsObject(slot4UpgradeLevels))
                global slot4UpgradeLevels := Map()
            slot4UpgradeLevels[unitIndex] := upgradeLevel
        } else if (slotNumber = 5) {
            if (!IsObject(slot5UpgradeLevels))
                global slot5UpgradeLevels := Map()
            slot5UpgradeLevels[unitIndex] := upgradeLevel
        } else if (slotNumber = 6) {
            if (!IsObject(slot6UpgradeLevels))
                global slot6UpgradeLevels := Map()
            slot6UpgradeLevels[unitIndex] := upgradeLevel
        }
    }
    
    UpdateCoordsStatus(slotNumber)
    coordsGui.Destroy()
}

GetCoordHandler(slotNumber, unitIndex, coordText, coordsGui, mapPicture, &markers, *) {
    GetUnitCoords(slotNumber, unitIndex, coordText, coordsGui, mapPicture, &markers)
}

GetUnitCoords(slotNumber, unitNumber, coordText, coordsGui, mapPicture, &markers) {
    CoordMode "Mouse", "Window"
    
    ToolTip("Click in the game window to set placement coordinates for Unit " unitNumber " in Slot " slotNumber)
    
   
    KeyWait "LButton", "D"
    MouseGetPos(&xpos, &ypos)
    coords := xpos . "," . ypos
    
    if (slotNumber = 1)
        slot1Coords[unitNumber] := coords
    else if (slotNumber = 2)
        slot2Coords[unitNumber] := coords
    else if (slotNumber = 3)
        slot3Coords[unitNumber] := coords
    else if (slotNumber = 4)
        slot4Coords[unitNumber] := coords
    else if (slotNumber = 5)
        slot5Coords[unitNumber] := coords
    else if (slotNumber = 6)
        slot6Coords[unitNumber] := coords
    
    coordText.Value := "Coordinates: " coords
    
    ToolTip()
    Sleep 200  
}
UpdateCoordsStatus(slotNumber) {
    coordsMap := slotNumber = 1 ? slot1Coords : 
               slotNumber = 2 ? slot2Coords : 
               slotNumber = 3 ? slot3Coords : 
               slotNumber = 4 ? slot4Coords :
               slotNumber = 5 ? slot5Coords : slot6Coords
    
    if (coordsMap.Count > 0) {
        statusText := "Coordinates: Set for " coordsMap.Count " unit(s)"
        
        if (slotNumber = 1)
            CoordsStatus1.Value := statusText
        else if (slotNumber = 2)
            CoordsStatus2.Value := statusText
        else if (slotNumber = 3)
            CoordsStatus3.Value := statusText
        else if (slotNumber = 4)
            CoordsStatus4.Value := statusText
        else if (slotNumber = 5)
            CoordsStatus5.Value := statusText
        else if (slotNumber = 6)
            CoordsStatus6.Value := statusText
    }
}

SaveConfig(*) {
    slot1Placements := DropDownList2.Text
    slot1SkillType := SkillTypeList1.Text
    slot1Priority := PriorityList1.Text
    
    slot2Placements := DropDownList4.Text
    slot2SkillType := SkillTypeList2.Text
    slot2Priority := PriorityList2.Text
    
    slot3Placements := DropDownList6.Text
    slot3SkillType := SkillTypeList3.Text
    slot3Priority := PriorityList3.Text
    
    slot4Placements := DropDownList8.Text
    slot4SkillType := SkillTypeList4.Text
    slot4Priority := PriorityList4.Text
    
    slot5Placements := DropDownList10.Text
    slot5SkillType := SkillTypeList5.Text
    slot5Priority := PriorityList5.Text
    
    slot6Placements := DropDownList12.Text
    slot6SkillType := SkillTypeList6.Text
    slot6Priority := PriorityList6.Text
    
    configFile := A_ScriptDir "\vanguards_config.txt"
    
    if (!FileExist(A_ScriptDir) || !InStr(FileExist(A_ScriptDir), "D"))
        configFile := A_ScriptDir "\..\vanguards_config.txt"
    
    configText := ""
    
    AddSlotToConfig(slotNum, placements, skillType, priority, coordsMap, upgradesMap) {
        if (coordsMap.Count > 0) {
            ; Use "1" as a default placeholder for the removed global upgrade setting
            configText .= "SLOT" . slotNum . ":1:" . placements . ":" . skillType . ":" . priority . ":"
            
            ; Add each unit's coordinates and individual upgrade level
            coordCount := 0
            for unitNum, coords in coordsMap {
                upgradeLevel := upgradesMap.Has(unitNum) ? upgradesMap[unitNum] : "1"
                configText .= coords . "|" . upgradeLevel
                coordCount++
                if (coordCount < coordsMap.Count)
                    configText .= ";"
            }
            configText .= "`r`n"
        }
    }
    
    AddSlotToConfig(1, slot1Placements, slot1SkillType, slot1Priority, slot1Coords, slot1UpgradeLevels)
    AddSlotToConfig(2, slot2Placements, slot2SkillType, slot2Priority, slot2Coords, slot2UpgradeLevels)
    AddSlotToConfig(3, slot3Placements, slot3SkillType, slot3Priority, slot3Coords, slot3UpgradeLevels)
    AddSlotToConfig(4, slot4Placements, slot4SkillType, slot4Priority, slot4Coords, slot4UpgradeLevels)
    AddSlotToConfig(5, slot5Placements, slot5SkillType, slot5Priority, slot5Coords, slot5UpgradeLevels)
    AddSlotToConfig(6, slot6Placements, slot6SkillType, slot6Priority, slot6Coords, slot6UpgradeLevels)
    
    ; Write to file with explicit encoding and proper line endings
    try {
        if (FileExist(configFile))
            FileDelete(configFile)
        FileAppend(configText, configFile, "UTF-8")
        MsgBox("Configuration saved to: " . configFile)
    } catch as e {
        MsgBox("Error saving configuration: " . e.Message)
    }
}