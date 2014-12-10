#include-once

; #INDEX# =======================================================================================================================
; Title .........: GUIConstantsEx
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants to be used in GUI applications.
; Author(s) .....: Jpm, Valik
; Dll ...........:
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Events and messages
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_EVENT_MINIMIZE = -4
Global Const $GUI_EVENT_RESTORE = -5
Global Const $GUI_EVENT_MAXIMIZE = -6
Global Const $GUI_EVENT_PRIMARYDOWN = -7
Global Const $GUI_EVENT_PRIMARYUP = -8
Global Const $GUI_EVENT_SECONDARYDOWN = -9
Global Const $GUI_EVENT_SECONDARYUP = -10
Global Const $GUI_EVENT_MOUSEMOVE = -11
Global Const $GUI_EVENT_RESIZED = -12
Global Const $GUI_EVENT_DROPPED = -13

Global Const $GUI_RUNDEFMSG = 'GUI_RUNDEFMSG'

; State
Global Const $GUI_CHECKED = 1
Global Const $GUI_UNCHECKED = 4

Global Const $GUI_DROPACCEPTED = 8

Global Const $GUI_SHOW = 16
Global Const $GUI_HIDE = 32
Global Const $GUI_ENABLE = 64
Global Const $GUI_DISABLE = 128

Global Const $GUI_FOCUS = 256
Global Const $GUI_DEFBUTTON = 512

; Resizing
Global Const $GUI_DOCKAUTO = 0x0001
Global Const $GUI_DOCKLEFT = 0x0002
Global Const $GUI_DOCKRIGHT = 0x0004
Global Const $GUI_DOCKHCENTER = 0x0008
Global Const $GUI_DOCKTOP = 0x0020
Global Const $GUI_DOCKBOTTOM = 0x0040
Global Const $GUI_DOCKVCENTER = 0x0080
Global Const $GUI_DOCKWIDTH = 0x0100
Global Const $GUI_DOCKHEIGHT = 0x0200

; Background color special flags
Global Const $GUI_BKCOLOR_TRANSPARENT = -2

; =============================================================================================================================
