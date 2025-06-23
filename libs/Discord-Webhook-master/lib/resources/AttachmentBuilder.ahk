/************************************************************************
 * @description Part of ninjus Discord.ahk library
 * @file AttachmentBuilder.ahk
 * @author ninju | .ninju.
 * @date 2024/07/12
 * @version 0.0.1
 ***********************************************************************/

Class AttachmentBuilder {
	/**
	 * new AttachmentBuilder()
	 * @param File relative path to file
	 */
	__New(param) {
		if !FileExist(param)
			try Integer(param)
			catch 
				Throw Error("AttachmentBuilder: File does not exist",,param)
		this.fileName := "image.png", this.file := param, this.isBitmap := 1
		loop files param
			this.file := A_LoopFileFullPath, this.fileName := A_LoopFileName, this.isBitmap := 0
		this.attachmentName := "attachment://" this.fileName, this.contentType := this.isBitmap ? "image/png" : AttachmentBuilder.MimeType(this.fileName)
	}
    static MimeType(path) {
        n :=(f:=FileOpen(path, "r")).ReadUInt(), f.Close()
        Return (n = 0x474E5089) ? "image/png"
        : (n = 0x38464947) ? "image/gif"
        : (n & 0xFFFF0000 = 0x4D42) ? "image/bmp"
        : (n & 0xFFFF0000 = 0xD8FF) ? "image/jpeg"
        : (n & 0xFFFF = 0x4949) ? "image/tiff"
        : (n & 0xFFFF = 0x4D4D) ? "image/tiff"
        : (n & 0xFFFFFFFF = 0x504B0304) ? "application/zip"
        : (n & 0xFFFF0000 = 0xFFFB) ? "audio/mp3"
        : (n & 0xFFFFFFFF = 0x25504446) ? "application/pdf"
        : (n & 0xFFFFFFFF = 0x89504E47) ? "image/x-icon"
        : (n & 0xFFFFFFFF = 0x52494646) ? "audio/wav"
        : (n & 0xFFFFFFFF = 0x7F454C46) ? "application/x-elf"
        : (n & 0xFFFFFFFF = 0x464C5601) ? "video/x-flv"
        : (n & 0xFFFFFFFF = 0x000001BA) ? "video/mpeg"
        : (n & 0xFFFFFFFF = 0x000001B3) ? "video/mpeg"
        : "application/octet-stream"
    }
}