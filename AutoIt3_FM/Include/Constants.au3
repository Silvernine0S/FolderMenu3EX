#include-once

; #INDEX# =======================================================================================================================
; Title .........: Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants to be included in an AutoIt v3 script.
; Author(s) .....: JLandes, Nutster, CyberSlug, Holger, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Sets the way coords are used in the mouse and pixel functions
Global Const $OPT_COORDSABSOLUTE	= 1 ; Absolute screen coordinates (default)

; DrawIconEx Constants
Global Const $DI_NORMAL			= 0x0003

; Virtual Keys Constants
Global Const $VK_DOWN	= 0x28
Global Const $VK_END	= 0x23
Global Const $VK_HOME	= 0x24
Global Const $VK_LEFT	= 0x25
Global Const $VK_NEXT	= 0x22
Global Const $VK_PRIOR	= 0x21
Global Const $VK_RIGHT	= 0x27
Global Const $VK_UP		= 0x26

; Message Box Constants
; Indicates the buttons displayed in the message box
Global Const $MB_OKCANCEL			= 1 ; Two push buttons: OK and Cancel
Global Const $MB_YESNO				= 4 ; Two push buttons: Yes and No

; Displays an icon in the message box
Global Const $MB_ICONHAND			= 16 ; Stop-sign icon
Global Const $MB_ICONQUESTION		= 32 ; Question-mark icon
Global Const $MB_ICONEXCLAMATION	= 48 ; Exclamation-point icon
Global Const $MB_ICONASTERISK		= 64 ; Icon consisting of an 'i' in a circle

; Indicates the default button
Global Const $MB_DEFBUTTON2		= 256 ; The second button is the default button
; Indicates miscellaneous message box attributes
Global Const $MB_TOPMOST		= 262144 ; top-most attribute

; Indicates the button selected in the message box
Global Const $IDOK			= 1 ; OK button was selected
Global Const $IDYES			= 6 ; Yes button was selected

; Tray Constants
; Tray event values
Global Const $TRAY_EVENT_PRIMARYUP			= -8
