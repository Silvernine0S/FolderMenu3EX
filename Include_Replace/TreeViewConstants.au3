#include-once

; #INDEX# =======================================================================================================================
; Title .........: TreeView_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: <a href="../appendix/GUIStyles.htm#TreeView">GUI control TreeView styles</a> and much more constants.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Styles
Global Const $TVS_HASBUTTONS = 0x00000001 ; Displays plus (+) and minus (-) buttons next to parent items
Global Const $TVS_HASLINES = 0x00000002 ; Uses lines to show the hierarchy of items
Global Const $TVS_SHOWSELALWAYS = 0x00000020 ; Causes a selected item to remain selected when the control loses focus

; Expand flags
Global Const $TVE_COLLAPSE = 0x0001
Global Const $TVE_EXPAND = 0x0002

; GetNext flags
Global Const $TVGN_ROOT = 0x00000000
Global Const $TVGN_NEXT = 0x00000001
Global Const $TVGN_PREVIOUS = 0x00000002
Global Const $TVGN_PARENT = 0x00000003
Global Const $TVGN_CHILD = 0x00000004
Global Const $TVGN_FIRSTVISIBLE = 0x00000005
Global Const $TVGN_NEXTVISIBLE = 0x00000006
Global Const $TVGN_DROPHILITE = 0x00000008
Global Const $TVGN_CARET = 0x00000009

; Insert flags
Global Const $TVI_ROOT = 0xFFFF0000
Global Const $TVI_FIRST = 0xFFFF0001
Global Const $TVI_LAST = 0xFFFF0002
Global Const $TVI_SORT = 0xFFFF0003

; item/itemex mask flags
Global Const $TVIF_TEXT = 0x00000001
Global Const $TVIF_IMAGE = 0x00000002
Global Const $TVIF_PARAM = 0x00000004
Global Const $TVIF_STATE = 0x00000008
Global Const $TVIF_HANDLE = 0x00000010
Global Const $TVIF_SELECTEDIMAGE = 0x00000020
Global Const $TVIF_CHILDREN = 0x00000040
Global Const $TVIF_INTEGRAL = 0x00000080
Global Const $TVIF_DI_SETITEM = 0x00001000

; item states
Global Const $TVIS_SELECTED = 0x00000002
Global Const $TVIS_EXPANDED = 0x00000020

Global Const $TVNA_ADD = 1
Global Const $TVNA_ADDFIRST = 2
Global Const $TVNA_ADDCHILD = 3
Global Const $TVNA_ADDCHILDFIRST = 4
Global Const $TVNA_INSERT = 5

Global Const $TVTA_ADDFIRST = 1
Global Const $TVTA_ADD = 2
Global Const $TVTA_INSERT = 3

; Messages to send to TreeView
Global Const $TV_FIRST = 0x1100
Global Const $TVM_INSERTITEMA = $TV_FIRST + 0
Global Const $TVM_DELETEITEM = $TV_FIRST + 1
Global Const $TVM_EXPAND = $TV_FIRST + 2
Global Const $TVM_GETITEMRECT = $TV_FIRST + 4
Global Const $TVM_GETCOUNT = $TV_FIRST + 5
Global Const $TVM_GETIMAGELIST = $TV_FIRST + 8
Global Const $TVM_SETIMAGELIST = $TV_FIRST + 9
Global Const $TVM_GETNEXTITEM = $TV_FIRST + 10
Global Const $TVM_SELECTITEM = $TV_FIRST + 11
Global Const $TVM_GETITEMA = $TV_FIRST + 12
Global Const $TVM_SETITEMA = $TV_FIRST + 13
Global Const $TVM_HITTEST = $TV_FIRST + 17
Global Const $TVM_CREATEDRAGIMAGE = $TV_FIRST + 18
Global Const $TVM_SORTCHILDREN = $TV_FIRST + 19
Global Const $TVM_ENSUREVISIBLE = $TV_FIRST + 20
Global Const $TVM_SETINSERTMARK = $TV_FIRST + 26
Global Const $TVM_INSERTITEMW = $TV_FIRST + 50
Global Const $TVM_GETITEMW = $TV_FIRST + 62
Global Const $TVM_SETITEMW = $TV_FIRST + 63
Global Const $TVM_GETUNICODEFORMAT = 0x2000 + 6
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $TVN_FIRST = -400
Global Const $TVN_SELCHANGEDA = $TVN_FIRST - 2
Global Const $TVN_BEGINDRAGA = $TVN_FIRST - 7
Global Const $TVN_KEYDOWN = $TVN_FIRST - 12
Global Const $TVN_SELCHANGEDW = $TVN_FIRST - 51
Global Const $TVN_BEGINDRAGW = $TVN_FIRST - 56
; ===============================================================================================================================
