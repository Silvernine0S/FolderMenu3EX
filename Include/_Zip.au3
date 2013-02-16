;http://www.autoitscript.com/forum/index.php?showtopic=73425
;#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#include <File.au3>
; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.2
; Language:       English
; Description:    ZIP Functions.
; Author:		  torels_
;
; ------------------------------------------------------------------------------

;===============================================================================
;
; Function Name:    _Zip_Unzip()
; Description:      Extract a single file contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFilename - Name of the element in the zip archive ex. "hello_world.txt"
;					$hDestPath - Complete path to where the files will be extracted
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the extracting process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_Unzip($hZipFile, $hFilename, $hDestPath)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	$hZipFile = _PathFull($hZipFile)
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	If Not FileExists($hDestPath) Then DirCreate($hDestPath)
	Local $oApp = ObjCreate("Shell.Application")
	Local $hFolderitem = $oApp.NameSpace($hZipFile).Parsename($hFilename)
	$oApp.NameSpace($hDestPath).Copyhere($hFolderitem)
	While 1
		If FileExists($hDestPath & "\" & $hFilename) Then
			return SetError(0, 0, 1)
			ExitLoop
		EndIf
		Sleep(500)
	WEnd
EndFunc   ;==>_Zip_Unzip

;===============================================================================
;
; Function Name:    _Zip_DllChk()
; Description:      Internal error handler.
; Parameter(s):     none.
; Requirement(s):   none.
; Return Value(s):  Failure - @extended = 1
; Author(s):        smashley
;
;===============================================================================
Func _Zip_DllChk()
	If Not FileExists(@SystemDir & "\zipfldr.dll") Then Return 2
	If Not RegRead("HKEY_CLASSES_ROOT\CLSID\{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}", "") Then Return 3
	Return 0
EndFunc   ;==>_Zip_DllChk
