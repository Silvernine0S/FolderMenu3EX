#include-once

; #INDEX# =======================================================================================================================
; Title .........: Windows_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: <a href="../appendix/GUIStyles.htm">GUI control Windows styles</a> and much more constants.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Window Styles
Global Const $WS_MAXIMIZEBOX = 0x00010000
Global Const $WS_MINIMIZEBOX = 0x00020000
Global Const $WS_TABSTOP = 0x00010000
Global Const $WS_GROUP = 0x00020000
Global Const $WS_SIZEBOX = 0x00040000
Global Const $WS_THICKFRAME = 0x00040000
Global Const $WS_SYSMENU = 0x00080000
Global Const $WS_BORDER = 0x00800000
Global Const $WS_CAPTION = 0x00C00000
Global Const $WS_OVERLAPPEDWINDOW = 0x00CF0000
Global Const $WS_TILEDWINDOW = 0x00CF0000
Global Const $WS_CLIPSIBLINGS = 0x04000000
Global Const $WS_POPUP = 0x80000000
Global Const $WS_POPUPWINDOW = 0x80880000

; Window Extended Styles
Global Const $WS_EX_ACCEPTFILES = 0x00000010
Global Const $WS_EX_MDICHILD = 0x00000040
Global Const $WS_EX_CLIENTEDGE = 0x00000200
Global Const $WS_EX_TOOLWINDOW = 0x00000080
Global Const $WS_EX_TOPMOST = 0x00000008
Global Const $WS_EX_TRANSPARENT = 0x00000020
Global Const $WS_EX_WINDOWEDGE = 0x00000100

; Messages
Global Const $WM_GETMINMAXINFO = 0x0024
Global Const $WM_NOTIFY = 0x004E
Global Const $WM_KEYDOWN = 0x0100
Global Const $WM_KEYUP = 0x0101
Global Const $WM_SYSKEYDOWN = 0x0104
Global Const $WM_SYSKEYUP = 0x0105
Global Const $WM_COMMAND = 0x0111

; Windows Color Constants
Global Const $COLOR_MENU = 4
; ===============================================================================================================================
