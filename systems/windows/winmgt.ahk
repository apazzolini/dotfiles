#Requires AutoHotkey v2.0

RDim      := [0, 0, 3840, 2160]
TaskbarH  := 42   ; taskbar height in pixels
PadX      := 8    ; gap on all horizontal edges and between tiled windows
PadY      := 8    ; gap on all vertical edges and between tiled windows

GetDimensions() {
    global RDim, TaskbarH
    d := RDim.Clone()
    d[4] := d[4] - TaskbarH  ; usable height
    return d
}

; Returns the visible (DWM) rect as [l, t, r, b]
GetVisibleRect(hwnd) {
    extRECT := Buffer(16, 0)
    DllCall("dwmapi\DwmGetWindowAttribute",
        "Ptr", hwnd, "UInt", 9, "Ptr", extRECT, "UInt", 16)
    return [NumGet(extRECT, 0, "Int"), NumGet(extRECT, 4, "Int"),
            NumGet(extRECT, 8, "Int"), NumGet(extRECT, 12, "Int")]
}

GetWindowBorders(hwnd) {
    ext := GetVisibleRect(hwnd)
    winRECT := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", winRECT)
    winL := NumGet(winRECT, 0, "Int")
    winT := NumGet(winRECT, 4, "Int")
    winR := NumGet(winRECT, 8, "Int")
    winB := NumGet(winRECT, 12, "Int")
    return [ext[1] - winL, ext[2] - winT, winR - ext[3], winB - ext[4]]
}

AdjustedWinMove(hwnd, x, y, w, h) {
    b := GetWindowBorders(hwnd)
    WinMove(x - b[1], y - b[2], w + b[1] + b[3], h + b[2] + b[4], hwnd)
}

; Use visible rect for position checks, not WinGetPos
IsAt(a, b) => Abs(a - b) <= 6

; Returns [x, w] for a named column slot using visible coordinates
ColGeometry(slot, d, padX) {
    full     := d[3]
    hp       := Floor(padX / 2)
    thirdW   := Floor(full / 3) - padX - hp
    twoThirdW := full - 3 * padX - thirdW

    if slot = "left-half"
        return [d[1] + padX, Floor(full / 2) - padX - hp]
    if slot = "right-half"
        return [d[1] + Floor(full / 2) + hp, Floor(full / 2) - padX - hp]
    if slot = "left-third"
        return [d[1] + padX, thirdW]
    if slot = "right-third"
        return [d[1] + full - padX - thirdW, thirdW]
    if slot = "left-twothird"
        return [d[1] + padX, twoThirdW]
    if slot = "right-twothird"
        return [d[1] + full - padX - twoThirdW, twoThirdW]
}

AdjustForPiP(hwnd, &x, &w, d, padX, slot) {
    try {
        title := WinGetTitle(hwnd)
        class := WinGetClass(hwnd)
        if (title = "Picture-in-Picture" && class = "MozillaDialogClass") {
            slotGeo := ColGeometry(slot = "left" ? "left-half" : "right-half", d, padX)
            slotX := slotGeo[1]
            slotW := slotGeo[2]
            w := slotW - 52
            x := slotX + Floor((slotW - w) / 2)
        }
    }
}

!+h:: {
    global PadX, PadY
    hwnd := WinGetID("A")
    d := GetDimensions()
    vis := GetVisibleRect(hwnd)
    visX := vis[1] - d[1]
    visW := vis[3] - vis[1]
    geo   := ColGeometry("left-half",      d, PadX)
    geo3  := ColGeometry("left-third",     d, PadX)
    geo23 := ColGeometry("left-twothird",  d, PadX)
    atLeft := IsAt(visX, geo[1] - d[1])
    if atLeft && IsAt(visW, geo[2])
        g := geo3
    else if atLeft && IsAt(visW, geo3[2])
        g := geo23
    else
        g := geo
    finalX := g[1]
    finalW := g[2]
    AdjustForPiP(hwnd, &finalX, &finalW, d, PadX, "left")
    AdjustedWinMove(hwnd, finalX, d[2] + PadY, finalW, d[4] - PadY * 2)
}

!+l:: {
    global PadX, PadY
    hwnd := WinGetID("A")
    d := GetDimensions()
    vis := GetVisibleRect(hwnd)
    visX := vis[1] - d[1]
    visW := vis[3] - vis[1]
    visR := visX + visW
    geo   := ColGeometry("right-half",      d, PadX)
    geo3  := ColGeometry("right-third",     d, PadX)
    geo23 := ColGeometry("right-twothird",  d, PadX)
    expectedR := geo[1] + geo[2] - d[1]
    atRight := IsAt(visR, expectedR)
    if atRight && IsAt(visW, geo[2])
        g := geo3
    else if atRight && IsAt(visW, geo3[2])
        g := geo23
    else
        g := geo
    finalX := g[1]
    finalW := g[2]
    AdjustForPiP(hwnd, &finalX, &finalW, d, PadX, "right")
    AdjustedWinMove(hwnd, finalX, d[2] + PadY, finalW, d[4] - PadY * 2)
}

RowGeometry(slot, d, padY) {
    full := d[4]
    hp   := Floor(padY / 2)
    ; third heights computed analogously to half heights
    thirdH    := Floor(full / 3) - padY - hp
    twoThirdH := full - Floor(full / 3) - padY - hp - padY  ; = full - thirdH - 3*padY - hp... let's just derive
    ; verify: padY + thirdH + padY + twoThirdH + padY = full
    ; => thirdH + twoThirdH = full - 3*padY
    twoThirdH := full - 3 * padY - thirdH

    if slot = "top-half"
        return [d[2] + padY, Floor(full / 2) - padY - hp]
    if slot = "bottom-half"
        return [d[2] + Floor(full / 2) + hp, Floor(full / 2) - padY - hp]
    if slot = "top-third"
        return [d[2] + padY, thirdH]
    if slot = "bottom-third"
        return [d[2] + full - padY - thirdH, thirdH]
    if slot = "top-twothird"
        return [d[2] + padY, twoThirdH]
    if slot = "bottom-twothird"
        return [d[2] + full - padY - twoThirdH, twoThirdH]
}


!+k:: {
    global PadY
    hwnd := WinGetID("A")
    d := GetDimensions()
    vis := GetVisibleRect(hwnd)
    visY := vis[2] - d[2]
    visH := vis[4] - vis[2]
    visX := vis[1]
    visW := vis[3] - vis[1]
    geo   := RowGeometry("top-half",     d, PadY)
    geo3  := RowGeometry("top-third",    d, PadY)
    geo23 := RowGeometry("top-twothird", d, PadY)
    atTop := IsAt(visY, geo[1] - d[2])
    if atTop && IsAt(visH, geo[2])
        g := geo3
    else if atTop && IsAt(visH, geo3[2])
        g := geo23
    else
        g := geo
    AdjustedWinMove(hwnd, visX, g[1], visW, g[2])
}

!+j:: {
    global PadY
    hwnd := WinGetID("A")
    d := GetDimensions()
    vis := GetVisibleRect(hwnd)
    visY := vis[2] - d[2]
    visH := vis[4] - vis[2]
    visB := visY + visH
    visX := vis[1]
    visW := vis[3] - vis[1]
    geo   := RowGeometry("bottom-half",     d, PadY)
    geo3  := RowGeometry("bottom-third",    d, PadY)
    geo23 := RowGeometry("bottom-twothird", d, PadY)
    expectedB := (geo[1] - d[2]) + geo[2]
    atBottom := IsAt(visB, expectedB)
    if atBottom && IsAt(visH, geo[2])
        g := geo3
    else if atBottom && IsAt(visH, geo3[2])
        g := geo23
    else
        g := geo
    AdjustedWinMove(hwnd, visX, g[1], visW, g[2])
}

; Store previous window geometry before maximizing
PrevGeometry := Map()

!+m:: {
    global PadX, PadY, PrevGeometry
    hwnd := WinGetID("A")
    d := GetDimensions()
    vis := GetVisibleRect(hwnd)
    visX := vis[1] - d[1]
    visY := vis[2] - d[2]
    visW := vis[3] - vis[1]
    visH := vis[4] - vis[2]
    fullW := d[3] - PadX * 2
    fullH := d[4] - PadY * 2
    isMaximized := IsAt(visX, PadX) && IsAt(visY, PadY) && IsAt(visW, fullW) && IsAt(visH, fullH)
    if isMaximized {
        if PrevGeometry.Has(hwnd) {
            p := PrevGeometry[hwnd]
            AdjustedWinMove(hwnd, p[1], p[2], p[3], p[4])
        }
    } else {
        PrevGeometry[hwnd] := [vis[1], vis[2], visW, visH]
        AdjustedWinMove(hwnd, d[1] + PadX, d[2] + PadY, fullW, fullH)
    }
}
