#include-once

; #INDEX# =======================================================================================================================
; Title .........: ListView_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: <a href="../appendix/GUIStyles.htm#ListView">GUI control ListView styles</a> and much more constants.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
; listView Extended Styles
Global Const $LVS_EX_CHECKBOXES = 0x00000004 ; Enables check boxes for items
Global Const $LVS_EX_FULLROWSELECT = 0x00000020 ; When an item is selected, the item and all its subitems are highlighted
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $LVFI_PARAM = 0x0001

Global Const $LVIF_COLFMT = 0x00010000
Global Const $LVIF_COLUMNS = 0x00000200
Global Const $LVIF_GROUPID = 0x00000100
Global Const $LVIF_IMAGE = 0x00000002
Global Const $LVIF_INDENT = 0x00000010
Global Const $LVIF_NORECOMPUTE = 0x00000800
Global Const $LVIF_PARAM = 0x00000004
Global Const $LVIF_STATE = 0x00000008
Global Const $LVIF_TEXT = 0x00000001

Global Const $LVIS_CUT = 0x0004
Global Const $LVIS_DROPHILITED = 0x0008
Global Const $LVIS_FOCUSED = 0x0001
Global Const $LVIS_OVERLAYMASK = 0x0F00
Global Const $LVIS_SELECTED = 0x0002
Global Const $LVIS_STATEIMAGEMASK = 0xF000
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $LVM_FIRST = 0x1000

Global Const $LVM_ENSUREVISIBLE = ($LVM_FIRST + 19)
Global Const $LVM_FINDITEM = ($LVM_FIRST + 13)
Global Const $LVM_GETHEADER = ($LVM_FIRST + 31)
Global Const $LVM_GETITEMA = ($LVM_FIRST + 5)
Global Const $LVM_GETITEMW = ($LVM_FIRST + 75)
Global Const $LVM_GETITEMCOUNT = ($LVM_FIRST + 4)
Global Const $LVM_GETITEMTEXTA = ($LVM_FIRST + 45)
Global Const $LVM_GETITEMTEXTW = ($LVM_FIRST + 115)
Global Const $LVM_GETNEXTITEM = ($LVM_FIRST + 12)
Global Const $LVM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $LVM_SETCOLUMNWIDTH = ($LVM_FIRST + 30)
Global Const $LVM_SETIMAGELIST = ($LVM_FIRST + 3)
Global Const $LVM_SETITEMA = ($LVM_FIRST + 6)
Global Const $LVM_SETITEMW = ($LVM_FIRST + 76)
Global Const $LVM_SETITEMSTATE = ($LVM_FIRST + 43)
Global Const $LVM_SORTITEMS = ($LVM_FIRST + 48)
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $LVN_FIRST = -100
Global Const $LVN_ITEMACTIVATE = ($LVN_FIRST - 14) ; The user activated an item
Global Const $LVN_ITEMCHANGED = ($LVN_FIRST - 1) ; An item has changed
Global Const $LVN_KEYDOWN = ($LVN_FIRST - 55)
; ===============================================================================================================================

Global Const $LVNI_ABOVE = 0x0100
Global Const $LVNI_BELOW = 0x0200
Global Const $LVNI_TOLEFT = 0x0400
Global Const $LVNI_TORIGHT = 0x0800
Global Const $LVNI_ALL = 0x0000
Global Const $LVNI_CUT = 0x0004
Global Const $LVNI_DROPHILITED = 0x0008
Global Const $LVNI_FOCUSED = 0x0001
Global Const $LVNI_SELECTED = 0x0002

Global Const $LVSCW_AUTOSIZE_USEHEADER = -2

Global Const $LVSIL_NORMAL = 0
Global Const $LVSIL_SMALL = 1
Global Const $LVSIL_STATE = 2
