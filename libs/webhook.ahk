#Requires AutoHotkey v2.0
#Include AHKv2-Gdip-master\Gdip_All.ahk
#Include Discord-Webhook-master\lib\WEBHOOK.ahk
#SingleInstance Force
global webhook := ""

SendWebhook() {
    ; Check if webhook is properly configured
    global webhook
    if (!webhook || webhook == "") {
        return
    }
    
    pToken := Gdip_Startup()
    if !pToken {
        MsgBox("Failed to initialize GDI+")
        return
    }

    ; Find the Roblox window and your UI
    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
    UIWindow := "Mango"
    
    ; Check if Roblox is running
    if !WinExist(RobloxWindow) {
        MsgBox("Roblox window not found - skipping webhook")
        Gdip_Shutdown(pToken)
        return
    }
    
    ; Get the position and size of the UI window
    if !WinExist(UIWindow) {
        MsgBox("UI window '" . UIWindow . "' not found - using Roblox window for screenshot")
        WinGetPos(&UIX, &UIY, &UIWidth, &UIHeight, RobloxWindow)
    } else {
        WinGetPos(&UIX, &UIY, &UIWidth, &UIHeight, UIWindow)
    }
    
    ; Capture the UI area
    pBitmap := Gdip_BitmapFromScreen(UIX . "|" . UIY . "|" . UIWidth . "|" . UIHeight)
    
    if !pBitmap {
        MsgBox("Failed to capture the screen - skipping webhook")
        Gdip_Shutdown(pToken)
        return
    }

    ; Read stats from ALS.ahk global variables
    ; Include the ALS.ahk file to access the global variables
    ; The variables Wins, Losses are already available globally
    global Wins, Losses, TotalRuns
    
    ; Use the actual values from the global variables
    wins := Wins
    losses := Losses
    totalRuns := TotalRuns

    ; Read total time usage and convert to HH:MM:SS
   

    ; Prepare the attachment and embed
    attachment := AttachmentBuilder(pBitmap)
    myEmbed := EmbedBuilder()
        .setAuthor({ name: "MangoGuards", icon_url: "https://cdn.discordapp.com/attachments/1342045511175376962/1342714291089969202/mango.png?ex=67c28ca1&is=67c13b21&hm=d0cbfa9458dcb435d4d9256446f70a22bccbf61bf2ae700237dabaac8a0841b8&"})
        .setTitle("Game Completed")
        .setDescription("**Wins:** " wins " | **Losses:** " losses " | **Total Runs:** " totalRuns "")
        .setColor(0xFFBF34)
        .setImage(attachment)
        .setFooter({ text: "MangoGuards" })
        .setTimeStamp()

    ; Assign a value to UserIDSent
    UserIDSent := ""

    ; Send the webhook
    webhook.send({
        content: UserIDSent,
        embeds: [myEmbed],
        files: [attachment]
    })

    ; Clean up resources
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
}



CropImage(pBitmap, x, y, width, height) {
    croppedBitmap := Gdip_CreateBitmap(width, height)
    if !croppedBitmap
        return 0
    g := Gdip_GraphicsFromImage(croppedBitmap)
    Gdip_DrawImage(g, pBitmap, 0, 0, width, height, x, y, width, height)
    Gdip_DeleteGraphics(g)
    return croppedBitmap
}

InitiateWebhook() {
    ; Get the correct path - remove the duplicate "libs\"
    filePath := A_ScriptDir . "\libs\settings\webhook.txt"
    
    ; Check if directory exists, create if it doesn't
    fileDir := A_ScriptDir . "\libs\settings"
    if !DirExist(fileDir)
        DirCreate(fileDir)
    
    ; Use try/catch to handle file errors
    try {
        global WebhookURL := FileRead(filePath, "UTF-8")
    } catch as err {
        MsgBox("Error reading webhook file: " . err.Message . "`n`nCreating empty file at:`n" . filePath)
        ; Create the file if it doesn't exist
        try {
            FileAppend("", filePath)
            global WebhookURL := ""
        } catch as writeErr {
            MsgBox("Failed to create webhook file: " . writeErr.Message)
            return
        }
    }
    
    if (WebhookURL = "") {
        return
    }

    ; Updated regex to be more flexible with webhook URLs
    if (WebhookURL ~= 'i)https?:\/\/discord\.com\/api\/webhooks\/\d{17,19}\/[\w-]+') {
        global webhook := WebHookBuilder(WebhookURL)
    } else {
        MsgBox("Invalid webhook URL format")
    }
}

SendWebhookWithResult(gameResult := "", wins := 0, losses := 0, totalRuns := 0) {
    ; Check if webhook is properly configured
    global webhook
    if (!webhook || webhook == "") {
        MsgBox("Webhook not configured - skipping webhook send")
        return
    }
    
    pToken := Gdip_Startup()
    if !pToken {
        MsgBox("Failed to initialize GDI+")
        return
    }

    ; Find the Roblox window and your UI
    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
    UIWindow := "Mango"
    
    ; Check if Roblox is running
    if !WinExist(RobloxWindow) {
        MsgBox("Roblox window not found - skipping webhook")
        Gdip_Shutdown(pToken)
        return
    }
    
    ; Get the position and size of the UI window
    if !WinExist(UIWindow) {
        MsgBox("UI window '" . UIWindow . "' not found - using Roblox window for screenshot")
        WinGetPos(&UIX, &UIY, &UIWidth, &UIHeight, RobloxWindow)
    } else {
        WinGetPos(&UIX, &UIY, &UIWidth, &UIHeight, UIWindow)
    }
    
    ; Capture the UI area
    pBitmap := Gdip_BitmapFromScreen(UIX . "|" . UIY . "|" . UIWidth . "|" . UIHeight)
    
    ; Use the stats passed as parameters
    ; wins, losses, totalRuns are already available from function parameters
    if !pBitmap {
        MsgBox("Failed to capture the screen - skipping webhook")
        Gdip_Shutdown(pToken)
        return
    }

    ; Customize embed based on game result
    embedTitle := "Game Completed"
    embedColor := 0xFFBF34  ; Default gold color
    resultEmoji := "🎮"
    GameMode := "Unknown"
    
    if (gameResult == "won") {
        embedTitle := "🎉 Victory!"
        embedColor := 0x00FF00  ; Green for wins
        resultEmoji := "🏆"
    } else if (gameResult == "lost") {
        embedTitle := "💀 Defeat"
        embedColor := 0xFF0000  ; Red for losses
        resultEmoji := "❌"
    }

    ; Prepare the attachment and embed
    attachment := AttachmentBuilder(pBitmap)
    myEmbed := EmbedBuilder()
        .setAuthor({ name: "MangoGuards", icon_url: "https://cdn.discordapp.com/attachments/1342045511175376962/1342714291089969202/mango.png?ex=67c28ca1&is=67c13b21&hm=d0cbfa9458dcb435d4d9256446f70a22bccbf61bf2ae700237dabaac8a0841b8&"})
        .setTitle(embedTitle)
        .setDescription(resultEmoji . " **Wins:** " wins " | **Losses:** " losses " | **Total Runs:** " totalRuns "")
        .setColor(embedColor)
        .setImage(attachment)
        .setFooter({ text: "MangoGuards" })
        .setTimeStamp()

    ; Assign a value to UserIDSent
    UserIDSent := ""

    ; Send the webhook
    webhook.send({
        content: UserIDSent,
        embeds: [myEmbed],
        files: [attachment]
    })

    ; Clean up resources
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
}

InitiateWebhook()



F7::SendWebhookWithResult("won", 5, 3, 8)  ; Test with sample stats
