#include-once
#include <Constants.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>

Func _SciTE_Send_Command($hWnd, $hSciTE, $sString)
	If StringStripWS($sString, $STR_STRIPALL) = '' Then
		Return SetError(2, 0, 0) ; String is blank.
	EndIf
	$sString = ':' & Dec(StringTrimLeft($hWnd, 2)) & ':' & $sString
	Local $tData = DllStructCreate('char[' & StringLen($sString) + 1 & ']') ; wchar
	DllStructSetData($tData, 1, $sString)

	Local Const $tagCOPYDATASTRUCT = 'ptr;dword;ptr' ; ';ulong_ptr;dword;ptr'
	Local $tCOPYDATASTRUCT = DllStructCreate($tagCOPYDATASTRUCT)
	DllStructSetData($tCOPYDATASTRUCT, 1, 1)
	DllStructSetData($tCOPYDATASTRUCT, 2, DllStructGetSize($tData))
	DllStructSetData($tCOPYDATASTRUCT, 3, DllStructGetPtr($tData))
	_SendMessage($hSciTE, $WM_COPYDATA, $hWnd, DllStructGetPtr($tCOPYDATASTRUCT))
	Return Number(Not @error)
EndFunc   ;==>_SciTE_Send_Command
