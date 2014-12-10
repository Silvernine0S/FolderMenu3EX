#include-once

#include "ListViewConstants.au3"
#include "GuiHeader.au3"
#include "Array.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: ListView
; AutoIt Version : 3.2.3++
; Language ......: English
; Description ...: Functions that assist with ListView control management.
;                  A ListView control is a window that displays a collection of items; each item consists of an icon and a label.
;                  ListView controls provide several ways to arrange and display items. For example, additional information about
;                  each item can be displayed in columns to the right of the icon and label.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s) ........: user32.dll
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_lv_ghLastWnd
Global $Debug_LV = False

; for use with the sort call back functions
Global $iLListViewSortInfoSize = 11
Global $aListViewSortInfo[1][$iLListViewSortInfoSize]
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__LISTVIEWCONSTANT_ClassName = "SysListView32"
Global Const $__LISTVIEWCONSTANT_WS_MAXIMIZEBOX = 0x00010000
Global Const $__LISTVIEWCONSTANT_WS_MINIMIZEBOX = 0x00020000
Global Const $__LISTVIEWCONSTANT_GUI_RUNDEFMSG = 'GUI_RUNDEFMSG'
Global Const $__LISTVIEWCONSTANT_WM_SETREDRAW = 0x000B
Global Const $__LISTVIEWCONSTANT_WM_SETFONT = 0x0030
Global Const $__LISTVIEWCONSTANT_WM_NOTIFY = 0x004E
Global Const $__LISTVIEWCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__LISTVIEWCONSTANT_ILD_TRANSPARENT = 0x00000001
Global Const $__LISTVIEWCONSTANT_ILD_BLEND25 = 0x00000002
Global Const $__LISTVIEWCONSTANT_ILD_BLEND50 = 0x00000004
Global Const $__LISTVIEWCONSTANT_ILD_MASK = 0x00000010
Global Const $__LISTVIEWCONSTANT_VK_DOWN = 0x28
Global Const $__LISTVIEWCONSTANT_VK_END = 0x23
Global Const $__LISTVIEWCONSTANT_VK_HOME = 0x24
Global Const $__LISTVIEWCONSTANT_VK_LEFT = 0x25
Global Const $__LISTVIEWCONSTANT_VK_NEXT = 0x22
Global Const $__LISTVIEWCONSTANT_VK_PRIOR = 0x21
Global Const $__LISTVIEWCONSTANT_VK_RIGHT = 0x27
Global Const $__LISTVIEWCONSTANT_VK_UP = 0x26
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlListView_BeginUpdate
;_GUICtrlListView_EndUpdate
;_GUICtrlListView_EnsureVisible
;_GUICtrlListView_FindItem
;_GUICtrlListView_GetColumnCount
;_GUICtrlListView_GetHeader
;_GUICtrlListView_GetItemChecked
;_GUICtrlListView_GetItemCount
;_GUICtrlListView_GetItemText
;_GUICtrlListView_GetItemTextArray
;_GUICtrlListView_GetItemTextString
;_GUICtrlListView_GetNextItem
;_GUICtrlListView_GetUnicodeFormat
;_GUICtrlListView_RegisterSortCallBack
;_GUICtrlListView_SetImageList
;_GUICtrlListView_SetItemEx
;_GUICtrlListView_SetItemImage
;_GUICtrlListView_SetItemSelected
;_GUICtrlListView_SortItems
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__GUICtrlListView_Sort
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_BeginUpdate
; Description ...: Prevents updating of the control until the EndUpdate function is called
; Syntax.........: _GUICtrlListView_BeginUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_EndUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_BeginUpdate($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW) = 0
EndFunc   ;==>_GUICtrlListView_BeginUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_EndUpdate
; Description ...: Enables screen repainting that was turned off with the BeginUpdate function
; Syntax.........: _GUICtrlListView_EndUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_BeginUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_EndUpdate($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW, 1) = 0
EndFunc   ;==>_GUICtrlListView_EndUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_EnsureVisible
; Description ...: Ensures that a list-view item is either entirely or partially visible
; Syntax.........: _GUICtrlListView_EnsureVisible($hWnd, $iIndex[, $fPartialOK = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the list-view item
;                  $fPartialOK  - Value specifying whether the item must be entirely visible
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $fPartialOK parameter is TRUE, no scrolling occurs if the item is at least partially visible
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_EnsureVisible($hWnd, $iIndex, $fPartialOK = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_ENSUREVISIBLE, $iIndex, $fPartialOK)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_ENSUREVISIBLE, $iIndex, $fPartialOK)
	EndIf
EndFunc   ;==>_GUICtrlListView_EnsureVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_FindItem
; Description ...: Searches for an item with the specified characteristics
; Syntax.........: _GUICtrlListView_FindItem($hWnd, $iStart, ByRef $tFindInfo[, $sText = ""])
; Parameters ....: $hWnd  - Handle to the control
;                  $iStart      - Zero based index of the item to begin the search with or -1 to start from  the  beginning.  The
;                  +specified item is itself excluded from the search.
;                  $tFindInfo   - $tagLVFINDINFO structure that contains the search information
;                  $sText       - String to compare with the item text. It is valid if $LVFI_STRING or $LVFI_PARTIAL is set in the
;                  +Flags member
; Return values .: Success      - The zero based index of the item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_FindParam, _GUICtrlListView_FindNearest, $tagLVFINDINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_FindItem($hWnd, $iStart, ByRef $tFindInfo, $sText = "")
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $pFindInfo = DllStructGetPtr($tFindInfo)
	DllStructSetData($tBuffer, "Text", $sText)
	Local  $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tFindInfo, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_FINDITEM, $iStart, $pFindInfo, 0, "wparam", "ptr")
		Else
			Local $iFindInfo = DllStructGetSize($tFindInfo)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iFindInfo + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iFindInfo
			DllStructSetData($tFindInfo, "Text", $pText)
			_MemWrite($tMemMap, $pFindInfo, $pMemory, $iFindInfo)
			_MemWrite($tMemMap, $pBuffer, $pText, $iBuffer)
			$iRet = _SendMessage($hWnd, $LVM_FINDITEM, $iStart, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		DllStructSetData($tFindInfo, "Text", $pBuffer)
		$iRet = GUICtrlSendMsg($hWnd, $LVM_FINDITEM, $iStart, $pFindInfo)
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlListView_FindItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetColumnCount
; Description ...: Retrieve the number of columns
; Syntax.........: _GUICtrlListView_GetColumnCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Number of columns
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetColumnCount($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

;~ 	Local Const $HDM_GETITEMCOUNT = 0x1200
	Return _SendMessage(_GUICtrlListView_GetHeader($hWnd), 0x1200)
EndFunc   ;==>_GUICtrlListView_GetColumnCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetHeader
; Description ...: Retrieves the handle to the header control
; Syntax.........: _GUICtrlListView_GetHeader($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle to the header control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetHeader($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETHEADER)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETHEADER, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetHeader

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemChecked
; Description ...: Returns the check state for a list-view control item
; Syntax.........: _GUICtrlListView_GetItemChecked($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index to retrieve item check state from
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......: Siao for external control
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemChecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemChecked($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $tLVITEM = DllStructCreate($tagLVITEM)
	Local $iSize = DllStructGetSize($tLVITEM)
	Local $pItem = DllStructGetPtr($tLVITEM)
	If @error Then Return SetError($LV_ERR, $LV_ERR, False)
	DllStructSetData($tLVITEM, "Mask", $LVIF_STATE)
	DllStructSetData($tLVITEM, "Item", $iIndex)
	DllStructSetData($tLVITEM, "StateMask", 0xffff)

	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETITEMW, 0, $pItem, 0, "wparam", "ptr") <> 0
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
			_MemWrite($tMemMap, $pItem)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr") <> 0
			Else
				$iRet = _SendMessage($hWnd, $LVM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr") <> 0
			EndIf
			_MemRead($tMemMap, $pMemory, $pItem, $iSize)
			_MemFree($tMemMap)
		EndIf
	Else
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMW, 0, $pItem) <> 0
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMA, 0, $pItem) <> 0
		EndIf
	EndIf

	If Not $iRet Then Return SetError($LV_ERR, $LV_ERR, False)
	Return BitAND(DllStructGetData($tLVITEM, "State"), 0x2000) <> 0
EndFunc   ;==>_GUICtrlListView_GetItemChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemCount
; Description ...: Retrieves the number of items in a list-view control
; Syntax.........: _GUICtrlListView_GetItemCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The number of items
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemCount
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemCount($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETITEMCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETITEMCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetItemCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemText
; Description ...: Retrieves the text of an item or subitem
; Syntax.........: _GUICtrlListView_GetItemText($hWnd, $iIndex[, $iSubItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iSubItem    - One based sub item index
; Return values .: Success      - Item or subitem text
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: To retrieve the item text, set iSubItem to zero. To retrieve the text of a subitem, set iSubItem to the one
;                  based subitem's index.
; Related .......: _GUICtrlListView_SetItemText, _GUICtrlListView_GetItemTextArray, _GUICtrlListView_GetItemTextString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemText($hWnd, $iIndex, $iSubItem = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tBuffer = DllStructCreate("char Text[4096]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tItem = DllStructCreate($tagLVITEM)
	Local $pItem = DllStructGetPtr($tItem)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	DllStructSetData($tItem, "TextMax", 4096)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tItem, "Text", $pBuffer)
			_SendMessage($hWnd, $LVM_GETITEMTEXTW, $iIndex, $pItem, 0, "wparam", "ptr")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem + 4096, $tMemMap)
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			_MemWrite($tMemMap, $pItem, $pMemory, $iItem)
			If $fUnicode Then
				_SendMessage($hWnd, $LVM_GETITEMTEXTW, $iIndex, $pMemory, 0, "wparam", "ptr")
			Else
				_SendMessage($hWnd, $LVM_GETITEMTEXTA, $iIndex, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemRead($tMemMap, $pText, $pBuffer, 4096)
			_MemFree($tMemMap)
		EndIf
	Else
		DllStructSetData($tItem, "Text", $pBuffer)
		If $fUnicode Then
			GUICtrlSendMsg($hWnd, $LVM_GETITEMTEXTW, $iIndex, $pItem)
		Else
			GUICtrlSendMsg($hWnd, $LVM_GETITEMTEXTA, $iIndex, $pItem)
		EndIf
	EndIf
	Return DllStructGetData($tBuffer, "Text")
EndFunc   ;==>_GUICtrlListView_GetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemTextArray
; Description ...: Retrieves all of a list-view item
; Syntax.........: _GUICtrlListView_GetItemTextArray($hWnd[, $iItem = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iItem       - Zero based index of item to retrieve
; Return values .: Success      - Array with the following format:
;                  |[0] - Number of Columns in array (n)
;                  |[1] - First column index
;                  |[2] - Second column index
;                  |[n] - Last column index
;                  Failure      - Array with the following format:
;                  |[0] - Number of Columns in array (0)
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $iItem = -1 then will attempt to get the Currently Selected item.
; Related .......: _GUICtrlListView_SetItemText, _GUICtrlListView_GetItemText, _GUICtrlListView_GetItemTextString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemTextArray($hWnd, $iItem = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $sItems = _GUICtrlListView_GetItemTextString($hWnd, $iItem)
	If $sItems = "" Then
		Local $vItems[1] = [0]
		Return SetError($LV_ERR, $LV_ERR, $vItems)
	EndIf
	Return StringSplit($sItems, Opt('GUIDataSeparatorChar'))
EndFunc   ;==>_GUICtrlListView_GetItemTextArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemTextString
; Description ...: Retrieves all of a list-view item
; Syntax.........: _GUICtrlListView_GetItemTextString($hWnd[, $iItem = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iItem       - Zero based index of item to retrieve
; Return values .: Success      - delimited string
;                  Failure      - Empty string
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $iItem = -1 then will attempt to get the Currently Selected item.
; Related .......: _GUICtrlListView_SetItemText, _GUICtrlListView_GetItemText, _GUICtrlListView_GetItemTextArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemTextString($hWnd, $iItem = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $sRow = "", $SeparatorChar = Opt('GUIDataSeparatorChar'), $iSelected
	If $iItem = -1 Then
		$iSelected = _GUICtrlListView_GetNextItem($hWnd) ; get current row selected
	Else
		$iSelected = $iItem ; get row
	EndIf
	For $x = 0 To _GUICtrlListView_GetColumnCount($hWnd) - 1
		$sRow &= _GUICtrlListView_GetItemText($hWnd, $iSelected, $x) & $SeparatorChar
	Next
	Return StringTrimRight($sRow, 1)
EndFunc   ;==>_GUICtrlListView_GetItemTextString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetNextItem
; Description ...: Searches for an item that has the specified properties
; Syntax.........:  _GUICtrlListView_GetNextItem($hWnd[, $iStart = -1[, $iSearch = 0[, $iState = 8]]])
; Parameters ....: $hWnd  - Handle to the control
;                  $iStart      - Index of the item to begin the search with, or -1 to find  the  first  item  that  matches  the
;                  +specified flags.  The specified item itself is excluded from the search.
;                  $iSearch     - Relationship to the index of the item where the search is to begin:
;                  |0 - Searches for a subsequent item by index
;                  |1 - Searches for an item that is above the specified item
;                  |2 - Searches for an item that is below the specified item
;                  |3 - Searches for an item to the left of the specified item
;                  |4 - Searches for an item to the right of the specified item
;                  $iState      - State of the item to find. Can be a combination of:
;                  |1 - The item is cut
;                  |2 - The item is highlighted
;                  |4 - The item is focused
;                  |8 - The item is selected
; Return values .: Success      - The zero based index of the next item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetNextItem($hWnd, $iStart = -1, $iSearch = 0, $iState = 8)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aSearch[5] = [$LVNI_ALL, $LVNI_ABOVE, $LVNI_BELOW, $LVNI_TOLEFT, $LVNI_TORIGHT]

	Local $iFlags = $aSearch[$iSearch]
	If BitAND($iState, 1) <> 0 Then $iFlags = BitOR($iFlags, $LVNI_CUT)
	If BitAND($iState, 2) <> 0 Then $iFlags = BitOR($iFlags, $LVNI_DROPHILITED)
	If BitAND($iState, 4) <> 0 Then $iFlags = BitOR($iFlags, $LVNI_FOCUSED)
	If BitAND($iState, 8) <> 0 Then $iFlags = BitOR($iFlags, $LVNI_SELECTED)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETNEXTITEM, $iStart, $iFlags)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETNEXTITEM, $iStart, $iFlags)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetNextItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetUnicodeFormat
; Description ...: Retrieves the UNICODE character format flag
; Syntax.........: _GUICtrlListView_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Using Unicode characters
;                  False        - Using ANSI characters
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetUnicodeFormat($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETUNICODEFORMAT) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETUNICODEFORMAT, 0, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_RegisterSortCallBack
; Description ...: Register the Simple Sort callback function
; Syntax.........: _GUICtrlListView_RegisterSortCallBack($hWnd[, $fNumbers = True[, $fArrows = True]])
; Parameters ....: $hWnd        - Handle of the control
;                  $fNumbers    - Treat number strings as numbers
;                  $fArrows     - Draws a down-arrow/up-arrow on column selected (Windows XP and above)
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: For each call to _GUICtrlListView_RegisterSortCallBack there must be a call
;                  to _GUICtrlListView_UnRegisterSortCallBack when done (before exit)
;+
;                  It is up to the user to call _GUICtrlListView_UnRegisterSortCallBack for each
;                  _GUICtrlListView_RegisterSortCallBack call made.
;+
;                  This is an alternative to the _GUICtrlListView_SimpleSort.
;                  This function will sort listviews that have icons, checkboxes, sub-item icons
; Related .......: _GUICtrlListView_UnRegisterSortCallBack, _GUICtrlListView_SortItems
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_RegisterSortCallBack($hWnd, $fNumbers = True, $fArrows = True)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hHeader = _GUICtrlListView_GetHeader($hWnd)

	ReDim $aListViewSortInfo[UBound($aListViewSortInfo) + 1][$iLListViewSortInfoSize]

	$aListViewSortInfo[0][0] = UBound($aListViewSortInfo) - 1
	Local $iIndex = $aListViewSortInfo[0][0]

	$aListViewSortInfo[$iIndex][1] = $hWnd ; Handle/ID of listview

	$aListViewSortInfo[$iIndex][2] = _
			DllCallbackRegister("__GUICtrlListView_Sort", "int", "int;int;hwnd") ; Handle of callback
	$aListViewSortInfo[$iIndex][3] = -1 ; $nColumn
	$aListViewSortInfo[$iIndex][4] = -1 ; nCurCol
	$aListViewSortInfo[$iIndex][5] = 1 ; $nSortDir
	$aListViewSortInfo[$iIndex][6] = -1 ; $nCol
	$aListViewSortInfo[$iIndex][7] = 0 ; $bSet
	$aListViewSortInfo[$iIndex][8] = $fNumbers ; Treat as numbers?
	$aListViewSortInfo[$iIndex][9] = $fArrows ; Use arrows in the header of the columns?
	$aListViewSortInfo[$iIndex][10] = $hHeader ; Handle to the Header

	Return $aListViewSortInfo[$iIndex][2] <> 0
EndFunc   ;==>_GUICtrlListView_RegisterSortCallBack

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetImageList
; Description ...: Assigns an image list to the control
; Syntax.........: _GUICtrlListView_SetImageList($hWnd, $hHandle[, $iType = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hHandle     - Handle to the image list to assign
;                  $iType       - Type of image list:
;                  |0 - Image list with large icons
;                  |1 - Image list with small icons
;                  |2 - Image list with state images
; Return values .: Success      - The handle to the previous image list
;                  Failue       - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The current image list will be destroyed when the control is destroyed unless you set the $LVS_SHAREIMAGELISTS
;                  style. If you use this message to replace one image list with another your application must explicitly destroy
;                  all image lists other than the current one.
; Related .......: _GUICtrlListView_GetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetImageList($hWnd, $hHandle, $iType = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aType[3] = [$LVSIL_NORMAL, $LVSIL_SMALL, $LVSIL_STATE]

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETIMAGELIST, $aType[$iType], $hHandle, 0, "wparam", "hwnd", "hwnd")
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETIMAGELIST, $aType[$iType], $hHandle)
	EndIf
EndFunc   ;==>_GUICtrlListView_SetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemEx
; Description ...: Sets some or all of a item's attributes
; Syntax.........: _GUICtrlListView_SetItemEx($hWnd, ByRef $tItem)
; Parameters ....: $hWnd  - Handle to the control
;                  $tItem       - $tagLVITEM structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: To set the attributes of an item set the Item member of the $tagLVITEM structure to the index of the item, and
;                  set the SubItem member to zero.  For an item, you can set the State, Text, Image, and Param members of the
;                  $tagLVITEM structure.
;+
;                  To set the text of a subitem, set the Item and SubItem members to indicate the specific subitem, and use the
;                  Text member to specify the text.  You cannot set the State or Param members for subitems because subitems do
;                  not have these attributes.
; Related .......: _GUICtrlListView_SetItem, $tagLVITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemEx($hWnd, ByRef $tItem)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $pItem = DllStructGetPtr($tItem)
	Local $iRet
	If IsHWnd($hWnd) Then
		Local $iItem = DllStructGetSize($tItem)
		Local $iBuffer = DllStructGetData($tItem, "TextMax")
		Local $pBuffer = DllStructGetData($tItem, "Text")
		If $fUnicode Then $iBuffer *= 2
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iItem
		DllStructSetData($tItem, "Text", $pText)
		_MemWrite($tMemMap, $pItem, $pMemory, $iItem)
		If $pBuffer <> 0 Then _MemWrite($tMemMap, $pBuffer, $pText, $iBuffer)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $LVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	Else
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMW, 0, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMA, 0, $pItem)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetItemEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemImage
; Description ...: Sets the index of the item's icon in the control's image list
; Syntax.........: _GUICtrlListView_SetItemImage($hWnd, $iIndex, $iImage[, $iSubItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iImage      - Zero based index into the control's image list
;                  $iSubItem    - One based index of the subitem
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemImage($hWnd, $iIndex, $iImage, $iSubItem = 0)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_IMAGE)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	DllStructSetData($tItem, "Image", $iImage)
	Return _GUICtrlListView_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlListView_SetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemSelected
; Description ...: Sets whether the item is selected
; Syntax.........: _GUICtrlListView_SetItemSelected($hWnd, $iIndex[, $fSelected = True[, $fFocused = False]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item, -1 to set selected state of all items
;                  $fSelected   - If True the item(s) are selected, otherwise not.
;                  $fFocused    - If True the item has focus, otherwise not.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemSelected
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemSelected($hWnd, $iIndex, $fSelected = True, $fFocused = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tstruct = DllStructCreate($tagLVITEM)
	Local $pItem = DllStructGetPtr($tstruct)
	Local $iRet, $iSelected = 0, $iFocused = 0, $iSize, $tMemMap, $pMemory
	If ($fSelected = True) Then $iSelected = $LVIS_SELECTED
	If ($fFocused = True And $iIndex <> -1) Then $iFocused = $LVIS_FOCUSED
	DllStructSetData($tstruct, "Mask", $LVIF_STATE)
	DllStructSetData($tstruct, "Item", $iIndex)
	DllStructSetData($tstruct, "State", BitOR($iSelected, $iFocused))
	DllStructSetData($tstruct, "StateMask", BitOR($LVIS_SELECTED, $iFocused))
	$iSize = DllStructGetSize($tstruct)
	If IsHWnd($hWnd) Then
		$pMemory = _MemInit($hWnd, $iSize, $tMemMap)
		_MemWrite($tMemMap, $pItem, $pMemory, $iSize)
		$iRet = _SendMessage($hWnd, $LVM_SETITEMSTATE, $iIndex, $pMemory)
		_MemFree($tMemMap)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMSTATE, $iIndex, $pItem)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetItemSelected

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_Sort
; Description ...: Our sorting callback function
; Syntax.........: __GUICtrlListView_Sort($nItem1, $nItem2, $hWnd)
; Parameters ....: $nItem1      - Param of 1st item
;                  $nItem2      - Param of 2nd item
;                  $hWnd        - Handle of the control
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_Sort($nItem1, $nItem2, $hWnd)
	Local $iIndex, $tInfo, $val1, $val2, $nResult
	$tInfo = DllStructCreate($tagLVFINDINFO)
	DllStructSetData($tInfo, "Flags", $LVFI_PARAM)

	For $x = 1 To $aListViewSortInfo[0][0]
		If $hWnd = $aListViewSortInfo[$x][1] Then
			$iIndex = $x
			ExitLoop
		EndIf
	Next

	; Switch the sorting direction
	If $aListViewSortInfo[$iIndex][3] = $aListViewSortInfo[$iIndex][4] Then ; $nColumn = nCurCol ?
		If Not $aListViewSortInfo[$iIndex][7] Then ; $bSet
			$aListViewSortInfo[$iIndex][5] *= -1 ; $nSortDir
			$aListViewSortInfo[$iIndex][7] = 1 ; $bSet
		EndIf
	Else
		$aListViewSortInfo[$iIndex][7] = 1 ; $bSet
	EndIf
	$aListViewSortInfo[$iIndex][6] = $aListViewSortInfo[$iIndex][3] ; $nCol = $nColumn
	DllStructSetData($tInfo, "Param", $nItem1)
	$val1 = _GUICtrlListView_FindItem($hWnd, -1, $tInfo)
	DllStructSetData($tInfo, "Param", $nItem2)
	$val2 = _GUICtrlListView_FindItem($hWnd, -1, $tInfo)
	$val1 = _GUICtrlListView_GetItemText($hWnd, $val1, $aListViewSortInfo[$iIndex][3])
	$val2 = _GUICtrlListView_GetItemText($hWnd, $val2, $aListViewSortInfo[$iIndex][3])
	If $aListViewSortInfo[$iIndex][8] Then ; Treat As Number
		If (StringIsFloat($val1) Or StringIsInt($val1)) Then $val1 = Number($val1)
		If (StringIsFloat($val2) Or StringIsInt($val2)) Then $val2 = Number($val2)
	EndIf

	$nResult = 0 ; No change of item1 and item2 positions

	If $val1 < $val2 Then
		$nResult = -1 ; Put item2 before item1
	ElseIf $val1 > $val2 Then
		$nResult = 1 ; Put item2 behind item1
	EndIf

	$nResult = $nResult * $aListViewSortInfo[$iIndex][5] ; $nSortDir

	Return $nResult
EndFunc   ;==>__GUICtrlListView_Sort

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SortItems
; Description ...: Starts the sort call back, also sets the Arrow in the Header
; Syntax.........: _GUICtrlListView_SortItems($hWnd, $iCol)
; Parameters ....: $hWnd        - Handle of the control
;                  $iCol        - Column clicked
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: For use only in conjunction with _GUICtrlListView_RegisterSortCallBack
;+
;                  A down-arrow/up-arrow is drawn on column selected for Windows XP and above if the option was set
;                  when calling _GUICtrlListView_RegisterSortCallBack
; Related .......: _GUICtrlListView_RegisterSortCallBack
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SortItems($hWnd, $iCol)
	Local $iRet, $iIndex, $pFunction, $hHeader, $iFormat

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	For $x = 1 To $aListViewSortInfo[0][0]
		If $hWnd = $aListViewSortInfo[$x][1] Then
			$iIndex = $x
			ExitLoop
		EndIf
	Next

	$pFunction = DllCallbackGetPtr($aListViewSortInfo[$iIndex][2]) ; get pointer to call back
	$aListViewSortInfo[$iIndex][3] = $iCol ; $nColumn = column clicked
	$aListViewSortInfo[$iIndex][7] = 0 ; $bSet
	$aListViewSortInfo[$iIndex][4] = $aListViewSortInfo[$iIndex][6] ; nCurCol = $nCol
	$iRet = _SendMessage($hWnd, $LVM_SORTITEMS, $hWnd, $pFunction, 0, "hwnd", "ptr")
	If $iRet <> 0 Then
		If $aListViewSortInfo[$iIndex][9] Then ; Use arrow in header
			$hHeader = $aListViewSortInfo[$iIndex][10]
			For $x = 0 To _GUICtrlHeader_GetItemCount($hHeader) - 1
				$iFormat = _GUICtrlHeader_GetItemFormat($hHeader, $x)
				If BitAND($iFormat, $HDF_SORTDOWN) Then
					_GUICtrlHeader_SetItemFormat($hHeader, $x, BitXOR($iFormat, $HDF_SORTDOWN))
				ElseIf BitAND($iFormat, $HDF_SORTUP) Then
					_GUICtrlHeader_SetItemFormat($hHeader, $x, BitXOR($iFormat, $HDF_SORTUP))
				EndIf
			Next
			$iFormat = _GUICtrlHeader_GetItemFormat($hHeader, $iCol)
			If $aListViewSortInfo[$iIndex][5] = 1 Then ; ascending
				_GUICtrlHeader_SetItemFormat($hHeader, $iCol, BitOR($iFormat, $HDF_SORTUP))
			Else ; descending
				_GUICtrlHeader_SetItemFormat($hHeader, $iCol, BitOR($iFormat, $HDF_SORTDOWN))
			EndIf
		EndIf
	EndIf

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SortItems
