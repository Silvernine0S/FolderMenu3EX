#Region Header

#cs

	Title:			Management of Hotkeys UDF Library for AutoIt3
	Filename:		HotKey.au3
	Description:	Sets a hot key that calls a user function
	Author:			Yashied
	Version:		1.7b
	Requirements:	AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
	Uses:			StructureConstants.au3, WinAPI.au3, WindowsConstants.au3
	Notes:			The library registers the WM_ACTIVATE window message

	Available functions:

	_HotKeyAssign
	_HotKeyEnable
	_HotKeyDisable
	_HotKeyRelease

	Example1:

		#Include <HotKey.au3>

		Global Const $VK_ESCAPE = 0x1B
		Global Const $VK_F12 = 0x7B

		; Assign "F12" with Message() and set extended function call
		_HotKeyAssign($VK_F12, 'Message', BitOR($HK_FLAG_DEFAULT, $HK_FLAG_EXTENDEDCALL))

		; Assign "CTRL-ESC" with Quit()
		_HotKeyAssign(BitOR($CK_CONTROL, $VK_ESCAPE), 'Quit')

		While 1
			Sleep(10)
		WEnd

		Func Message($iKey)
			MsgBox(0, 'Hot key Test Message', 'F12 (0x' & Hex($iKey, 4) & ') has been pressed!')
		EndFunc   ;==>Message

		Func Quit()
			Exit
		EndFunc   ;==>Quit

	Example2:

		#Include <HotKey.au3>

		Global Const $VK_OEM_PLUS = 0xBB
		Global Const $VK_OEM_MINUS = 0xBD

		Global $Form, $Label
		Global $i = 0

		$Form = GUICreate('MyGUI', 200, 200)
		$Label = GUICtrlCreateLabel($i, 20, 72, 160, 52, 0x01)
		GUICtrlSetFont(-1, 32, 400, 0, 'Tahoma')
		GUISetState()

		; Assign "CTRL-(+)" with MyFunc1() and "CTRL-(-)" with MyFunc2() for created window only
		_HotKeyAssign(BitOR($CK_CONTROL, $VK_OEM_PLUS), 'MyFunc1', 0, $Form)
		_HotKeyAssign(BitOR($CK_CONTROL, $VK_OEM_MINUS), 'MyFunc2', 0, $Form)

		Do
		Until GUIGetMsg() = -3

		Func MyFunc1()
			$i += 1
			GUICtrlSetData($Label, $i)
		EndFunc   ;==>MyFunc1

		Func MyFunc2()
			$i -= 1
			GUICtrlSetData($Label, $i)
		EndFunc   ;==>MyFunc2

	Example3:

		#Include <GUIConstants.au3>
		#Include <HotKey.au3>

		Global Const $VK_ESCAPE = 0x1B
		Global Const $VK_F12 = 0x7B

		; Assign "F12" with Form()
		_HotKeyAssign($VK_F12, 'Form')

		; Assign "CTRL-ESC" with Quit()
		_HotKeyAssign(BitOR($CK_CONTROL, $VK_ESCAPE), 'Quit')

		While 1
			Sleep(10)
		WEnd

		Func Form()

			Local $Form, $Button, $Msg

			$Form = GUICreate('MyGUI', 350, 350, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), $WS_EX_TOPMOST)
			$Button = GUICtrlCreateButton('Exit', 140, 315, 70, 23)
			GUICtrlSetState(-1, BitOR($GUI_DEFBUTTON, $GUI_FOCUS))
			GUISetState(@SW_SHOW, $Form)

			While 1
				Switch GUIGetMsg()
					Case $Button, $GUI_EVENT_CLOSE
						ExitLoop
				EndSwitch
			WEnd

			GUIDelete($Form)
		EndFunc   ;==>Form

		Func Quit()
			Exit
		EndFunc   ;==>Quit

#ce

#Include-once

#Include <StructureConstants.au3>
#Include <WinAPI.au3>
#Include <WindowsConstants.au3>

#EndRegion Header

#Region Global Variables and Constants

; Flags.
;
; $HK_FLAG_NOBLOCKHOTKEY
; Prevents lock specified hot keys for other applications at the lower levels in
; the hook chain.
; For example, if you want to get just the fact of pressing a hot key, but leave
; the event to other applications.
; Ie specified hot key will work like before you set it.
; Only the _HotKeyAssign() function uses this flag.
;
; $HK_FLAG_NOUNHOOK
; Prevents an unhook application-defined hook procedure from the hook chain.
; It makes sense only if you want to keep order in the chain of hook procedures.
; For example, two applications have reserved the same hot keys and your
; application is not at the top in this chain.
; In this case, if the call _HotKeyDisable() without this flag and then call
; _HotKeyEnable(), then your application will receive priority over the
; re-defined hot keys.
; In some cases this is not required, then you must use this flag.
; This flag can be used by _HotKeyAssign() - unset hot keys only,
; _HotKeyDisable(), and _HotKeyRelease().
;
; $HK_FLAG_NOOVERLAPCALL
; Prevents a call the user function if it has not complete.
; This flag is primarily to be set if the user function uses the MsgBox() and
; similar to it.
; Remember that your specified function is an interrupt function to the program
; and should not suspend the program or the program may hang.
; However, it is not recommended to use the MsgBox() inside your function, it is
; better to define the control flag which will test the main program loop.
; Only the _HotKeyAssign() function uses this flag.
;
; $HK_FLAG_NOREPEAT
; Prevents a repeat characters when you hold down a key.
; If this flag is set hotkey will only work once until you can not release.
; Used if needed to avoid repeated alarms keys, for example when you install the
; hot keys to increase, decrease, or mute the volume.
; Only the _HotKeyAssign() function uses this flag.
;
; $HK_FLAG_NOERROR
; Prevents a return of error if one of the functions from this library was
; called from user function which has been defined by the _HotKeyAssign().
; Without this flag, in such cases will always return an error and @extended
; flag will be set to (-1).
; Be careful when using this flag, because improper use may cause a malfunction
; of your program, or to hang it.
; This flag can be used by _HotKeyAssign(), _HotKeyDisable(), and _HotKeyRelease().
;
; $HK_FLAG_EXTENDEDCALL
; Adds a hot key code as a parameter when calling a user function.
; If you set this flag, 16-bit hot key code will be pass as a parameter to the
; user function.
; This can be useful if you assign multiple hot keys with the same function.
; If the flag was set, the function must have the header with one parameter (see
; _HotKeyAssign()).
; Only the _HotKeyAssign() function uses this flag.
;
; $HK_FLAG_POSTCALL
; Calls a user function after a hot key has been released. If the hot key has been
; released, 16-bit hot key code will be pass as a parameter to the user function
; as a negative value.
; When using this flag, you should check the passed value inside the specified
; function.
; If the value is negative, the hot key was released, and vice versa. Otherwise,
; it will be twice the function call: when you pressing and releasing the hot key.
; If the flag was set, the function must have the header same as when using a
; $HK_FLAG_EXTENDEDCALL flag. Workes only if $HK_FLAG_EXTENDEDCALL flag has been
; set.
; Only the _HotKeyAssign() function uses this flag.

; $HK_FLAG_DEFAULT
; The combination of the $HK_FLAG_NOOVERLAPCALL and $HK_FLAG_NOREPEAT.

Global Const $HK_FLAG_NOBLOCKHOTKEY = 0x01
Global Const $HK_FLAG_NOUNHOOK = 0x02
Global Const $HK_FLAG_NOOVERLAPCALL = 0x04
Global Const $HK_FLAG_NOREPEAT = 0x08
Global Const $HK_FLAG_NOERROR = 0x10
Global Const $HK_FLAG_EXTENDEDCALL = 0x40
Global Const $HK_FLAG_POSTCALL = 0x80
Global Const $HK_FLAG_DEFAULT = BitOR($HK_FLAG_NOOVERLAPCALL, $HK_FLAG_NOREPEAT)


; System keys constants, see _HotKeyAssign() for more information.

Global Const $CK_SHIFT = 0x0100
Global Const $CK_CONTROL = 0x0200
Global Const $CK_ALT = 0x0400
Global Const $CK_WIN = 0x0800

#EndRegion Global Variables and Constants

#Region Local Variables and ConstantsExtended function call flag

Global Const $HK_WM_ACTIVATE = 0x0006
Global Const $HK_WM_HOTKEY = _WinAPI_RegisterWindowMessage('WM_HOTKEY')

Global $OnHotKeyExit = Opt('OnExitFunc', 'OnHotKeyExit')

Dim $hkTb[1][12] = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, GUICreate('')]]

#cs

DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$hkTb[0][0 ]   - Count item of array
     [0][1 ]   - Interruption control flag (need to set this flag before changing $hkTb array)
     [0][2 ]   - Last hot key pressed (16-bit)
     [0][3 ]   - Disable hot keys control flag (_HotKeyDisable(), _HotKeyEnable())
     [0][4 ]   - Handle to the user-defined DLL callback function (returned by DllCallbackRegister())
     [0][5 ]   - Handle to the hook procedure (returned by _WinAPI_SetWindowsHookEx())
     [0][6 ]   - Block hot key flag for last pressed ($hkTb[i][3])
     [0][7 ]   - Possition in the array for last pressed
     [0][8 ]   - Hold down control flag
     [0][9 ]   - SCAW status (SHIFT-CTRL-ALT-WIN, 8-bit)
     [0][10]   - General counter of calls all user functions
     [0][11]   - Handle to "Hot" window

$hkTb[i][0 ]   - Combined hot key code (see _HotKeyAssign)
     [i][1 ]   - User function name
     [i][2 ]   - The title of the window to allow the hot key
     [i][3 ]   - Block hot key flag
     [i][4 ]   - Block overlapping user function flag
     [i][5 ]   - Block repeat flag
     [i][6 ]   - Extended function call flag
     [i][7 ]   - Post function call flag
     [i][8 ]   - Counter of calls user function
     [i][9-11] - Reserved

#ce

#EndRegion Local Variables and Constants

#Region Initialization

; IMPORTANT! If you register the ACTIVATE window messages in your code, you should call handlers from this library until
; you return from your handlers, otherwise the hot key will not work properly. For example:
;
; Func MY_WM_ACTIVATE($hWnd, $iMsg, $wParam, $lParam)
;   HK_WM_ACTIVATE($hWnd, $iMsg, $wParam, $lParam)
;   ...
; EndFunc   ;==>MY_WM_ACTIVATE

GUIRegisterMsg($HK_WM_ACTIVATE, 'HK_WM_ACTIVATE')
GUIRegisterMsg($HK_WM_HOTKEY, 'HK_WM_HOTKEY')

#EndRegion Initialization

#Region Public Functions

; #FUNCTION# ========================================================================================================================
; Function Name:	_HotKeyAssign
; Description:		Sets a hot key that calls a user function.
; Syntax:			_HotKeyAssign ( $iKey [, $sFunction [, $iFlags [, $sTitle]]] )
; Parameter(s):		$iKey      - Combined 16-bit hot key code, which consists of upper and lower bytes. Value of bits shown in the following table.
;
;								 Hot key code bits:
;
;								 0-7   - Specifies the virtual-key (VK) code of the key. Codes for the mouse buttons (0x01 - 0x06) are not supported.
;										 (http://msdn.microsoft.com/en-us/library/dd375731(VS.85).aspx)
;
;								 8     - SHIFT key
;								 9     - CONTROL key
;								 10    - ALT key
;								 11    - WIN key
;								 12-15 - Don`t used (must be set to zero).
;
;								 The combination of keys can be composed of one function key (VK) and some system keys (CK). This code can not consist
;								 only of the system keys. To combine system keys with the function key use BitOR(). See following examples.
;								 (VK-constants are used in the vkConstants.au3)
;
;								 SHIFT-F12    - BitOR($CK_SHIFT, $VK_F12)
;								 SHIFT-A      - BitOR($CK_SHIFT, $VK_A)
;								 CTRL-ALT-TAB - BitOR($CK_CONTROL, $CK_ALT, $VK_TAB)
;								 etc.
;
;								 Not acceptable combinations:
;
;								 SHIFT-WIN    - BitOR($CK_SHIFT, $CK_WIN)
;								 CTRL-Q-W     - BitOR($CK_CONTROL, $VK_Q, $VK_W)
;								 etc.
;
;								 Do not attempt to define as hot keys SHIFT, CONTROL, ALT, and WIN follows.
;
;								 $VK_SHIFT, $VK_LSHIFT, $VK_RSHIFT etc.
;
;								 It still will not work. These keys can not be defined as "hot" in this library. Also, there are no differences
;								 between left and right system keys.
;
;					$sFunction - [optional] The name of the function to call when the key is pressed. The function cannot be a built-in AutoIt
;								 function or plug-in function and must have the following header:
;
;								 Func _MyFunc()
;
;								 Do not try to call _HotKeyAssign(), _HotKeyEnable(), _HotKeyDisable(), or _HotKeyRelease() from this function. This is
;								 not a good idea. In this cases the error will be returned. In doing so, @extended will be set to (-1). Do not use inside
;								 the function MsgBox() and any other functions of stopping the operation of your script. This may cause the script to hang.
;								 Your function should not introduce significant delays in the main script. Not specifying this parameter or set to zero
;								 will unset a previous hot key. If there are no designated hot keys, the hook procedure will be unhook from the hook chain.
;
;					$iFlags    - [optional] Hot key control flag(s). This parameter can be a combination of the following values.
;
;								 $HK_FLAG_NOBLOCKHOTKEY
;								 $HK_FLAG_NOUNHOOK
;								 $HK_FLAG_NOOVERLAPCALL
;								 $HK_FLAG_NOREPEAT
;								 $HK_FLAG_NOERROR
;								 $HK_FLAG_EXTENDEDCALL
;								 $HK_FLAG_POSTCALL
;
;								 (See constants section in this library)
;
;								 $HK_FLAG_NOUNHOOK here is valid if you delete a hotkey only (_HotKeyAssign($iKey)).
;
;								 $HK_FLAG_EXTENDEDCALL it makes sense to set if you assign multiple hot keys with the same function. If the flag was set,
;								 the function must have following header:
;
;								 Func _MyFunc($Code)
;
;					$sTitle    - [optional] The title of the window to allow the hot key. This parameter is the same as the WinActive() function.
;								 The default is 0, which is allow hot key for all window.
;
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero.
; Author(s):		Yashied
; Note(s):			This function does not affect the _HotKeyEnable() and _HotKeyDisable() and can be called at any time.
;====================================================================================================================================

Func _HotKeyAssign($iKey, $sFunction = 0, $iFlags = -1, $sTitle = 0)

	If $iFlags < 0 Then
		$iFlags = $HK_FLAG_DEFAULT
	EndIf

	If (BitAND($iFlags, $HK_FLAG_NOERROR) = 0) And ($hkTb[0][10] > 0) Then
		Return SetError(1,-1, 0)
	EndIf

	Local $n = 0, $Redim = False, $Error = False

	If (Not IsString($sFunction)) And ($sFunction = 0) Then
		$sFunction = ''
	EndIf
	$sFunction = StringStripWS($sFunction, 3)
	$iKey = BitAND($iKey, 0x0FFF)
	If BitAND($iKey, 0x00FF) = 0 Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = 1 To $hkTb[0][0]
		If $hkTb[$i][0] = $iKey Then
			$n = $i
			ExitLoop
		EndIf
	Next
	If $sFunction = '' Then
		If $n = 0 Then
			Return SetError(0, 0, 1)
		EndIf
		If (BitAND($iFlags, $HK_FLAG_NOUNHOOK) = 0) And (IsPtr($hkTb[0][5])) And ($hkTb[0][0] = 1) Then
			If Not _WinAPI_UnhookWindowsHookEx($hkTb[0][5]) Then
				Return SetError(1, 0, 0)
			EndIf
			DllCallbackFree($hkTb[0][4])
			$hkTb[0][5] = 0
			_HotKey_Reset()
		EndIf
		$hkTb[0][8] = 1
		For $i = $n To $hkTb[0][0] - 1
			For $j = 0 To UBound($hkTb, 2) - 1
				$hkTb[$i][$j] = $hkTb[$i + 1][$j]
			Next
		Next
		ReDim $hkTb[$hkTb[0][0]][UBound($hkTb, 2)]
		$hkTb[0][0] -= 1
		If $hkTb[0][2] = $iKey Then
			_HotKey_Reset()
		EndIf
		If $hkTb[0][7] > $n Then
			$hkTb[0][7] -= 1
		EndIf
		$hkTb[0][8] = 0
	Else
		If $n = 0 Then
			If ($hkTb[0][5] = 0) And ($hkTb[0][3] = 0) Then
				$hkTb[0][4] = DllCallbackRegister('_HotKey_Hook', 'long', 'int;wparam;lparam')
				$hkTb[0][5] = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($hkTb[0][4]), _WinAPI_GetModuleHandle(0), 0)
				If (@error) Or ($hkTb[0][5] = 0) Then
					Return SetError(1, 0, 0)
				EndIf
			EndIf
			$n = $hkTb[0][0] + 1
			ReDim $hkTb[$n + 1][UBound($hkTb, 2)]
			$Redim = 1
		EndIf
		$hkTb[$n][0] = $iKey
		$hkTb[$n][1] = $sFunction
		$hkTb[$n][2] = $sTitle
		$hkTb[$n][3] = (BitAND($iFlags, $HK_FLAG_NOBLOCKHOTKEY) = $HK_FLAG_NOBLOCKHOTKEY)
		$hkTb[$n][4] = (BitAND($iFlags, $HK_FLAG_NOOVERLAPCALL) = $HK_FLAG_NOOVERLAPCALL)
		$hkTb[$n][5] = (BitAND($iFlags, $HK_FLAG_NOREPEAT) = $HK_FLAG_NOREPEAT)
		$hkTb[$n][6] = (BitAND($iFlags, $HK_FLAG_EXTENDEDCALL) = $HK_FLAG_EXTENDEDCALL)
		$hkTb[$n][7] = (BitAND($iFlags, $HK_FLAG_POSTCALL) = $HK_FLAG_POSTCALL) And ($hkTb[$n][6])
		$hkTb[$n][8] = 0
		If $Redim Then
			$hkTb[0][0] += 1
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_HotKeyAssign

; #FUNCTION# ========================================================================================================================
; Function Name:	_HotKeyEnable
; Description:		Enables all the hot keys that were defined by _HotKeyAssign() and installs a hook procedure into a hook chain.
; Syntax:			_HotKeyEnable (  )
; Parameter(s):		None.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero. Also, can be sets @extended flag to (-1).
; Author(s):		Yashied
; Note(s):			Do not call this function from user function which has been defined by the _HotKeyAssign(). This will always
;					return an error and sets @extended flag to (-1).
;====================================================================================================================================

Func _HotKeyEnable()

	If $hkTb[0][10] > 0 Then
		Return SetError(1,-1, 0)
	EndIf

	If ($hkTb[0][5] = 0) And ($hkTb[0][0] > 0) Then
		$hkTb[0][4] = DllCallbackRegister('_HotKey_Hook', 'long', 'int;wparam;lparam')
		$hkTb[0][5] = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($hkTb[0][4]), _WinAPI_GetModuleHandle(0), 0)
		If (@error) Or ($hkTb[0][5] = 0) Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf
	$hkTb[0][3] = 0
	Return 1
EndFunc   ;==>_HotKeyEnable

; #FUNCTION# ========================================================================================================================
; Function Name:	_HotKeyDisable
; Description:		Disables all the hot keys that were defined by _HotKeyAssign() and unhooks a hook procedure from the hook chain.
; Syntax:			_HotKeyDisable ( [$iFlags] )
; Parameter(s):		$iFlags - [optional] Hot key control flag(s). This parameter can be a combination of the following values.
;
;							  $HK_FLAG_NOUNHOOK
;							  $HK_FLAG_NOERROR
;
;							  (See constants section in this library)
;
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero. Also, can be sets @extended flag to (-1).
; Author(s):		Yashied
; Note(s):			Do not call this function from user function which has been defined by the _HotKeyAssign(). The function does not
;					remove installed hot keys.
;====================================================================================================================================

Func _HotKeyDisable($iFlags = -1)

	If $iFlags < 0 Then
		$iFlags = 0
	EndIf

	If (BitAND($iFlags, $HK_FLAG_NOERROR) = 0) And ($hkTb[0][10] > 0) Then
		Return SetError(1,-1, 0)
	EndIf

	If (BitAND($iFlags, $HK_FLAG_NOUNHOOK) = 0) And (IsPtr($hkTb[0][5])) Then
		If Not _WinAPI_UnhookWindowsHookEx($hkTb[0][5]) Then
			Return SetError(1, 0, 0)
		EndIf
		DllCallbackFree($hkTb[0][4])
		$hkTb[0][5] = 0
	EndIf
	$hkTb[0][3] = 1
	_HotKey_Reset()
	Return 1
EndFunc   ;==>_HotKeyDisable

; #FUNCTION# ========================================================================================================================
; Function Name:	_HotKeyRelease
; Description:		Removes all the hot keys that were defined by _HotKeyAssign() and unhooks a hook procedure from the hook chain.
; Syntax:			_HotKeyRelease ( [$iFlags] )
; Parameter(s):		$iFlags - [optional] Hot key control flag(s). This parameter can be a combination of the following values.
;
;							  $HK_FLAG_NOUNHOOK
;							  $HK_FLAG_NOERROR
;
;							  (See constants section in this library)
;
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero. Also, can be sets @extended flag to (-1).
; Author(s):		Yashied
; Note(s):			Do not call this function from user function which has been defined by the _HotKeyAssign().
;====================================================================================================================================

Func _HotKeyRelease($iFlags = -1)

	If $iFlags < 0 Then
		$iFlags = 0
	EndIf

	If (BitAND($iFlags, $HK_FLAG_NOERROR) = 0) And ($hkTb[0][10] > 0) Then
		Return SetError(1,-1, 0)
	EndIf

	If (BitAND($iFlags, $HK_FLAG_NOUNHOOK) = 0) And (IsPtr($hkTb[0][5])) Then
		If Not _WinAPI_UnhookWindowsHookEx($hkTb[0][5]) Then
			Return SetError(1, 0, 0)
		EndIf
		DllCallbackFree($hkTb[0][4])
		$hkTb[0][5] = 0
		_HotKey_Reset()
	EndIf
	$hkTb[0][0] = 0
	ReDim $hkTb[1][UBound($hkTb, 2)]
	Return 1
EndFunc   ;==>_HotKeyRelease

#EndRegion Public Functions

#Region Internal Functions

Func _HotKey_Call($iFlag)

	Local $Index = $hkTb[0][7]

	Switch $iFlag
		Case 1
			If (Not _HotKey_WinActive($hkTb[$Index][2])) Or ($hkTb[$Index][7] = 0) Then
				Return
			EndIf
	EndSwitch
	If ($hkTb[$Index][4] = 0) Or ($hkTb[$Index][8] = 0) Then
		_WinAPI_PostMessage($hkTb[0][11], $HK_WM_HOTKEY, $iFlag, $Index)
	EndIf
EndFunc   ;==>_HotKey_Call

Func _HotKey_Error($sMessage)
	$hkTb[0][3] = 1
	_HotKey_Reset()
	_WinAPI_ShowError($sMessage)
EndFunc   ;==>_HotKey_Error

Func _HotKey_Hook($iCode, $wParam, $lParam)

	If ($iCode > -1) And ($hkTb[0][1] = 0) And ($hkTb[0][3] = 0) Then

		Local $vkCode = DllStructGetData(DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam), 'vkCode')
		Local $Call = False, $Return = False

		Switch $wParam
			Case $WM_KEYDOWN, $WM_SYSKEYDOWN
				If $hkTb[0][8] = 1 Then
					Return -1
				EndIf
				Switch $vkCode
					Case 0xA0 To 0xA5, 0x5B, 0x5C
						Switch $vkCode
							Case 0xA0, 0xA1
								$hkTb[0][9] = BitOR($hkTb[0][9], 0x01)
							Case 0xA2, 0xA3
								$hkTb[0][9] = BitOR($hkTb[0][9], 0x02)
							Case 0xA4, 0xA5
								$hkTb[0][9] = BitOR($hkTb[0][9], 0x04)
							Case 0x5B, 0x5C
								$hkTb[0][9] = BitOR($hkTb[0][9], 0x08)
						EndSwitch
						If $hkTb[0][2] > 0 Then
							$hkTb[0][2] = 0
						EndIf
					Case Else

						Local $Key = BitOR(BitShift($hkTb[0][9], -8), $vkCode)

						If ($hkTb[0][2] = 0) Or ($hkTb[0][2] = $Key) Then
							For $i = 1 To $hkTb[0][0]
								If (_HotKey_WinActive($hkTb[$i][2])) And ($hkTb[$i][0] = $Key) Then
									If $hkTb[0][2] = $hkTb[$i][0] Then
										If $hkTb[$i][5] = 0 Then
											$Call = 1
										EndIf
									Else
										$hkTb[0][2] = $hkTb[$i][0]
										$hkTb[0][6] = $hkTb[$i][3]
										$hkTb[0][7] = $i
										$Call = 1
									EndIf
									If $hkTb[$i][3] = 0 Then
										$Return = 1
									EndIf
									If $Call Then
										_HotKey_Call(0)
									EndIf
									ExitLoop
								EndIf
							Next
						Else
							$Return = 1
						EndIf
				EndSwitch
				If $Return Then
					Return -1
				EndIf
			Case $WM_KEYUP, $WM_SYSKEYUP
				Switch $vkCode
					Case 0xA0 To 0xA5, 0x5B, 0x5C
						Switch $vkCode
							Case 0xA0, 0xA1
								$hkTb[0][9] = BitAND($hkTb[0][9], 0xFE)
							Case 0xA2, 0xA3
								$hkTb[0][9] = BitAND($hkTb[0][9], 0xFD)
							Case 0xA4, 0xA5
								$hkTb[0][9] = BitAND($hkTb[0][9], 0xFB)
							Case 0x5B, 0x5C
								$hkTb[0][9] = BitAND($hkTb[0][9], 0xF7)
						EndSwitch
						If ($hkTb[0][2] > 0) And ($hkTb[0][6] = 0) And ($hkTb[0][9] = 0) Then
							$hkTb[0][1] = 1
							_HotKey_KeyUp($vkCode)
							$hkTb[0][1] = 0
							Return -1
						EndIf
					Case BitAND($hkTb[0][2], 0x00FF)
						$hkTb[0][2] = 0
						If ($hkTb[0][7] > 0) And ($hkTb[0][8] = 0) Then
							_HotKey_Call(1)
						EndIf
					Case Else

				EndSwitch
		EndSwitch
	EndIf

	Return _WinAPI_CallNextHookEx($hkTb[0][5], $iCode, $wParam, $lParam)
EndFunc   ;==>_HotKey_Hook

Func _HotKey_KeyUp($vkCode)
	DllCall('user32.dll', 'int', 'keybd_event', 'int', 0x88, 'int', 0, 'int', 0, 'ptr', 0)
	DllCall('user32.dll', 'int', 'keybd_event', 'int', $vkCode, 'int', 0, 'int', 2, 'ptr', 0)
	DllCall('user32.dll', 'int', 'keybd_event', 'int', 0x88, 'int', 0, 'int', 2, 'ptr', 0)
EndFunc   ;==>_HotKey_KeyUp

Func _HotKey_Reset()
	$hkTb[0][2] = 0
	$hkTb[0][6] = 0
	$hkTb[0][7] = 0
	$hkTb[0][9] = 0
EndFunc   ;==>_HotKey_Reset

Func _HotKey_WinActive($hWnd)
	If (IsInt($hWnd)) And ($hWnd = 0) Then
		Return 1
	Else
		If WinActive($hWnd) Then
			Return 1
		EndIf
	EndIf
	Return 0
EndFunc   ;==>_HotKey_WinActive

#EndRegion Internal Functions

#Region Windows Message Functions

Func HK_WM_ACTIVATE($hWnd, $iMsg, $wParam, $lParam)
	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>HK_WM_ACTIVATE

Func HK_WM_HOTKEY($hWnd, $iMsg, $wParam, $lParam)
	Switch $hWnd
		Case $hkTb[0][11]

			Local $Key = $hkTb[$lParam][0]

			Switch $wParam
				Case 0

				Case 1
					$Key = -$Key
				Case Else
					Return
			EndSwitch
			$hkTb[0][10] += 1
			$hkTb[$lParam][8] += 1
			If $hkTb[$lParam][6] = 1 Then
				Call($hkTb[$lParam][1], $Key)
			Else
				Call($hkTb[$lParam][1])
			EndIf
			$hkTb[$lParam][8] -= 1
			$hkTb[0][10] -= 1
;			If (@error = 0xDEAD) And (@extended = 0xBEEF) Then
;				_HotKey_Error($hkTb[$lParam][1] & '(): Function does not exist or invalid number of parameters.')
;			EndIf
	EndSwitch
EndFunc   ;==>HK_WM_HOTKEY

#EndRegion Windows Message Functions

#Region OnAutoItExit

Func OnHotKeyExit()
	_WinAPI_UnhookWindowsHookEx($hkTb[0][5])
	DllCallbackFree($hkTb[0][4])
	Call($OnHotKeyExit)
EndFunc   ;==>OnHotKeyExit

#EndRegion OnAutoItExit

#Region Global Variables and Constants

; http://msdn.microsoft.com/en-us/library/ms645540.aspx

Global Const $VK_LBUTTON = 0x01
Global Const $VK_RBUTTON = 0x02
Global Const $VK_CANCEL = 0x03
Global Const $VK_MBUTTON = 0x04
Global Const $VK_XBUTTON1 = 0x05
Global Const $VK_XBUTTON2 = 0x06
; 0x07 - Undefined
Global Const $VK_BACK = 0x08
Global Const $VK_TAB = 0x09
; 0x0A - 0x0B - Reserved
Global Const $VK_CLEAR = 0x0C
Global Const $VK_RETURN = 0x0D
; 0x0E - 0x0F - Undefined
Global Const $VK_SHIFT = 0x10
Global Const $VK_CONTROL = 0x11
Global Const $VK_MENU = 0x12
Global Const $VK_PAUSE = 0x13
Global Const $VK_CAPITAL = 0x14
; 0x15
; 0x16 - Undefined
; 0x17
; 0x18
; 0x19
; 0x1A - Undefined
Global Const $VK_ESCAPE = 0x1B
; 0x1C
; 0x1D
; 0x1E
; 0x1F
Global Const $VK_SPACE = 0x20
;Global Const $VK_PRIOR = 0x21
;Global Const $VK_NEXT = 0x22
;Global Const $VK_END = 0x23
;Global Const $VK_HOME = 0x24
;Global Const $VK_LEFT = 0x25
;Global Const $VK_UP = 0x26
;Global Const $VK_RIGHT = 0x27
;Global Const $VK_DOWN = 0x28
Global Const $VK_SELECT = 0x29
Global Const $VK_PRINT = 0x2A
Global Const $VK_EXECUTE = 0x2B
Global Const $VK_SNAPSHOT = 0x2C
Global Const $VK_INSERT = 0x2D
Global Const $VK_DELETE = 0x2E
Global Const $VK_HELP = 0x2F
Global Const $VK_0 = 0x30
Global Const $VK_1 = 0x31
Global Const $VK_2 = 0x32
Global Const $VK_3 = 0x33
Global Const $VK_4 = 0x34
Global Const $VK_5 = 0x35
Global Const $VK_6 = 0x36
Global Const $VK_7 = 0x37
Global Const $VK_8 = 0x38
Global Const $VK_9 = 0x39
; 0x3A - 0x40 - Undefined
Global Const $VK_A = 0x41
Global Const $VK_B = 0x42
Global Const $VK_C = 0x43
Global Const $VK_D = 0x44
Global Const $VK_E = 0x45
Global Const $VK_F = 0x46
Global Const $VK_G = 0x47
Global Const $VK_H = 0x48
Global Const $VK_I = 0x49
Global Const $VK_J = 0x4A
Global Const $VK_K = 0x4B
Global Const $VK_L = 0x4C
Global Const $VK_M = 0x4D
Global Const $VK_N = 0x4E
Global Const $VK_O = 0x4F
Global Const $VK_P = 0x50
Global Const $VK_Q = 0x51
Global Const $VK_R = 0x52
Global Const $VK_S = 0x53
Global Const $VK_T = 0x54
Global Const $VK_U = 0x55
Global Const $VK_V = 0x56
Global Const $VK_W = 0x57
Global Const $VK_X = 0x58
Global Const $VK_Y = 0x59
Global Const $VK_Z = 0x5A
Global Const $VK_LWIN = 0x5B
Global Const $VK_RWIN = 0x5C
; 0x5E - Reserved
Global Const $VK_APPS = 0x5D
Global Const $VK_SLEEP = 0x5F
Global Const $VK_NUMPAD0 = 0x60
Global Const $VK_NUMPAD1 = 0x61
Global Const $VK_NUMPAD2 = 0x62
Global Const $VK_NUMPAD3 = 0x63
Global Const $VK_NUMPAD4 = 0x64
Global Const $VK_NUMPAD5 = 0x65
Global Const $VK_NUMPAD6 = 0x66
Global Const $VK_NUMPAD7 = 0x67
Global Const $VK_NUMPAD8 = 0x68
Global Const $VK_NUMPAD9 = 0x69
Global Const $VK_MULTIPLY = 0x6A
Global Const $VK_ADD = 0x6B
Global Const $VK_SEPARATOR = 0x6C
Global Const $VK_SUBTRACT = 0x6D
Global Const $VK_DECIMAL = 0x6E
Global Const $VK_DIVIDE = 0x6F
Global Const $VK_F1 = 0x70
Global Const $VK_F2 = 0x71
Global Const $VK_F3 = 0x72
Global Const $VK_F4 = 0x73
Global Const $VK_F5 = 0x74
Global Const $VK_F6 = 0x75
Global Const $VK_F7 = 0x76
Global Const $VK_F8 = 0x77
Global Const $VK_F9 = 0x78
Global Const $VK_F10 = 0x79
Global Const $VK_F11 = 0x7A
Global Const $VK_F12 = 0x7B
Global Const $VK_F13 = 0x7C
Global Const $VK_F14 = 0x7D
Global Const $VK_F15 = 0x7E
Global Const $VK_F16 = 0x7F
Global Const $VK_F17 = 0x80
Global Const $VK_F18 = 0x81
Global Const $VK_F19 = 0x82
Global Const $VK_F20 = 0x83
Global Const $VK_F21 = 0x84
Global Const $VK_F22 = 0x85
Global Const $VK_F23 = 0x86
Global Const $VK_F24 = 0x87
; 0x88 - 0x8F - Unassigned
Global Const $VK_NUMLOCK = 0x90
Global Const $VK_SCROLL = 0x91
; 0x92 - 0x96 - OEM specific
; 0x97 - 0x9F - Unassigned
Global Const $VK_LSHIFT = 0xA0
Global Const $VK_RSHIFT = 0xA1
Global Const $VK_LCONTROL = 0xA2
Global Const $VK_RCONTROL = 0xA3
Global Const $VK_LMENU = 0xA4
Global Const $VK_RMENU = 0xA5
Global Const $VK_BROWSER_BACK = 0xA6
Global Const $VK_BROWSER_FORWARD = 0xA7
Global Const $VK_BROWSER_REFRESH = 0xA8
Global Const $VK_BROWSER_STOP = 0xA9
Global Const $VK_BROWSER_SEARCH = 0xAA
Global Const $VK_BROWSER_FAVORITES = 0xAB
Global Const $VK_BROWSER_HOME = 0xAC
Global Const $VK_VOLUME_MUTE = 0xAD
Global Const $VK_VOLUME_DOWN = 0xAE
Global Const $VK_VOLUME_UP = 0xAF
Global Const $VK_MEDIA_NEXT_TRACK = 0xB0
Global Const $VK_MEDIA_PREV_TRACK = 0xB1
Global Const $VK_MEDIA_STOP = 0xB2
Global Const $VK_MEDIA_PLAY_PAUSE = 0xB3
Global Const $VK_LAUNCH_MAIL = 0xB4
Global Const $VK_LAUNCH_MEDIA_SELECT = 0xB5
Global Const $VK_LAUNCH_APP1 = 0xB6
Global Const $VK_LAUNCH_APP2 = 0xB7
; 0xB8 - 0xB9 - Reserved
Global Const $VK_OEM_1 = 0xBA; ';:'
Global Const $VK_OEM_PLUS = 0xBB; '=+'
Global Const $VK_OEM_COMMA = 0xBC; ',<'
Global Const $VK_OEM_MINUS = 0xBD; '-_'
Global Const $VK_OEM_PERIOD = 0xBE; '.>'
Global Const $VK_OEM_2 = 0xBF; '/?'
Global Const $VK_OEM_3 = 0xC0; '`~'
; 0xC1 - 0xD7 - Reserved
; 0xD8 - 0xDA - Unassigned
Global Const $VK_OEM_4 = 0xDB; '[{'
Global Const $VK_OEM_5 = 0xDC; '\|'
Global Const $VK_OEM_6 = 0xDD; ']}'
Global Const $VK_OEM_7 = 0xDE; ''"'
Global Const $VK_OEM_8 = 0xDF
; 0xE0 - Reserved
; 0xE1 - OEM specific
Global Const $VK_OEM_102 = 0xE2
; 0xE3 - 0xE4 - OEM specific
; 0xE5
; 0xE6 - OEM specific
; 0xE7
; 0xE8 - Unassigned
; 0xE9 - 0xF5 - OEM specific
Global Const $VK_ATTN = 0xF6
Global Const $VK_CRSEL = 0xF7
Global Const $VK_EXSEL = 0xF8
Global Const $VK_EREOF = 0xF9
Global Const $VK_PLAY = 0xFA
Global Const $VK_ZOOM = 0xFB
Global Const $VK_NONAME = 0xFC
Global Const $VK_PA1 = 0xFD
Global Const $VK_OEM_CLEAR = 0xFE

#EndRegion Global Variables and Constants
