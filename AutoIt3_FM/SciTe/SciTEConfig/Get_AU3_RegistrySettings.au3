;***********************************************************
; Scriptname: Get_AU3_Settings.au3
; Script to display Registry setting for SciTE & AutoIt3
; reporting possible issues with these settings
;***********************************************************
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
_Check_Au3_Registry()
;
Func _Check_Au3_Registry()
	Local $TotalMsg
	Display_Console("******************************************************************************************************************************************" & @CRLF, $TotalMsg)
	Local $FixedOpen = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.au3", "Application")
	Local $FixedOpenW7 = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.au3\Userchoice", "ProgId")
	If $FixedOpen <> "" Then
		Display_Console("!*  Found always open with         :" & $FixedOpen & @CRLF, $TotalMsg)
		Display_Console('!*  Fixed by removing Registry Hyve: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.au3" Key:"Application"' & @CRLF, $TotalMsg)
	EndIf
	If $FixedOpenW7 <> "" Then
		Display_Console("!*  Found always open with Win7    :" & $FixedOpenW7 & @CRLF, $TotalMsg)
		Display_Console('!*  Fixed by removing Registry key : "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.au3\Userchoice"' & @CRLF, $TotalMsg)
	EndIf
	Local $au3prof = RegRead("HKCR\.au3", "")
	If $au3prof <> "AutoIt3Script" And $au3prof <> "AutoIt3ScriptBeta" Then
		Display_Console('!*  Registry key: "HKCR\.au3" - "Default" is currently set to ' & $au3prof, $TotalMsg)
		Display_Console('   ==> This should be changed to "AutoIt3Script" (or "AutoIt3ScriptBeta")' & @CRLF, $TotalMsg)
;~ 	RegWrite("HKCR\.au3","","REG_SZ","AutoIt3Script")
	Else
		Display_Console("* HKCR\.au3 Default       :" & $au3prof & @CRLF, $TotalMsg)
	EndIf
	Local $RegKeyBase = "HKCR\" & $au3prof & "\shell"
	Display_Console("* HKCR\.au3 ShellNew      :" & @WindowsDir & "\SHELLNEW\" & RegRead("HKCR\.au3\Shellnew", "Filename"), $TotalMsg)
	If FileExists(@WindowsDir & "\SHELLNEW\" & RegRead("HKCR\.au3\Shellnew", "Filename")) Then
		Display_Console(" (File Exists)" & @CRLF, $TotalMsg)
	Else
		Display_Console(" (*** File is Misssing!)" & @CRLF, $TotalMsg)
	EndIf
	Display_Console("******************************************************************************************************************************************" & @CRLF, $TotalMsg)
	Display_Console("* Explorer shell options:" & @CRLF, $TotalMsg)
	Display_Console("* " & $RegKeyBase & ": " & @CRLF, $TotalMsg)
	Display_Console("*  => Default Action:" & RegRead($RegKeyBase, "") & @CRLF, $TotalMsg)
	Local  $var, $var2
	For $i = 1 To 30
		$var = RegEnumKey($RegKeyBase, $i)
		If @error <> 0 Then ExitLoop
		Display_Console("*     " & StringLeft($var & "                       ", 22), $TotalMsg)
		$var2 = RegEnumKey($RegKeyBase & "\" & $var, 1)
		Display_Console(" => " & $var2, $TotalMsg)
		Display_Console(":" & RegRead($RegKeyBase & "\" & $var & "\" & $var2, "") & @CRLF, $TotalMsg)
	Next
	Display_Console("******************************************************************************************************************************************" & @CRLF, $TotalMsg)
	ClipPut($TotalMsg)
	GUICreate(".au3 registry settings", 1000, 400)
	GUICtrlCreateLabel($TotalMsg, 1, 1, 998, 320)
	GUICtrlSetFont(-1, Default, Default, Default, "Courier New")
	Local $HReg_Exit = GUICtrlCreateButton("Exit", 450, 350, 50, 30)
	GUICtrlCreateLabel("* information is stored on the clipboard.", 10, 370)
	GUISetState(@SW_SHOW)
	Do
		$msg = GUIGetMsg()
	Until $msg = $GUI_EVENT_CLOSE Or $msg = $HReg_Exit
	GUIDelete()
EndFunc   ;==>_Check_Au3_Registry
;
Func Display_Console($msg, ByRef $TotalMsg)
;~ 	ConsoleWrite($msg)
	$TotalMsg &= $msg
EndFunc   ;==>Display_Console
