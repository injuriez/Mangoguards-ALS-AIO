#Requires AutoHotkey v2.0
#Include ../../FindText.ahk

bleh() {
        TowerLimitPattern := "|<>*121$65.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzxzw1zzzznnznDzDzzzzbzzyTyMGG4DD818TwUE98ySE2NzvAUEHwwYYnzr31nrxxdBXzjDPVjsPPPbzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw" ; Placeholder pattern

    if (FindText(&X, &Y, 702-150000, 680-150000, 702+150000, 680+150000, 0, 0, TowerLimitPattern)) {
        MsgBox("Tower Limit found at coordinates: " X ", " Y, "Tower Limit Detected", 64)

    }
            
}
F9::bleh