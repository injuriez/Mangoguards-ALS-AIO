/************************************************************************
 * @description FormData class for creating form data for POST requests
 * @file FormData.ahk
 * @author ninju | .ninju.
 * @date 2024/07/08
 * @version 0.0.1
 * @credits Based on the Discord.CreateFormData method by SP (or zspz) from https://github.com/NatroTeam/NatroMacro
 ***********************************************************************/

Class FormData {
    __New() {
        this.boundary := '------------------------------' SubStr(A_Now, 1, 12)
        this.hGlobal := DllCall("GlobalAlloc", "UInt", 2, "Ptr", 0, "ptr")
        this.pStream := (DllCall("ole32\CreateStreamOnHGlobal", "ptr", this.hGlobal, "int", false, "ptrp", &_:=0, "uint"), _)
        this.fileCount:=0
        this.contentType := "multipart/form-data; boundary=" SubStr(this.boundary, 3)
    }
    Call(data) {
        str :=
        (
        '
        ' . this.boundary . '
        Content-Disposition: form-data; name="' . data.name . '"' . (data.hasProp("filename") ? '; filename="' . data.filename . '"' : "") . '
        Content-Type: ' . data.type . '

        ' . (data.hasProp("string") ? data.string . "`r`n": "")
        )
        A_Clipboard := str
        this.utf8(str)
        if (data.hasProp("pBitmap")) {
            try {
                DllCall("gdiplus\GdipGetImageEncodersSize", "uintp", &n:=0, "uintp", &s:=0)
                c := Buffer(s)
                DllCall("gdiplus\GdipGetImageEncoders", "uint", n, "uint", s, "ptr", c)
                if !(s && n)
                    throw Error("no image encoders found")
                loop n {
                    addr := NumGet(c, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize, "UPtr")
                    str := StrGet(addr, "UTF-16")
                    if !InStr(str, "*.png")
                        continue
            
                    pCodec := c.ptr+idx
                    break
                }
                if !IsSet(pCodec)
                    throw Error("no PNG encoder found")
                DllCall("GdiPlus\GdipSaveImageToStream", "ptr", data.pBitmap, "ptr", this.pStream, "ptr", pCodec, "uint", 0)
			}
        }
        if (data.hasProp("file")) {
            DllCall("shlwapi\SHCreateStreamOnFileEx", "WStr", data.file, "Int", 0, "UInt", 0x80, "Int", 0, "Ptr", 0, "PtrP", &pFileStream:=0)
			DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
			DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", this.pStream, "UInt", size, "UInt")
			ObjRelease(pFileStream)
        }
        return this
    }
    AppendJSON(name, value) => this({name: name, string: JSON.stringify(value, false, ""), type: "application/json"})
    AppendBitmap(pBitmap, filename?) => this({name: 'files[' this.fileCount++ ']',pBitmap: pBitmap, filename: filename ?? 'image.png', type: "image/png"})
    AppendFile(file, contentType := 'application/octet-stream') => this({name: 'files[' this.fileCount++ ']', file: file, type: contentType, filename: (SplitPath(file, &name), name)})
    AppendString(name, value) => this({name: name, string: value, type: "text/plain"})
    utf8(str) {
        StrPut(str, buf:=Buffer(StrPut(str, "UTF-8") - 1), buf.Size, "UTF-8")
        DllCall("shlwapi\IStream_Write", "ptr", this.pStream, "ptr", buf, "uint", buf.Size)
    }
    data() {
        if this.HasOwnProp("_data")
            return this._data
        this.utf8('`r`n`r`n' this.boundary '--`r`n')
        ObjRelease(this.pStream)
        pGlobal := DllCall("GlobalLock", "Ptr", this.hGlobal, "ptr")
        size := DllCall("GlobalSize", "ptr", pGlobal, "uint")
        data := ComObjArray(0x11, size)
        pvData := NumGet(ComObjValue(data), 8 + A_PtrSize, "ptr")
        DllCall("RtlMoveMemory", "ptr", pvData, "ptr", pGlobal, "uint", size)

        DllCall("GlobalUnlock", "Ptr", this.hGlobal)
        DllCall("GlobalFree", "Ptr", this.hGlobal)
        this._data := data
        return data
    }
}