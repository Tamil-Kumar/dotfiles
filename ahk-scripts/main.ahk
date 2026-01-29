#Requires AutoHotkey v2.0

TraySetIcon("C:\Users\tamil\OneDrive\Desktop\AutoHotkey\settings.ico")
A_IconTip := "Main"

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Makes a border around a window
DrawBorder(hwnd, color := 0xFF0000, enable := 1) {
    static DWMWA_BORDER_COLOR := 34
    static DWMWA_COLOR_DEFAULT := 0xFFFFFFFF
    R := (color & 0xFF0000) >> 16
    G := (color & 0xFF00) >> 8
    B := (color & 0xFF)
    color := (B << 16) | (G << 8) | R
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_BORDER_COLOR, "int*", enable ? color : DWMWA_COLOR_DEFAULT, "int", 4)
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Checks if a youtube video is fullscreen

IsYouTubeFullScreen() {
    try {
        WinGetPos(&X, &Y, &Width, &Height, "A")
    } catch {
        return false
    }
    Title := WinGetTitle("A")
    Tolerance := 15
    IsLocationOK := (Abs(X) <= Tolerance && Abs(Y) <= Tolerance)
    IsSizeOK := (Width >= A_ScreenWidth - Tolerance && Height >= A_ScreenHeight - Tolerance)
    IsYouTube := InStr(Title, "YouTube")
    return IsLocationOK && IsSizeOK && IsYouTube
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Gets the PID of a process ran by a path
GetPidByPath(targetScriptPath)
{
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name='AutoHotkey.exe' or Name='AutoHotkey64.exe'")
    {
        ; Some processes may not have a CommandLine property
        try {
            if InStr(process.CommandLine, '"' targetScriptPath '"')
                return process.ProcessId
        }
    }
    return 0
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Close all windows but the active one
#!h::
{
    active_id := WinGetID("A")
    for hwnd in WinGetList() {
        if hwnd != active_id {
            class := WinGetClass(hwnd)
            process := WinGetProcessName(hwnd)
            ; Exclude desktop, and taskbar windows
            if (class != "Progman") && (class != "Shell_TrayWnd") {
                WinClose(hwnd)
            }
        }
    }
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Stop the focused media, minimize all windows, and brings vs code to top if already open, else runs vs code
#h::
{
    SendInput "{Media_Stop}"
    WinMinimizeAll()
    if WinExist("ahk_exe Code - Insiders.exe ahk_class Chrome_WidgetWin_1") {
        WinActivate
    } else {
        Run 'cmd.exe /c code-insiders "F:\Coding Projects\Languages\Python\Google Webscraper"'
        Sleep(1000)
        WinClose('ahk_exe WindowsTerminal.exe')
    }
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Remaps Capslock to home, and remaps specific shortcuts
CapsLock::Send("{Home}")
+CapsLock::Send("+{Home}")
^CapsLock::Send("^{Home}")

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Remaps Right Alt to end, and remaps specific shortcuts
RAlt::Send("{End}")
+RAlt::Send("+{End}")
^RAlt::Send("^{End}")

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Remaps the copilot key to escape
#+F23::Send("{Esc}")

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Remaps windows+s to windows+shift+s
#s::Send("#+s")

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Makes alt+backspace delete the entire line that your cursor is on
!Backspace::
{
    Send("{End}")
    Send("+{Home}")
    Send("{Backspace}")
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Makes windows+t put the focused window as always on top
#t::
{
    WinSetAlwaysOnTop -1, "A" ; -1 toggles, "A" targets the active window
    hwnd := WinExist("A") ; Gets the ID of the always on top window
    isAlwaysOnTop := (WinGetExStyle("ahk_id " hwnd) & 0x8) != 0 ; Gets the "always on top" status of a window, true or false
    if (isAlwaysOnTop) {
        DrawBorder(hwnd) ; Uses the custom DrawBorder function defined above to put a red border around the always on top window
    } else {
        DrawBorder(hwnd, , 0) ; Removes the border
    }

}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Reload ahk scripts
^+r::Reload

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Autoclicker
^,::
{
    static toggleAuto := false
    toggleAuto := !toggleAuto
    SetTimer(Click, toggleAuto ? 1 : 0)
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Remaps num keys to numpad keys when Capslock is active
#HotIf GetKeyState("CapsLock", "T")
0::Numpad0
1::Numpad1
2::Numpad2
3::Numpad3
4::Numpad4
5::Numpad5
6::Numpad6
7::Numpad7
8::Numpad8
9::Numpad9
#HotIf

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Remaps "AppsKey" (Fn+Copilot) to make my computer sleep
AppsKey::
{
    SendInput "{Media_Stop}"
    If (IsYouTubeFullScreen()) {
        Sleep(100)
        Send("f")
        Sleep(100)
    }
    Send("!x")
    WinWait("ahk_class Xaml_WindowedPopupClass ahk_exe explorer.exe")
    Send("u")
    Send("s")
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Makes Ctrl+Shift+S open window spy
^+s::Run("C:\Program Files\AutoHotkey\WindowSpy.ahk")

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Duplicate the line that your cursor is on
^d::
{
    Send("{End}")
    Send("+{Home}")
    Send("^c")
    Sleep(100)
    Send("{End}")
    Send("{Enter}")
    Sleep(100)
    Send("^v")
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Makes alt + up/down arrow scroll 5 times when nushell is active
#HotIf WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS ahk_exe WindowsTerminal.exe") 
>!up::Send("{Up 5}")
>!down::Send("{Down 5}")
#HotIf

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Makes the computer not go to sleep

#+s::
{
    static toggleMouse := false
    static pid := 0
    toggleMouse := !toggleMouse
    if (toggleMouse) {
        Run('C:\Users\tamil\OneDrive\Desktop\AutoHotkey\dont sleep.ahk')
        Loop 20 {
            pid := GetPidByPath('C:\Users\tamil\OneDrive\Desktop\AutoHotkey\dont sleep.ahk')
            if pid
                break
            Sleep 100
        }
    } else {
        ProcessClose(pid)
        pid := 0
    }
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Remaps the middle click button on the mouse, to a close tab function

MButton::
{
    Send("^w")
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; A bunch of mouse things

XButton2::Return
#HotIf GetKeyState("XButton2", "P")
WheelUp::Send("{WheelUp 3}")
WheelDown::Send("{WheelDown 3}")
RButton::SendInput "{Browser_Refresh}"
LButton::Send("^{LButton}")
XButton1::SendInput "{Browser_Back}"
#HotIf

XButton1::Return
#HotIf GetKeyState("XButton1", "P")
WheelUp::Send("{WheelRight}")
WheelDown::Send("{WheelLeft}")
#HotIf

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Makes win + x close a window, and alt + x do the same function as win + x

#w::Send("!{F4}")
!x::Send("#x")

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Launch a bunch of apps

#Enter::
{
    Run("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Alacritty\Alacritty.lnk")
}

#f::
{
    Run("explorer.exe shell:AppsFolder\Files_1y0xx7n9077q4!App")
}

#b::
{
    Run("C:\Users\tamil\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\qutebrowser.lnk")
}

#e::
{
    Run("firefox.exe")
}

;------------------------------------------------------------------------------------------------------------------------------------------------------

; Remaps Win + ctrl + left/right, to ctrl + win + alt + left/right

#!^left::#^left
#!^right::#^right

#^left::return
#^right::return