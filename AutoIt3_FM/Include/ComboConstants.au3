#include-once

; #INDEX# =======================================================================================================================
; Title .........: ComboBox_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for <a href="../appendix/GUIStyles.htm#Combo">GUI control Combo styles</a> and more.
; Author(s) .....: Valik, Gary Frost
; ===============================================================================================================================

; ComboBox
; #STYLES# ======================================================================================================================
Global Const $CBS_AUTOHSCROLL = 0x40 ; Automatically scrolls the text in an edit control to the right when the user types a character at the end of the line.
Global Const $CBS_DROPDOWN = 0x2 ; Similar to $CBS_SIMPLE, except that the list box is not displayed unless the user selects an icon next to the edit control
Global Const $CBS_DROPDOWNLIST = 0x3 ; Similar to $CBS_DROPDOWN, except that the edit control is replaced by a static text item that displays the current selection in the list box
Global Const $CBS_SORT = 0x100 ; Automatically sorts strings added to the list box
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $CB_ADDSTRING = 0x143
Global Const $CB_GETCOMBOBOXINFO = 0x164
Global Const $CB_GETCURSEL = 0x147
Global Const $CB_SELECTSTRING = 0x14D
Global Const $CB_SETCURSEL = 0x14E
Global Const $CB_SETEDITSEL = 0x142
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $CBN_EDITCHANGE = 5
Global Const $CBN_SELCHANGE = 1
; ===============================================================================================================================
