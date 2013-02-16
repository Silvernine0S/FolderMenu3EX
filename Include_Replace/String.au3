#include-once

; #INDEX# =======================================================================================================================
; Title .........: String
; Description ...: Functions that assist with String management.
; Author(s) .....: Jarvis Stubblefield, SmOke_N, Valik, Wes Wolfe-Wolvereness, WeaponX, Louis Horvath, JdeB, Jeremy Landes, Jon
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_StringExplode
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _StringExplode
; Description ...: Splits up a string into substrings depending on the given delimiters as PHP Explode v5.
; Syntax.........: _StringExplode($sString, $sDelimiter [, $iLimit] )
; Parameters ....: $sString    - String to be split
;                  $sDelimiter - Delimiter to split on (split is performed on entire string, not individual characters)
;                  $iLimit     - [optional] Maximum elements to be returned
;                  |=0 : (default) Split on every instance of the delimiter
;                  |>0 : Split until limit, last element will contain remaining portion of the string
;                  |<0 : Split on every instance, removing limit count from end of the array
; Return values .: Success - an array containing the exploded strings.
; Author ........: WeaponX
; Modified.......:
; Remarks .......: Use negative limit values to remove the first possible elements.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringExplode($sString, $sDelimiter, $iLimit = 0)
	If $iLimit > 0 Then
		;Replace delimiter with NULL character using given limit
		$sString = StringReplace($sString, $sDelimiter, Chr(0), $iLimit)

		;Split on NULL character, this will leave the remainder in the last element
		$sDelimiter = Chr(0)
	ElseIf $iLimit < 0 Then
		;Find delimiter occurence from right-to-left
		Local $iIndex = StringInStr($sString, $sDelimiter, 0, $iLimit)

		If $iIndex Then
			;Split on left side of string only
			$sString = StringLeft($sString, $iIndex - 1)
		EndIf
	EndIf

	Return StringSplit($sString, $sDelimiter, 3)
EndFunc   ;==>_StringExplode
