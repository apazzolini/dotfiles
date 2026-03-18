#Requires AutoHotkey v2.0

#SingleInstance Force

; https://www.autohotkey.com/docs/KeyList.htm#modifier

GroupAdd "games", "ahk_exe TslGame.exe"
GroupAdd "games", "ahk_exe ProjectZomboid64.exe"
GroupAdd "games", "ahk_exe Raft.exe"
GroupAdd "games", "ahk_exe DungeonCrawler.exe"
GroupAdd "games", "ahk_exe HITMAN3.exe"
GroupAdd "games", "ahk_exe portal2.exe"
GroupAdd "games", "ahk_exe cs2.exe"
GroupAdd "games", "ahk_exe FactoryGame-Win64-Shipping.exe"
GroupAdd "games", "ahk_exe FactoryGameSteam-Win64-Shipping.exe"
GroupAdd "games", "ahk_exe valheim.exe"
GroupAdd "games", "ahk_exe NWXClient-Win64-Shipping"
GroupAdd "games", "ahk_exe Factorio.exe"

; Program specific MacOS similarity bindings -----------------------------------
#HotIf WinActive("ahk_exe alacritty.exe")
$!{::Send "!+["
$!}::Send "!+]"
$!w::Send "!w"
$!a::Send "!a"
$!f::Send "!f"
$!y::Send "!y"
$!p::Send "!p"
$!v::Send "!v"

#HotIf WinActive("ahk_exe Nvy.exe")
!q::ExitApp

#HotIf WinActive("ahk_exe jcpicker.exe")
$!w::Send "!{f4}"

#HotIf WinActive("ahk_exe Discord.exe")
$!{::Send "{alt down}{shift down}[{shift up}{alt up}"
$!}::Send "{alt down}{shift down}]{shift up}{alt up}"
$#{::Send "!+{Up}"
$#}::Send "!+{Down}"

#HotIf WinActive("ahk_exe Neovide.exe")
!q::ExitApp

#HotIf WinActive("ahk_exe firefox.exe")
!l::Send "!d"
!t::Send "^t"
!+p::Send "^+p"
!+t::Send "^+t"
!#i::Send "^+i"

#HotIf WinActive("ahk_exe chrome.exe")
!l::Send "!d"
!t::Send "^t"
!+n::Send "^+n"

#HotIf WinActive("ahk_exe DSPGAME.exe")
!q::ExitApp
$^a::Return
$#i::Return
$+1::Send "{f1}"
$+2::Send "{f2}"
$+3::Send "{f3}"
$+4::Send "{f4}"
$+5::Send "{f5}"
$+6::Send "{f6}"
$+7::Send "{f7}"
$+8::Send "{f8}"
$+9::Send "{f9}"
$+0::Send "{f0}"
XButton1::Send ","
XButton2::Send "."

#HotIf

; Program Activation -----------------------------------------------------------
Activate(name, executable) {
    DetectHiddenWindows True
    if WinExist(name) {
        id := WinGetID(name)
        if WinActive("ahk_id " id) {
            WinHide "ahk_id " id
            DetectHiddenWindows False
            wList := WinGetList()
            WinActivate "ahk_id " wList[2]
        } else {
            WinShow "ahk_id " id
            WinActivate "ahk_id " id
        }
    } else {
        Run executable
        WinWait name
        id := WinGetID(name)
        WinActivate "ahk_id " id
    }
}

#HotIf !WinActive("ahk_group games")
$#i::Activate("Neovide", "D:\Apps\neovide\notes.lnk")

$!1::Send "^1"
$!2::Send "^2"
$!3::Send "^3"
$!4::Send "^4"
$!5::Send "^5"
$!6::Send "^6"
$!7::Send "^7"
$!8::Send "^8"
$!9::Send "^9"
$!0::Send "^0"
$!{::Send "^+{Tab}"
$!}::Send "^{Tab}"
$#{::Send "^+{Tab}"
$#}::Send "^{Tab}"
$!x::Send "^x"
$!c::Send "^c"
$!v::Send "^v"
$!s::Send "^s"
$!a::Send "^a"
$!z::Send "^z"
$!+z::Send "^y"
$!w::Send "^w"
$!f::Send "^f"
$!n::Send "^n"
$!q::Send "!{f4}"
$!r::Send "^{f5}"

^+r::Reload()

#HotIf

#Include "D:\Other\winmgt.ahk"
