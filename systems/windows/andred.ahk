; Autoexec --------------------------------------------------------------------

#SingleInstance force

global MonitorWidth := 1294 * 2 ;2588
global MonitorHeight := 1447

return

; MacOS similarity bindings ---------------------------------------------------

$!{::Send, ^+{Tab}
$!}::Send, ^{Tab}
$#{::Send, ^+{Tab}
$#}::Send, ^{Tab}
$!x::Send ^x
$!c::Send ^c
$!v::Send ^v
$!s::Send ^s
$!a::Send ^a
$!z::Send ^z
$!+z::Send ^y
$!w::Send ^w
$!f::Send ^f
$!n::Send ^n
$!q::Send !{f4}
$!r::Send ^{f5}
$!1::Send ^1
$!2::Send ^2
$!3::Send ^3
$!4::Send ^4
$!5::Send ^5
$!6::Send ^6
$!7::Send ^7
$!8::Send ^8
$!9::Send ^9
$!0::Send ^0

; Program specific MacOS similarity bindings -----------------------------------

#IfWinActive, ahk_exe alacritty.exe ; ------------------------------------------

$!w::Send !w
!c::Send, ^+c
!v::
    ClipboardBackup := Clipboard                        ; To restore clipboard contents after paste
    FixString := StrReplace(Clipboard, "`r`n", "`n")    ; Change endings
    Clipboard := FixString                              ; Set to clipboard
    Send ^+v                                            ; Paste text
    Clipboard := ClipboardBackup                        ; Restore clipboard that has windows endings
    return
$#{::Send, !^[
$#}::Send, !^]

#IfWinActive, ahk_exe Nvy.exe ; ------------------------------------------------

!q::

#IfWinActive, ahk_exe jcpicker.exe ; ------------------------------------------------

$!w::Send !{f4}

#IfWinActive, ahk_exe Discord.exe ; --------------------------------------------

$!{::Send, {alt down}{shift down}[{shift up}{alt up}
$!}::Send, {alt down}{shift down}]{shift up}{alt up}
$#{::Send, !+{Up}
$#}::Send, !+{Down}

#IfWinActive, ahk_exe Neovide.exe ; --------------------------------------------

!q::

#IfWinActive, ahk_exe firefox.exe ; --------------------------------------------

!l::Send, !d
!t::Send, ^t
!+n::Send, ^+p

#IfWinActive

; Program Activation -----------------------------------------------------------

$^a::
DetectHiddenWindows, On
if WinExist("Alacritty") {
  WinGet, id, ID, Alacritty

  if WinActive("ahk_id" . id) {
    WinHide, ahk_id %id%
    DetectHiddenWindows, Off
    WinGet, wList, List
    WinActivate, ahk_id %wList2%
  } else {
    WinShow, ahk_id %id%
    WinActivate, ahk_id %id%
  }
} else {
  Run, C:\Apps\Alacritty\alacritty.exe
  WinGet, id, ID, Alacritty
  WinActivate, ahk_id %id%
}
return

$#i::
DetectHiddenWindows, On
if WinExist("Nvy") {
  WinGet, id, ID, Nvy

  if WinActive("ahk_id" . id) {
    WinHide, ahk_id %id%
    DetectHiddenWindows, Off
    WinGet, wList, List
    WinActivate, ahk_id %wList2%
  } else {
    WinShow, ahk_id %id%
    WinActivate, ahk_id %id%
  }
} else {
  Run, C:\Apps\NeoVim\bin\NvyNotes.lnk
  WinGet, id, ID, Nvy
  WinActivate, ahk_id %id%
}
return

; Window management -----------------------------------------------------------

; [x, y, w, h]
GetWinPadding() {
  if WinActive("ahk_exe firefox.exe") {
    return [-6, -3, -3, 2]
  } else if WinActive("ahk_exe alacritty.exe") {
    return [0, -1, -14, 2]
  } else if WinActive("ahk_exe chrome.exe") {
    return [-7, 29, 0, -32]
  } else if WinActive("ahk_exe discord.exe") or WinActive("ahk_exe Spotify.exe") {
    return [0, 0, -14, -7]
  }
  return [-7, -1, 0, 1]
}

!+m::
  padding := GetWinPadding()
  WinMove A, , padding[1], padding[2], MonitorWidth - 14 + padding[3], MonitorHeight + padding[4]
return

!+h::
  WinGetActiveStats, title, curW, curH, curX, curY
  padding := GetWinPadding()
  isPinned := curX == padding[1]

  if (isPinned && curW == Floor(MonitorWidth / 2) + padding[3]) {
    w := Floor(MonitorWidth / 3) + padding[3]
  } else if (isPinned && curW < Floor(MonitorWidth / 2) + padding[3]) {
    w := Floor(MonitorWidth * 2 / 3) + padding[3]
  } else {
    w := Floor(MonitorWidth / 2) + padding[3]
  }

  WinMove A, , padding[1], padding[2], w, MonitorHeight + padding[4]
return

!+l::
  WinGetActiveStats, title, curW, curH, curX, curY
  padding := GetWinPadding()
  targetWidth := 2560 - padding[1]

  if (curX == 1280 + padding[1]) {
    x := 1280 + padding[1] - Ceil(MonitorWidth / 6)
  } else if (curX == 1280 + padding[1] - Ceil(MonitorWidth / 6)) {
    x := 1280 + padding[1] + Floor(MonitorWidth / 6)
  } else {
    x := 1280 + padding[1]
  }

  WinMove A, , x, padding[2], targetWidth - x, MonitorHeight + padding[4]
return

!+k::
  WinGetActiveStats, title, curW, curH, curX, curY
  padding := GetWinPadding()
  WinMove A, , curX, padding[2], curW, (MonitorHeight / 2) + padding[4]
return

!+j::
  WinGetActiveStats, title, curW, curH, curX, curY
  padding := GetWinPadding()
  WinMove A, , curX, 716 + padding[2], curW, MonitorHeight - 716 + padding[4]
return

^+r::
Reload
return
