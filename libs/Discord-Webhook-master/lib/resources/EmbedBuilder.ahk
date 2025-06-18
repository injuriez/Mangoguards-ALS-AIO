/************************************************************************
 * @description Part of ninjus Discord.ahk library
 * @file EmbedBuilder.ahk
 * @author ninju | .ninju.
 * @date 2024/07/12
 * @version 0.0.2
 ***********************************************************************/

Class EmbedBuilder {
    __New() {
        this.embedObj := {}
        this.embedObj.color := 0x2b2d31 + 0 ; Discord Embed color
    }
    /**
     * @method setTitle()
     * @param {string} title 
     */
    setTitle(title) {
        if !(title is String)
            throw Error("expected a string", , title)
        this.embedObj.title := title
        return this
    }
    /**
     * @method setDescription()
     * @param {string} description 
     */
    setDescription(description) {
        if !(description is String)
            throw Error("expected a string", , description)
        this.embedObj.description := description
        return this
    }
    /**
     * @method setURL()
     * @param {URL} URL 
     */
    setURL(URL) {
        if !(URL is String)
            throw Error("expected a string", , URL)
        if !(RegExMatch(URL, ":\/\/"))
            throw Error("expected an URL", , URL)
        this.embedObj.url := URL
        return this
    }
    /**
     * @method setColor()
     * @param {Hex | Decimal Integer} Color 
     */
    setColor(Color) {
        if !(Color is Integer)
            throw Error("expected an integer", , Color)
        this.embedObj.color := Color + 0
        return this
    }
    /**
     * @method setTimestamp()
     * @param {timestamp} timestamp "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"
     * @default this.now()
     */
    setTimeStamp(timestamp?) {
        time := A_Now
        timestamp := timestamp ?? SubStr(time, 1, 4) "-" SubStr(time, 5, 2) "-" SubStr(time, 7, 2) "T" SubStr(time, 9, 2) ":" SubStr(time, 11, 2) ":" SubStr(time, 13, 2) ".000Z"
        if !RegExMatch(timestamp, "i)\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}")
            throw Error("invalid timestamp", , timestamp)
        this.embedObj.timestamp := timestamp
        return this
    }
    /**
     * @method setAuthor()
     * @param {object} author
     * @property {string} name
     * @property {url} url
     * @property {url} icon_url
     */
    setAuthor(author) {
        if !(author is object)
            throw Error("Expected an object literal")
        for k, v in author.OwnProps()
            if !this.hasVal(["name", "icon_url", "url"], k)
                throw Error("Expected one of the following propertires: `"name`", `"icon_url`", `"url`"`nReceived: " k)
        this.embedObj.author := author
        return this
    }
    /**
     * @method addFields()
     * @param {array of objects} fields .addFields([{name:"name",value:"value"}])
     * @property {string} name
     * @property {string} value
     * @property {Boolean} inline
     */
    addFields(fields) {
        if !(fields is Array)
            throw Error("expected an array", , fields)
        for i in fields {
            if !(i is Object)
                throw Error("Expected an object literal")
            for k, v in i.OwnProps()
                if !this.hasVal(["name", "value", "inline"], k)
                    throw Error("Expected one of the following propertires: `"name`", `"value`", `"inline`"`nReceived: " k)
        }
        if this.embedObj.HasProp("fields")
            this.embedObj.fields.push(fields)
        else this.embedObj.fields := fields
        return this
    }
    /**
     * @method setFooter()
     * @param {object} footer
     * @property {string} text
     * @property {url} icon_url
     */
    setFooter(footer) {
        if !(footer is object)
            throw Error("Expected an object literal")
        for k, v in footer.OwnProps()
            if !this.hasVal(["text", "icon_url"], k)
                throw Error("Expected one of the following propertires: `"text`", `"icon_url`"`nReceived: " k)
        this.embedObj.footer := footer
        return this
    }
    /**
     * @method setThumbnail()
     * @param {object} thumbnail
     * @property {url} url
     */
    setThumbnail(thumbnail) {
        if !IsObject(thumbnail)
            throw Error("expected an object", , thumbnail)
        if !RegExMatch(thumbnail.url, ":\/\/")
            throw Error("requires an url or attachment.attachmentName (attachment://filename.extension)", , thumbnail.url)
        this.embedObj.thumbnail := thumbnail
        return this
    }
    hasVal(obj, val) {
        for k, v in obj
            if v = val
                return k
        return 0
    }
    /**
     * @method setImage()
     * @param {object} image
     * @property {url} url 
     */
    setImage(image) {
        if image is AttachmentBuilder {
            this.embedObj.image := {url: image.attachmentName}
            return this
        }
        if !IsObject(image)
            throw Error("expected an object", , image)
        if !RegExMatch(image.url, ":\/\/")
            throw Error("requires an url or attachment.attachmentName (attachment://filename.extension)", , image.url)
        this.embedObj.image := image
        return this
    }
}
