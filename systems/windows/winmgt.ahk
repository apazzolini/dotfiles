; [x, y, w, h]
GetWinPadding() {
  if WinActive("ahk_exe firefox.exe") {
    return [-6, -3, -2, 2]
  } else if WinActive("ahk_exe alacritty.exe") {
    return [0, -1, -14, 2]
  } else if WinActive("ahk_exe chrome.exe") {
    return [-7, 29, 0, -29]
  } else if WinActive("ahk_exe discord.exe") or WinActive("ahk_exe Spotify.exe") {
    return [0, 0, -14, -7]
  }
  return [-7, -1, 0, 1]
}

GetDimensions() {
  WinGetActiveStats, title, w, h, x, y
  if x < -10
  {
    return LDim
  } else {
    return RDim
  }
}

; --------------------------------------------------------------------------------------------------

!+m::
  padding := GetWinPadding()
  d := GetDimensions()
  WinMove A, , d[1] + padding[1], d[2] + padding[2], d[3] - 14 + padding[3], d[4] + padding[4]
return

!+h::
  WinGetActiveStats, title, curW, curH, curX, curY
  padding := GetWinPadding()
  d := GetDimensions()
  isPinned := curX == d[1] + padding[1]

  if (isPinned && curW == Floor(d[3] / 2) + padding[3]) {
    w := Floor(d[3] / 3) + padding[3]
  } else if (isPinned && curW < Floor(d[3] / 2) + padding[3]) {
    w := Floor(d[3] * 2 / 3) + padding[3]
  } else {
    w := Floor(d[3] / 2) + padding[3]
  }

  WinMove A, , d[1] + padding[1], d[2] + padding[2], w, d[4] + padding[4]
return

!+l::
  WinGetActiveStats, title, curW, curH, curX, curY
  padding := GetWinPadding()
  targetWidth := 2560 - padding[1]

  if (curX == 1280 + padding[1]) {
    x := 1280 + padding[1] - Ceil(d[3] / 6)
  } else if (curX == 1280 + padding[1] - Ceil(d[3] / 6)) {
    x := 1280 + padding[1] + Floor(d[3] / 6)
  } else {
    x := 1280 + padding[1]
  }

  WinMove A, , x, padding[2], targetWidth - x, d[4] + padding[4]
return

!+k::
  WinGetActiveStats, title, curW, curH, curX, curY
  padding := GetWinPadding()
  d := GetDimensions()
  WinMove A, , curX, d[2] + padding[2], curW, (d[4] / 2) + padding[4]
return

!+j::
  WinGetActiveStats, title, curW, curH, curX, curY
  padding := GetWinPadding()
  d := GetDimensions()
  WinMove A, , curX, d[2] + (d[4] / 2) + padding[2], curW, d[4] - (d[4] / 2) + padding[4]
return

^+r::
Reload
return

; --------------------------------------------------------------------------------------------------

!+2::
  WinGetActiveStats, title, w, h, x, y
  d := LDim
  padding := GetWinPadding()

  if x < -10
  {
    d := RDim
  }

  WinMove A, , d[1] + padding[1], d[2] + padding[2], d[3] - 14 + padding[3], d[4] + padding[4]
return
