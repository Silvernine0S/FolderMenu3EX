#include-once

#include '_Functions.au3' ; By SoftwareSpot.

Func _SciTE_GetSciTEDefaultHome()
	Local $sSciTEPath = _GetFullPath('..') ; Get the path up from the application.
	If FileExists($sSciTEPath & '\SciTE.exe') = 0 Then
		$sSciTEPath = _WinAPI_PathRemoveFileSpec(_WinAPI_GetProcessFileName(ProcessExists('SciTE.exe')))
	EndIf
	Return $sSciTEPath
EndFunc   ;==>_SciTE_GetSciTEDefaultHome
