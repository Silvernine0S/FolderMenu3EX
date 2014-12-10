#include-once

#include "ComboConstants.au3"
#include "WinAPI.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: ComboBox
; AutoIt Version : 3.2.3++
; Language ......: English
; Description ...: Functions that assist with ComboBox control management.
; Author(s) .....: gafrost, PaulIA, Valik
; Dll(s) ........: User32.dll
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_ghCBLastWnd
Global $Debug_CB = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__COMBOBOXCONSTANT_ClassName		= "ComboBox"
Global Const $__COMBOBOXCONSTANT_EM_GETLINE		= 0xC4
Global Const $__COMBOBOXCONSTANT_EM_LINEINDEX	= 0xBB
Global Const $__COMBOBOXCONSTANT_EM_LINELENGTH	= 0xC1
Global Const $__COMBOBOXCONSTANT_EM_REPLACESEL	= 0xC2

Global Const $__COMBOBOXCONSTANT_WM_SETREDRAW		= 0x000B
Global Const $__COMBOBOXCONSTANT_WS_TABSTOP			= 0x00010000
Global Const $__COMBOBOXCONSTANT_DEFAULT_GUI_FONT	= 17
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlComboBox_AddString
;_GUICtrlComboBox_GetComboBoxInfo
;_GUICtrlComboBox_GetCurSel
;_GUICtrlComboBox_ReplaceEditSel
;_GUICtrlComboBox_SelectString
;_GUICtrlComboBox_SetCurSel
;_GUICtrlComboBox_SetEditSel
;_GUICtrlComboBox_SetEditText
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagCOMBOBOXINFO
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagCOMBOBOXINFO
; Description ...: Contains combo box status information
; Fields ........: cbSize      - The size, in bytes, of the structure. The calling application must set this to sizeof(COMBOBOXINFO).
;                  rcItem      - A RECT structure that specifies the coordinates of the edit box.
;                  |EditLeft
;                  |EditTop
;                  |EditRight
;                  |EditBottom
;                  rcButton    - A RECT structure that specifies the coordinates of the button that contains the drop-down arrow.
;                  |BtnLeft
;                  |BtnTop
;                  |BtnRight
;                  |BtnBottom
;                  stateButton - The combo box button state. This parameter can be one of the following values.
;                  |0                       - The button exists and is not pressed.
;                  |$STATE_SYSTEM_INVISIBLE - There is no button.
;                  |$STATE_SYSTEM_PRESSED   - The button is pressed.
;                  hCombo      - A handle to the combo box.
;                  hEdit       - A handle to the edit box.
;                  hList       - A handle to the drop-down list.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagCOMBOBOXINFO = "dword Size;long EditLeft;long EditTop;long EditRight;long EditBottom;long BtnLeft;long BtnTop;" & _
		"long BtnRight;long BtnBottom;dword BtnState;hwnd hCombo;hwnd hEdit;hwnd hList"

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_AddString
; Description ...: Add a string
; Syntax.........: _GUICtrlComboBox_AddString($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String to add
; Return values .: Success      - The index of the new item
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBox_DeleteString, _GUICtrlComboBox_InsertString, _GUICtrlComboBox_ResetContent, _GUICtrlComboBox_InitStorage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_AddString($hWnd, $sText)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $CB_ADDSTRING, 0, $sText, 0, "wparam", "wstr")
EndFunc   ;==>_GUICtrlComboBox_AddString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_GetComboBoxInfo
; Description ...: Gets information about the specified ComboBox
; Syntax.........: _GUICtrlComboBox_GetComboBoxInfo($hWnd, ByRef $tInfo)
; Parameters ....: $hWnd        - Handle to control
;                  $tInfo       - infos as defined by $tagCOMBOBOXINFO
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Minimum OS: Windows XP
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_GetComboBoxInfo($hWnd, ByRef $tInfo)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	$tInfo = DllStructCreate($tagCOMBOBOXINFO)
	Local $pInfo = DllStructGetPtr($tInfo)
	Local $iInfo = DllStructGetSize($tInfo)
	DllStructSetData($tInfo, "Size", $iInfo)
	Return _SendMessage($hWnd, $CB_GETCOMBOBOXINFO, 0, $pInfo, 0, "wparam", "ptr") <> 0
EndFunc   ;==>_GUICtrlComboBox_GetComboBoxInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_GetCurSel
; Description ...: Retrieve the index of the currently selected item
; Syntax.........: _GUICtrlComboBox_GetCurSel($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      -  Zero-based index of the currently selected item
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBox_SetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_GetCurSel($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $CB_GETCURSEL)
EndFunc   ;==>_GUICtrlComboBox_GetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_ReplaceEditSel
; Description ...: Replace text selected in edit box
; Syntax.........: _GUICtrlComboBox_ReplaceEditSel($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String containing the replacement text
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Minimum OS: Windows XP
;                  If the message is sent to a ComboBox with the $CBS_DROPDOWN or $CBS_DROPDOWNLIST style the Function will fail.
; Related .......: _GUICtrlComboBox_SetEditText, _GUICtrlComboBox_SetEditSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_ReplaceEditSel($hWnd, $sText)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tInfo
	If _GUICtrlComboBox_GetComboBoxInfo($hWnd, $tInfo) Then
		Local $hEdit = DllStructGetData($tInfo, "hEdit")
		_SendMessage($hEdit, $__COMBOBOXCONSTANT_EM_REPLACESEL, True, $sText, 0, "wparam", "wstr")
	EndIf
EndFunc   ;==>_GUICtrlComboBox_ReplaceEditSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_SelectString
; Description ...: Searches the ListBox of a ComboBox for an item that begins with the characters in a specified string
; Syntax.........: _GUICtrlComboBox_SelectString($hWnd, $sText[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String that contains the characters for which to search
;                  $iIndex      - Specifies the zero-based index of the item preceding the first item to be searched
; Return values .: Success      - The index of the selected item
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: When the search reaches the bottom of the list, it continues from the top of the list back to the
;                  item specified by the wParam parameter.
;+
;                  If $iIndex is –1, the entire list is searched from the beginning.
;                  A string is selected only if the characters from the starting point match the characters in the
;                  prefix string
;+
;                  If a matching item is found, it is selected and copied to the edit control
; Related .......: _GUICtrlComboBox_FindString, _GUICtrlComboBox_FindStringExact, _GUICtrlComboBoxEx_FindStringExact
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_SelectString($hWnd, $sText, $iIndex = -1)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $CB_SELECTSTRING, $iIndex, $sText, 0, "wparam", "wstr")
EndFunc   ;==>_GUICtrlComboBox_SelectString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_SetCurSel
; Description ...: Select a string in the list of a ComboBox
; Syntax.........: _GUICtrlComboBox_SetCurSel($hWnd[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero-based index of the string to select
; Return values .: Success      - The index of the item selected
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $iIndex is –1, any current selection in the list is removed and the edit control is cleared.
;+
;                  If $iIndex is greater than the number of items in the list or if $iIndex is –1, the return value
;                  is -1 and the selection is cleared.
; Related .......: _GUICtrlComboBox_GetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_SetCurSel($hWnd, $iIndex = -1)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $CB_SETCURSEL, $iIndex)
EndFunc   ;==>_GUICtrlComboBox_SetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_SetEditSel
; Description ...: Select characters in the edit control of a ComboBox
; Syntax.........: _GUICtrlComboBox_SetEditSel($hWnd, $iStart, $iStop)
; Parameters ....: $hWnd        - Handle to control
;                  $iStart      - Starting position
;                  $iStop       - Ending postions
; Return values .: Success      - True
;                  Failure      - False If the message is sent to a ComboBox with the $CBS_DROPDOWN or $CBS_DROPDOWNLIST style
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The positions are zero-based. The first character of the edit control is in the zero position.
;                  If $iStop is –1, all text from the starting position to the last character in the edit control is selected.
;+
;                  The first character after the last selected character is in the ending position.
;+
;                  For example, to select the first four characters of the edit control, use a starting position
;                  of 0 and an ending position of 4.
; Related .......: _GUICtrlComboBox_GetEditSel, _GUICtrlComboBox_ReplaceEditSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_SetEditSel($hWnd, $iStart, $iStop)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXCONSTANT_ClassName)
	If Not HWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $CB_SETEDITSEL, 0, _WinAPI_MakeLong($iStart, $iStop)) <> -1
EndFunc   ;==>_GUICtrlComboBox_SetEditSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_SetEditText
; Description ...: Set the text of the edit control of the ComboBox
; Syntax.........: _GUICtrlComboBox_SetEditText($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - Text to be set
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Minimum OS: Windows XP
;                  If the message is sent to a ComboBox with the $CBS_DROPDOWN or $CBS_DROPDOWNLIST style the Function will fail.
; Related .......: _GUICtrlComboBox_GetEditText, _GUICtrlComboBox_ReplaceEditSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_SetEditText($hWnd, $sText)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_GUICtrlComboBox_SetEditSel($hWnd, 0, -1)
	_GUICtrlComboBox_ReplaceEditSel($hWnd, $sText)
EndFunc   ;==>_GUICtrlComboBox_SetEditText
