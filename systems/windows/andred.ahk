; Autoexec --------------------------------------------------------------------

; https://www.autohotkey.com/docs/KeyList.htm#modifier

#SingleInstance force

global LDim := [-1442, -610, 1472, 2588]
global RDim := [0, 0, 2588, 1417]

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

$!{::Send, !+[
$!}::Send, !+]
$!w::Send !w
$!a::Send !a
$!y::Send !y
$!p::Send !p

!c::Send, ^+c
!v::
    ClipboardBackup := Clipboard                        ; To restore clipboard contents after paste
    FixString := StrReplace(Clipboard, "`r`n", "`n")    ; Change endings
    Clipboard := FixString                              ; Set to clipboard
    Send ^+v                                            ; Paste text
    Clipboard := ClipboardBackup                        ; Restore clipboard that has windows endings
    return

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

#IfWinActive, ahk_exe chrome.exe ; --------------------------------------------

!l::Send, !d
!t::Send, ^t
!+n::Send, ^+n

#IfWinActive

; Program Activation -----------------------------------------------------------

Activate(name, executable)
{
  DetectHiddenWindows, On
  if WinExist(name) {
    WinGet, id, ID, %name%

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
    Run, %executable%
    WinGet, id, ID, Alacritty
    WinActivate, ahk_id %id%
  }
}


#IfWinNotActive, ahk_exe TslGame.exe ; ------------------------------------------

$!z::
$^a::Activate("Alacritty", "C:\Apps\Alacritty\alacritty.exe")
$#i::Activate("Nvy", "C:\Apps\NeoVim\bin\NvyNotes.lnk")

#IfWinNotActive

#Include L:\home\andre\.dotfiles\systems\windows\winmgt.ahk
