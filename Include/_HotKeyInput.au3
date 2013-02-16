#Region Header

#cs

	Title:			Hotkeys Input Control UDF Library for AutoIt3
	Filename:		HotKeyInput.au3
	Description:	Creates and manages an Hotkey Input control for the GUI
					(see "Shortcut key" input control in shortcut properties dialog box for example)
	Author:			Yashied
	Version:		1.2
	Requirements:	AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
	Uses:			StructureConstants.au3, WinAPI.au3, WindowsConstants.au3, vkArray.au3
	Notes:			-

	Available functions:
	
	_GUICtrlCreateHotKeyInput
	_GUICtrlDeleteHotKeyInput
	_GUICtrlReadHotKeyInput
	_GUICtrlSetHotKeyInput
	_GUICtrlReleaseHotKeyInput
	
	Additional features:
	
	_KeyLock
	_KeyLoadName
	_KeyToStr
	
	Example:

		#Include <GUIConstantsEx.au3>
		#Include <HotKeyInput.au3>

		Global $Form, $ButtonOk, $HotkeyInput1, $HotkeyInput2, $GUIMsg
		Global $t

		$Form = GUICreate('Test', 300, 160)
		GUISetFont(8.5, 400, 0, 'Tahoma', $Form)

		$HotkeyInput1 = _GUICtrlCreateHotKeyInput(0, 56, 55, 230, 20)
		$HotkeyInput2 = _GUICtrlCreateHotKeyInput(0, 56, 89, 230, 20)

		_KeyLock(0x062E) ; Lock CTRL-ALT-DEL for Hotkey Input control, but not for Windows

		GUICtrlCreateLabel('Hotkey1:', 10, 58, 44, 14)
		GUICtrlCreateLabel('Hotkey2:', 10, 92, 44, 14)
		GUICtrlCreateLabel('Click on Input box and hold a combination of keys.' & @CR & 'Press OK to view the code.', 10, 10, 280, 28)
		$ButtonOk = GUICtrlCreateButton('OK', 110, 124, 80, 23)
		GUICtrlSetState(-1, BitOR($GUI_DEFBUTTON, $GUI_FOCUS))
		GUISetState()

		While 1
			$GUIMsg = GUIGetMsg()

			Select
				Case $GUIMsg = $GUI_EVENT_CLOSE
					Exit
				Case $GUIMsg = $ButtonOk
					$t = '   Hotkey1:  0x' & StringRight(Hex(_GUICtrlReadHotKeyInput($HotkeyInput1)), 4) & '  (' & GUICtrlRead($HotkeyInput1) & ')   ' & @CR & @CR & _
						 '   Hotkey2:  0x' & StringRight(Hex(_GUICtrlReadHotKeyInput($HotkeyInput2)), 4) & '  (' & GUICtrlRead($HotkeyInput2) & ')   '
					MsgBox(0, 'Code', $t, 0, $Form)
			EndSelect
		WEnd

#ce

#Include-once

#Include <StructureConstants.au3>
#Include <WinAPI.au3>
#Include <WindowsConstants.au3>

#EndRegion Header

#Region Local Variables and Constants

Dim $hkId[1][9] = [[0, 0, 0, 0, 0, 0, 0, 0]]

#cs
	
DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$hkId[0][0]   - Count item of array
	 [0][1]   - Interruption control flag (need to set this flag before changing $hkId array)
	 [0][2]   - Last key pressed (16-bit code)
	 [0][3]   - SCAW status (8-bit)
     [0][4]   - Handle to the user-defined DLL Callback function (returned by DllCallbackRegister())
     [0][5]   - Handle to the hook procedure (returned by _WinAPI_SetWindowsHookEx())
	 [0][6]   - Index in array of the last control with the keyboard focus (don`t change it)
	 [0][7]   - Hold down key control flag
	 [0][8]   - Release key control flag
	 
$hkId[i][0]   - The control identifier (controlID) as returned by GUICtrlCreateInput()
	 [i][1]   - Handle of the given controlID (GUICtrlGetHandle($hkId[i][0]))
	 [i][2]   - Last hotkey code for Hotkey Input control
	 [i][3]   - Separating characters
	 [i][4-8] - Reserved
	
#ce

Dim $hkLock[1] = [0]

#cs
	
DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$hkLock[0] - Count item of array
	   [i] - Lock keys, these keys will not be blocked (16-bit code)
#ce

Global Const $HK_WM_NCLBUTTONDOWN = 0x00A1

Global $OnHotKeyInputExit = Opt('OnExitFunc', 'OnHotKeyInputExit')

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlCreateHotKeyInput
; Description:		Creates a Hotkey Input control for the GUI.
; Syntax:			_GUICtrlCreateHotKeyInput ( $iKey, $iLeft, $iTop [, $iWidth [, $iHeight [, $iStyle [, $iExStyle]]]] )
; Parameter(s):		$iKey       - Combined 16-bit hotkey code, which consists of upper and lower bytes. Value of bits shown in the following table.
;
;								  Hotkey code bits:
;
;								  0-7   - Specifies the virtual-key (VK) code of the key. Codes for the mouse buttons (0x01 - 0x06) are not supported.
;										 (http://msdn.microsoft.com/en-us/library/dd375731(VS.85).aspx)
;
;								  8     - SHIFT key
;								  9     - CONTROL key
;								  10    - ALT key
;								  11    - WIN key
;								  12-15 - Don`t used
;
;					$iLeft, $iTop, $iWidth, $iHeight, $iStyle, $iExStyle - See description for the GUICtrlCreateInput() function.
;					(http://www.autoitscript.com/autoit3/docs/functions/GUICtrlCreateInput.htm)
;
;					$sSeparator - Separating characters. Default is "-".
;
; Return Value(s):	Success: Returns the identifier (controlID) of the new control.
;					Failure: Returns 0.
; Author(s):		Yashied
;
; Note(s):			Use _GUICtrlDeleteHotKeyInput() to delete Hotkey Input control. DO NOT USE GUICtrlDelete()! To work with the Hotkey Input
;					control used functions designed to Input control. If you set the GUI_DISABLE state for control then Hotkey Input control
;					will not work until the state will be set to GUI_ENABLE. Before calling GUIDelete() remove all created Hotkey Input controls
;					by _GUICtrlReleaseHotKeyInput().
;====================================================================================================================================

Func _GUICtrlCreateHotKeyInput($iKey, $iLeft, $iTop, $iWidth = -1, $iHeight = -1, $iStyle = -1, $iExStyle = -1, $sSeparator = ' + ')

	Local $ID

	$iKey = BitAND($iKey, 0x0FFF)
	If BitAND($iKey, 0x00FF) = 0 Then
		$iKey = 0
	EndIf
	If $iStyle < 0 Then
		$iStyle = 0x0080
	EndIf
	If ($hkId[0][0] = 0) And ($hkId[0][5] = 0) Then
		GUIRegisterMsg($HK_WM_NCLBUTTONDOWN, 'HK_WM_NCLBUTTONDOWN')
		$hkId[0][4] = DllCallbackRegister('__hook', 'long', 'int;wparam;lparam')
		$hkId[0][5] = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($hkId[0][4]), _WinAPI_GetModuleHandle(0), 0)
		If (@error) Or ($hkId[0][5] = 0) Then
			Return 0
		EndIf
	EndIf
	$ID = GUICtrlCreateInput('', $iLeft, $iTop, $iWidth, $iHeight, BitOR($iStyle, 0x0800), $iExStyle)
	If $ID = 0 Then
		If $hkId[0][0] = 0 Then
			If _WinAPI_UnhookWindowsHookEx($hkId[0][5]) Then
				DllCallbackFree($hkId[0][4])
				GUIRegisterMsg($HK_WM_NCLBUTTONDOWN, '')
				$hkId[0][5] = 0
			EndIf
		EndIf
		Return 0
	EndIf
	GUICtrlSetBkColor($ID, 0xFFFFFF)
	GUICtrlSetData($ID, _KeyToStr($iKey, $sSeparator))
	ReDim $hkId[$hkId[0][0] + 2][UBound($hkId, 2)]
	$hkId[$hkId[0][0] + 1][0] = $ID
	$hkId[$hkId[0][0] + 1][1] = GUICtrlGetHandle($ID)
	$hkId[$hkId[0][0] + 1][2] = $iKey
	$hkId[$hkId[0][0] + 1][3] = $sSeparator
	$hkId[$hkId[0][0] + 1][4] = 0
	$hkId[$hkId[0][0] + 1][5] = 0
	$hkId[$hkId[0][0] + 1][6] = 0
	$hkId[$hkId[0][0] + 1][7] = 0
	$hkId[$hkId[0][0] + 1][8] = 0
	$hkId[0][0] += 1
	Return $ID
EndFunc   ;==>_GUICtrlCreateHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlDeleteHotKeyInput
; Description:		Deletes a Hotkey Input control.
; Syntax:			_GUICtrlDeleteHotKeyInput ( $controlID )
; Parameter(s):		$controlID - The control identifier (controlID) as returned by a _GUICtrlCreateHotKeyInput() function.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _GUICtrlDeleteHotKeyInput($controlID)

	Local $Index = _focus(_WinAPI_GetFocus())

	For $i = 1 To $hkId[0][0]
		If $controlID = $hkId[$i][0] Then
			$hkId[0][1] = 1
			If Not GUICtrlDelete($hkId[$i][0]) Then
;				$hkId[0][1] = 0
;				return 0
			EndIf
			For $j = $i To $hkId[0][0] - 1
				For $k = 0 To UBound($hkId, 2) - 1
					$hkId[$j][$k] = $hkId[$j + 1][$k]
				Next
			Next
			$hkId[0][0] -= 1
			ReDim $hkId[$hkId[0][0] + 1][UBound($hkId, 2)]
			If $hkId[0][0] = 0 Then
				If _WinAPI_UnhookWindowsHookEx($hkId[0][5]) Then
					DllCallbackFree($hkId[0][4])
					GUIRegisterMsg($HK_WM_NCLBUTTONDOWN, '')
					$hkId[0][2] = 0
					$hkId[0][3] = 0
					$hkId[0][5] = 0
					$hkId[0][6] = 0
					$hkId[0][7] = 0
					$hkId[0][8] = 0
				EndIf
			EndIf
			If $i = $hkId[0][6] Then
				$hkId[0][6] = 0
			EndIf
			If $i = $Index Then
				$hkId[0][2] = 0
				$hkId[0][7] = 0
				$hkId[0][8] = 0
			EndIf
			$hkId[0][1] = 0
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>_GUICtrlDeleteHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlReadHotKeyInput
; Description:		Reads a hotkey code from Hotkey Input control.
; Syntax:			_GUICtrlReadHotKeyInput ( $controlID )
; Parameter(s):		$controlID - The control identifier (controlID) as returned by a _GUICtrlCreateHotKeyInput() function.
; Return Value(s):	Success: Returns combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			Use the GUICtrlRead() to obtain the string of hotkey.
;====================================================================================================================================

Func _GUICtrlReadHotKeyInput($controlID)

	Local $Ret = 0

	For $i = 1 To $hkId[0][0]
		If $controlID = $hkId[$i][0] Then
			Return $hkId[$i][2]
		EndIf
	Next
	Return 0
EndFunc   ;==>_GUICtrlReadHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlSetHotKeyInput
; Description:		Modifies a data for a Hotkey Input control.
; Syntax:			_GUICtrlSetHotKeyInput ( $controlID, $iKey )
; Parameter(s):		$controlID - The control identifier (controlID) as returned by a _GUICtrlCreateHotKeyInput() function.
;					$iKey      - Combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _GUICtrlSetHotKeyInput($controlID, $iKey)

	Local $Ret = 0

	$iKey = BitAND($iKey, 0x0FFF)
	If BitAND($iKey, 0x00FF) = 0 Then
		$iKey = 0
	EndIf
	For $i = 1 To $hkId[0][0]
		If $controlID = $hkId[$i][0] Then
			$hkId[0][1] = 1
			If GUICtrlSetData($hkId[$i][0], _KeyToStr($iKey, $hkId[$i][3])) Then
				If ($i = _focus(_WinAPI_GetFocus())) And ($hkId[0][8] = 1) And (BitAND(BitXOR($iKey, $hkId[$i][2]), 0x00FF) > 0) Then
					$hkId[0][8] = 0
				EndIf
				$hkId[$i][2] = $iKey
				$Ret = 1
			EndIf
			ExitLoop
		EndIf
	Next
	$hkId[0][1] = 0
	Return $Ret
EndFunc   ;==>_GUICtrlSetHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlReleaseHotKeyInput
; Description:		Deletes all Hotkey Input control, which were created by a _GUICtrlCreateHotKeyInput() function.
; Syntax:			_GUICtrlReleaseHotKeyInput (  )
; Parameter(s):		None.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			Use this function before calling GUIDelete() to remove all created Hotkey Input controls.
;====================================================================================================================================

Func _GUICtrlReleaseHotKeyInput()

	Local $Ret = 1, $n = $hkId[0][0]

	While $n > 0
		If Not _GUICtrlDeleteHotKeyInput($hkId[$n][0]) Then
			$Ret = 0
		EndIf
		$n -= 1
	WEnd
	Return $Ret
EndFunc   ;==>_GUICtrlReleaseHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_KeyLock
; Description:		Locks a specified key combination for a Hotkey Input control.
; Syntax:			_KeyLock ( $iKey )
; Parameter(s):		$iKey - Combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
; Return Value(s):	None.
; Author(s):		Yashied
;
; Note(s):			This function is independent and can be called at any time. The keys are blocked only for the Hotkey Input controls
;					and will be available for other applications. Using this feature, you can not lock the key, but only with the combination
;					of this key. To completely lock the keys, use _KeyLoadName(). For example, this feature can be used to lock for
;					Hotkey Input control "ALT-TAB". In this case, "ALT-TAB" will work as always. You can block any number of keys,
;					but no more than one in one function call.
;====================================================================================================================================

Func _KeyLock($iKey)
	$iKey = BitAND($iKey, 0x0FFF)
	For $i = 1 To $hkLock[0]
		If $hkLock[$i] = $iKey Then
			Return
		EndIf
	Next
	ReDim $hkLock[$hkLock[0] + 2]
	$hkLock[$hkLock[0] + 1] = $iKey
	$hkLock[0] += 1
EndFunc   ;==>_KeyLock

; #FUNCTION# ========================================================================================================================
; Function Name:	_KeyUnlock
; Description:		Unlocks a specified key combination for a Hotkey Input control.
; Syntax:			_KeyUnlock ( $iKey )
; Parameter(s):		$iKey - Combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
; Return Value(s):	None.
; Author(s):		Yashied
; Note(s):			This function is inverse to _KeyLock().
;====================================================================================================================================

Func _KeyUnlock($iKey)
	$iKey = BitAND($iKey, 0x0FFF)
	For $i = 1 To $hkLock[0]
		If $hkLock[$i] = $iKey Then
			For $j = $i To $hkLock[0] - 1
				$hkLock[$j] = $hkLock[$j + 1]
			Next
			$hkLock[0] -= 1
			ReDim $hkLock[$hkLock[0] + 1]
			Return
		EndIf
	Next
EndFunc   ;==>_KeyUnlock

; #FUNCTION# ========================================================================================================================
; Function Name:	_KeyLoadName
; Description:		Loads a names of keys.
; Syntax:			_KeyLoadName ( $aKeyName )
; Parameter(s):		$aKeyName - 256-string array that receives the name for each virtual key (see vkCodes.au3). If the name is not
;								specified ("") in array then the key will be ignored.
;
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero.
; Author(s):		Yashied
;
; Note(s):			You can use this function to replace the names of the keys in the Hotkey Input control, such as "Shift" => "SHIFT".
;					Also through this program can lock the keys.
;====================================================================================================================================

Func _KeyLoadName(ByRef $aKeyName)

	If (Not IsArray($aKeyName)) Or (UBound($aKeyName) < 256) Then
		Return SetError(1, 0, 0)
	EndIf

	For $i = 0 To 255
		$VK[$i] = $aKeyName[$i]
	Next
	For $i = 0 To $hkId[0][0]
		GUICtrlSetData($hkId[$i][0], _KeyToStr($hkId[$i][2], $hkId[$i][3]))
	Next
	Return SetError(1, 0, 0)
EndFunc   ;==>_KeyLoadName

; #FUNCTION# ========================================================================================================================
; Function Name:	_KeyToStr
; Description:		Places the key names of an hotkey into a single string, separated by the specified characters.
; Syntax:			_KeyToStr ( $iKey [, $sSeparator] )
;					$iKey       - Combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
;					$sSeparator - Separating characters. Default is "-".
; Return Value(s):	Returns a string containing of a combination of the key names and separating characters, eg. "Alt-Shift-D".
; Author(s):		Yashied
; Note(s):			Use _KeyLoadName() to change the names of the keys in the Hotkey Input control.
;====================================================================================================================================

Func _KeyToStr($iKey, $sSeparator = ' + ')

	Local $Ret = '', $n = StringLen($sSeparator)

	If BitAND($iKey, 0x0100) = 0x0100 Then
		$Ret = $Ret & $sLang_Shift & $sSeparator
	EndIf
	If BitAND($iKey, 0x0200) = 0x0200 Then
		$Ret = $Ret & $sLang_Ctrl & $sSeparator
	EndIf
	If BitAND($iKey, 0x0400) = 0x0400 Then
		$Ret = $Ret & $sLang_Alt & $sSeparator
	EndIf
	If BitAND($iKey, 0x0800) = 0x0800 Then
		$Ret = $Ret & $sLang_Win & $sSeparator
	EndIf
	If BitAND($iKey, 0x00FF) > 0 Then
		$Ret = $Ret & $VK[BitAND($iKey, 0x00FF)]
	Else
		If StringRight($Ret, $n) = $sSeparator Then
			$Ret = StringTrimRight($Ret, $n)
		EndIf
	EndIf
	If $Ret = '' Then
		$Ret = $VK[0x00]
	EndIf
	Return $Ret
EndFunc   ;==>_KeyToStr

#EndRegion Public Functions

#Region Internal Functions

Func _check($ID)
	If ($hkId[0][6] > 0) And ($ID <> $hkId[0][6]) Then
;		if (($hkId[0][3] > 0) and ($hkId[$hkId[0][6]][2] = 0)) or (($ID > 0) and ($hkId[0][7] = 1) and ($hkId[0][8] = 1)) then
		If ($hkId[0][3] > 0) And ($hkId[$hkId[0][6]][2] = 0) Then
			GUICtrlSetData($hkId[$hkId[0][6]][0], $VK[0x00])
		EndIf
		$hkId[0][2] = 0
		$hkId[0][7] = 0
		$hkId[0][8] = 0
	EndIf
	$hkId[0][6] = $ID
EndFunc   ;==>_check

Func _focus($Focus)
	For $i = 1 To $hkId[0][0]
		If $Focus = $hkId[$i][1] Then
			Return $i
		EndIf
	Next
	Return 0
EndFunc   ;==>_focus

Func _hold()

	Local $Ret, $tState = DllStructCreate('byte[256]')

	$Ret = DllCall('user32.dll', 'int', 'GetKeyboardState', 'ptr', DllStructGetPtr($tState))
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	For $i = 0x08 To 0xFF
		Switch $i
			Case 0x0A, 0x0B, 0x0E To 0x0F, 0x16, 0x1A, 0x1C To 0x1F, 0x3A To 0x40, 0x5E, 0x88 To 0x8F, 0x97 To 0x9F, 0xB8 To 0xB9, 0xC1 To 0xDA, 0xE0, 0xE8
				ContinueLoop
			Case Else
				If BitAND(DllStructGetData($tState, 1, $i + 1), 0xF0) > 0 Then
					Return 1
				EndIf
		EndSwitch
	Next
	Return 0
EndFunc   ;==>_hold

Func __hook($iCode, $wParam, $lParam)

	If ($iCode < 0) Or ($hkId[0][1] = 1) Then
		Switch $wParam
			Case $WM_KEYDOWN, $WM_SYSKEYDOWN
				If $iCode < 0 Then
					ContinueCase
				EndIf
				Return -1
			Case Else
				Return _WinAPI_CallNextHookEx($hkId[0][5], $iCode, $wParam, $lParam)
		EndSwitch
	EndIf

	Local $vkCode = DllStructGetData(DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam), 'vkCode')
	Local $Key, $Return = True, $Index = _focus(_WinAPI_GetFocus())

	_check($Index)

	Switch $wParam
		Case $WM_KEYDOWN, $WM_SYSKEYDOWN
			Switch $vkCode
				Case 0xA0, 0xA1
					$hkId[0][3] = BitOR($hkId[0][3], 0x01)
				Case 0xA2, 0xA3
					$hkId[0][3] = BitOR($hkId[0][3], 0x02)
				Case 0xA4, 0xA5
					$hkId[0][3] = BitOR($hkId[0][3], 0x04)
				Case 0x5B, 0x5C
					$hkId[0][3] = BitOR($hkId[0][3], 0x08)
			EndSwitch
			If $Index > 0 Then
				If $vkCode = $hkId[0][2] Then
					Return -1
				EndIf
				$hkId[0][2] = $vkCode
				Switch $vkCode
					Case 0xA0 To 0xA5, 0x5B, 0x5C
						If $hkId[0][7] = 1 Then
							Return -1
						EndIf
						$hkId[$Index][2] = 0
						GUICtrlSetData($hkId[$Index][0], _KeyToStr(BitShift($hkId[0][3], -8), $hkId[$Index][3]))
					Case Else
						If $hkId[0][7] = 1 Then
							Return -1
						EndIf
						Switch $vkCode
							Case 0x08, 0x1B
								If $hkId[0][3] = 0 Then
									If $hkId[$Index][2] > 0 Then
										$hkId[$Index][2] = 0
										GUICtrlSetData($hkId[$Index][0], $VK[0x00])
									EndIf
									Return -1
								EndIf
						EndSwitch
						If $VK[$vkCode] > '' Then
							$Key = BitOR(BitShift($hkId[0][3], -8), $vkCode)
							If Not _lock($Key) Then
								$hkId[$Index][2] = $Key
								GUICtrlSetData($hkId[$Index][0], _KeyToStr($Key, $hkId[$Index][3]))
								$hkId[0][7] = 1
								$hkId[0][8] = 1
							Else
								$Return = 0
							EndIf
						EndIf
				EndSwitch
				If $Return Then
					Return -1
				EndIf
			EndIf
		Case $WM_KEYUP, $WM_SYSKEYUP
			Switch $vkCode
				Case 0xA0, 0xA1
					$hkId[0][3] = BitAND($hkId[0][3], 0xFE)
				Case 0xA2, 0xA3
					$hkId[0][3] = BitAND($hkId[0][3], 0xFD)
				Case 0xA4, 0xA5
					$hkId[0][3] = BitAND($hkId[0][3], 0xFB)
				Case 0x5B, 0x5C
					$hkId[0][3] = BitAND($hkId[0][3], 0xF7)
			EndSwitch
			If $Index > 0 Then
				If $hkId[$Index][2] = 0 Then
					Switch $vkCode
						Case 0xA0 To 0xA5, 0x5B, 0x5C
							GUICtrlSetData($hkId[$Index][0], _KeyToStr(BitShift($hkId[0][3], -8), $hkId[$Index][3]))
					EndSwitch
				EndIf
			EndIf
			$hkId[0][2] = 0
			If $vkCode = BitAND($hkId[$Index][2], 0x00FF) Then
				$hkId[0][8] = 0
			EndIf
			If $hkId[0][3] = 0 Then
				If $hkId[0][8] = 0 Then
					$hkId[0][7] = 0
				EndIf
			EndIf
	EndSwitch

	Return _WinAPI_CallNextHookEx($hkId[0][5], $iCode, $wParam, $lParam)
EndFunc   ;==>__hook

Func _lock($iKey)
	For $i = 1 To $hkLock[0]
		If $iKey = $hkLock[$i] Then
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>_lock

#EndRegion Internal Functions

#Region Windows Message Functions

Func HK_WM_NCLBUTTONDOWN($hWnd, $iMsg, $wParam, $lParam)

	Switch $wParam
		Case 0x08, 0x09, 0x14, 0x15
			If ($hkId[0][3] > 0) Or ($hkId[0][8] = 1) Or (_hold()) Then
				Return 0
			EndIf
	EndSwitch
	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>HK_WM_NCLBUTTONDOWN

#EndRegion Windows Message Functions

#Region OnAutoItExit

Func OnHotKeyInputExit()
	_WinAPI_UnhookWindowsHookEx($hkId[0][5])
	DllCallbackFree($hkId[0][4])
	GUIRegisterMsg($HK_WM_NCLBUTTONDOWN, '')
	Call($OnHotKeyInputExit)
EndFunc   ;==>OnHotKeyInputExit

#EndRegion OnAutoItExit

#Region VKey Table
Dim $VK[256]
$VK[0x00] = 'None'
$VK[0x01] = 'LButton'
$VK[0x02] = 'RButton'
$VK[0x03] = ''
$VK[0x04] = 'MButton'
$VK[0x05] = 'XButton1'
$VK[0x06] = 'XButton2'
$VK[0x07] = ''
$VK[0x08] = 'Backspace'
$VK[0x09] = 'Tab'
$VK[0x0A] = ''
$VK[0x0B] = ''
$VK[0x0C] = 'Clear'
$VK[0x0D] = 'Enter'
$VK[0x0E] = ''
$VK[0x0F] = ''
$VK[0x10] = ''
$VK[0x11] = ''
$VK[0x12] = ''
$VK[0x13] = 'Pause'
$VK[0x14] = 'CapsLosk'
$VK[0x15] = ''
$VK[0x16] = ''
$VK[0x17] = ''
$VK[0x18] = ''
$VK[0x19] = ''
$VK[0x1A] = ''
$VK[0x1B] = 'Esc'
$VK[0x1C] = ''
$VK[0x1D] = ''
$VK[0x1E] = ''
$VK[0x1F] = ''
$VK[0x20] = 'Spacebar'
$VK[0x21] = 'PgUp'
$VK[0x22] = 'PgDown'
$VK[0x23] = 'End'
$VK[0x24] = 'Home'
$VK[0x25] = 'Left'
$VK[0x26] = 'Up'
$VK[0x27] = 'Right'
$VK[0x28] = 'Down'
$VK[0x29] = 'Select'
$VK[0x2A] = 'Print'
$VK[0x2B] = 'Execute'
$VK[0x2C] = 'PrtScr'
$VK[0x2D] = 'Ins'
$VK[0x2E] = 'Del'
$VK[0x2F] = 'Help'
$VK[0x30] = '0'
$VK[0x31] = '1'
$VK[0x32] = '2'
$VK[0x33] = '3'
$VK[0x34] = '4'
$VK[0x35] = '5'
$VK[0x36] = '6'
$VK[0x37] = '7'
$VK[0x38] = '8'
$VK[0x39] = '9'
$VK[0x3A] = ''
$VK[0x3B] = ''
$VK[0x3C] = ''
$VK[0x3D] = ''
$VK[0x3E] = ''
$VK[0x3F] = ''
$VK[0x40] = ''
$VK[0x41] = 'A'
$VK[0x42] = 'B'
$VK[0x43] = 'C'
$VK[0x44] = 'D'
$VK[0x45] = 'E'
$VK[0x46] = 'F'
$VK[0x47] = 'G'
$VK[0x48] = 'H'
$VK[0x49] = 'I'
$VK[0x4A] = 'J'
$VK[0x4B] = 'K'
$VK[0x4C] = 'L'
$VK[0x4D] = 'M'
$VK[0x4E] = 'N'
$VK[0x4F] = 'O'
$VK[0x50] = 'P'
$VK[0x51] = 'Q'
$VK[0x52] = 'R'
$VK[0x53] = 'S'
$VK[0x54] = 'T'
$VK[0x55] = 'U'
$VK[0x56] = 'V'
$VK[0x57] = 'W'
$VK[0x58] = 'X'
$VK[0x59] = 'Y'
$VK[0x5A] = 'Z'
$VK[0x5B] = 'Win'
$VK[0x5C] = 'Win'
$VK[0x5D] = '0x5D'
$VK[0x5E] = ''
$VK[0x5F] = 'Sleep'
$VK[0x60] = 'Num 0'
$VK[0x61] = 'Num 1'
$VK[0x62] = 'Num 2'
$VK[0x63] = 'Num 3'
$VK[0x64] = 'Num 4'
$VK[0x65] = 'Num 5'
$VK[0x66] = 'Num 6'
$VK[0x67] = 'Num 7'
$VK[0x68] = 'Num 8'
$VK[0x69] = 'Num 9'
$VK[0x6A] = 'Num *'
$VK[0x6B] = 'Num +'
$VK[0x6C] = '0x6C'
$VK[0x6D] = 'Num -'
$VK[0x6E] = 'Num .'
$VK[0x6F] = 'Num /'
$VK[0x70] = 'F1'
$VK[0x71] = 'F2'
$VK[0x72] = 'F3'
$VK[0x73] = 'F4'
$VK[0x74] = 'F5'
$VK[0x75] = 'F6'
$VK[0x76] = 'F7'
$VK[0x77] = 'F8'
$VK[0x78] = 'F9'
$VK[0x79] = 'F10'
$VK[0x7A] = 'F11'
$VK[0x7B] = 'F12'
$VK[0x7C] = 'F13'
$VK[0x7D] = 'F14'
$VK[0x7E] = 'F15'
$VK[0x7F] = 'F16'
$VK[0x80] = 'F17'
$VK[0x81] = 'F18'
$VK[0x82] = 'F19'
$VK[0x83] = 'F20'
$VK[0x84] = 'F21'
$VK[0x85] = 'F22'
$VK[0x86] = 'F23'
$VK[0x87] = 'F24'
$VK[0x88] = ''
$VK[0x89] = ''
$VK[0x8A] = ''
$VK[0x8B] = ''
$VK[0x8C] = ''
$VK[0x8D] = ''
$VK[0x8E] = ''
$VK[0x8F] = ''
$VK[0x90] = 'NumLock'
$VK[0x91] = 'ScrollLock'
$VK[0x92] = ''
$VK[0x93] = ''
$VK[0x94] = ''
$VK[0x95] = ''
$VK[0x96] = ''
$VK[0x97] = ''
$VK[0x98] = ''
$VK[0x99] = ''
$VK[0x9A] = ''
$VK[0x9B] = ''
$VK[0x9C] = ''
$VK[0x9D] = ''
$VK[0x9E] = ''
$VK[0x9F] = ''
$VK[0xA0] = 'Shift'
$VK[0xA1] = 'Shift'
$VK[0xA2] = 'Ctrl'
$VK[0xA3] = 'Ctrl'
$VK[0xA4] = 'Alt'
$VK[0xA5] = 'Alt'
$VK[0xA6] = 'BrowserBack'
$VK[0xA7] = 'BrowserForward'
$VK[0xA8] = 'BrowserRefresh'
$VK[0xA9] = 'BrowserStop'
$VK[0xAA] = 'BrowserSearch'
$VK[0xAB] = 'BrowserFavorites'
$VK[0xAC] = 'BrowserStart'
$VK[0xAD] = 'VolumeMute'
$VK[0xAE] = 'VolumeDown'
$VK[0xAF] = 'VolumeUp'
$VK[0xB0] = 'NextTrack'
$VK[0xB1] = 'PreviousTrack'
$VK[0xB2] = 'StopMedia'
$VK[0xB3] = 'Play'
$VK[0xB4] = 'Mail'
$VK[0xB5] = 'Media'
$VK[0xB6] = '0xB6'
$VK[0xB7] = '0xB7'
$VK[0xB8] = ''
$VK[0xB9] = ''
$VK[0xBA] = ';'
$VK[0xBB] = '+'
$VK[0xBC] = ','
$VK[0xBD] = '-'
$VK[0xBE] = '.'
$VK[0xBF] = '/'
$VK[0xC0] = '~'
$VK[0xC1] = ''
$VK[0xC2] = ''
$VK[0xC3] = ''
$VK[0xC4] = ''
$VK[0xC5] = ''
$VK[0xC6] = ''
$VK[0xC7] = ''
$VK[0xC8] = ''
$VK[0xC9] = ''
$VK[0xCA] = ''
$VK[0xCB] = ''
$VK[0xCC] = ''
$VK[0xCD] = ''
$VK[0xCE] = ''
$VK[0xCF] = ''
$VK[0xD0] = ''
$VK[0xD1] = ''
$VK[0xD2] = ''
$VK[0xD3] = ''
$VK[0xD4] = ''
$VK[0xD5] = ''
$VK[0xD6] = ''
$VK[0xD7] = ''
$VK[0xD8] = ''
$VK[0xD9] = ''
$VK[0xDA] = ''
$VK[0xDB] = '['
$VK[0xDC] = '\'
$VK[0xDD] = ']'
$VK[0xDE] = '"'
$VK[0xDF] = '0xDF'
$VK[0xE0] = ''
$VK[0xE1] = ''
$VK[0xE2] = '0xE2'
$VK[0xE3] = ''
$VK[0xE4] = ''
$VK[0xE5] = '0xE5'
$VK[0xE6] = ''
$VK[0xE7] = '0xE7'
$VK[0xE8] = ''
$VK[0xE9] = ''
$VK[0xEA] = ''
$VK[0xEB] = ''
$VK[0xEC] = '0xEC'
$VK[0xED] = ''
$VK[0xEE] = ''
$VK[0xEF] = ''
$VK[0xF0] = ''
$VK[0xF1] = ''
$VK[0xF2] = ''
$VK[0xF3] = ''
$VK[0xF4] = ''
$VK[0xF5] = ''
$VK[0xF6] = '0xF6'
$VK[0xF7] = '0xF7'
$VK[0xF8] = '0xF8'
$VK[0xF9] = '0xF9'
$VK[0xFA] = '0xFA'
$VK[0xFB] = '0xFB'
$VK[0xFC] = '0xFC'
$VK[0xFD] = '0xFD'
$VK[0xFE] = '0xFE'
$VK[0xFF] = ''
#EndRegion VKey Table
