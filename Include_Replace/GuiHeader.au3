#include-once

#include "HeaderConstants.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Header
; Description ...: Functions that assist with Header control management.
;                  A header control is a window that is usually positioned above columns of text or numbers.  It contains a title
;                  for each column, and it can be divided into parts.
; Author(s) .....: Paul Campbell (PaulIA)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_ghHDRLastWnd
Global $Debug_HDR = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__HEADERCONSTANT_ClassName = "SysHeader32"
Global Const $__HEADERCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__HEADERCONSTANT_SWP_SHOWWINDOW = 0x0040
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlHeader_GetItem
;_GUICtrlHeader_GetItemCount
;_GUICtrlHeader_GetItemFormat
;_GUICtrlHeader_GetUnicodeFormat
;_GUICtrlHeader_SetItem
;_GUICtrlHeader_SetItemFormat
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItem
; Description ...: Retrieves information about an item
; Syntax.........: _GUICtrlHeader_GetItem($hWnd, $iIndex, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $tItem       - $tagHDITEM structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: When the message is sent, the mask member indicates the type of information being requested.  When the message
;                  returns, the other members receive the requested information.  If the mask member specifies zero, the  message
;                  returns True but copies no information to the structure.
; Related .......: _GUICtrlHeader_SetItem, $tagHDITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItem($hWnd, $iIndex, ByRef $tItem)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlHeader_GetUnicodeFormat($hWnd)

	Local $pItem = DllStructGetPtr($tItem)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		$iRet = _SendMessage($hWnd, $HDM_GETITEMW, $iIndex, $pItem, 0, "wparam", "ptr")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
		_MemWrite($tMemMap, $pItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $HDM_GETITEMW, $iIndex, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $HDM_GETITEMA, $iIndex, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pMemory, $pItem, $iItem)
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_GetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemCount
; Description ...: Retrieves a count of the items
; Syntax.........: _GUICtrlHeader_GetItemCount($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The number of items
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemCount($hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_GETITEMCOUNT)
EndFunc   ;==>_GUICtrlHeader_GetItemCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemFormat
; Description ...: Returns the format of the item
; Syntax.........: _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item format:
;                  |HDF_CENTER          - The item's contents are centered
;                  |HDF_LEFT            - The item's contents are left-aligned.
;                  |HDF_RIGHT           - The item's contents are right-aligned.
;                  |HDF_BITMAP          - The item displays a bitmap.
;                  |HDF_BITMAP_ON_RIGHT - The bitmap appears to the right of text.
;                  |HDF_OWNERDRAW       - The control's owner draws the item.
;                  |HDF_STRING          - The item displays a string.
;                  |HDF_IMAGE           - Display an image from an image list
;                  |HDF_RTLREADING      - Text will read in the opposite direction
;                  |HDF_SORTDOWN        - Draw a down-arrow on this item
;                  |HDF_SORTUP          - Draw an up-arrow on this item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_FORMAT)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)
	Return DllStructGetData($tItem, "Fmt")
EndFunc   ;==>_GUICtrlHeader_GetItemFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemFormat
; Description ...: Sets the format of the item
; Syntax.........: _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iFormat     - Combination of the following format identifiers:
;                  |$HDF_CENTER          - The item's contents are centered
;                  |$HDF_LEFT            - The item's contents are left-aligned
;                  |$HDF_RIGHT           - The item's contents are right-aligned
;                  |$HDF_BITMAP          - The item displays a bitmap
;                  |$HDF_BITMAP_ON_RIGHT - The bitmap appears to the right of text
;                  |$HDF_OWNERDRAW       - The header control's owner draws the item
;                  |$HDF_STRING          - The item displays a string
;                  |$HDF_IMAGE           - Display an image from an image list
;                  |$HDF_RTLREADING      - Text will read in the opposite direction from the text in the parent window
;                  |$HDF_SORTDOWN        - Draws a down-arrow on this item (Windows XP and above)
;                  |$HDF_SORTUP          - Draws an up-arrow on this item (Windows XP and above)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_FORMAT)
	DllStructSetData($tItem, "Fmt", $iFormat)
	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag for the control
; Syntax.........: _GUICtrlHeader_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: True         - Control uses Unicode characters
;                  False        - Control uses ANSI characters
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetUnicodeFormat($hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlHeader_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItem
; Description ...: Sets information about an item
; Syntax.........: _GUICtrlHeader_SetItem($hWnd, $iIndex, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $tItem       - DllStructCreate($tagHDITEM) structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItem, $tagHDITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItem($hWnd, $iIndex, ByRef $tItem)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlHeader_GetUnicodeFormat($hWnd)

	Local $pItem = DllStructGetPtr($tItem)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		$iRet = _SendMessage($hWnd, $HDM_SETITEMW, $iIndex, $pItem, 0, "wparam", "ptr")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
		_MemWrite($tMemMap, $pItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $HDM_SETITEMW, $iIndex, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $HDM_SETITEMA, $iIndex, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_SetItem
