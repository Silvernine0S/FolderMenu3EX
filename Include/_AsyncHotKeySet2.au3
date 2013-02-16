#include-once
; ================================================================================================
; <_AsyncHotKeySet.au3>
;
; 'Asynchronous' emulation of HotKeySet, utilizing _IsPressed() function
;   (Great workaround for programs/games that disable hotkeys and/or keyboard hooks)
;
; NOTE: The functions BEING called *must* have *ONE* parameter, which is a keystate indicator
;       (True = all keys pressed, False = all keys released)
;       These are both only called once per press/release cycle. (Keys held down do not send multiple messages)
;
; --------------------------------------------------------------------------------------
; Original Author's Description:
;   Desc: "Async" emulation of HotKeySet, inspired by the _IsPressed() code by ezzetabi
;       <http://www.autoitscript.com/forum/index.php?showuser=839> posted at
;       <http://www.autoitscript.com/forum/index.php?showtopic=5760>.
;   Auth: Berean <http://www.autoitscript.com/forum/index.php?showuser=4581>.
;   Original code @: http://www.autoitscript.com/forum/index.php?showtopic=8220
; --------------------------------------------------------------------------------------
;
; Functions:
;   AsyncHotKeySet()   ; adds a key(+optional modifiers) & function to the internal table
;   AsyncHotKeyUnSet() ; removes a key(+optional modifiers) & function from the internal table
;   AsyncHotKeyPoll()  ; Polls the state of all the keys/functions in the internal table, calls appropriate functions
;
; INTERNAL Functions:
;   __IsPressed()    ; Tests if a given key (numerical codes only!) is set/unset. Can be called externally
;   _ahks_KeyAdd()  ; Adds a key(+optional modifiers) & function to the internal table
;   _ahks_KeyRemove()  ; Removes a key(+optional modifiers) & function from the internal table
;   _ahks_MapSendKeyToVirtualKey() ; Maps the AutoIT-style string key representations (see Send()) into actual numerical codes
;
;   Author(s): ezzetabi and Jon: Original _IsPressed() <from Misc.au3>, Berean: Original AsyncHotKeySet code
;       Ascend4nt: Rewrite of AsyncHotKeyPoll(), other modifications & cleanup, plus the addition of modifier keys
; ================================================================================================

#region Global var
;   ==================== CONSTANTS ====================
Global Const $ahks_kMaxKeys = 256 ; maximum # of key/function combos for internal table
; Column indexes into key/function combination table:
Global Const $ahks_kKeyCode   = 0
Global Const $ahks_kUserFunc  = 1
Global Const $ahks_kLastState = 2
Global Const $ahks_kSendParam = 3 ; send vkey code param to called func
Global Const $ahks_kCallOn    = 4
; set when the func is called.
;   0 for both 1 & 2, an additional param will be sent to the called func for key down/up.
;   1 for key down (default)
;   2 for key up
;   4 for main key up
Global Const $ahks_kMaxIndices = 5 ; # of columns in key/function combination table. Added 1 for send key info, 1 for calls on key up
; Bit States of key, modifer S C A W, plus indicator of whether the full hotkey was invoked previously
Global Const $ahks_MainKeyBit = 1
Global Const $ahks_ModifierSBit = 2
Global Const $ahks_ModifierCBit = 4
Global Const $ahks_ModifierABit = 8
Global Const $ahks_ModifierWBit = 16
Global Const $ahks_HotKeyInvokedBit = 32

;   ==================== GLOBALS ====================
Global $ahks_CurrentKeyCount = 0 ; count of key/function combos in internal table
Dim $ahks_keyMap[$ahks_kMaxKeys][$ahks_kMaxIndices]  ; AsyncHotKey internal table
#endregion

; ================================================================================================
; Func AsyncHotKeySet($iKeyCode, $sUserFunc)
;
; Add/remove a hotkey(+optional modifiers) & function to/from the internal table.
;
; $iKeyCode = main keystroke (in AutoIT Send()-style string format)
; $iModifier1 = 1st (optional) modifier key (Shift, Ctrl, Alt), (in AutoIT Send()-style string format)
; $iModifier2 = 2nd (optional) modifier key (Shift, Ctrl, Alt), (in AutoIT Send()-style string format)
; $sUserFunc = User Function to call when the entire key combination is pressed
;      (the function will be called only from the AsyncHotKeyPoll() function)
; NOTE: The functions to call must have *ONE* parameter, which is a keystate indicator ($bAllKeysPressed)
;      (True = all keys pressed, False = all keys released)
;      These are both only called once per press/release cycle. (Keys held down do not send multiple messages)
;
; returns:
;   Success: True, @Error = 0
;   Failure: False, @Error set:
;      @Error = 1 = invalid key
;      @Error = 2 = could not locate key mapping combination in internal table (remove only)
;      @Error = 4 = key mapping combination already mapped to another function in internal table (add only)
;      @Error = -1 = Maximum # of key/function combinations has been reached, can't add more (add only)
;
; Author(s): Berean (original code), Ascend4nt: addition of modifier keys, True/False + @Error returns
; ================================================================================================
Func AsyncHotKeySet($iKeyCode, $sUserFunc="", $fSendParam=0, $fCallOn=1)
	Local $vRet
	; Function passed?
	if $sUserFunc<>"" then
		$vRet=_ahks_KeyAdd($iKeyCode, $sUserFunc, $fSendParam, $fCallOn)
	else
		; "" passed, meaning 'Remove' HotKey
		$vRet=_ahks_KeyRemove($iKeyCode)
	endif
	return SetError(@Error, 0, $vRet)
EndFunc

; ================================================================================================
; Func AsyncHotKeyPoll($hDLL)
;
; Check if required keys are set for the list of functions to call, and calls the function when those keys are pressed.
;
; $hDLL = handle to user32.dll, returned from a call to DLLOpen('user32.dll').
;   NOTE: It is HIGHLY recommended the DLLOpen be performed before all polling takes place, as otherwise
;    it will slow down the function/processing.
;
; returns:
;   Nothing.
;
; Author: Ascend4nt: Complete rewrite of Berean's code, addition of modifier keys, & Berean (original code)
; ================================================================================================
Func AsyncHotKeyPoll($hDLL='user32.dll')
	Local $index, $iKeyLastState, $iAllHotKeyBits
	Local $iKeyCode, $iVKey, $iCK_S, $iCK_C, $iCK_A, $iCK_W

	; Poll each key we are watching.
	For $index=0 To $ahks_CurrentKeyCount-1
		$iKeyCode = $ahks_keyMap[$index][$ahks_kKeyCode]
		$iVKey = BitAND($iKeyCode,0xFF)
		$iCK_S = BitAND($iKeyCode, $CK_SHIFT  )
		$iCK_C = BitAND($iKeyCode, $CK_CONTROL)
		$iCK_A = BitAND($iKeyCode, $CK_ALT    )
		$iCK_W = BitAND($iKeyCode, $CK_WIN    )

		; Get the last key-state(s) from array
		$iKeyLastState=$ahks_keyMap[$index][$ahks_kLastState]

		; Main key code pressed?
		if __IsPressed($iVKey, $hDLL) then
			; Find out what the full 'ON' number would be for all-keys-pressed. (additions below)
			$iAllHotKeyBits=$ahks_MainKeyBit

			; Ensure Last State reflects that the Main Key is pressed.
			$iKeyLastState=BitOR($iKeyLastState, $ahks_MainKeyBit)

			; Checks if modifier present? Add to full 'ON' number, then check pressed-state

			if $iCK_S <> 0 then
				$iAllHotKeyBits+=$ahks_ModifierSBit
				; Is the modifier Key pressed? Ensure the Last State reflects this.
				if __IsPressed($VK_SHIFT, $hDLL) then $iKeyLastState=BitOR($iKeyLastState, $ahks_ModifierSBit)
			endif
			if $iCK_C <> 0 then
				$iAllHotKeyBits+=$ahks_ModifierCBit
				; Is the modifier Key pressed? Ensure the Last State reflects this.
				if __IsPressed($VK_CONTROL, $hDLL) then $iKeyLastState=BitOR($iKeyLastState, $ahks_ModifierCBit)
			endif
			if $iCK_A <> 0 then
				$iAllHotKeyBits+=$ahks_ModifierABit
				; Is the modifier Key pressed? Ensure the Last State reflects this.
				if __IsPressed($VK_MENU, $hDLL) then $iKeyLastState=BitOR($iKeyLastState, $ahks_ModifierABit)
			endif
			if $iCK_W <> 0 then
				$iAllHotKeyBits+=$ahks_ModifierWBit
				; Is the modifier Key pressed? Ensure the Last State reflects this.
				if __IsPressed($VK_LWIN, $hDLL) then $iKeyLastState=BitOR($iKeyLastState, $ahks_ModifierWBit)
			endif

			; Are ALL keys set? (And $ahks_HotKeyInvokedBit not set?) Make the call!. [$ahks_HotKeyInvokedBit prevents continuous calls]
			if $iKeyLastState=$iAllHotKeyBits then
				; Make a call to the proc with an 'all-keys-pressed' message
				if $ahks_keyMap[$index][$ahks_kCallOn] = 0 then ; calls func when key down and key up, send true for key down
					if $ahks_keyMap[$index][$ahks_kSendParam] = 1 then
						Call($ahks_keyMap[$index][$ahks_kUserFunc], True, $iKeyCode)
					else
						Call($ahks_keyMap[$index][$ahks_kUserFunc], True)
					endif
				elseif $ahks_keyMap[$index][$ahks_kCallOn] = 1 then ; calls func when key down
					if $ahks_keyMap[$index][$ahks_kSendParam] = 1 then
						Call($ahks_keyMap[$index][$ahks_kUserFunc], $iKeyCode)
					else
						Call($ahks_keyMap[$index][$ahks_kUserFunc])
					endif
				endif
				; Make certain continuous calls aren't made while the keys are held down, & also allow notification when all released
				$iKeyLastState+=$ahks_HotKeyInvokedBit
			endif

		else
		; Main Key *not* pressed if got here

			; calls func when main key up, and the hotkey is invoked
			if $ahks_keyMap[$index][$ahks_kCallOn] = 4 and BitAND($iKeyLastState, $ahks_HotKeyInvokedBit) then
				if $ahks_keyMap[$index][$ahks_kSendParam] = 1 then
					Call($ahks_keyMap[$index][$ahks_kUserFunc], $iKeyCode)
				else
					Call($ahks_keyMap[$index][$ahks_kUserFunc])
				endif
			endif

			; Is the Main Key last-state 'ON'? Clear/Reset it to OFF.
			if BitAND($iKeyLastState, $ahks_MainKeyBit) then $iKeyLastState=BitXOR($iKeyLastState, $ahks_MainKeyBit)

			; Modifier Bit set, and no longer pressed? Clear 'pressed' bit.
			if BitAND($iKeyLastState, $ahks_ModifierSBit) And Not __IsPressed($VK_SHIFT, $hDLL) then
				$iKeyLastState=BitXOR($iKeyLastState, $ahks_ModifierSBit)
			endif
			if BitAND($iKeyLastState, $ahks_ModifierCBit) And Not __IsPressed($VK_CONTROL, $hDLL) then
				$iKeyLastState=BitXOR($iKeyLastState, $ahks_ModifierCBit)
			endif
			if BitAND($iKeyLastState, $ahks_ModifierABit) And Not __IsPressed($VK_MENU, $hDLL) then
				$iKeyLastState=BitXOR($iKeyLastState, $ahks_ModifierABit)
			endif
			if BitAND($iKeyLastState, $ahks_ModifierWBit) And Not __IsPressed($VK_LWIN, $hDLL) then
				$iKeyLastState=BitXOR($iKeyLastState, $ahks_ModifierWBit)
			endif

			; ALL keys switched off? (and were they previously all pressed?)
			if $iKeyLastState=$ahks_HotKeyInvokedBit then
				; Make a call to the proc with an 'all-keys-released' message
				if $ahks_keyMap[$index][$ahks_kCallOn] = 0 then ; calls func when key down and key up, send true for key down
					if $ahks_keyMap[$index][$ahks_kSendParam] = 1 then
						Call($ahks_keyMap[$index][$ahks_kUserFunc], False, $iKeyCode)
					else
						Call($ahks_keyMap[$index][$ahks_kUserFunc], False)
					endif
				elseif $ahks_keyMap[$index][$ahks_kCallOn] = 2 then ; calls func when key up
					if $ahks_keyMap[$index][$ahks_kSendParam] = 1 then
						Call($ahks_keyMap[$index][$ahks_kUserFunc], $iKeyCode)
					else
						Call($ahks_keyMap[$index][$ahks_kUserFunc])
					endif
				endif
				; Completely reset state
				$iKeyLastState=0
			endif
		endif
		; Assign state back to array
		$ahks_keyMap[$index][$ahks_kLastState] = $iKeyLastState
	Next
	return
EndFunc

; ================================================================================================
; Func _ahks_KeyAdd($iKeyCode, $sUserFunc)
;
; Add a hotkey(+optional modifiers) & function to the internal table.
;
; $iKeyCode = main keystroke (in AutoIT Send()-style string format)
; $iModifier1 = 1st (optional) modifier key (Shift, Ctrl, Alt), (in AutoIT Send()-style string format)
; $iModifier2 = 2nd (optional) modifier key (Shift, Ctrl, Alt), (in AutoIT Send()-style string format)
; $sUserFunc = User Function to call when the entire key combination is pressed
;      (the function will be called only from the AsyncHotKeyPoll() function)
;
; returns:
;   Success: True, @Error = 0
;   Failure: False, @Error set:
;      @Error = 1 = invalid key
;      @Error = 4 = key mapping combination already mapped to another function in internal table
;      @Error = -1 = Maximum # of key/function combinations has been reached, can't add more
;
; Author: Berean (original code), Ascend4nt: addition of modifier keys, cleanup, True/False + @Error returns
; ================================================================================================
Func _ahks_KeyAdd($iKeyCode, $sUserFunc, $fSendParam, $fCallOn)
	Local $index

	Local $iModifier1, $iModifier2 = 0
	if BitAND($iKeyCode, $CK_SHIFT  ) then $iModifier1 = $VK_SHIFT
	if BitAND($iKeyCode, $CK_CONTROL) then $iModifier1 = $VK_CONTROL
	if BitAND($iKeyCode, $CK_ALT    ) then $iModifier1 = $VK_MENU
	if BitAND($iKeyCode, $CK_WIN    ) then $iModifier1 = $VK_LWIN

	; Search for a match in the existing table.
	For $index=0 To $ahks_CurrentKeyCount-1
		if $ahks_keyMap[$index][$ahks_kKeyCode] = $iKeyCode then
			; Found a match. Is it already assigned to same function?
			if $ahks_keyMap[$index][$ahks_kUserFunc] = $sUserFunc then return True
			; The key combination is assigned to another function. BADDD
			return SetError(4, 0, False)
		endif
	Next

	; Have we reached the limit of maximum # of key/function combinations?
	if $index>=$ahks_kMaxKeys then return SetError(-1, @extended, False)

	; Add the key. & modifiers
	$ahks_keyMap[$index][$ahks_kKeyCode]   = $iKeyCode
	$ahks_keyMap[$index][$ahks_kUserFunc]  = $sUserFunc
	$ahks_keyMap[$index][$ahks_kLastState] = 0
	$ahks_keyMap[$index][$ahks_kSendParam] = $fSendParam
	$ahks_keyMap[$index][$ahks_kCallOn]    = $fCallOn

	; Bump the array count if we extended the array.
	if $index=$ahks_CurrentKeyCount then $ahks_CurrentKeyCount+=1
	return True
EndFunc

; ================================================================================================
; Func _ahks_KeyRemove($iKeyCode)
;
; Removes a hotkey(+optional modifiers) & its function from internal table.
;
; returns:
;   Success: True, @Error = 0
;   Failure: False, @Error set:
;      @Error = 1 = invalid key
;      @Error = 2 = could not locate key mapping combination in internal table
;
; Author: Berean (original code), Ascend4nt: addition of modifier keys, cleanup, True/False + @Error returns
; ================================================================================================

Func _ahks_KeyRemove($iKeyCode)
	Local $index, $index2

	Local $iModifier1, $iModifier2 = ""
	if BitAND($iKeyCode, $CK_SHIFT  ) then $iModifier1 = $VK_SHIFT
	if BitAND($iKeyCode, $CK_CONTROL) then $iModifier1 = $VK_CONTROL
	if BitAND($iKeyCode, $CK_ALT    ) then $iModifier1 = $VK_MENU
	if BitAND($iKeyCode, $CK_WIN    ) then $iModifier1 = $VK_LWIN

	; Search for a match in the existing table.
	For $index=0 To $ahks_CurrentKeyCount-1
		if $ahks_keyMap[$index][$ahks_kKeyCode] = $iKeyCode then ExitLoop
	Next

	; Not found?
	if $index=$ahks_CurrentKeyCount then return SetError(2, 0, False)

	; Remove the key and shift the remaining keys back in the array.
	For $index2=$index To $ahks_CurrentKeyCount-1
		$ahks_keyMap[$index2][$ahks_kKeyCode]   = $ahks_keyMap[$index2 + 1][$ahks_kKeyCode]
		$ahks_keyMap[$index2][$ahks_kUserFunc]  = $ahks_keyMap[$index2 + 1][$ahks_kUserFunc]
		$ahks_keyMap[$index2][$ahks_kLastState] = $ahks_keyMap[$index2 + 1][$ahks_kLastState]
		$ahks_keyMap[$index2][$ahks_kSendParam] = $ahks_keyMap[$index2 + 1][$ahks_kSendParam]
		$ahks_keyMap[$index2][$ahks_kCallOn]  = $ahks_keyMap[$index2 + 1][$ahks_kCallOn]
	Next

	; Decrement key count.
	if $ahks_CurrentKeyCount>0 then $ahks_CurrentKeyCount-=1

	return True
EndFunc

; ================================================================================================
; Func __IsPressed($iKey, $hDLL='user32.dll')
;
; Checks if a key has been pressed.
; Taken from <Misc.au3>, modified to work on numbers instead of strings
;
; $iKey = numerical key code of key to check
; $hDLL = handle to user32.dll (optional)
;
; returns:
;   Success: @Error is clear, and either True (key is pressed) or False (key is not pressed)
;   Failure: @Error is set to one of DllCall()'s errors, False is returned
;
; Author(s): ezzetabi and Jon: Original _IsPressed() function <Misc.au3>,
;   Ascend4nt (modified function to work on #'s instead of strings, + returns True/False now)
; ================================================================================================
Func __IsPressed($iKey, $hDLL='user32.dll')
	; _Is_Key_Pressed will return 0 if the key is not pressed, 1 if it is.
	Local $a_R = DllCall($hDLL, "int", "GetAsyncKeyState", "int", $iKey)
	if Not @Error And BitAND($a_R[0], 0x8000) = 0x8000 then return True
	return False
EndFunc

