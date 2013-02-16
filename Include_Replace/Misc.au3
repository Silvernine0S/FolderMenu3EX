#include-once

#include "StructureConstants.au3"
#include "WinAPIError.au3"

; #INDEX# =======================================================================================================================
; Title .........: Misc
; AutoIt Version : 3.1.1++
; Language ......: English
; Description ...: Functions that assist with Common Dialogs.
; Author(s) .....: Gary Frost, Florian Fida (Piccaso), Dale (Klaatu) Thompson, Valik, ezzetabi, Jon, Paul Campbell (PaulIA)
; Dll(s) ........: comdlg32.dll, user32.dll, kernel32.dll, advapi32.dll, gdi32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_Singleton
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Singleton
; Description ...: Enforce a design paradigm where only one instance of the script may be running.
; Syntax.........: _Singleton($sOccurenceName[, $iFlag = 0])
; Parameters ....: $sOccurenceName - String to identify the occurrence of the script.  This string may not contain the \ character unless you are placing the object in a namespace (See Remarks).
;                  $iFlag          - Behavior options.
;                  |0 - Exit the script with the exit code -1 if another instance already exists.
;                  |1 - Return from the function without exiting the script.
;                  |2 - Allow the object to be accessed by anybody in the system. This is useful if specifying a "Global\" object in a multi-user environment.
; Return values .: Success      - The handle to the object used for synchronization (a mutex).
;                  Failure      - 0
; Author ........: Valik
; Modified.......:
; Remarks .......: You can place the object in a namespace by prefixing your object name with either "Global\" or "Local\".  "Global\" objects combined with the flag 2 are useful in multi-user environments.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Singleton($sOccurenceName, $iFlag = 0)
	Local Const $ERROR_ALREADY_EXISTS = 183
	Local Const $SECURITY_DESCRIPTOR_REVISION = 1
	Local $pSecurityAttributes = 0

	If BitAND($iFlag, 2) Then
		; The size of SECURITY_DESCRIPTOR is 20 bytes.  We just
		; need a block of memory the right size, we aren't going to
		; access any members directly so it's not important what
		; the members are, just that the total size is correct.
		Local $tSecurityDescriptor = DllStructCreate("dword[5]")
		Local $pSecurityDescriptor = DllStructGetPtr($tSecurityDescriptor)
		; Initialize the security descriptor.
		Local $aRet = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", _
				"ptr", $pSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
		If @error Then Return SetError(@error, @extended, 0)
		If $aRet[0] Then
			; Add the NULL DACL specifying access to everybody.
			$aRet = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", _
					"ptr", $pSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
			If @error Then Return SetError(@error, @extended, 0)
			If $aRet[0] Then
				; Create a SECURITY_ATTRIBUTES structure.
				Local $structSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
				; Assign the members.
				DllStructSetData($structSecurityAttributes, 1, DllStructGetSize($structSecurityAttributes))
				DllStructSetData($structSecurityAttributes, 2, $pSecurityDescriptor)
				DllStructSetData($structSecurityAttributes, 3, 0)
				; Everything went okay so update our pointer to point to our structure.
				$pSecurityAttributes = DllStructGetPtr($structSecurityAttributes)
			EndIf
		EndIf
	EndIf

	Local $handle = DllCall("kernel32.dll", "handle", "CreateMutexW", "ptr", $pSecurityAttributes, "bool", 1, "wstr", $sOccurenceName)
	If @error Then Return SetError(@error, @extended, 0)
	Local $lastError = DllCall("kernel32.dll", "dword", "GetLastError")
	If @error Then Return SetError(@error, @extended, 0)
	If $lastError[0] = $ERROR_ALREADY_EXISTS Then
		If BitAND($iFlag, 1) Then
			Return SetError($lastError[0], $lastError[0], 0)
		Else
			Exit -1
		EndIf
	EndIf
	Return $handle[0]
EndFunc   ;==>_Singleton
