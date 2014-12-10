#include-once

#include "SecurityConstants.au3"
#include "StructureConstants.au3"
#include "WinAPIError.au3"

; #INDEX# =======================================================================================================================
; Title .........: Security
; Description ...: Functions that assist with Security management.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s) ........: advapi32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_Security__OpenThreadTokenEx
;_Security__SetPrivilege
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__OpenThreadTokenEx
; Description ...: Opens the access token associated with a thread, impersonating the client's security context if required
; Syntax.........: _Security__OpenThreadTokenEx($iAccess[, $hThread = 0[, $fOpenAsSelf = False]])
; Parameters ....: $iAccess     - Access mask that specifies the requested types of access to the access token.  These  requested
;                  +access types are reconciled against the token's discretionary access control list (DACL) to  determine  which
;                  +accesses are granted or denied.
;                  $hThread     - Handle to the thread whose access token is opened
;                  $fOpenAsSelf - Indicates whether the access check is to be made against the security  context  of  the  thread
;                  +calling the OpenThreadToken function or against the security context of the process for the  calling  thread.
;                  +If this parameter is False, the access check is performed using the security context for the calling  thread.
;                  +If the thread is impersonating a client, this security context can be that  of  a  client  process.  If  this
;                  +parameter is True, the access check is made using the security context of the process for the calling thread.
; Return values .: Success      - Handle to the newly opened access token
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _Security__OpenThreadToken, _Security__ImpersonateSelf
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Security__OpenThreadTokenEx($iAccess, $hThread = 0, $fOpenAsSelf = False)
	Local $hToken = _Security__OpenThreadToken($iAccess, $hThread, $fOpenAsSelf)
	If $hToken = 0 Then
		If _WinAPI_GetLastError() <> $ERROR_NO_TOKEN Then Return SetError(-3, _WinAPI_GetLastError(), 0)
		If Not _Security__ImpersonateSelf() Then Return SetError(-1, _WinAPI_GetLastError(), 0)
		$hToken = _Security__OpenThreadToken($iAccess, $hThread, $fOpenAsSelf)
		If $hToken = 0 Then Return SetError(-2, _WinAPI_GetLastError(), 0)
	EndIf
	Return $hToken
EndFunc   ;==>_Security__OpenThreadTokenEx

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__SetPrivilege
; Description ...: Enables or disables a local token privilege
; Syntax.........: _Security__SetPrivilege($hToken, $sPrivilege, $fEnable)
; Parameters ....: $hToken      - Handle to a token
;                  $sPrivilege  - Privilege name
;                  $fEnable     - Privilege setting:
;                  | True - Enable privilege
;                  |False - Disable privilege
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Security__SetPrivilege($hToken, $sPrivilege, $fEnable)
	Local $iLUID = _Security__LookupPrivilegeValue("", $sPrivilege)
	If $iLUID = 0 Then Return SetError(-1, 0, False)

	Local $tCurrState = DllStructCreate($tagTOKEN_PRIVILEGES)
	Local $pCurrState = DllStructGetPtr($tCurrState)
	Local $iCurrState = DllStructGetSize($tCurrState)
	Local $tPrevState = DllStructCreate($tagTOKEN_PRIVILEGES)
	Local $pPrevState = DllStructGetPtr($tPrevState)
	Local $iPrevState = DllStructGetSize($tPrevState)
	Local $tRequired = DllStructCreate("int Data")
	Local $pRequired = DllStructGetPtr($tRequired)
	; Get current privilege setting
	DllStructSetData($tCurrState, "Count", 1)
	DllStructSetData($tCurrState, "LUID", $iLUID)
	If Not _Security__AdjustTokenPrivileges($hToken, False, $pCurrState, $iCurrState, $pPrevState, $pRequired) Then  _
							Return SetError(-2, @error, False)
	; Set privilege based on prior setting
	DllStructSetData($tPrevState, "Count", 1)
	DllStructSetData($tPrevState, "LUID", $iLUID)
	Local $iAttributes = DllStructGetData($tPrevState, "Attributes")
	If $fEnable Then
		$iAttributes = BitOR($iAttributes, $SE_PRIVILEGE_ENABLED)
	Else
		$iAttributes = BitAND($iAttributes, BitNOT($SE_PRIVILEGE_ENABLED))
	EndIf
	DllStructSetData($tPrevState, "Attributes", $iAttributes)
	If Not _Security__AdjustTokenPrivileges($hToken, False, $pPrevState, $iPrevState, $pCurrState, $pRequired) Then _
							Return SetError(-3, @error, False)
	Return True
EndFunc   ;==>_Security__SetPrivilege
