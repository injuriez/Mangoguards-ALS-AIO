/************************************************************************
 * @description Part of ninjus Discord.ahk library
 * @file WebHookBuilder.ahk
 * @author ninju | .ninju.
 * @date 2024/07/12
 * @version 0.0.1
 ***********************************************************************/

Class WebHookBuilder {
    __New(webhookURL) {
        if !(webhookURL ~= 'i)https?:\/\/discord\.com\/api\/webhooks\/(\d{18,19})\/[\w-]{68}')
            throw Error("invalid webhook URL", , webhookURL)
        this.webhookURL := webhookURL   
    }
    Call(method, options) {
        defaultHeaders := {
            %"User-Agent"%: "DiscordBot (by Ninju)"
        }
        (whr := ComObject("WinHttp.WinHttpRequest.5.1")).Open(method, this.webhookURL, false)
        for i, j in defaultHeaders.OwnProps()
            whr.SetRequestHeader(i, j)
        for i, j in (options.hasProp("header") ? options.header : {}).OwnProps()
            whr.SetRequestHeader(i, j)
        if options.hasProp("body") {
            whr.Send(options.hasProp("body") ? ((IsObject(options.hasProp("body") ? options.body : "") && !(options.body is ComObjArray || options.body is FormData)) ? JSON.stringify(options.hasProp("body") ? options.body : "") : (options.body is FormData) ? (options.body).data() : options.hasProp("body") ? options.body : "") : "")
        }
        return { status: whr.Status, text: whr.ResponseText, json: JSON.parse(whr.ResponseText) }
    }
    send(obj) {
        contentType := "application/json"
        if obj.hasProp("embeds") {
            embeds := []
            for i, j in obj.embeds {
                if j is EmbedBuilder
                    embeds.Push(j.embedObj)
                else embeds.Push(j)
            }
            obj.embeds := embeds
        }
        if obj.hasProp("files") {
            form := FormData()
            for i, j in obj.files {
                if !j is AttachmentBuilder
                    throw Error("expected AttachmentBuilder")
                if j.isBitmap
                    form.AppendBitmap(j.file, j.fileName)
                else form.AppendFile(j.file, j.contentType)
                obj.files[i] := j.attachmentName
            }
            form.AppendJSON("payload_json", { content: obj.hasProp("content") ? obj.content : "", embeds: embeds ?? [], files: obj.files})
            contentType := form.contentType, body := form.data()
        }
        return this("POST", { header: { %"Content-Type"%: contentType }, body: body ?? obj })
    }
}
