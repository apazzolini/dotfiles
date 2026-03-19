#Requires AutoHotkey v2.0

PadX := 8   ; horizontal gap between edges/windows
PadY := 8   ; vertical gap between edges/windows

; ---------------------------------------------------------------------------
; Monitor / work-area helpers
; ---------------------------------------------------------------------------

GetWorkArea() {
    MonitorGetWorkArea(, &L, &T, &R, &B)
    return {x: L, y: T, w: R - L, h: B - T}
}

; Returns the DWM visible rect as {l, t, r, b}
GetVisibleRect(hwnd) {
    buf := Buffer(16, 0)
    DllCall("dwmapi\DwmGetWindowAttribute",
        "Ptr", hwnd, "UInt", 9, "Ptr", buf, "UInt", 16)
    return {l: NumGet(buf, 0, "Int"), t: NumGet(buf, 4, "Int"),
            r: NumGet(buf, 8, "Int"), b: NumGet(buf, 12, "Int")}
}

GetWindowBorders(hwnd) {
    vis := GetVisibleRect(hwnd)
    buf := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", buf)
    wl := NumGet(buf, 0, "Int"), wt := NumGet(buf, 4, "Int")
    wr := NumGet(buf, 8, "Int"), wb := NumGet(buf, 12, "Int")
    return {l: vis.l - wl, t: vis.t - wt, r: wr - vis.r, b: wb - vis.b}
}

AdjustedWinMove(hwnd, x, y, w, h) {
    b := GetWindowBorders(hwnd)
    WinMove(x - b.l, y - b.t, w + b.l + b.r, h + b.t + b.b, hwnd)
}

IsAt(a, b) => Abs(a - b) <= 6

; ---------------------------------------------------------------------------
; Axis geometry  (replaces both ColGeometry and RowGeometry)
;   origin : pixel start of the axis (wa.x or wa.y)
;   length : total pixels along the axis (wa.w or wa.h)
;   pad    : gap size (PadX or PadY)
;
; Returns a Map of slot-name => {pos, size} for the near/far side.
; "near" = left or top, "far" = right or bottom.
; ---------------------------------------------------------------------------

AxisSlots(origin, length, pad) {
    hp      := Floor(pad / 2)
    halfS   := Floor(length / 2) - pad - hp
    thirdS  := Floor(length / 3) - pad - hp
    twoThS  := length - 3 * pad - thirdS

    return Map(
        "near-half",     {pos: origin + pad,                        size: halfS},
        "far-half",      {pos: origin + Floor(length / 2) + hp,     size: halfS},
        "near-third",    {pos: origin + pad,                        size: thirdS},
        "far-third",     {pos: origin + length - pad - thirdS,      size: thirdS},
        "near-twothird", {pos: origin + pad,                        size: twoThS},
        "far-twothird",  {pos: origin + length - pad - twoThS,      size: twoThS}
    )
}

; ---------------------------------------------------------------------------
; PiP adjustment (Firefox Picture-in-Picture)
;   Narrows the window by 52px and centers it within its half-slot.
; ---------------------------------------------------------------------------

AdjustForPiP(hwnd, &x, &w, slotW) {
    try {
        if (WinGetTitle(hwnd) = "Picture-in-Picture"
            && WinGetClass(hwnd) = "MozillaDialogClass") {
            w := slotW - 52
            x := x + Floor((slotW - w) / 2)
        }
    }
}

; ---------------------------------------------------------------------------
; Saved-position store for Alt+Shift+M toggle (static inside accessor)
; ---------------------------------------------------------------------------

_SavedPositions() {
    static m := Map()
    return m
}

; ---------------------------------------------------------------------------
; Detect whether a window is currently in the "filled" position
; ---------------------------------------------------------------------------

IsFilledPos(hwnd) {
    global PadX, PadY
    wa  := GetWorkArea()
    vis := GetVisibleRect(hwnd)
    return IsAt(vis.l, wa.x + PadX)
        && IsAt(vis.t, wa.y + PadY)
        && IsAt(vis.r - vis.l, wa.w - PadX * 2)
        && IsAt(vis.b - vis.t, wa.h - PadY * 2)
}

; ---------------------------------------------------------------------------
; Core tiling function
;   dir : "left" | "right" | "top" | "bottom"
;
; Cycle order: half -> third -> two-thirds -> half ...
; ---------------------------------------------------------------------------

CycleTile(dir) {
    global PadX, PadY
    hwnd := WinGetID("A")
    wa   := GetWorkArea()
    vis  := GetVisibleRect(hwnd)

    isHoriz := (dir = "left" || dir = "right")
    isNear  := (dir = "left" || dir = "top")

    pad    := isHoriz ? PadX : PadY
    origin := isHoriz ? wa.x : wa.y
    length := isHoriz ? wa.w : wa.h
    slots  := AxisSlots(origin, length, pad)

    side   := isNear ? "near" : "far"
    sHalf  := slots[side "-half"]
    sThird := slots[side "-third"]
    sTwoTh := slots[side "-twothird"]

    ; Current visible position/size along this axis
    if isHoriz {
        curPos  := vis.l
        curSize := vis.r - vis.l
    } else {
        curPos  := vis.t
        curSize := vis.b - vis.t
    }

    ; Detect current slot and cycle
    if isNear
        atEdge := IsAt(curPos, sHalf.pos)
    else
        atEdge := IsAt(curPos + curSize, sHalf.pos + sHalf.size)

    if atEdge && IsAt(curSize, sHalf.size)
        s := sThird
    else if atEdge && IsAt(curSize, sThird.size)
        s := sTwoTh
    else
        s := sHalf

    ; Build final x, y, w, h
    if isHoriz {
        fx := s.pos, fy := wa.y + PadY
        fw := s.size, fh := wa.h - PadY * 2
        AdjustForPiP(hwnd, &fx, &fw, sHalf.size)
    } else {
        fx := vis.l,  fy := s.pos
        fw := vis.r - vis.l, fh := s.size
    }

    AdjustedWinMove(hwnd, fx, fy, fw, fh)
}

; ---------------------------------------------------------------------------
; Hotkeys  (Alt+Shift + vim keys)
; ---------------------------------------------------------------------------

!+h:: CycleTile("left")
!+l:: CycleTile("right")
!+k:: CycleTile("top")
!+j:: CycleTile("bottom")

!+m:: {
    global PadX, PadY
    hwnd := WinGetID("A")
    m    := _SavedPositions()

    if IsFilledPos(hwnd) && m.Has(hwnd) {
        s := m[hwnd]
        m.Delete(hwnd)
        AdjustedWinMove(hwnd, s.x, s.y, s.w, s.h)
        return
    }

    vis := GetVisibleRect(hwnd)
    m[hwnd] := {x: vis.l, y: vis.t, w: vis.r - vis.l, h: vis.b - vis.t}

    wa := GetWorkArea()
    AdjustedWinMove(hwnd, wa.x + PadX, wa.y + PadY, wa.w - PadX * 2, wa.h - PadY * 2)
}
