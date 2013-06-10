#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\folder_go.ico
#AutoIt3Wrapper_Outfile=FolderMenu.exe
#AutoIt3Wrapper_Outfile_x64=FolderMenu_x64.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=FolderMenu3 EX
#AutoIt3Wrapper_Res_Fileversion=1.0.0
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Icon_Add=Res\201.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\202.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\203.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\204.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\205.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\206.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\207.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\208.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\209.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\210.ico
#AutoIt3Wrapper_Res_Icon_Add=Res\211.ico
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; Oringally Folder Menu3 EX by rexx
; FolderMenu3EX is Forked from v3.1.2.2
Global Const $iCurrentVer = "1.0.1"

; ** CREDITS **
; Icons from "Silk Icons" by Mark James @ FAMFAMFAM
; http://www.famfamfam.com/lab/icons/silk/
;
; AsyncHotKeySet by Berean
; http://www.autoitscript.com/forum/index.php?showtopic=8220
;
; XML DOM wrapper by eltorro
; http://www.autoitscript.com/forum/index.php?showtopic=19848
;
; HotKey by Yashied
; http://www.autoitscript.com/forum/index.php?showtopic=90492
;
; Zip by torels_
; http://www.autoitscript.com/forum/index.php?showtopic=73425
;

#region AutoIt3Wrapper Directives
;#AutoIt3Wrapper_UseUpx=N
#endregion AutoIt3Wrapper Directives

#include <Constants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include <WinAPIEx.au3>
#include <Array.au3>
#include <Misc.au3>
#include <File.au3>
#include <SendMessage.au3>
#include <GuiMenu.au3>
#include "Include\_AsyncHotKeySet2.au3"
#include "Include\_HotKey.au3"
#include "Include\_HotKeyInput.au3"
#include "Include\_XMLDomWrapper.au3"
#include "Include\_Zip.au3"
#include "GUI.au3"
#include "Language.au3"

; http://www.autoitscript.com/forum/topic/122212-running-a-command-prompt-command-as-administrator/
; http://www.autoitscript.com/forum/topic/44048-x64-wow64disablewow64fsredirection/
; DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "int", 1) ; Disables 32Bit Redirected To SYSWOW64 Instead Of System32

#region Initialization
If _Singleton("FolderMenu3 EX", 1) = 0 Then ; What Is This?
	Send("#!+^x")
	Exit
EndIf

Opt('MustDeclareVars', 1)

FileChangeDir(@ScriptDir)

Global Const $sFolderMenuExe = @ScriptFullPath ;Originally StringReplace(@ScriptFullPath, ".au3", ".exe") Why?

; main menu gui controls
Global $hGuiMain = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST, $WS_EX_MDICHILD), _WinAPI_GetDesktopWindow())
Global $iMainMenuID = GUICtrlCreateContextMenu()
Global $fSecondaryDown = 0
GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "MenuSecondaryDown", $hGuiMain)
Global $iRecentMenuID, $iExplorerMenuID, $iDriveMenuID, $iToolMenuID, $iSVSMenuID, $iTCMenuID
; temp menu gui controls
Global $hGuiTemp, $iTempMenuID
; target window handle, class, addressbar class
Global $hWnd, $sWinClass, $sAdrClassNN
; options gui
Global $hGuiOptions

Global $sErrorMsg, $sLoadingTipText
Global $iPriorKey, $iPriorKeySel, $iPriorMouseTime, $iPriorKeyTime

Switch @OSVersion
	Case "WIN_8", "WIN_2008R2", "WIN_7", "WIN_2008", "WIN_VISTA"
		Global $sOSVersion = "WIN_VISTA"
	Case Else ;"WIN_2003","WIN_XP","WIN_XPe","WIN_2000"
		Global $sOSVersion = "WIN_XP"
EndSwitch

Opt('TrayMenuMode', 1 + 2) ; no default tray menu items + no check
Opt('TrayAutoPause', 0)
Opt("TrayOnEventMode", 1)
TraySetIcon($sFolderMenuExe)
TraySetToolTip("FolderMenu3 EX")
TraySetClick(8) ; only right click show the tray menu

Global Const $sConfigFile = @ScriptDir & "\FolderMenu.xml"
If Not FileExists($sConfigFile) Then
	$sErrorMsg = "Configuration File FolderMenu.xml Does Not Exist." & @LF & "Default Configuration File Is Used." & @LF
	FileInstall("Default.xml", $sConfigFile)
	ExeNameCheck()
EndIf
If _XMLFileOpen($sConfigFile) = -1 Then $sErrorMsg &= "FolderMenu.xml Error." & @LF
_XMLSetAutoFormat(False)
_XMLSetAutoSave(False)

ReadLanguage()
ReadConfig()
SetConfig()
CreateTrayMenu()
; Local $begin = TimerInit()
CreateMainMenu()
; TrayTip("FolderMenu3 EX", TimerDiff($begin), 5, 1)
SetHotkey()

If $fCheckVersion = 1 Then CheckVersion(1)

If $sErrorMsg <> "" Then
	TrayTip($sLang_Error, $sErrorMsg, 5, 3)
	$sErrorMsg = ""
EndIf

Global $oMyError = ObjEvent("AutoIt.Error", "_ComErrorHandler")

While 1
	AsyncHotKeyPoll()
	Sleep(10) ; Idle loop
WEnd
#endregion Initialization

#region Settings
Func ReadConfig()
	ReadConfigApp()
	ReadConfigKey()
	ReadConfigIcon()
	ReadConfigMenu()
	ReadConfigOthers()
	ReadConfigGUI()
EndFunc
Func ReadConfigApp()
	Global $iAppsCount = _XMLGetNodeCount("/FolderMenu/Settings/Applications/Setting[@Name='ApplicationList']/Application")
	If $iAppsCount > 0 Then
		Global $afAppCheck[$iAppsCount]
		Global $asAppType[$iAppsCount]
		Global $asAppName[$iAppsCount]
		Global $asAppClass[$iAppsCount]
		Global $asAppClassNN[$iAppsCount]
		For $i = 0 To $iAppsCount - 1
			$afAppCheck[$i] = _XMLGetAttrib("/FolderMenu/Settings/Applications/Setting[@Name='ApplicationList']/Application[" & $i + 1 & "]", "Check")
			$asAppType[$i] = _XMLGetAttrib("/FolderMenu/Settings/Applications/Setting[@Name='ApplicationList']/Application[" & $i + 1 & "]", "Type")
			$asAppName[$i] = _XMLGetAttrib("/FolderMenu/Settings/Applications/Setting[@Name='ApplicationList']/Application[" & $i + 1 & "]", "Name")
			$asAppClass[$i] = _XMLGetAttrib("/FolderMenu/Settings/Applications/Setting[@Name='ApplicationList']/Application[" & $i + 1 & "]", "Class")
			$asAppClassNN[$i] = _XMLGetAttrib("/FolderMenu/Settings/Applications/Setting[@Name='ApplicationList']/Application[" & $i + 1 & "]", "ClassNN")
			If $asAppClassNN[$i] = "" Then $asAppClassNN[$i] = "Edit1"
		Next
	EndIf
EndFunc
Func ReadConfigKey()
	Global $iHotkeysCount = _XMLGetNodeCount("/FolderMenu/Settings/Hotkeys/Setting[@Name='HotkeyList']/Hotkey")
	Global $iHotkeysCountO = 0
	Global $aiHotkeyKeyO[1]
	If $iHotkeysCount > 0 Then
		Global $aiHotkeyKey[$iHotkeysCount]
		Global $asHotkeyFunc[$iHotkeysCount]
		For $i = 0 To $iHotkeysCount - 1
			$aiHotkeyKey[$i] = _XMLGetAttrib("/FolderMenu/Settings/Hotkeys/Setting[@Name='HotkeyList']/Hotkey[" & $i + 1 & "]", "Key")
			$asHotkeyFunc[$i] = _XMLGetAttrib("/FolderMenu/Settings/Hotkeys/Setting[@Name='HotkeyList']/Hotkey[" & $i + 1 & "]", "Func")
		Next
	EndIf
EndFunc
Func ReadConfigIcon()
	Global $fNoMenuIcon = ReadConfigSetting("/FolderMenu/Settings/Icons", "NoMenuIcon", "0")
	Global $fGetFavIcon = ReadConfigSetting("/FolderMenu/Settings/Icons", "GetFavIcon", "0")
	Global $fShellIcon = ReadConfigSetting("/FolderMenu/Settings/Icons", "ShellIcon", "1")
	Global $iIconSizeG = ReadConfigSetting("/FolderMenu/Settings/Icons", "IconSizeG", "16")
	Global $iIconsCount = _XMLGetNodeCount("/FolderMenu/Settings/Icons/Setting[@Name='IconList']/Icon")
	If $iIconsCount > 0 Then
		Global $asIconIcon[$iIconsCount]
		Global $asIconExt[$iIconsCount]
		Local $iSize
		Local $sPath
		Local $iIndex
		For $i = 0 To $iIconsCount - 1
			$asIconExt[$i] = _XMLGetAttrib("/FolderMenu/Settings/Icons/Setting[@Name='IconList']/Icon[" & $i + 1 & "]", "Ext")
			$iSize = _XMLGetAttrib("/FolderMenu/Settings/Icons/Setting[@Name='IconList']/Icon[" & $i + 1 & "]", "Size")
			$sPath = _XMLGetAttrib("/FolderMenu/Settings/Icons/Setting[@Name='IconList']/Icon[" & $i + 1 & "]", "Path")
			$iIndex = _XMLGetAttrib("/FolderMenu/Settings/Icons/Setting[@Name='IconList']/Icon[" & $i + 1 & "]", "Index")
			$asIconIcon[$i] = $sPath & "," & $iIndex & "," & $iSize
		Next
	EndIf
EndFunc
Func ReadConfigMenu()
	Global $iMenuPositionX = ReadConfigSetting("/FolderMenu/Settings/Menus", "MenuPositionX", "0")
	Global $iMenuPositionY = ReadConfigSetting("/FolderMenu/Settings/Menus", "MenuPositionY", "0")
	Global $iMenuPosition = ReadConfigSetting("/FolderMenu/Settings/Menus", "MenuPosition", "0")

	Global $fTempShowFile = ReadConfigSetting("/FolderMenu/Settings/Menus", "TempShowFile", "0")
	Global $sTempShowFExt = ReadConfigSetting("/FolderMenu/Settings/Menus", "TempShowFExt", "*")
	Global $asTempShowFExt = StringSplit($sTempShowFExt, ",")
	Global $fAltFolderIcon = ReadConfigSetting("/FolderMenu/Settings/Menus", "AltFolderIcon", "1")
	Global $fBrowseMode = ReadConfigSetting("/FolderMenu/Settings/Menus", "BrowseMode", "0")
	Global $sTempDriveType = ReadConfigSetting("/FolderMenu/Settings/Menus", "TempDriveType", "Fixed")

	Global $fHideExt = ReadConfigSetting("/FolderMenu/Settings/Menus", "HideExt", "0")
	Global $fHideLnk = ReadConfigSetting("/FolderMenu/Settings/Menus", "HideLnk", "0")
	Global $fItemWarn = ReadConfigSetting("/FolderMenu/Settings/Menus", "ItemWarn", "1")

	Global $sDriveType = ReadConfigSetting("/FolderMenu/Settings/Menus", "DriveType", "Fixed")
	Global $fDriveReload = ReadConfigSetting("/FolderMenu/Settings/Menus", "DriveReload", "1")
	Global $fDriveFree = ReadConfigSetting("/FolderMenu/Settings/Menus", "DriveFree", "1")

	Global $sTCPathExe = ReadConfigSetting("/FolderMenu/Settings/Menus", "TCPathExe", "C:\totalcmd\totalcmd.exe")
	Global $sTCPathIni = ReadConfigSetting("/FolderMenu/Settings/Menus", "TCPathIni", "C:\totalcmd\wincmd.ini")
	Global $fTCAsMain = ReadConfigSetting("/FolderMenu/Settings/Menus", "TCAsMain", "0")
	Global $fTCSubmenu = ReadConfigSetting("/FolderMenu/Settings/Menus", "TCSubmenu", "1")

	Global $iSRecentSize = ReadConfigSetting("/FolderMenu/Settings/Menus", "SRecentSize", "16")
	If $iSRecentSize < 1 Then $iSRecentSize = 1
	Global $fSRecentDate = ReadConfigSetting("/FolderMenu/Settings/Menus", "SRecentDate", "0")
	Global $fSRecentIndex = ReadConfigSetting("/FolderMenu/Settings/Menus", "SRecentIndex", "1")
	Global $fSRecentFolder = ReadConfigSetting("/FolderMenu/Settings/Menus", "SRecentFolder", "0")
	Global $fSRecentFull = ReadConfigSetting("/FolderMenu/Settings/Menus", "SRecentFull", "1")

	Global $iRecentSize = ReadConfigSetting("/FolderMenu/Settings/Menus", "RecentSize", "16")
	If $iRecentSize < 1 Then $iRecentSize = 1
	Global $fRecentDate = ReadConfigSetting("/FolderMenu/Settings/Menus", "RecentDate", "0")
	Global $fRecentIndex = ReadConfigSetting("/FolderMenu/Settings/Menus", "RecentIndex", "1")
	Global $fRecentFolder = ReadConfigSetting("/FolderMenu/Settings/Menus", "RecentFolder", "0")
	Global $fRecentFull = ReadConfigSetting("/FolderMenu/Settings/Menus", "RecentFull", "1")
	Global $iRecentsCount = _XMLGetNodeCount("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']/Recent")
	Global $asRecentDate[$iRecentSize]
	Global $asRecentPath[$iRecentSize]
	;   Global $asRecentApp[$iRecentSize]
	If $iRecentsCount > 0 Then ; -1 error
		If $iRecentsCount > $iRecentSize Then $iRecentsCount = $iRecentSize
		For $i = 0 To $iRecentsCount - 1
			$asRecentDate[$i] = _XMLGetAttrib("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']/Recent[" & $i + 1 & "]", "Date")
			$asRecentPath[$i] = _XMLGetAttrib("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']/Recent[" & $i + 1 & "]", "Path")
			;           $asRecentApp[$i] = _XMLGetAttrib("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']/Recent[" & $i+1 & "]", "App")
		Next
	EndIf
EndFunc
Func ReadConfigOthers()
	Global $fStartWithWin = ReadConfigSetting("/FolderMenu/Settings/Others", "StartWithWin", "0")
	Global $fNoTray = ReadConfigSetting("/FolderMenu/Settings/Others", "NoTray", "0")
	Global $fAddFavAtTop = ReadConfigSetting("/FolderMenu/Settings/Others", "AddFavAtTop", "0")
	Global $fAddFavCheck = ReadConfigSetting("/FolderMenu/Settings/Others", "AddFavCheck", "0")
	Global $fAddFavSkipGui = ReadConfigSetting("/FolderMenu/Settings/Others", "AddFavSkipGui", "0")
	Global $fAddFavApp = ReadConfigSetting("/FolderMenu/Settings/Others", "AddFavApp", "1")
	Global $fAddFavAppCmd = ReadConfigSetting("/FolderMenu/Settings/Others", "AddFavAppCmd", "0")
	Global $fAddFavLnk = ReadConfigSetting("/FolderMenu/Settings/Others", "AddFavLnk", "1")
	Global $sFileManager = ReadConfigSetting("/FolderMenu/Settings/Others", "FileManager", "")
	Global $sBrowser = ReadConfigSetting("/FolderMenu/Settings/Others", "Browser", "")
	Global $fSearchSel = ReadConfigSetting("/FolderMenu/Settings/Others", "SearchSel", "0")
	Global $sSearchSelUrl = ReadConfigSetting("/FolderMenu/Settings/Others", "SearchSelUrl", "http://www.google.com/search?q=%s")
	Global $iLoadingTip = ReadConfigSetting("/FolderMenu/Settings/Others", "LoadingTip", "1")
	Global $iLoadingTipFor = ReadConfigSetting("/FolderMenu/Settings/Others", "LoadingTipFor", "31")
	; Global $iTrayIconClick    = ReadConfigSetting("/FolderMenu/Settings/Others", "TrayIconClick", "2")
	Global $fCheckVersion = ReadConfigSetting("/FolderMenu/Settings/Others", "CheckVersion", "1")
	Local $iVer = ReadConfigSetting("/FolderMenu/Settings/Others", "CurrentVer", "0")
	If $iVer < $iCurrentVer Then
		Local $sLang_NewVerUpdated_ = StringReplace($sLang_NewVerUpdated, "%CurrentVer%", $iCurrentVer)
		MsgBox($MB_ICONASTERISK, "FolderMenu3 EX", $sLang_NewVerUpdated_)
		_XMLDeleteNode("/FolderMenu/Settings/Others/Setting[@Name='CurrentVer']")
		WriteConfigSetting("/FolderMenu/Settings/Others", "CurrentVer", $iCurrentVer)
		_XMLTransform()
		_XMLSaveDoc("", 1)
	EndIf
EndFunc
Func ReadConfigGUI()
	Global $aGuiOptionsPos[4]
	$aGuiOptionsPos[0] = ReadConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosX", "")
	$aGuiOptionsPos[1] = ReadConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosY", "")
	$aGuiOptionsPos[2] = ReadConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosW", "")
	$aGuiOptionsPos[3] = ReadConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosH", "")
	Global $fGuiOptionsMax = ReadConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosM", "")
EndFunc
Func ReadConfigSetting($sXPath, $sName, $sDefault)
	Local $sValue = _XMLGetAttrib($sXPath & "/Setting[@Name='" & $sName & "']", "Value")
	If $sValue = "" Or @error Then
		Return $sDefault
	Else
		Return $sValue
	EndIf
EndFunc

Func SetConfig()
	Global $iAppsCountC = 0
	Global $iAppsCountM = 0
	If $iAppsCount > 0 Then
		Local $asAppClassTemp[1] ; for CSV
		Global $asAppClassC[$iAppsCount], $asAppClassNNC[$iAppsCount]
		Global $asAppClassM[$iAppsCount], $asAppClassNNM[$iAppsCount]
		For $i = 0 To $iAppsCount - 1
			If $afAppCheck[$i] = 1 Then ; if enabled
				$asAppClassTemp = StringSplit($asAppClass[$i], ",") ; split CSV
				For $j = 1 To $asAppClassTemp[0]
					If $asAppType[$i] = "C" Then ; contain
						If UBound($asAppClassC) <= $iAppsCountC Then
							ReDim $asAppClassC[UBound($asAppClassC) * 2]
							ReDim $asAppClassNNC[UBound($asAppClassNNC) * 2]
						EndIf
						$asAppClassC[$iAppsCountC] = $asAppClassTemp[$j]
						$asAppClassNNC[$iAppsCountC] = $asAppClassNN[$i]
						$iAppsCountC += 1
					Else ; match
						If UBound($asAppClassM) <= $iAppsCountM Then
							ReDim $asAppClassM[UBound($asAppClassM) * 2]
							ReDim $asAppClassNNM[UBound($asAppClassNNM) * 2]
						EndIf
						$asAppClassM[$iAppsCountM] = $asAppClassTemp[$j]
						$asAppClassNNM[$iAppsCountM] = $asAppClassNN[$i]
						$iAppsCountM += 1
					EndIf
				Next
			EndIf
		Next
		; Trim unused slots
		If $iAppsCountC > 0 Then
			ReDim $asAppClassC[$iAppsCountC]
			ReDim $asAppClassNNC[$iAppsCountC]
		EndIf
		If $iAppsCountM > 0 Then
			ReDim $asAppClassM[$iAppsCountM]
			ReDim $asAppClassNNM[$iAppsCountM]
		EndIf
	EndIf

	Opt('TrayIconHide', $fNoTray)

	If $fStartWithWin = 1 Then
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "FolderMenu", "REG_SZ", @ScriptFullPath)
	Else
		RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "FolderMenu")
	EndIf

	If $iIconsCount > 0 Then
		For $i = 0 To $iIconsCount - 1
			Assign("sIconPath" & TrimVarName($asIconExt[$i]), $asIconIcon[$i], 2)
		Next
	EndIf

	Global $fLoadingTipForM = BitAND($iLoadingTipFor, 1) ; main
	Global $fLoadingTipForT = BitAND($iLoadingTipFor, 2) ; temp
	Global $fLoadingTipForR = BitAND($iLoadingTipFor, 4) ; recent
	Global $fLoadingTipForD = BitAND($iLoadingTipFor, 8) ; drive
	Global $fLoadingTipForC = BitAND($iLoadingTipFor, 16) ; tc

	Global $COMMANDER_PATH = StringReplace($sTCPathExe, "totalcmd.exe", "")
EndFunc

Func SetHotkey()
	; if $iTrayIconClick = 1 then
	; HotKeySet("#!+^x", "_ShowMainMenu1")
	; TraySetOnEvent($TRAY_EVENT_PRIMARYUP,"_ShowMainMenu1")
	; elseif $iTrayIconClick = 1.5 then
	; HotKeySet("#!+^x", "_ShowMainMenu15")
	; TraySetOnEvent($TRAY_EVENT_PRIMARYUP,"_ShowMainMenu15")
	; elseif $iTrayIconClick = 2 then
	HotKeySet("#!+^x", "_ShowMainMenu2")
	TraySetOnEvent($TRAY_EVENT_PRIMARYUP, "_ShowMainMenu2")
	; endif

	Local $iKey, $sFunc, $sName
	; disable old
	If $iHotkeysCountO > 0 Then
		For $i = 0 To $iHotkeysCountO - 1
			HotKeySetVKey($aiHotkeyKeyO[$i])
		Next
	EndIf
	; set new
	$iHotkeysCountO = $iHotkeysCount
	If $iHotkeysCount > 0 Then
		ReDim $aiHotkeyKeyO[$iHotkeysCountO]
		For $i = 0 To $iHotkeysCount - 1
			$iKey = $aiHotkeyKey[$i]
			$sFunc = $asHotkeyFunc[$i]
			$sName = HotkeyFunc2Name($sFunc)
			If $sName = "" Then
				Local $sLang_ErrHotkey_
				$sLang_ErrHotkey_ = StringReplace($sLang_ErrHotkey, "[%HotkeyName%]", "")
				$sLang_ErrHotkey_ = StringReplace($sLang_ErrHotkey_, "%HotkeyKey%", _KeyToStr($iKey))
				$sErrorMsg &= $sLang_ErrHotkey_ & @LF
			Else
				$aiHotkeyKeyO[$i] = $iKey
				HotKeySetVKey($iKey, $sFunc)
				If @error And $iKey <> 0 Then
					Local $sLang_ErrHotkey_
					$sLang_ErrHotkey_ = StringReplace($sLang_ErrHotkey, "%HotkeyName%", $sName)
					$sLang_ErrHotkey_ = StringReplace($sLang_ErrHotkey_, "%HotkeyKey%", _KeyToStr($iKey))
					$sErrorMsg &= $sLang_ErrHotkey_ & @LF
				EndIf
			EndIf
		Next
	EndIf

	Return
EndFunc
Func HotKeySetVKey($iKey, $sFunc = "")
	#cs
		0-7   - Specifies the virtual-key (VK) code of the key.
		8     - SHIFT key
		9     - CONTROL key
		10    - ALT key
		11    - WIN key
		12    - Double click
		13    - Native function
		14-15 - Not used
	#ce
	Local $fDouble = BitAND($iKey, 0x1000)
	Local $fNative = BitAND($iKey, 0x2000)
	$iKey = BitAND($iKey, 0x0FFF)

	; 1 2 4 5 6 are mouse buttons
	If BitAND($iKey, 0xFF) > 0 And BitAND($iKey, 0xFF) < 7 Then
		If $fDouble = 0 Then
			AsyncHotKeySet($iKey, $sFunc, 0, 4) ; on main key up
			Return SetError(@error, 0, 0)
		Else
			Assign("HotkeyFunc" & $iKey, $sFunc, 2)
			AsyncHotKeySet($iKey, "HotkeyDoubleClick", 1, 1) ; on key down
			Return SetError(@error, 0, 0)
		EndIf
	EndIf

	Local $iFlag = $HK_FLAG_DEFAULT
	If $fNative <> 0 Then $iFlag = BitOR($iFlag, $HK_FLAG_NOBLOCKHOTKEY)

	If $fDouble = 0 Then
		_HotKeyAssign($iKey, $sFunc, $iFlag)
		Return SetError(@error, 0, 0)
	Else
		$iFlag = BitOR($iFlag, $HK_FLAG_EXTENDEDCALL, $HK_FLAG_POSTCALL)
		Assign("HotkeyFunc" & $iKey, $sFunc, 2)
		_HotKeyAssign($iKey, "HotkeyDoublePress", $iFlag)
		Return SetError(@error, 0, 0)
	EndIf
EndFunc
Func HotkeyDoubleClick($iKey)
	Local $iTimeDiff = TimerDiff($iPriorMouseTime)
	If $iPriorKey = $iKey And $iTimeDiff < 250 Then ;and $iTimeDiff > 20 then ; > 20 to prevent poll calls this twice within 10ms
		If $iKey = 1 And $iPriorKeySel <> "" Then Return ; double click on a file
		Call(Eval("HotkeyFunc" & $iKey))
	EndIf
	$iPriorKey = $iKey
	If _WinAPI_GetClassName(WinGetHandle("[ACTIVE]")) = "CabinetWClass" Then
		If $sOSVersion = "WIN_VISTA" Then
			$iPriorKeySel = ""
			; Local $oWindow = GetShellWindowObj(WinGetHandle("[ACTIVE]"))
			; if IsObj($oWindow) then
			; $iPriorKeySel = $oWindow.Document.SelectedItems.Count
			; if $iPriorKeySel = 0 then $iPriorKeySel = ""
			; endif
		Else
			$iPriorKeySel = ControlListView("[ACTIVE]", "", "SysListView321", "GetSelected")
		EndIf
	EndIf
	$iPriorMouseTime = TimerInit()
EndFunc
Func HotkeyDoublePress($iKey)
	If $iKey > 0 Then
		Local $iTimeDiff = TimerDiff($iPriorKeyTime)
		If ($iPriorKeyTime) And ($iTimeDiff < 250) Then
			Call(Eval("HotkeyFunc" & $iKey))
			$iPriorKeyTime = 0
			Return
		EndIf
		$iPriorKeyTime = TimerInit()
	EndIf
EndFunc
Func HotkeyFunc2Name($sFunc)
	Switch $sFunc
		Case "_ShowMainMenu1"
			Return $sLang_ShowMenu & " 1"
		Case "_ShowMainMenu15"
			Return $sLang_ShowMenu & " 1.5"
		Case "_ShowMainMenu2"
			Return $sLang_ShowMenu & " 2"
		Case "_OpenSel"
			Return $sLang_OpenSelText
		Case "_AddApp"
			Return $sLang_AddApp
		Case "_GoWebsite"
			Return $sLang_Website
		Case "_CheckUpdate"
			Return $sLang_CheckVer
		Case "_AddFavorite"
			Return $sLang_AddFavorite
		Case "_Reload"
			Return $sLang_Reload
		Case "_Options"
			Return $sLang_Options
		Case "_Edit"
			Return $sLang_EditConfig
		Case "_Exit"
			Return $sLang_Exit
		Case "_ToggleHidden"
			Return $sLang_ToggleHidden
		Case "_ToggleFileExt"
			Return $sLang_ToggleFileExt
		Case "_SystemRecent"
			Return $sLang_SystemRecent
		Case "_RecentMenu"
			Return $sLang_RecentMenu
		Case "_ExplorerMenu"
			Return $sLang_ExplorerMenu
		Case "_DriveMenu"
			Return $sLang_DriveMenu
		Case "_ToolMenu"
			Return $sLang_ToolMenu
		Case "_SVSMenu"
			Return $sLang_SVSMenu
		Case "_TCMenu"
			Return $sLang_TCMenu
		Case Else
			Return ""
	EndSwitch
EndFunc
Func HotkeyName2Func($sName)
	Switch $sName
		Case $sLang_ShowMenu & " 1"
			Return "_ShowMainMenu1"
		Case $sLang_ShowMenu & " 1.5"
			Return "_ShowMainMenu15"
		Case $sLang_ShowMenu & " 2"
			Return "_ShowMainMenu2"
		Case $sLang_OpenSelText
			Return "_OpenSel"
		Case $sLang_AddApp
			Return "_AddApp"
		Case $sLang_Website
			Return "_GoWebsite"
		Case $sLang_CheckVer
			Return "_CheckUpdate"
		Case $sLang_AddFavorite
			Return "_AddFavorite"
		Case $sLang_Reload
			Return "_Reload"
		Case $sLang_Options
			Return "_Options"
		Case $sLang_EditConfig
			Return "_Edit"
		Case $sLang_Exit
			Return "_Exit"
		Case $sLang_ToggleHidden
			Return "_ToggleHidden"
		Case $sLang_ToggleFileExt
			Return "_ToggleFileExt"
		Case $sLang_SystemRecent
			Return "_SystemRecent"
		Case $sLang_RecentMenu
			Return "_RecentMenu"
		Case $sLang_ExplorerMenu
			Return "_ExplorerMenu"
		Case $sLang_DriveMenu
			Return "_DriveMenu"
		Case $sLang_ToolMenu
			Return "_ToolMenu"
		Case $sLang_SVSMenu
			Return "_SVSMenu"
		Case $sLang_TCMenu
			Return "_TCMenu"
		Case Else
			Return ""
	EndSwitch
EndFunc

#endregion Settings

#region Create Menu
Func CreateTrayMenu()
	Global $hTrayMenu = TrayItemGetHandle(0)
	While _GUICtrlMenu_DeleteMenu($hTrayMenu, 0)
	WEnd
	CreateTrayMenuItem($sLang_ToolWebsite, "_GoWebsite", GetIcon("_GoWebsite"))
	TrayCreateItem("")
	CreateTrayMenuItem($sLang_ToolAdd, "_AddFavorite", GetIcon("_AddFavorite"))
	TrayCreateItem("")
	CreateTrayMenuItem($sLang_ToolReload, "_Reload", GetIcon("_Reload"))
	CreateTrayMenuItem($sLang_ToolOption, "_Options", GetIcon("_Options"))
	CreateTrayMenuItem($sLang_ToolEdit, "_Edit", GetIcon("_Edit"))
	TrayCreateItem("")
	CreateTrayMenuItem($sLang_ToolExit, "_Exit", GetIcon("_Exit"))
	_GUICtrlMenu_SetMenuStyle($hTrayMenu, $MNS_CHECKORBMP)
EndFunc
Func CreateTrayMenuItem($sItemName, $sItemFunc, $sItemIcon)
	Local $iItemID = TrayCreateItem($sItemName)
	TrayItemSetOnEvent($iItemID, $sItemFunc)
	SetMenuItemIcon($hTrayMenu, $iItemID, $sItemFunc, $sItemIcon)
	Return $iItemID
EndFunc

Func CreateMainMenu()
	If $fLoadingTipForM <> 0 Then $sLoadingTipText = $sLang_LoadFav
	LoadingTip()
	While _GUICtrlMenu_DeleteMenu(GUICtrlGetHandle($iMainMenuID), 0)
	WEnd

	If $fTCAsMain = 1 Then
		CreateTCMenu($iMainMenuID)
	Else
		Global $iFavoriteCount = _XMLGetNodeCount("/FolderMenu/Menu//Item")
		If $iFavoriteCount > 0 Then
			Global $asFavorite[$iFavoriteCount][2]
			$iFavoriteCount = 0
			CreateMenuXML($iMainMenuID, "/FolderMenu/Menu")
			ReDim $asFavorite[$iFavoriteCount][2]
		EndIf
	EndIf

	$sLoadingTipText = ""
	LoadingTip()
	Return
EndFunc
Func CreateMenuXML($iMenuID, $sXPath)
	Local $fNewColumn = 0
	Local $iItemCount = _XMLGetNodeCount($sXPath & "/Item")
	If $iItemCount < 1 Then Return
	Local $iItemID, $sItemType, $sItemName, $sItemPath, $sItemIcon, $iItemSize, $iItemDepth, $sItemFile, $sItemExt, $sItemDrive
	For $i = 1 To $iItemCount
		$sItemType = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Type")
		$sItemName = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Name")
		If $sItemName = "" Then $sItemName = "[No Name]"
		If $sItemType = "Separator" Then
			GUICtrlCreateMenuItem("", $iMenuID)
		ElseIf $sItemType = "ColSeparator" Then
			$fNewColumn = 1
		ElseIf $sItemType = "Item" Then
			$sItemPath = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Path")
			$sItemIcon = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Icon")
			$iItemSize = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Size")
			If StringRight($sItemPath, 1) = "\" Then $sItemPath = StringTrimRight($sItemPath, 1)
			$asFavorite[$iFavoriteCount][0] = $sItemName
			$asFavorite[$iFavoriteCount][1] = $sItemPath
			$iFavoriteCount += 1
			If StringLeft($sItemPath, 1) = ":" And StringLeft($sItemPath, 2) <> "::" Then ; special menu item
				$iItemID = GUICtrlCreateMenu($sItemName, $iMenuID) ; create submenu
				Switch $sItemPath
					Case ":RecentMenu"
						If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iRecentMenuID)) = -1 Then
							$iRecentMenuID = CreateRecentMenu($iItemID)
						Else
							_GUICtrlMenu_SetItemSubMenu(GUICtrlGetHandle($iMenuID), $iItemID, GUICtrlGetHandle($iRecentMenuID), False)
						EndIf
					Case ":ExplorerMenu"
						If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iExplorerMenuID)) = -1 Then
							$iExplorerMenuID = CreateExplorerMenu($iItemID)
						Else
							_GUICtrlMenu_SetItemSubMenu(GUICtrlGetHandle($iMenuID), $iItemID, GUICtrlGetHandle($iExplorerMenuID), False)
						EndIf
					Case ":DriveMenu"
						If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iDriveMenuID)) = -1 Then
							$iDriveMenuID = CreateDriveMenu($iItemID)
						Else
							_GUICtrlMenu_SetItemSubMenu(GUICtrlGetHandle($iMenuID), $iItemID, GUICtrlGetHandle($iDriveMenuID), False)
						EndIf
					Case ":ToolMenu"
						If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iToolMenuID)) = -1 Then ; first time create this menu
							$iToolMenuID = CreateToolMenu($iItemID)
						Else
							_GUICtrlMenu_SetItemSubMenu(GUICtrlGetHandle($iMenuID), $iItemID, GUICtrlGetHandle($iToolMenuID), False)
						EndIf
					Case ":SVSMenu"
						If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iSVSMenuID)) = -1 Then
							$iSVSMenuID = CreateSVSMenu($iItemID)
						Else
							_GUICtrlMenu_SetItemSubMenu(GUICtrlGetHandle($iMenuID), $iItemID, GUICtrlGetHandle($iSVSMenuID), False)
						EndIf
					Case ":TCMenu"
						If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iTCMenuID)) = -1 Then
							If $fTCSubmenu = 1 Then
								$iTCMenuID = CreateTCMenu($iItemID)
							Else
								_GUICtrlMenu_DeleteMenu(GUICtrlGetHandle($iMenuID), $iItemID, False)
								CreateTCItem($iMenuID)
							EndIf
						Else
							_GUICtrlMenu_SetItemSubMenu(GUICtrlGetHandle($iMenuID), $iItemID, GUICtrlGetHandle($iTCMenuID), False)
						EndIf
					Case Else
						Local $sErrSpecial
						$sErrSpecial = StringReplace($sLang_ErrSpecial, "%ItemPath%", $sItemPath)
						$sErrorMsg &= $sErrSpecial & @LF
				EndSwitch
				SetMenuItemIcon($iMenuID, $iItemID, $sItemPath, $sItemIcon, $iItemSize)
			Else
				$iItemID = CreateMenuItem($iMenuID, $sItemName, $sItemPath, $sItemIcon, $iItemSize)
				If $sItemPath = "_AddHere" Then Assign("iMenu" & $iItemID, $iMenuID, 2)
			EndIf
			If $fNewColumn = 1 Then
				_GUICtrlMenu_SetItemType(GUICtrlGetHandle($iMenuID), $iItemID, $MFT_MENUBARBREAK, False)
				$fNewColumn = 0
			EndIf
		ElseIf $sItemType = "ItemMenu" Then
			$sItemPath = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Path")
			$sItemIcon = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Icon")
			$iItemSize = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Size")
			$iItemDepth = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Depth")
			$sItemFile = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "File")
			$sItemExt = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Ext")
			$sItemDrive = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Drive")
			$asFavorite[$iFavoriteCount][0] = $sItemName
			$asFavorite[$iFavoriteCount][1] = $sItemPath
			$iFavoriteCount += 1
			If IsFolder($sItemPath) Then
				$iItemID = GUICtrlCreateMenu($sItemName, $iMenuID)
				SetMenuItemIcon($iMenuID, $iItemID, $sItemPath, $sItemIcon, $iItemSize)
				CreateItemMenu($iItemID, $sItemPath, $sItemFile, $sItemExt, $sItemDrive, $iItemDepth)
			Else
				CreateMenuItem($iMenuID, $sItemName, $sItemPath, $sItemIcon, $iItemSize)
			EndIf
			If $fNewColumn = 1 Then
				_GUICtrlMenu_SetItemType(GUICtrlGetHandle($iMenuID), $iItemID, $MFT_MENUBARBREAK, False)
				$fNewColumn = 0
			EndIf
		ElseIf $sItemType = "Menu" Then
			$sItemIcon = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Icon")
			$iItemSize = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Size")
			$iItemID = GUICtrlCreateMenu($sItemName, $iMenuID)
			Assign("iMenu" & $iItemID, $iMenuID, 2) ; for _AddHere
			SetMenuItemIcon($iMenuID, $iItemID, "Menu", $sItemIcon, $iItemSize)
			CreateMenuXML($iItemID, $sXPath & "/Item[" & $i & "]")
			If $fNewColumn = 1 Then
				_GUICtrlMenu_SetItemType(GUICtrlGetHandle($iMenuID), $iItemID, $MFT_MENUBARBREAK, False)
				$fNewColumn = 0
			EndIf
		EndIf
	Next
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iMenuID), $MNS_CHECKORBMP)
	Return
EndFunc
Func CreateItemMenu($iMenuID, $sPath, $fShowFile, $sShowFExt, $sDriveType, $iMaxDepth = 1, $iDepth = 1)
	If Not IsFolder($sPath) Then Return 0 ; not a folder
	$sPath = DerefPath($sPath)

	If $iMaxDepth = "" Then $iMaxDepth = 1

	CreateMenuItem($iMenuID, "[Open]", $sPath)
	GUICtrlCreateMenuItem("", $iMenuID)

	If $sPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" Then ; Computer, list HDDs
		Local $aDriveList = DriveGetDrive($sDriveType)
		If @error Then
			GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iMenuID), $GUI_DISABLE)
		Else
			Local $fEmpty = True
			For $i = 1 To $aDriveList[0]
				Local $nTotal = DriveSpaceTotal($aDriveList[$i])
				If Not @error Then
					$fEmpty = False
					Local $nFree = DriveSpaceFree($aDriveList[$i])
					Local $sName = DriveGetLabel($aDriveList[$i]) & " (" & StringUpper($aDriveList[$i]) & ")    "
					$sName &= Round($nFree / 1024, 1) & "GB/" & Round($nTotal / 1024, 1) & "GB    "
					$sName &= Round(100 * $nFree / $nTotal, 1) & "% Free"
					If $iDepth < $iMaxDepth Then ;or $iMaxDepth = 0 then
						Local $iSubMenuID = GUICtrlCreateMenu($sName, $iMenuID)
						SetMenuItemIcon($iMenuID, $iSubMenuID, $aDriveList[$i])
						CreateItemMenu($iSubMenuID, $aDriveList[$i], $fShowFile, $sShowFExt, $sDriveType, $iMaxDepth, $iDepth + 1)
					Else
						CreateMenuItem($iMenuID, $sName, StringUpper($aDriveList[$i]))
					EndIf
				EndIf
			Next
			If $fEmpty Then
				GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iMenuID), $GUI_DISABLE)
			EndIf
		EndIf
		Return 1
	EndIf

	Local $hSearch = FileFindFirstFile($sPath & "\*")
	If $hSearch = -1 Then ; search failed
		GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iMenuID), $GUI_DISABLE)
		FileClose($hSearch)
		Return 1
	EndIf

	Local $sFile, $iFileCount = 0, $iFolderCount = 0, $asFolderList[1]
	While 1
		$sFile = FileFindNextFile($hSearch)
		If @error Then ExitLoop
		If StringInStr(FileGetAttrib($sPath & "\" & $sFile), "D") Then
			If UBound($asFolderList) <= $iFolderCount Then ReDim $asFolderList[UBound($asFolderList) * 2]
			$asFolderList[$iFolderCount] = $sFile
			$iFolderCount += 1
		EndIf
	WEnd
	FileClose($hSearch)
	If $iFolderCount <> 0 Then ReDim $asFolderList[$iFolderCount] ; Trim unused slots
	_ArraySort($asFolderList)

	If $fShowFile = 1 Then
		Local $sFile, $asFileList[1], $asShowFExt = StringSplit($sShowFExt, ",")
		For $i = 1 To $asShowFExt[0]
			Local $hSearch = FileFindFirstFile($sPath & "\*." & $asShowFExt[$i])
			If $hSearch = -1 Then ; search failed
				FileClose($hSearch)
				ContinueLoop
			EndIf
			While 1
				$sFile = FileFindNextFile($hSearch)
				If @error Then ExitLoop
				If StringInStr(FileGetAttrib($sPath & "\" & $sFile), "D") Then ContinueLoop
				If UBound($asFileList) <= $iFileCount Then ReDim $asFileList[UBound($asFileList) * 2]
				$asFileList[$iFileCount] = $sFile
				$iFileCount += 1
			WEnd
			FileClose($hSearch)
		Next
		If $iFileCount <> 0 Then ReDim $asFileList[$iFileCount]
		_ArraySort($asFileList)
	EndIf

	If $iFolderCount = 0 Then
		If $iFileCount = 0 Or $fShowFile = 0 Then
			GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iMenuID), $GUI_DISABLE)
			Return 1
		EndIf
	EndIf

	Local $iCount = 1
	For $sItem In $asFolderList
		If $sItem = "" Then ContinueLoop
		If $iCount = 500 And $fItemWarn = 1 Then
			Local $sLang_TooManyItems_ = $sPath & @LF & @LF & StringReplace($sLang_TooManyItems, "%ItemCount%", $iFolderCount)
			If MsgBox($MB_YESNO + $MB_ICONEXCLAMATION + $MB_DEFBUTTON2, $sLang_Warning & " - FolderMenu3 EX", $sLang_TooManyItems_) <> $IDYES Then ExitLoop
		EndIf

		If $iDepth < $iMaxDepth Then ; or $iMaxDepth = 0 then
			Local $iSubMenuID = GUICtrlCreateMenu($sItem, $iMenuID)
			SetMenuItemIcon($iMenuID, $iSubMenuID, $sPath & "\" & $sItem)
			CreateItemMenu($iSubMenuID, $sPath & "\" & $sItem, $fShowFile, $sShowFExt, $sDriveType, $iMaxDepth, $iDepth + 1)
		Else
			CreateMenuItem($iMenuID, $sItem, $sPath & "\" & $sItem)
		EndIf
		$iCount += 1
	Next

	If $fShowFile = 1 Then
		If $iFolderCount <> 0 And $iFileCount <> 0 Then GUICtrlCreateMenuItem("", $iMenuID) ; separator between folder & file
		$iCount = 1
		For $sItem In $asFileList
			If $iCount = 500 And $fItemWarn = 1 Then
				Local $sLang_TooManyItems_ = $sPath & @LF & @LF & StringReplace($sLang_TooManyItems, "%ItemCount%", $iFileCount)
				If MsgBox($MB_YESNO + $MB_ICONEXCLAMATION + $MB_DEFBUTTON2, $sLang_Warning & " - FolderMenu3 EX", $sLang_TooManyItems_) <> $IDYES Then ExitLoop
			EndIf
			If $sItem <> "" Then CreateMenuItem($iMenuID, $sItem, $sPath & "\" & $sItem)
			$iCount += 1
		Next
	EndIf

	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iMenuID), $MNS_CHECKORBMP)
	Return 1
EndFunc

Func CreateTempMenu($sPath, $fShowFile) ; return 1 on success
	If Not IsFolder($sPath) Then Return 0 ; not a folder

	$hGuiTemp = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST, $WS_EX_MDICHILD), $hGuiMain)
	GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "MenuSecondaryDown", $hGuiTemp)
	$iTempMenuID = GUICtrlCreateContextMenu()

	If $sPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" Then ; Computer, list HDDs
		CreateMenuItem($iTempMenuID, $sLang_Computer, $sPath)
		GUICtrlCreateMenuItem("", $iTempMenuID)
		If $fLoadingTipForT <> 0 Then LoadingTip($sLang_LoadTemp)
		Local $aDriveList = DriveGetDrive($sTempDriveType)
		If @error Then
			GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iTempMenuID), $GUI_DISABLE)
		Else
			Local $fEmpty = True
			For $i = 1 To $aDriveList[0]
				Local $nTotal = DriveSpaceTotal($aDriveList[$i])
				If Not @error Then
					$fEmpty = False
					Local $nFree = DriveSpaceFree($aDriveList[$i])
					Local $sName = DriveGetLabel($aDriveList[$i]) & " (" & StringUpper($aDriveList[$i]) & ")    "
					$sName &= Round($nFree / 1024, 1) & "GB/" & Round($nTotal / 1024, 1) & "GB    "
					$sName &= Round(100 * $nFree / $nTotal, 1) & "% Free"
					CreateMenuItem($iTempMenuID, $sName, StringUpper($aDriveList[$i]))
				EndIf
			Next
			If $fEmpty Then
				GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iTempMenuID), $GUI_DISABLE)
			EndIf
		EndIf
		LoadingTip()
		Return 1
	EndIf

	If StringRight($sPath, 1) = ":" Then ; drive
		CreateMenuItem($iTempMenuID, "&..\", "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
	Else
		Local $sDrive, $sDir, $sFName, $sExt
		_PathSplit($sPath, $sDrive, $sDir, $sFName, $sExt)
		If StringRight($sDir, 1) = "\" Then $sDir = StringTrimRight($sDir, 1)
		CreateMenuItem($iTempMenuID, "&..\", $sDrive & $sDir)
	EndIf
	CreateMenuItem($iTempMenuID, "& " & $sPath, $sPath)
	GUICtrlCreateMenuItem("", $iTempMenuID)

	Local $hSearch = FileFindFirstFile($sPath & "\*")
	If $hSearch = -1 Then ; search failed
		GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iTempMenuID), $GUI_DISABLE)
		FileClose($hSearch)
		Return 1
	EndIf

	If $fLoadingTipForT <> 0 Then LoadingTip($sLang_LoadTemp)
	Local $sFile, $iFileCount = 0, $iFolderCount = 0, $asFolderList[1]
	While 1
		$sFile = FileFindNextFile($hSearch)
		If @error Then ExitLoop
		If StringInStr(FileGetAttrib($sPath & "\" & $sFile), "D") Then
			If UBound($asFolderList) <= $iFolderCount Then ReDim $asFolderList[UBound($asFolderList) * 2]
			$asFolderList[$iFolderCount] = $sFile
			$iFolderCount += 1
		EndIf
	WEnd
	FileClose($hSearch)
	If $iFolderCount <> 0 Then ReDim $asFolderList[$iFolderCount] ; Trim unused slots
	_ArraySort($asFolderList)

	If $fShowFile = 1 Then
		Local $sFile, $asFileList[1]
		For $i = 1 To $asTempShowFExt[0]
			Local $hSearch = FileFindFirstFile($sPath & "\*." & $asTempShowFExt[$i])
			If $hSearch = -1 Then ; search failed
				FileClose($hSearch)
				ContinueLoop
			EndIf
			While 1
				$sFile = FileFindNextFile($hSearch)
				If @error Then ExitLoop
				If StringInStr(FileGetAttrib($sPath & "\" & $sFile), "D") Then ContinueLoop
				If UBound($asFileList) <= $iFileCount Then ReDim $asFileList[UBound($asFileList) * 2]
				$asFileList[$iFileCount] = $sFile
				$iFileCount += 1
			WEnd
			FileClose($hSearch)
		Next
		If $iFileCount <> 0 Then ReDim $asFileList[$iFileCount]
		_ArraySort($asFileList)
	EndIf

	If $iFolderCount = 0 Then
		If $iFileCount = 0 Or $fShowFile = 0 Then
			GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iTempMenuID), $GUI_DISABLE)
			LoadingTip()
			Return 1
		EndIf
	EndIf

	Local $iCount = 1
	For $sItem In $asFolderList
		If $sItem = "" Then ContinueLoop
		If $iCount = 500 And $fItemWarn = 1 Then
			Local $sLang_TooManyItems_ = StringReplace($sLang_TooManyItems, "%ItemCount%", $iFolderCount)
			If MsgBox($MB_YESNO + $MB_ICONEXCLAMATION + $MB_DEFBUTTON2, $sLang_Warning & " - FolderMenu3 EX", $sLang_TooManyItems_) <> $IDYES Then ExitLoop
		EndIf
		If $fAltFolderIcon = 1 Then
			Local $fHasSubfolder = False, $sFile
			$hSearch = FileFindFirstFile($sPath & "\" & $sItem & "\*.*")
			If $hSearch <> -1 Then
				While 1
					$sFile = FileFindNextFile($hSearch)
					If @error Then ExitLoop
					If StringInStr(FileGetAttrib($sPath & "\" & $sItem & "\" & $sFile), "D") Then
						$fHasSubfolder = True
						ExitLoop
					EndIf
				WEnd
			EndIf
			If $fHasSubfolder Then
				CreateMenuItem($iTempMenuID, $sItem, $sPath & "\" & $sItem, GetIcon("FolderS"))
			Else
				CreateMenuItem($iTempMenuID, $sItem, $sPath & "\" & $sItem)
			EndIf
		Else
			CreateMenuItem($iTempMenuID, $sItem, $sPath & "\" & $sItem)
		EndIf
		$iCount += 1
	Next

	If $fShowFile = 1 Then
		If $iFolderCount <> 0 And $iFileCount <> 0 Then GUICtrlCreateMenuItem("", $iTempMenuID) ; separator between folder & file
		$iCount = 0
		For $sItem In $asFileList
			If $iCount = 500 And $fItemWarn = 1 Then
				Local $sLang_TooManyItems_ = StringReplace($sLang_TooManyItems, "%ItemCount%", $iFileCount)
				If MsgBox($MB_YESNO + $MB_ICONEXCLAMATION + $MB_DEFBUTTON2, $sLang_Warning & " - FolderMenu3 EX", $sLang_TooManyItems_) <> $IDYES Then ExitLoop
			EndIf
			If $sItem <> "" Then CreateMenuItem($iTempMenuID, $sItem, $sPath & "\" & $sItem)
			$iCount += 1
		Next
	EndIf

	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iTempMenuID), $MNS_CHECKORBMP)

	LoadingTip()
	Return 1
EndFunc

Func CreateToolMenu($iMenuID)
	While _GUICtrlMenu_DeleteMenu(GUICtrlGetHandle($iMenuID), 0)
	WEnd
	CreateMenuItem($iMenuID, $sLang_ToolWebsite, "_GoWebsite", GetIcon("_GoWebsite"))
	GUICtrlCreateMenuItem("", $iMenuID)
	CreateMenuItem($iMenuID, $sLang_ToolAdd, "_AddFavorite", GetIcon("_AddFavorite"))
	GUICtrlCreateMenuItem("", $iMenuID)
	CreateMenuItem($iMenuID, $sLang_ToolReload, "_Reload", GetIcon("_Reload"))
	CreateMenuItem($iMenuID, $sLang_ToolOption, "_Options", GetIcon("_Options"))
	CreateMenuItem($iMenuID, $sLang_ToolEdit, "_Edit", GetIcon("_Edit"))
	GUICtrlCreateMenuItem("", $iMenuID)
	CreateMenuItem($iMenuID, $sLang_ToolExit, "_Exit", GetIcon("_Exit"))
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iMenuID), $MNS_CHECKORBMP)
	Return $iMenuID
EndFunc

Func CreateRecentMenu($iMenuID)
	If $fLoadingTipForR Then LoadingTip($sLang_LoadRecent)

	While _GUICtrlMenu_DeleteMenu(GUICtrlGetHandle($iMenuID), 0)
	WEnd
	If $asRecentPath[0] <> "" Then
		Local $sDrive, $sDir, $sName, $sExt
		For $i = 0 To $iRecentSize - 1
			If $asRecentPath[$i] = "" Then ContinueLoop
			_PathSplit($asRecentPath[$i], $sDrive, $sDir, $sName, $sExt)
			If $fRecentIndex = 0 And $sName <> "" Then $sName = "&" & $sName
			If $fRecentFull = 1 Then $sName = $sDrive & $sDir & $sName
			If $fHideExt = 0 Then
				If $fHideLnk = 0 Then ; show all ext
					$sName &= $sExt
				Else ; show ext but hide .lnk .url
					If $sExt <> ".lnk" And $sExt <> ".url" Then $sName &= $sExt
				EndIf
			EndIf
			If $sName = "" Then $sName = $asRecentPath[$i]
			If $fRecentDate = 1 Then $sName &= @TAB & $asRecentDate[$i]
			If $fRecentIndex = 1 Then
				If $i < 10 Then
					$sName = "&" & $i & "    " & $sName
				Else
					$sName = "&" & Chr(87 + $i) & "    " & $sName
				EndIf
			EndIf
			CreateMenuItem($iMenuID, $sName, $asRecentPath[$i])
		Next
		GUICtrlCreateMenuItem("", $iMenuID)
		If $fRecentIndex = 1 Then
			CreateMenuItem($iMenuID, "&r    " & $sLang_ClearRecent, "_ClearRecent", GetIcon("_ClearRecent"))
		Else
			If StringInStr($sLang_ClearRecent, "R", 1) Then
				CreateMenuItem($iMenuID, StringReplace($sLang_ClearRecent, "R", "&R", 1, 1), "_ClearRecent", GetIcon("_ClearRecent"))
			ElseIf StringInStr($sLang_ClearRecent, "r", 1) Then
				CreateMenuItem($iMenuID, StringReplace($sLang_ClearRecent, "r", "&r", 1, 1), "_ClearRecent", GetIcon("_ClearRecent"))
			Else
				CreateMenuItem($iMenuID, $sLang_ClearRecent & "(&R)", "_ClearRecent", GetIcon("_ClearRecent"))
			EndIf
		EndIf
		GUICtrlCreateMenuItem("", $iMenuID)
	EndIf
	If $fRecentIndex = 1 Then
		CreateMenuItem($iMenuID, "&s    " & $sLang_SystemRecent, "_SystemRecent", GetIcon("_SystemRecent"))
	Else
		If StringInStr($sLang_SystemRecent, "S", 1) Then
			CreateMenuItem($iMenuID, StringReplace($sLang_SystemRecent, "S", "&S", 1, 1), "_SystemRecent", GetIcon("_SystemRecent"))
		ElseIf StringInStr($sLang_SystemRecent, "s", 1) Then
			CreateMenuItem($iMenuID, StringReplace($sLang_SystemRecent, "s", "&s", 1, 1), "_SystemRecent", GetIcon("_SystemRecent"))
		Else
			CreateMenuItem($iMenuID, $sLang_SystemRecent & "(&S)", "_SystemRecent", GetIcon("_SystemRecent"))
		EndIf
	EndIf

	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iMenuID), $MNS_CHECKORBMP)

	LoadingTip()
	Return $iMenuID
EndFunc
Func AddRecent($sPath)
	Local $iIndex = -1, $iIndex0, $iIndex1

	; find if this path already exist
	For $i = 0 To $iRecentSize - 1
		If $sPath = $asRecentPath[$i] Then
			$iIndex = $i
			ExitLoop
		EndIf
	Next
	; not found, move all
	If $iIndex = -1 Then $iIndex = $iRecentSize - 1

	; move items down
	For $i = 1 To $iIndex ; move only items above this path (i = 1 2 3)
		$iIndex0 = $iIndex - $i ; (i0 = 2 1 0)
		$iIndex1 = $iIndex0 + 1 ; (i1 = 3 2 1)
		$asRecentDate[$iIndex1] = $asRecentDate[$iIndex0]
		$asRecentPath[$iIndex1] = $asRecentPath[$iIndex0]
		;       $asRecentApp[$iIndex1] = $asRecentApp[$iIndex0]
	Next
	$asRecentDate[0] = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
	$asRecentPath[0] = $sPath
	;   $asRecentApp[0] = GetProcessName($hWnd)

	_XMLDeleteNode("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']")
	_XMLCreateChildWAttr("/FolderMenu/Settings/Menus", "Setting", "Name", "RecentList")
	For $i = 0 To $iRecentSize - 1
		Local $asAtt[2], $asVal[2]
		$asAtt[0] = "Date"
		$asAtt[1] = "Path"
		; $asAtt[2] = "App"
		$asVal[0] = $asRecentDate[$i]
		$asVal[1] = $asRecentPath[$i]
		; $asVal[2] = $asRecentApp[$i]
		_XMLCreateChildWAttr("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']", "Recent", $asAtt, $asVal)
	Next
	_XMLTransform()
	_XMLSaveDoc("", 1)

	CreateRecentMenu($iRecentMenuID)
	Return
EndFunc
Func _ClearRecent()
	For $i = 0 To $iRecentSize - 1
		$asRecentDate[$i] = ""
		$asRecentPath[$i] = ""
		;       $asRecentApp[$i] = ""
	Next
	_XMLDeleteNode("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']")
	_XMLCreateChildWAttr("/FolderMenu/Settings/Menus", "Setting", "Name", "RecentList")
	_XMLCreateChildWAttr("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']", "Recent", "Path", "")
	_XMLTransform()
	_XMLSaveDoc("", 1)
	CreateRecentMenu($iRecentMenuID)
EndFunc

Func CreateSystemRecentMenu()
	$hGuiTemp = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST, $WS_EX_MDICHILD), $hGuiMain)
	GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "MenuSecondaryDown", $hGuiTemp)
	$iTempMenuID = GUICtrlCreateContextMenu()

	If $sOSVersion = "WIN_VISTA" Then
		Local $sSRecentPath = @AppDataDir & "\Microsoft\Windows\Recent" ; For Vista / 7
	Else
		Local $sSRecentPath = @UserProfileDir & "\Recent" ; For XP
	EndIf

	Local $hSearch = FileFindFirstFile($sSRecentPath & "\*.lnk")
	If $hSearch = -1 Then ; search failed
		GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iTempMenuID), $GUI_DISABLE)
		FileClose($hSearch)
		Return
	EndIf

	If $fLoadingTipForR Then LoadingTip($sLang_LoadRecent)
	Local $sFile, $iFileCount = 0, $asFileList[1]
	Local $aLink, $aTime
	While 1
		$sFile = FileFindNextFile($hSearch)
		If @error Then ExitLoop

		$aTime = FileGetTime($sSRecentPath & "\" & $sFile)
		If @error Then ContinueLoop
		$aTime = $aTime[0] & "/" & $aTime[1] & "/" & $aTime[2] & " " & $aTime[3] & ":" & $aTime[4] & ":" & $aTime[5]

		$aLink = FileGetShortcut($sSRecentPath & "\" & $sFile)
		If @error Then ContinueLoop
		$sFile = $aLink[0]

		If Not FileExists($sFile) Then ContinueLoop

		If Not StringInStr(FileGetAttrib($sFile), "D") And $fSRecentFolder = 1 Then ContinueLoop

		If UBound($asFileList) <= $iFileCount Then ReDim $asFileList[UBound($asFileList) * 2]
		$asFileList[$iFileCount] = $aTime & " " & $sFile
		$iFileCount += 1

	WEnd
	FileClose($hSearch)
	LoadingTip()
	If $iFileCount = 0 Then
		GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iTempMenuID), $GUI_DISABLE)
		Return
	Else
		ReDim $asFileList[$iFileCount] ; Trim unused slots
	EndIf
	_ArraySort($asFileList, 1)

	Local $iIndex = 0, $sIndex, $sName, $sPath, $sDate
	For $sItem In $asFileList
		If $iIndex > $iSRecentSize - 1 Then ExitLoop
		If $sItem = "" Then ContinueLoop
		$sPath = StringTrimLeft($sItem, 20)
		$sDate = StringLeft($sItem, 19)
		Local $sDrive, $sDir, $sExt
		_PathSplit($sPath, $sDrive, $sDir, $sName, $sExt)
		If $fSRecentIndex = 0 And $sName <> "" Then $sName = "&" & $sName
		If $fSRecentFull = 1 Then $sName = $sDrive & $sDir & $sName
		If $fHideExt = 0 Then
			If $fHideLnk = 0 Then ; show all ext
				$sName &= $sExt
			Else ; show ext but hide .lnk .url
				If $sExt <> ".lnk" And $sExt <> ".url" Then $sName &= $sExt
			EndIf
		EndIf
		If $sName = "" Then $sName = $sPath
		If $fSRecentDate = 1 Then $sName &= @TAB & $sDate
		If $fSRecentIndex = 1 Then
			If $iIndex > 9 Then
				$sName = "&" & Chr(87 + $iIndex) & "    " & $sName
			Else
				$sName = "&" & $iIndex & "    " & $sName
			EndIf
		EndIf
		CreateMenuItem($iTempMenuID, $sName, $sPath)
		$iIndex += 1
	Next

	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iTempMenuID), $MNS_CHECKORBMP)
	Return
EndFunc

Func CreateExplorerMenu($iMenuID)
	While _GUICtrlMenu_DeleteMenu(GUICtrlGetHandle($iMenuID), 0)
	WEnd
	Local $asExplorerList = GetExplorerList()
	Global $iExplorerCount = $asExplorerList[0][0]
	If $iExplorerCount = 0 Then
		$iExplorerCount = 1
		GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iMenuID), $GUI_DISABLE)
	Else
		Local $iItem
		For $i = 1 To $iExplorerCount
			$iItem = CreateMenuItem($iMenuID, $asExplorerList[$i][0], "_ActivateExplorer", GetIcon(":ExplorerMenu"))
			Assign("sNameExplorer" & $iItem, $asExplorerList[$i][0], 2)
			Assign("hWndExplorer" & $iItem, $asExplorerList[$i][1], 2)
		Next
	EndIf
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iMenuID), $MNS_CHECKORBMP)
	Return $iMenuID
EndFunc
Func GetExplorerList()
	Local $asList = WinList("[CLASS:CabinetWClass]")
	Local $asPathList[$asList[0][0] + 1][2]
	$asPathList[0][0] = $asList[0][0]
	Local $sPath
	For $i = 1 To $asList[0][0]
		If $sOSVersion = "WIN_VISTA" Then
			$sPath = ControlGetText($asList[$i][1], "", "ToolbarWindow322")
			StringSplit2($sPath, ":", $sPath, $sPath)
			$sPath = StringStripWS($sPath, 3)
		Else
			$sPath = ControlGetText($asList[$i][1], "", "ComboBoxEx321")
		EndIf
		If $sPath = "" Then $sPath = $asList[$i][0]
		$asPathList[$i][0] = $sPath
		$asPathList[$i][1] = $asList[$i][1]
		$sPath = ""
	Next

	$asList = WinList("[CLASS:ExploreWClass]")
	$asPathList[0][0] += $asList[0][0]
	ReDim $asPathList[$asPathList[0][0] + 1][2]
	For $i = 1 To $asList[0][0]
		If $sOSVersion = "WIN_VISTA" Then
			$sPath = ControlGetText($asList[$i][1], "", "ToolbarWindow322")
			StringSplit2($sPath, ":", $sPath, $sPath)
			$sPath = StringStripWS($sPath, 3)
		Else
			$sPath = ControlGetText($asList[$i][1], "", "ComboBoxEx321")
		EndIf
		If $sPath = "" Then $sPath = WinGetTitle($asList[$i][1])
		$asPathList[$i][0] = $sPath
		$asPathList[$i][1] = $asList[$i][1]
		$sPath = ""
	Next
	Return $asPathList
EndFunc
Func _ActivateExplorer()
	If _IsPressedI($VK_SHIFT) Or _IsPressedI($VK_CONTROL) Or $fSecondaryDown Then
		Local $sPath = Eval("sNameExplorer" & @GUI_CtrlId)
		If OpenPath($sPath) = 0 And $iRecentMenuID <> 0 Then AddRecent($sPath)
	Else
		WinActivate(Eval("hWndExplorer" & @GUI_CtrlId))
	EndIf
	$fSecondaryDown = 0
	Return
EndFunc

Func CreateDriveMenu($iMenuID)
	If $fLoadingTipForD Then LoadingTip($sLang_LoadDrive)
	While _GUICtrlMenu_DeleteMenu(GUICtrlGetHandle($iMenuID), 0)
	WEnd
	Local $aDriveList = DriveGetDrive($sDriveType)
	If @error Then
		Global $iDriveCount = 1
		GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iMenuID), $GUI_DISABLE)
	Else
		Global $iDriveCount = $aDriveList[0]
		Local $fEmpty = True
		For $i = 1 To $iDriveCount
			Local $nTotal = DriveSpaceTotal($aDriveList[$i])
			If Not @error Then
				$fEmpty = False
				Local $sName = DriveGetLabel($aDriveList[$i]) & " (" & StringUpper($aDriveList[$i]) & ")    "
				If $fDriveFree = 1 Then
					Local $nFree = DriveSpaceFree($aDriveList[$i])
					$sName &= Round($nFree / 1024, 1) & "GB/" & Round($nTotal / 1024, 1) & "GB    "
					$sName &= Round(100 * $nFree / $nTotal, 1) & "% Free"
				EndIf
				CreateMenuItem($iMenuID, $sName, StringUpper($aDriveList[$i]))
			EndIf
		Next
		If $fEmpty Then
			Global $iDriveCount = 1
			GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iMenuID), $GUI_DISABLE)
		EndIf
	EndIf
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iMenuID), $MNS_CHECKORBMP)
	LoadingTip()
	Return $iMenuID
EndFunc

Func CreateSVSMenu($iMenuID)
	While _GUICtrlMenu_DeleteMenu(GUICtrlGetHandle($iMenuID), 0)
	WEnd
	RunWait("cmd.exe /c svscmd.exe enum -v > " & @TempDir & "\FM_svsstatus.tmp", "", @SW_HIDE)

	Local $hSVSFile = FileOpen(@TempDir & "\FM_svsstatus.tmp", 0)
	If $hSVSFile = -1 Then
		Global $iSVSCount = -1
		CreateMenuItem($iMenuID, $sLang_RunSVSAdmin, "svsadmin.exe")
	Else
		Local $sLine
		Global $iSVSCount = 0
		Local $asLayerName[100], $asLayerPath[100], $sLayerStatus
		While 1
			$sLine = FileReadLine($hSVSFile)
			If @error = -1 Then ExitLoop
			If StringLeft($sLine, 11) = "Layer name:" Then
				$iSVSCount += 1
				$asLayerName[$iSVSCount] = StringStripWS(StringTrimLeft($sLine, 11), 3)
			ElseIf StringLeft($sLine, 7) = "Active:" Then
				$sLayerStatus = StringStripWS(StringTrimLeft($sLine, 7), 3)
				If $sLayerStatus = "No" Then
					$asLayerPath[$iSVSCount] = "svscmd.exe -W """ & $asLayerName[$iSVSCount] & """ A"
				Else
					$asLayerPath[$iSVSCount] = "svscmd.exe -W """ & $asLayerName[$iSVSCount] & """ D"
				EndIf
			EndIf
		WEnd
		Local $iItem
		For $i = 1 To $iSVSCount
			$iItem = GUICtrlCreateMenuItem($asLayerName[$i], $iMenuID)
			If StringRight($asLayerPath[$i], 2) = " D" Then GUICtrlSetState($iItem, $GUI_CHECKED)
			Assign("sName" & $iItem, $asLayerName[$i], 2)
			Assign("sPath" & $iItem, $asLayerPath[$i], 2)
			GUICtrlSetOnEvent($iItem, "OpenFavoriteItem")
		Next
		GUICtrlCreateMenuItem("", $iMenuID)
		CreateMenuItem($iMenuID, $sLang_RunSVSAdmin, "svsadmin.exe")
		FileClose($hSVSFile)
	EndIf
	FileDelete(@TempDir & "\FM_svsstatus.tmp")

	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iMenuID), $MNS_CHECKORBMP)
	Return $iMenuID
EndFunc

Func CreateTCMenu($iMenuID)
	If $fLoadingTipForC Then LoadingTip($sLang_LoadTC)
	While _GUICtrlMenu_DeleteMenu(GUICtrlGetHandle($iMenuID), 0)
	WEnd
	CreateTCItem($iMenuID)
	Return $iMenuID
EndFunc
Func CreateTCItem($iMenuID)
	$sTCPathIni = IniRead($sTCPathIni, "DirMenu", "RedirectSection", $sTCPathIni) ; read redirect info
	$sTCPathIni = DerefPath($sTCPathIni)
	If Not FileExists($sTCPathIni) Then
		Global $iTCCount = 1
		If $fTCSubmenu = 1 Then GUICtrlSetState(GUICtrlCreateMenuItem($sLang_Empty, $iMenuID), $GUI_DISABLE)
	Else
		Global $iTCCount = 0
		Local $i = 1
		Local $iCurMenu = $iMenuID
		Local $sName, $sPath, $iItem
		While 1
			$sName = IniRead($sTCPathIni, "DirMenu", "menu" & $i, "")
			If $sName = "" Then ExitLoop
			If $sName = "-" Then ; separator
				GUICtrlCreateMenuItem("", $iCurMenu)
				$iTCCount += 1
			ElseIf $sName = "--" Then ; out of a submenu
				If Eval("Menu" & $iCurMenu) <> 0 Then $iCurMenu = Eval("Menu" & $iCurMenu)
			ElseIf StringLeft($sName, 1) = "-" Then ; into a submenu
				$sName = StringTrimLeft($sName, 1)
				$iItem = GUICtrlCreateMenu($sName, $iCurMenu)
				SetMenuItemIcon($iCurMenu, $iItem, "Menu", GetIcon("Menu"))
				Assign("Menu" & $iItem, $iCurMenu, 1)
				$iCurMenu = $iItem
				$iTCCount += 1
			Else
				$sPath = IniRead($sTCPathIni, "DirMenu", "cmd" & $i, "")
				If StringLeft($sPath, 3) = "cd " Then $sPath = StringTrimLeft($sPath, 3)
				CreateMenuItem($iCurMenu, $sName, $sPath)
				$iTCCount += 1
			EndIf
			$i += 1
		WEnd
	EndIf
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($iMenuID), $MNS_CHECKORBMP)
	LoadingTip()
EndFunc

Func CreateMenuItem($iMenuID, $sItemName, $sItemPath, $sItemIcon = "", $iItemSize = "")
	Local $iItemID = GUICtrlCreateMenuItem($sItemName, $iMenuID)
	GUICtrlSetOnEvent($iItemID, "OpenFavoriteItem")
	Assign("sName" & $iItemID, $sItemName, 2) ; 2 for global
	Assign("sPath" & $iItemID, $sItemPath, 2)
	SetMenuItemIcon($iMenuID, $iItemID, $sItemPath, $sItemIcon, $iItemSize)
	Return $iItemID
EndFunc

Func SetMenuItemIcon($hMenu, $iItemID, $sItemPath, $sItemIcon = "", $iItemSize = "")
	If $fNoMenuIcon = 1 Then Return

	; create menu background bitmap
	If Not IsDeclared("iMenuBkColor") Then
		Global $iMenuBkColor = _WinAPI_GetSysColor($COLOR_MENU)
		Global $iMenuBkSize = 64 * 64
		Global $tMenuBkBits = DllStructCreate("int[" & $iMenuBkSize & "]")
		For $i = 1 To $iMenuBkSize
			DllStructSetData($tMenuBkBits, 1, $iMenuBkColor, $i)
		Next
	EndIf

	If Not IsPtr($hMenu) Then $hMenu = GUICtrlGetHandle($hMenu)

	If $sItemIcon = "" Then $sItemIcon = GetIcon($sItemPath)
	Local $sIconPath, $iIconIndex, $iIconSize
	SplitIconPath($sItemIcon, $sIconPath, $iIconIndex, $iIconSize)
	If $sIconPath = "%1" Or $sIconPath = """%1""" Then ; the icon is itself
		Local $sDrive, $sDir, $sFName, $sExt
		_PathSplit($sItemPath, $sDrive, $sDir, $sFName, $sExt)
		If $sExt = ".lnk" Then ; get target of .lnk file
			Local $aLink = FileGetShortcut($sItemPath)
			If Not @error Then $sIconPath = $aLink[0]
		Else
			$sIconPath = StringReplace($sItemPath, """", "")
			$sIconPath = StringStripWS($sIconPath, 3)
		EndIf
	EndIf
	$sIconPath = DerefPath($sIconPath)
	If $iIconIndex = "" Then $iIconIndex = 0
	If $iIconSize = "" Then $iIconSize = $iItemSize
	If $iIconSize = "" Then $iIconSize = $iIconSizeG

	Local $sVarName = TrimVarName($sIconPath & "_" & $iIconIndex & "_" & $iIconSize)
	Local $hBmp
	If IsDeclared("sIconBmp" & $sVarName) Then
		$hBmp = Eval("sIconBmp" & $sVarName)
	Else
		$hBmp = _CreateBitmapFromIcon($iMenuBkColor, $sIconPath, $iIconIndex, $iIconSize, $iIconSize)
		Assign("sIconBmp" & $sVarName, $hBmp, 2)
	EndIf
	_GUICtrlMenu_SetItemBmp($hMenu, $iItemID, $hBmp, 0)
	Return
EndFunc
Func GetIcon($sPath)
	$sPath = StringReplace($sPath, """", "")
	$sPath = StringStripWS($sPath, 3)
	$sPath = DerefPath($sPath)
	Local $sIcon
	If StringLeft($sPath, 4) = "http" Then ; Url
		$sIcon = GetIconForUrl($sPath)
	ElseIf StringLeft($sPath, 2) = "HK" Then ; Registry
		$sIcon = GetIconForExt("reg")
	ElseIf StringLeft($sPath, 2) = "\\" Then ; UNC path
		$sIcon = GetIconForExt("Share")
	ElseIf $sPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" Then ; Computer
		$sIcon = GetIconForExt("Computer")
	ElseIf StringLeft($sPath, 2) = "::" Then ; System folder
		$sIcon = GetIconForCLSID(StringTrimLeft($sPath, 2))
	ElseIf StringLeft($sPath, 1) = ":" Or StringLeft($sPath, 1) = "_" Then ; Special path
		$sIcon = GetIconForExt($sPath)
	Else
		$sIcon = GetIconForFile($sPath)
	EndIf
	Return StringReplace($sIcon, """", "")
EndFunc
Func GetIconForUrl($sUrl)
	If $fGetFavIcon = 1 Then
		If StringRight($sUrl, 1) = "/" Then $sUrl = StringTrimRight($sUrl, 1)
		Local $sDomain, $sDummy, $sFile
		StringSplit2($sUrl, "://", $sDummy, $sFile)
		StringSplit2($sFile, "/", $sDomain, $sDummy)
		$sFile = StringRegExpReplace($sFile, "[/|\\?*:<>]", "_")
		DirCreate(@ScriptDir & "\ico")
		$sFile = @ScriptDir & "\ico\" & $sFile & ".ico"
		If FileExists($sFile) Then
			; cache exist and is not a blank file
			If FileGetSize($sFile) <> 0 Then Return $sFile
		Else
			; get icon url from html
			Local $sText = BinaryToString(InetRead($sUrl))
			If $sText <> "" Then
				Local $iStart, $iEnd
				$iStart = StringInStr($sText, "rel=""shortcut icon""")
				If $iStart = 0 Then $iStart = StringInStr($sText, "rel=""icon""")
				If $iStart <> 0 Then
					$iStart = StringInStr($sText, "<link ", 0, -1, $iStart)
					$iEnd = StringInStr($sText, ">", 0, 1, $iStart)
					$sText = StringMid($sText, $iStart, $iEnd - $iStart)
					$iStart = StringInStr($sText, "href=", 0, 1) + 6
					$iEnd = StringInStr($sText, " ", 0, 1, $iStart) - 1
					$sText = StringMid($sText, $iStart, $iEnd - $iStart)
					; full path
					If InetGet($sText, $sFile) Then
						Return $sFile
					Else
						Local $sUrlRel = StringLeft($sUrl, StringInStr($sUrl, "/", 0, -1))
						; relative path
						If InetGet($sUrlRel & $sText, $sFile) Then Return $sFile
					EndIf
				EndIf
			EndIf
			; get favicon.ico
			If InetGet("http://" & $sDomain & "/favicon.ico", $sFile) Then
				Return $sFile
			EndIf
			; favicon not found, create blank file to prevent check again
			Local $hFile = FileOpen($sFile, 2)
			If $hFile <> -1 Then FileClose($hFile)
		EndIf
	EndIf
	; use default
	Return GetIconForExt("url")
EndFunc
Func GetIconForFile($sFile)
	; Get associated icon by WideBoyDixon http://www.autoitscript.com/forum/index.php?showtopic=94207
	If $sFile = "" Then Return GetIconForExt("Unknown")
	; Folder
	If FileExists($sFile) And (StringInStr(FileGetAttrib($sFile), "D") > 0) Then
		If $fShellIcon = 0 Then Return GetIconForExt("Folder")
		Local $tSHFILEINFO = _WinAPI_ShellGetFileInfo($sFile, $SHGFI_ICONLOCATION)
		Local $sIconFile = DllStructGetData($tSHFILEINFO, 4)
		Local $iIconIndex = DllStructGetData($tSHFILEINFO, 2)
		If $sIconFile = "" Then Return GetIconForExt("Folder")
		Return $sIconFile & "," & $iIconIndex
		; File
	Else
		Local $sDrive, $sDir, $sFName, $sExt
		_PathSplit($sFile, $sDrive, $sDir, $sFName, $sExt)
		If $sExt = "" Then $sExt = $sFile
		If StringLeft($sExt, 1) = "." Then $sExt = StringTrimLeft($sExt, 1)
		If $sExt = "lnk" Then
			Local $aLink = FileGetShortcut($sFile)
			If Not @error Then
				If $aLink[4] <> "" Then Return $aLink[4] & "," & $aLink[5]
				Return GetIconForFile($aLink[0])
			EndIf
		EndIf
		Return GetIconForExt($sExt)
	EndIf
EndFunc
Func GetIconForCLSID($sCLSID)
	Return RegRead("HKEY_CLASSES_ROOT\CLSID\" & $sCLSID & "\DefaultIcon", "")
EndFunc
Func GetIconForExt($sExt)
	If IsDeclared("sIconPath" & TrimVarName($sExt)) Then Return Eval("sIconPath" & TrimVarName($sExt))

	Local $sIcon
	Switch $sExt
		Case ":ToolMenu", "FolderS", "Menu", "_GoWebsite"
			$sIcon = $sFolderMenuExe & ",0"
		Case "_AddFavorite", "_AddHere"
			$sIcon = $sFolderMenuExe & ",-201"
		Case "_Reload", "_ToggleHidden", "_ToggleFileExt", "_CheckUpdate"
			$sIcon = $sFolderMenuExe & ",-202"
		Case "_Options", "_Test"
			$sIcon = $sFolderMenuExe & ",-203"
		Case "_Edit"
			$sIcon = $sFolderMenuExe & ",-204"
		Case "_Exit", "_ClearRecent", "Error"
			$sIcon = $sFolderMenuExe & ",-205"
		Case "Separator"
			$sIcon = $sFolderMenuExe & ",-206"
		Case ":RecentMenu"
			$sIcon = $sFolderMenuExe & ",-207"
		Case "Folder"
			$sIcon = $sFolderMenuExe & ",-208"
		Case "Drive"
			$sIcon = $sFolderMenuExe & ",-209"
		Case "Computer", ":DriveMenu"
			$sIcon = $sFolderMenuExe & ",-210"
		Case "Share"
			$sIcon = $sFolderMenuExe & ",-211"
		Case "_SystemRecent"
			If $sOSVersion = "WIN_VISTA" Then
				$sIcon = "imageres.dll,-117"
			Else
				$sIcon = "shell32.dll,-21"
			EndIf
		Case ":SVSMenu"
			$sIcon = "svsadmin.exe"
		Case ":TCMenu"
			$sIcon = $sTCPathExe
		Case ":ExplorerMenu"
			If $sOSVersion = "WIN_VISTA" Then
				$sIcon = "explorer.exe,0"
			Else
				$sIcon = "explorer.exe,1"
			EndIf
		Case "Unknown"
			$sIcon = RegRead("HKEY_CLASSES_ROOT\Unknown\DefaultIcon", "")
		Case Else
			$sIcon = _WinAPI_AssocQueryString("." & $sExt, $ASSOCSTR_DEFAULTICON, $ASSOCF_INIT_IGNOREUNKNOWN)
			If $sIcon = "" Then $sIcon = GetIconForExt("Unknown")
	EndSwitch
	Assign("sIconPath" & TrimVarName($sExt), $sIcon, 2)
	Return $sIcon
EndFunc
Func _CreateBitmapFromIcon($iBackground, $sPath, $iIndex, $iWidth, $iHeight)
	; thanks to Yashied http://www.autoitscript.com/forum/index.php?showtopic=97365
	Local $hDC = _WinAPI_GetDC(0)
	Local $hBackDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hBitmap = _WinAPI_CreateSolidBitmap2(0, $iBackground, $iWidth, $iHeight)
	Local $hBackSv = _WinAPI_SelectObject($hBackDC, $hBitmap)

	;slow here ~2ms
	Local $hIcon = _WinAPI_ShellExtractIcons($sPath, $iIndex, $iWidth, $iHeight)
	; Local $hIcon = _WinAPI_PrivateExtractIcon($sPath, $iIndex, $iWidth, $iHeight)

	If Not @error Then
		_WinAPI_DrawIconEx($hBackDC, 0, 0, $hIcon, 0, 0, 0, 0, $DI_NORMAL)
		_WinAPI_DestroyIcon($hIcon)
	EndIf
	_WinAPI_SelectObject($hBackDC, $hBackSv)
	_WinAPI_ReleaseDC(0, $hDC)
	_WinAPI_DeleteDC($hBackDC)
	Return $hBitmap
EndFunc
#endregion Create Menu

#region Special Function
Func _AddFavorite()
	Local $sName, $sPath
	If AddFavoriteGetInfo($sName, $sPath) = 1 Then Return
	If $fAddFavSkipGui = 1 And $sPath <> "" Then ; skip gui only if path is not blank
		Local $asAttr[5], $asVal[5]
		$asAttr[0] = "Type"
		$asAttr[1] = "Name"
		$asAttr[2] = "Path"
		$asAttr[3] = "Icon"
		$asAttr[4] = "Size"
		$asVal[0] = "Item"
		$asVal[1] = $sName
		$asVal[2] = $sPath
		$asVal[3] = ""
		$asVal[4] = ""
		_XMLCreateChildWAttr("/FolderMenu/Menu", "Item", $asAttr, $asVal)
		_XMLTransform()
		_XMLSaveDoc("", 1)
		Local $sLang_FavoriteAdded_ = $sLang_FavoriteAdded
		$sLang_FavoriteAdded_ = StringReplace($sLang_FavoriteAdded_, "%ItemName%", $sName)
		$sLang_FavoriteAdded_ = StringReplace($sLang_FavoriteAdded_, "%ItemPath%", $sPath)
		TrayTip($sLang_AddFavorite, $sLang_FavoriteAdded_, 5, 1)
		CreateMenuItem($iMainMenuID, $sName, $sPath)
		Return
	Else
		_Options()
		GUICtrlSendMsg($Tab1, $TCM_SETCURFOCUS, 0, 0)
		TreeViewFavAddPath($sPath)
	EndIf
EndFunc
Func _AddHere()
	Local $iMenu = Eval("iMenu" & @GUI_CtrlId)
	Local $sName, $sPath
	If AddFavoriteGetInfo($sName, $sPath) = 1 Then Return
	CreateMenuItem($iMenu, $sName, $sPath)
	ReDim $asFavorite[$iFavoriteCount + 1][2]
	$asFavorite[$iFavoriteCount][0] = $sName
	$asFavorite[$iFavoriteCount][1] = $sPath
	$iFavoriteCount += 1
	Local $sXPath
	While $iMenu <> $iMainMenuID
		$sXPath = "/Item[@Name='" & _GUICtrlMenu_GetItemText(GUICtrlGetHandle($iMainMenuID), $iMenu, 0) & "']" & $sXPath
		$iMenu = Eval("iMenu" & $iMenu)
	WEnd
	$sXPath = "/FolderMenu/Menu" & $sXPath
	Local $asAttr[5], $asVal[5]
	$asAttr[0] = "Type"
	$asAttr[1] = "Name"
	$asAttr[2] = "Path"
	$asAttr[3] = "Icon"
	$asAttr[4] = "Size"
	$asVal[0] = "Item"
	$asVal[1] = $sName
	$asVal[2] = $sPath
	$asVal[3] = ""
	$asVal[4] = ""
	_XMLCreateChildWAttr($sXPath, "Item", $asAttr, $asVal)
	_XMLTransform()
	_XMLSaveDoc("", 1)
	Local $sLang_FavoriteAdded_ = $sLang_FavoriteAdded
	$sLang_FavoriteAdded_ = StringReplace($sLang_FavoriteAdded_, "%ItemName%", $sName)
	$sLang_FavoriteAdded_ = StringReplace($sLang_FavoriteAdded_, "%ItemPath%", $sPath)
	TrayTip($sLang_AddFavorite, $sLang_FavoriteAdded_, 5, 1)
EndFunc
Func AddFavoriteGetInfo(ByRef $sName, ByRef $sPath)
	If $sWinClass = "" Then
		$hWnd = WinGetHandle("[ACTIVE]")
		$sWinClass = _WinAPI_GetClassName($hWnd)
	EndIf

	$sPath = GetPath($hWnd, $sWinClass)

	If $sPath = "" Then ; cannot get folder path, get process path
		If $fAddFavApp = 1 Then $sPath = GetProcessPath($hWnd, $fAddFavAppCmd)
	EndIf

	If $fAddFavCheck = 1 Then
		$sName = ItemPathExist($sPath)
		If $sName Then
			Local $sLang_PathExist_ = StringReplace($sLang_PathExist, "%ItemName%", $sName)
			$sLang_PathExist_ = StringReplace($sLang_PathExist_, "%ItemPath%", $sPath)
			If MsgBox($MB_YESNO + $MB_ICONQUESTION, $sLang_Warning & " - FolderMenu3 EX", $sLang_PathExist_) <> $IDYES Then
				Return 1
			EndIf
		EndIf
	EndIf

	$sName = GetName($sPath)
	If $sName = "" Then $sName = $sLang_NewItem
	Return 0
EndFunc
Func GetPath($hWnd, $sWinClass)
	; return if not supported
	CheckApp($hWnd, $sWinClass)
	If $sAdrClassNN = "" Then Return ""

	Local $sPath
	Switch $sWinClass
		Case "#32770"
			If $sOSVersion = "WIN_VISTA" Then
				Local $sText, $i = 1
				While 1
					$sText = ControlGetText($hWnd, "", "ToolbarWindow32" & $i)
					If StringInStr($sText, ": ") Then ExitLoop
					If $i = 10 Then ExitLoop
					$i += 1
				WEnd
				WinActivate($hWnd)
				ControlClick($hWnd, "", "ToolbarWindow32" & $i, "", 1, 2)
				Sleep(100)
				$sPath = ControlGetText($hWnd, "", ControlGetFocus($hWnd))
			Else
				; old file open dialog
			EndIf
		Case "CabinetWClass", "ExploreWClass"
			If $sOSVersion = "WIN_VISTA" Then
				Local $oWindow = GetShellWindowObj($hWnd)
				If IsObj($oWindow) Then
					$sPath = $oWindow.Document.Folder.Self.Path
				Else
					ControlGetHandle($hWnd, "", "ToolbarWindow322")
					If Not @error Then
						WinActivate($hWnd)
						ControlClick($hWnd, "", "ToolbarWindow322", "", 1, 2)
						Sleep(100)
						$sPath = ControlGetText($hWnd, "", ControlGetFocus($hWnd))
					EndIf
				EndIf
			Else
				$sPath = ControlGetText($hWnd, "", "ComboBoxEx321")
			EndIf
		Case "ConsoleWindowClass"
			WinActivate($hWnd)
			Send("cd > %Temp%\FM_cd.tmp{Enter}")
			Sleep(100)
			$sPath = FileReadLine(@TempDir & "\FM_cd.tmp")
			FileDelete(@TempDir & "\FM_cd.tmp")
		Case "TTOTAL_CMD", "TxUNCOM", "TxUNCOM.UnicodeClass"
			Local $sEdit1Text = ControlGetText($hWnd, "", $sAdrClassNN)
			WinActivate($hWnd)
			Send("{Esc}^p") ; get current path, thanks to winflowers
			$sPath = ControlGetText($hWnd, "", $sAdrClassNN)
			ControlSetText($hWnd, "", $sAdrClassNN, $sEdit1Text)
		Case "TfcForm"
			WinActivate($hWnd)
			Send("!g")
			$sPath = ControlGetText($hWnd, "", "TfcPathEdit1")
			Send("{Esc}")
		Case Else
			$sPath = ControlGetText($hWnd, "", $sAdrClassNN)
	EndSwitch
	; Remove the trailing backslash.
	If StringRight($sPath, 1) = "\" Then $sPath = StringTrimRight($sPath, 1)
	Return $sPath
EndFunc
Func GetName($sPath)
	$sPath = StringReplace($sPath, """", "")
	If $sPath = "" Then Return ""
	Local $sDrive, $sDir, $sFName, $sExt
	_PathSplit($sPath, $sDrive, $sDir, $sFName, $sExt)
	Local $sName = $sFName
	If $fHideExt <> 1 Then ; don't hide ext, add it to name
		If $fHideLnk <> 1 Then ; don't hide lnk, add it to name
			$sName &= $sExt
		Else ; don't hide ext but hide lnk, add ext only if it's not lnk or url
			If $sExt <> ".lnk" And $sExt <> ".url" Then $sName &= $sExt
		EndIf
	EndIf
	If $sName = "" Then $sName = $sPath
	Return $sName
EndFunc
Func GetProcessPath($hWnd, $fAddFavAppCmd)
	If $fAddFavAppCmd = 1 Then
		Return _WinAPI_GetCommandLineFromPID(WinGetProcess($hWnd))
	Else
		Return _WinAPI_GetModuleFileNameEx(WinGetProcess($hWnd))
	EndIf
EndFunc
; use Func _WinAPI_GetProcessName($PID = 0)
#cs
	Func GetProcessName($hWnd)
	if $hWnd="FolderMenu" then return "FolderMenu"
	Local $sPath=GetProcessPath($hWnd, 0)
	Local $sDrive, $sDir, $sName, $sExt
	_PathSplit($sPath, $sDrive, $sDir, $sName, $sExt)
	return $sName
	EndFunc
#ce
Func ItemPathExist($sPath)
	If $sPath = "" Then Return ""
	If $iFavoriteCount < 1 Then Return ""
	For $i = 0 To $iFavoriteCount - 1
		If $sPath = $asFavorite[$i][1] Then Return $asFavorite[$i][0]
	Next
	Return ""
EndFunc

Func _Reload()
	If @Compiled Then
		Run(@ScriptFullPath)
	Else
		Run(@AutoItExe & " " & @ScriptFullPath)
	EndIf
	Exit
EndFunc

Func _Options()
	If $hGuiOptions Then
		WinActivate($hGuiOptions)
	Else
		$hGuiOptions = CreateOptionsGui()
		If $aGuiOptionsPos[2] Then WinMove($hGuiOptions, "", $aGuiOptionsPos[0], $aGuiOptionsPos[1], $aGuiOptionsPos[2], $aGuiOptionsPos[3])
		If $fGuiOptionsMax = 32 Then WinSetState($hGuiOptions, "", @SW_MAXIMIZE)
		GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
		GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
		GUISetState(@SW_SHOW, $hGuiOptions)
	EndIf
EndFunc

Func _Edit()
	ShellExecute($sConfigFile, "", "", "edit")
EndFunc

Func _Exit()
	Exit
EndFunc

Func _ToggleHidden()
	Local $iShowHidden = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")
	If $iShowHidden = 2 Then
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden", "REG_DWORD", 1)
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "ShowSuperHidden", "REG_DWORD", 1)
		TrayTip($sLang_ToggleHidden, $sLang_ShowHidden, 5, 1)
	Else
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden", "REG_DWORD", 2)
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "ShowSuperHidden", "REG_DWORD", 0)
		TrayTip($sLang_ToggleHidden, $sLang_HideHidden, 5, 1)
	EndIf
	RefreshExplorer()
EndFunc
Func _ToggleFileExt()
	Local $fSysHideExt = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt")
	If $fSysHideExt = 1 Then
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt", "REG_DWORD", 0)
		TrayTip($sLang_ToggleFileExt, $sLang_ShowFileExt, 5, 1)
	Else
		RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt", "REG_DWORD", 1)
		TrayTip($sLang_ToggleFileExt, $sLang_HideFileExt, 5, 1)
	EndIf
	RefreshExplorer()
EndFunc
Func RefreshExplorer()
	Local $hWndDesktop = WinGetHandle("[CLASS:Progman]")
	If $sOSVersion = "WIN_VISTA" Then
		_SendMessage($hWndDesktop, $WM_COMMAND, 0x0001A220)
	Else
		_SendMessage($hWndDesktop, $WM_COMMAND, 0x00007103)
	EndIf
	Local $ahWndExplorer = WinList("[CLASS:CabinetWClass]")
	For $i = 1 To $ahWndExplorer[0][0]
		If $sOSVersion = "WIN_VISTA" Then
			_SendMessage($ahWndExplorer[$i][1], $WM_COMMAND, 0x0001A220)
		Else
			_SendMessage($ahWndExplorer[$i][1], $WM_COMMAND, 0x00007103)
		EndIf
	Next
	Local $ahWndExplorer = WinList("[CLASS:ExploreWClass]")
	For $i = 1 To $ahWndExplorer[0][0]
		If $sOSVersion = "WIN_VISTA" Then
			_SendMessage($ahWndExplorer[$i][1], $WM_COMMAND, 0x0001A220)
		Else
			_SendMessage($ahWndExplorer[$i][1], $WM_COMMAND, 0x00007103)
		EndIf
	Next

	Local $ahWndExplorer = WinList("[CLASS:#32770]")
	For $i = 1 To $ahWndExplorer[0][0]
		Local $hCtrl = ControlGetHandle($ahWndExplorer[$i][1], "", "SHELLDLL_DefView1")
		If $hCtrl <> "" Then _SendMessage($hCtrl, $WM_COMMAND, 0x00007103)
	Next
EndFunc

Func _SystemRecent()
	CreateSystemRecentMenu()
	ShowMenu($hGuiTemp, $iTempMenuID)
EndFunc

Func _RecentMenu()
	If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iRecentMenuID)) = -1 Then
		Global $iRecentMenuID = CreateRecentMenu(GUICtrlCreateMenu(""))
	EndIf
	ShowMenu($hGuiMain, $iRecentMenuID)
EndFunc

Func _ExplorerMenu()
	If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iExplorerMenuID)) = -1 Then
		Global $iExplorerMenuID = CreateExplorerMenu(GUICtrlCreateMenu(""))
	Else
		CreateExplorerMenu($iExplorerMenuID)
	EndIf
	ShowMenu($hGuiMain, $iExplorerMenuID)
EndFunc

Func _DriveMenu()
	If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iDriveMenuID)) = -1 Then
		Global $iDriveMenuID = CreateDriveMenu(GUICtrlCreateMenu(""))
	Else
		CreateDriveMenu($iDriveMenuID)
	EndIf
	ShowMenu($hGuiMain, $iDriveMenuID)
EndFunc

Func _ToolMenu()
	If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iToolMenuID)) = -1 Then ; first time create this menu
		Global $iToolMenuID = CreateToolMenu(GUICtrlCreateMenu(""))
	EndIf
	ShowMenu($hGuiMain, $iToolMenuID)
EndFunc

Func _SVSMenu()
	If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iSVSMenuID)) = -1 Then
		Global $iSVSMenuID = CreateSVSMenu(GUICtrlCreateMenu(""))
	EndIf
	ShowMenu($hGuiMain, $iSVSMenuID)
EndFunc

Func _TCMenu()
	If _GUICtrlMenu_GetItemCount(GUICtrlGetHandle($iTCMenuID)) = -1 Then
		Global $iTCMenuID = CreateTCMenu(GUICtrlCreateMenu(""))
	EndIf
	ShowMenu($hGuiMain, $iTCMenuID)
EndFunc

Func _AddApp()
	Local $sWinTitle, $sClassNN
	$hWnd = WinGetHandle("[ACTIVE]")
	$sWinTitle = WinGetTitle($hWnd)
	$sWinClass = _WinAPI_GetClassName($hWnd)
	Local $sLang_AddAppTitle_ = $sLang_AddAppTitle
	$sLang_AddAppTitle_ = StringReplace($sLang_AddAppTitle_, "%Title%", $sWinTitle)
	$sLang_AddAppTitle_ = StringReplace($sLang_AddAppTitle_, "%Class%", $sWinClass)

	; Edit1 found
	If AddAppMask($hWnd, "Edit1") Then
		; Edit1 is addressbar, add it.
		If MsgBox($MB_YESNO + $MB_ICONQUESTION, $sLang_AddApp & " - FolderMenu3 EX", $sLang_AddAppTitle_ & $sLang_AddAppAddr) = $IDYES Then
			GUIDelete($hWndMask)
			If MsgBox($MB_YESNO + $MB_ICONQUESTION, $sLang_AddApp & " - FolderMenu3 EX", $sLang_AddAppTitle_ & $sLang_AddAppPrompt) = $IDYES Then AddAppGUI($sWinTitle, $sWinClass)
			Return
		EndIf
	EndIf

	; Get focused until found or canceled
	While 1
		GUIDelete($hWndMask)
		If MsgBox($MB_OKCANCEL + $MB_ICONASTERISK + $MB_TOPMOST, $sLang_AddApp & " - FolderMenu3 EX", $sLang_AddAppTitle_ & $sLang_AddAppNoAddr & @LF & $sLang_AddAppFocus) = $IDOK Then
			$sClassNN = ControlGetFocus($hWnd)
			If AddAppMask($hWnd, $sClassNN) Then
				; Focused is addressbar
				If MsgBox($MB_YESNO + $MB_ICONQUESTION, $sLang_AddApp & " - FolderMenu3 EX", $sLang_AddAppTitle_ & $sLang_AddAppAddr) = $IDYES Then
					GUIDelete($hWndMask)
					If MsgBox($MB_YESNO + $MB_ICONQUESTION, $sLang_AddApp & " - FolderMenu3 EX", $sLang_AddAppTitle_ & $sLang_AddAppPrompt) = $IDYES Then AddAppGUI($sWinTitle, $sWinClass, $sClassNN)
					Return
				EndIf
			EndIf
		Else ; Canceled
			GUIDelete($hWndMask)
			If MsgBox($MB_YESNO + $MB_ICONEXCLAMATION + $MB_DEFBUTTON2, $sLang_AddApp & " - FolderMenu3 EX", $sLang_AddAppTitle_ & $sLang_AddAppNoAddr & @LF & $sLang_AddAppPrompt) = $IDYES Then AddAppGUI($sWinTitle, $sWinClass)
			Return
		EndIf
	WEnd

	GUIDelete($hWndMask)
	Return
EndFunc
Func AddAppMask($hWnd, $sClassNN) ; return 1 if $sClassNN is found
	If $sClassNN = "" Then Return 0
	Global $hWndMask
	If $hWndMask Then GUIDelete($hWndMask)
	Local $pos = ControlGetPos($hWnd, "", $sClassNN)
	If @error Then Return 0
	Local $x = $pos[0]
	Local $y = $pos[1]
	Local $w = $pos[2]
	Local $h = $pos[3]

	Local $tPoint = DllStructCreate("int;int")
	DllStructSetData($tPoint, 1, $x)
	DllStructSetData($tPoint, 2, $y)
	_WinAPI_ClientToScreen($hWnd, $tPoint)
	$x = DllStructGetData($tPoint, 1)
	$y = DllStructGetData($tPoint, 2)
	$tPoint = 0

	$hWndMask = GUICreate("", $w, $h, $x, $y, BitOR($WS_POPUP, $WS_CLIPSIBLINGS), BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST, $WS_EX_TRANSPARENT, $WS_EX_WINDOWEDGE))
	GUISetBkColor(0xFF0000, $hWndMask)
	WinSetTrans($hWndMask, "", 64)
	GUISetState()
	Return 1
EndFunc
Func AddAppGUI($sTitle, $sClass, $sClassNN = "Edit1")
	_Options()
	GUICtrlSendMsg($Tab1, $TCM_SETCURFOCUS, 1, 0)
	GUICtrlSetState(GUICtrlCreateListViewItem($sTitle & "|" & $sLang_Match & "|" & $sClass & "|" & $sClassNN, $ListViewApp), $GUI_CHECKED)
	Local $iIndex = _GUICtrlListView_GetItemCount($ListViewApp) - 1
	_GUICtrlListView_SetItemSelected($ListViewApp, $iIndex, True, True)
	_GUICtrlListView_EnsureVisible($ListViewApp, $iIndex, False)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc

Func _OpenSel()
	Local $sClipSaved = ClipGet()
	Send("^c")
	Sleep(500)
	Local $sClip = ClipGet()
	Local $sSelectedPath = DerefPath($sClip)
	$sSelectedPath = StringReplace($sSelectedPath, "｢@", "\")
	If StringRight($sSelectedPath, 1) = "\" Then $sSelectedPath = StringTrimRight($sSelectedPath, 1)
	If $sSelectedPath = "" Then Return
	If StringInStr(FileGetAttrib($sSelectedPath), "D") Then ; Folder, run file manager
		OpenFolder($sSelectedPath)
	Else
		If OpenPath($sSelectedPath) Then
			Local $sCannotOpenClip = StringReplace($sLang_CannotOpenClip, "%Clipboard%", $sClip)
			If $fSearchSel = 1 Then
				$sCannotOpenClip &= @LF & $sLang_Search & @LF & """" & $sClip & """"
				OpenUrl(StringReplace($sSearchSelUrl, "%s", $sClip))
			EndIf
			TrayTip($sLang_Error, $sCannotOpenClip, 5, 3)
			Return ; don't keep error item
		EndIf
	EndIf
	If $iRecentMenuID <> 0 Then ; recent menu enabled
		If IsFolder($sSelectedPath) Then
			AddRecent($sSelectedPath)
		Else ; if recent not only keep folders
			If $fRecentFolder = 0 Then AddRecent($sSelectedPath)
		EndIf
	EndIf
	ClipPut($sClipSaved)
	$sClipSaved = "" ; Free the memory in case the clipboard was very large.
EndFunc

Func _CheckUpdate()
	CheckVersion()
EndFunc
Func CheckVersion($fQuiet = 0)
	Local $iLatestVer = BinaryToString(InetRead("https://github.com/Silvernine0S/FolderMenu3EX/blob/master/Version.txt?raw=true"))
	If $iLatestVer <> "" Then
		If $iCurrentVer < $iLatestVer Then
			Local $sLang_NewVerAvailable_ = StringReplace($sLang_NewVerAvailable, "%LatestVer%", $iLatestVer)
			If MsgBox($MB_ICONQUESTION + $MB_YESNO, $sLang_NewVer & " - FolderMenu3 EX", $sLang_NewVerAvailable_) = $IDYES Then
				DownloadUpdate($iLatestVer)
			Else
				If MsgBox($MB_ICONQUESTION + $MB_YESNO, $sLang_CheckVer & " - FolderMenu3 EX", $sLang_NewVerWebsite) = $IDYES Then _GoWebsite()
			EndIf
		Else
			Local $sLang_NewVerUnavailable_ = StringReplace($sLang_NewVerUnavailable, "%CurrentVer%", $iCurrentVer)
			If $fQuiet = 0 Then MsgBox($MB_ICONASTERISK, $sLang_CheckVer & " - FolderMenu3 EX", $sLang_NewVerUnavailable_)
		EndIf
	Else
		If $fQuiet = 0 Then MsgBox($MB_ICONHAND, $sLang_Error & " - FolderMenu3 EX", $sLang_CannotConnect)
	EndIf
EndFunc
Func DownloadUpdate($iVer)
	If @AutoItX64 Then
		;Local $sFileName = "FolderMenu_x64_" & $iVer & ".zip"
		Local $sFileName = "FolderMenu_x64" & ".zip"
	Else
		;Local $sFileName = "FolderMenu_" & $iVer & ".zip"
		Local $sFileName = "FolderMenu" & ".zip"
	EndIf
	Local $sFilePath = @TempDir & "\" & $sFileName
	;Local $iFileSize = InetGetSize("http://downloads.sourceforge.net/foldermenu/" & $sFileName)
	Local $iFileSize = InetGetSize("https://github.com/Silvernine0S/FolderMenu3EX/blob/master/" & $sFileName & "?raw=true")
	If $iFileSize = 0 Then
		If MsgBox($MB_ICONEXCLAMATION + $MB_YESNO, $sLang_CheckVer & " - FolderMenu3 EX", $sLang_NewVerFailed & @LF & @LF & $sLang_NewVerWebsite) = $IDYES Then _GoWebsite()
	Else
		;Local $hDownload = InetGet("http://downloads.sourceforge.net/foldermenu/" & $sFileName, $sFilePath, 0, 1)
		Local $hDownload = InetGet("https://github.com/Silvernine0S/FolderMenu3EX/blob/master/" & $sFileName & "?raw=true", $sFilePath, 0, 1)
		MsgBox(1,"Test","https://github.com/Silvernine0S/FolderMenu3EX/blob/master/" & $sFileName & "?raw=true")
		Local $sLang_DownloadUpdate_ = $sLang_DownloadUpdate
		ToolTip2($sLang_DownloadUpdate_, "FolderMenu3 EX", 1)
		Do
			$sLang_DownloadUpdate_ &= "."
			ToolTip2($sLang_DownloadUpdate_, "FolderMenu3 EX", 1)
			Sleep(500)
		Until InetGetInfo($hDownload, 2) ; Check if the download is complete.
		ToolTip("")
		Local $aData = InetGetInfo($hDownload)
		InetClose($hDownload)
		If $aData[3] Then
			FileDelete(@TempDir & "\FolderMenu.exe")
			_Zip_Unzip($sFilePath, "FolderMenu.exe", @TempDir)
			FileDelete($sFilePath)
			FileDelete(@TempDir & "\FM_update.bat")
			FileWrite(@TempDir & "\FM_update.bat", _
					"cls" & @CRLF & _
					"@echo off" & @CRLF & _
					":LoopStart" & @CRLF & _
					"echo ====== " & $sLang_UpdateFolderMenu & " ======" & @CRLF & _
					"echo " & $sLang_UpdateExit & @CRLF & _
					"pause" & @CRLF & _
					"del """ & $sFolderMenuExe & """" & @CRLF & _
					"if exist """ & $sFolderMenuExe & """ goto LoopStart" & @CRLF & _
					"move """ & @TempDir & "\FolderMenu.exe"" """ & $sFolderMenuExe & """" & @CRLF & _
					"start """" """ & $sFolderMenuExe & """" & @CRLF & _
					"echo ====== " & $sLang_UpdateFolderMenu & " ======" & @CRLF & _
					"echo " & $sLang_UpdateDone & @CRLF & _
					"pause" & @CRLF & _
					"del """ & @TempDir & "\FM_update.bat""")
			ShellExecute(@TempDir & "\FM_update.bat")
			Exit
		Else
			If MsgBox($MB_ICONEXCLAMATION + $MB_YESNO, $sLang_CheckVer & " - FolderMenu3 EX", $sLang_NewVerFailed & @LF & @LF & $sLang_NewVerWebsite) = $IDYES Then _GoWebsite()
		EndIf
	EndIf
EndFunc

Func _GoWebsite()
	OpenUrl("https://github.com/Silvernine0S/FolderMenu3EX/")
EndFunc
#endregion Special Function

#region Show Menu
Func ShowTempMenu($hGui, $iMenuID)
	Local $hMenu = GUICtrlGetHandle($iMenuID)
	Local $iX = MouseGetPos(0) - 65
	Local $iY = MouseGetPos(1) - 35
	GUISetState(@SW_SHOW, $hGui)
	_GUICtrlMenu_TrackPopupMenu($hMenu, $hGui, $iX, $iY, 1, 1, 0, 1)
	GUISetState(@SW_HIDE, $hGui)
	GUIDelete($hGuiTemp)
	Return
EndFunc

Func ShowMenu($hGui, $iMenuID)
	Local $iX, $iY, $iW, $iH
	Opt("MouseCoordMode", $OPT_COORDSABSOLUTE)
	If $iMenuPosition = 0 Then ; relative to cursor
		$iX = MouseGetPos(0) + $iMenuPositionX
		$iY = MouseGetPos(1) + $iMenuPositionY
	ElseIf $iMenuPosition = 1 Then ; relative to screen
		$iX = $iMenuPositionX
		$iY = $iMenuPositionY
	ElseIf $iMenuPosition = 2 Then ; relative to window
		Local $aiWinPos = WinGetPos("[ACTIVE]")
		$iX = $aiWinPos[0]
		$iY = $aiWinPos[1]
		$iW = $aiWinPos[2]
		$iH = $aiWinPos[3]
		If $iMenuPositionX < $iW Then ; < window width, inside window
			$iX += $iMenuPositionX
		Else ; out of window, use window edge
			$iX += $iW
		EndIf
		If $iMenuPositionY < $iH Then
			$iY += $iMenuPositionY
		Else
			$iY += $iH
		EndIf
	EndIf

	If $iMenuID = $iMainMenuID Then
		If $iExplorerMenuID <> 0 Then CreateExplorerMenu($iExplorerMenuID)
		If $iDriveMenuID <> 0 And $fDriveReload = 1 Then CreateDriveMenu($iDriveMenuID)
	EndIf

	GUISetState(@SW_SHOW, $hGui)
	Local $hMenu = GUICtrlGetHandle($iMenuID)
	_GUICtrlMenu_TrackPopupMenu($hMenu, $hGui, $iX, $iY, 1, 1, 0, 1)
	GUISetState(@SW_HIDE, $hGui)
	If $hGui = $hGuiTemp Then GUIDelete($hGuiTemp)

	Return
EndFunc

Func _ShowMainMenu1()
	$hWnd = WinGetHandle("[ACTIVE]")
	$sWinClass = _WinAPI_GetClassName($hWnd)
	CheckApp($hWnd, $sWinClass)
	If $sAdrClassNN <> "" Then ShowMenu($hGuiMain, $iMainMenuID)
EndFunc

Func _ShowMainMenu15()
	$hWnd = WinGetHandle("[ACTIVE]")
	$sWinClass = _WinAPI_GetClassName($hWnd)
	CheckApp($hWnd, $sWinClass)
	ShowMenu($hGuiMain, $iMainMenuID)
EndFunc

Func _ShowMainMenu2()
	$hWnd = WinGetHandle("[ACTIVE]")
	$sWinClass = _WinAPI_GetClassName($hWnd)
	$sAdrClassNN = ""
	ShowMenu($hGuiMain, $iMainMenuID)
EndFunc

Func CheckApp($hWnd, $sWinClass)
	$sAdrClassNN = ""
	; match list
	If $iAppsCountM > 0 Then
		For $i = 0 To $iAppsCountM - 1
			If $sWinClass = $asAppClassM[$i] Then
				$sAdrClassNN = $asAppClassNNM[$i]
				ExitLoop
			EndIf
		Next
	EndIf
	; contain list
	If $iAppsCountC > 0 Then
		For $i = 0 To $iAppsCountC - 1
			If StringInStr($sWinClass, $asAppClassC[$i]) Then
				$sAdrClassNN = $asAppClassNNC[$i]
				ExitLoop
			EndIf
		Next
	EndIf
	If $sAdrClassNN = "" Then Return

	Switch $sWinClass
		Case "#32770" ; Dialog
			Local $pos, $i = 1
			For $i = 1 To 10
				$pos = ControlGetPos($hWnd, "", "Edit" & $i)
				If @error Then ExitLoop
				If $pos[3] <> 0 Then
					$sAdrClassNN = "Edit" & $i
					ExitLoop
				EndIf
			Next
		Case "CabinetWClass" ; Vista Explorer
			ControlGetHandle($hWnd, "", $sAdrClassNN)
			If @error Then
				ControlClick($hWnd, "", "ToolbarWindow322", "", 1, 2)
				Sleep(100)
				ControlGetHandle($hWnd, "", $sAdrClassNN)
				If @error Then $sAdrClassNN = ""
			EndIf
		Case "ExploreWClass" ; Explorer
			Local $sTemp = ControlGetText($hWnd, "", "ComboBoxEx321")
			For $i = 1 To 10
				If ControlGetText($hWnd, "", "Edit" & $i) = $sTemp Then
					$sAdrClassNN = "Edit" & $i
					ExitLoop
				EndIf
			Next
		Case "Progman", "WorkerW", "Shell_TrayWnd", "ConsoleWindowClass", "Emacs" ; Desktop or Taskbar or Cmd or Emacs
			; $hWnd = 0
			; $sWinClass = ""
			; $sAdrClassNN = ""
		Case Else ; Others
			If StringInStr($sWinClass, "bosa_sdm_") Then ; Microsoft Office application
				ControlGetHandle($hWnd, "", $sAdrClassNN)
				If @error Then $sAdrClassNN = ""
			ElseIf StringInStr($sWinClass, "rxvt") Then ; Rxvt command prompt (thanks to catweazle (John))
			Else ; Others
				ControlGetHandle($hWnd, "", $sAdrClassNN)
				If @error Then $sAdrClassNN = ""
			EndIf
	EndSwitch
EndFunc
#endregion Show Menu

#region Open Item
Func OpenFavoriteItem()
	If Not IsDeclared("sPath" & @GUI_CtrlId) Then
		MsgBox(0, $sLang_Error & " - FolderMenu3 EX", "var ""sPath" & @GUI_CtrlId & """ not declared")
		$fSecondaryDown = 0
		Return
	EndIf

	Local $sPath = Eval("sPath" & @GUI_CtrlId)
	If StringRight($sPath, 1) = "\" Then $sPath = StringTrimRight($sPath, 1)
	If StringInStr($sPath, "%F_CurrentDir%") Then $sPath = StringReplace($sPath, "%F_CurrentDir%", GetPath($hWnd, $sWinClass))
	$sPath = DerefPath($sPath)

	If $sPath = "" Then
		Local $sLang_CannotOpenBlank_ = StringReplace($sLang_CannotOpenBlank, "%ItemName%", Eval("sName" & @GUI_CtrlId))
		TrayTip($sLang_Error, $sLang_CannotOpenBlank_, 5, 3)
		$fSecondaryDown = 0
		Return
	EndIf

	Local $fCtrlDown = _IsPressedI($VK_CONTROL)
	Local $fShiftDown = _IsPressedI($VK_SHIFT)
	Local $fTempMenu = BitOR($fCtrlDown, $fShiftDown, $fSecondaryDown) ; show temp menu
	If IsFolder($sPath) Then
		Local $fCapsLock = BitAND(_WinAPI_GetKeyState($VK_CAPITAL), 1)
		Local $fUseBrowseMode = BitXOR($fBrowseMode, $fCapsLock) ; if one of them is 1, use browse mode.
		If $fUseBrowseMode = 1 Then $fTempMenu = 1 - $fTempMenu ; if in browse mode, invert tempmenu
		If ($fCtrlDown + $fShiftDown + $fSecondaryDown) > 1 Then ; two or more are down, show folders and files in temp menu
			CreateTempMenu($sPath, 1)
			ShowTempMenu($hGuiTemp, $iTempMenuID)
		ElseIf $fTempMenu = 1 Then ; show temp menu
			CreateTempMenu($sPath, $fTempShowFile)
			ShowTempMenu($hGuiTemp, $iTempMenuID)
		Else ; open item
			If OpenPath($sPath) = 0 And $iRecentMenuID <> 0 Then AddRecent($sPath) ; OpenPath() return 0 if success
		EndIf
	Else ; not folder
		If $fTempMenu Then ; show temp menu
			Local $sDrive, $sDir, $sFName, $sExt
			_PathSplit($sPath, $sDrive, $sDir, $sFName, $sExt)
			Local $sFolder = DerefPath($sDrive & $sDir)
			If IsFolder($sFolder) Then
				CreateTempMenu($sFolder, 1)
				ShowTempMenu($hGuiTemp, $iTempMenuID)
			Else
				If OpenPath($sPath) = 0 And $iRecentMenuID <> 0 And $fRecentFolder = 0 And StringLeft($sPath, 1) <> "_" Then AddRecent($sPath)
			EndIf
		Else ; open
			If OpenPath($sPath) = 0 And $iRecentMenuID <> 0 And $fRecentFolder = 0 And StringLeft($sPath, 1) <> "_" Then AddRecent($sPath)
		EndIf
	EndIf
	$fSecondaryDown = 0
	Return
EndFunc

Func OpenPath($sPath)
	; Special item
	If StringLeft($sPath, 1) = "_" Then
		Call($sPath)
		If @error = 0xDEAD And @extended = 0xBEEF Then
			Local $sErrSpecial
			$sErrSpecial = StringReplace($sLang_ErrSpecial, "%ItemPath%", $sPath)
			TrayTip($sLang_Error, $sErrSpecial, 5, 3)
			Return 1
		Else
			Return 0
		EndIf
		; Filter
	ElseIf StringLeft($sPath, 1) = "*" Then
		Return OpenFilter($sPath)
		; Url
	ElseIf StringLeft($sPath, 4) = "http" Then
		Return OpenUrl($sPath)
		; Registry
	ElseIf StringLeft($sPath, 2) = "HK" Then
		Return OpenReg($sPath)
		; UNC path
	ElseIf StringLeft($sPath, 2) = "\\" Then
		Return OpenUNC($sPath)
		; SVS
	ElseIf StringLeft($sPath, 10) = "svscmd.exe" Then
		If StringRight($sPath, 2) = " D" Then
			TrayTip("SVS", $sLang_SVSDeactivate, 5, 1)
		Else
			TrayTip("SVS", $sLang_SVSActivate, 5, 1)
		EndIf
		RunWait($sPath, "", @SW_HIDE)
		CreateSVSMenu($iSVSMenuID)
		Return 0
		; Folder
	ElseIf IsFolder($sPath) Then
		Return OpenFolder($sPath)
		; File
	Else
		Return OpenFile($sPath)
	EndIf
EndFunc

Func OpenFolder($sPath)
	If $sAdrClassNN = "" Then
		If $sFileManager = "" Then
			ShellExecute($sPath)
		Else
			If StringInStr($sFileManager, "%s") Then
				Run(StringReplace($sFileManager, "%s", $sPath))
			Else
				Run($sFileManager & " " & """" & $sPath & """")
			EndIf
		EndIf
	Else
		WinActivate($hWnd)
		Switch $sWinClass
			Case "#32770" ; Dialog
				Local $sEdit1Text = ControlGetText($hWnd, "", $sAdrClassNN)
				ControlClick($hWnd, "", $sAdrClassNN)
				ControlSetText($hWnd, "", $sAdrClassNN, $sPath)
				ControlSend($hWnd, "", $sAdrClassNN, "{Enter}")
				Sleep(100)
				ControlSetText($hWnd, "", $sAdrClassNN, $sEdit1Text)
			Case "CabinetWClass", "ExploreWClass" ; Explorer
				ControlSetText($hWnd, "", $sAdrClassNN, $sPath)
				; Tekl reported the following: "If I want to change to Folder L:\folder
				; then the addressbar shows http://www.L:\folder.com. To solve this,
				; I added a {right} before {Enter}":
				ControlSend($hWnd, "", $sAdrClassNN, "{Right}{Enter}")
			Case "Progman", "WorkerW", "Shell_TrayWnd" ; Desktop or Taskbar
				If $sFileManager = "" Then
					ShellExecute($sPath)
				Else
					If StringInStr($sFileManager, "%s") Then
						Run(StringReplace($sFileManager, "%s", $sPath))
					Else
						Run($sFileManager & " " & """" & $sPath & """")
					EndIf
				EndIf
			Case "ConsoleWindowClass" ; Command Prompt
				Send("cd /d " & $sPath & "\") ; (thanks to tireless for the /d switch)
				Send("{Enter}")
			Case "TTOTAL_CMD", "TxUNCOM", "TxUNCOM.UnicodeClass" ; Total Commander (thanks to FatZgrED)
				;Total Commander has Edit1 control but you need to cd to location
				ControlSetText($hWnd, "", $sAdrClassNN, "cd " & $sPath)
				ControlSend($hWnd, "", $sAdrClassNN, "{Enter}")
				; Case "TfcForm" ; FreeCommander (thanks to catweazle (John))
				; Send("!g")
				; ControlClick($hWnd, "", "TfcPathEdit1")
				; ControlSetText($hWnd, "", "TfcPathEdit1", $sPath)
				; ControlSend($hWnd, "", "TfcPathEdit1", "{Enter}")
			Case "Emacs" ; Emacs (thanks to catweazle (John))
				Send("!xfind-file{Enter}")
				Send($sPath & "{Tab}")
			Case Else
				If StringInStr($sWinClass, "bosa_sdm_") Then ; Microsoft Office application
					Local $sEdit1Text = ControlGetText($hWnd, "", $sAdrClassNN)
					ControlClick($hWnd, "", $sAdrClassNN) ;<----------important!!!
					ControlSetText($hWnd, "", $sAdrClassNN, $sPath)
					ControlSend($hWnd, "", $sAdrClassNN, "{Enter}")
					Sleep(100)
					ControlSetText($hWnd, "", $sAdrClassNN, $sEdit1Text)
				ElseIf StringInStr($sWinClass, "rxvt") Then ; Rxvt command prompt (thanks to catweazle (John))
					Send("cd '" & $sPath & "'{Enter}")
					Send("ls{Enter}")
					; Others
				Else
					ControlClick($hWnd, "", $sAdrClassNN)
					ControlSetText($hWnd, "", $sAdrClassNN, $sPath)
					ControlSend($hWnd, "", $sAdrClassNN, "{Right}{Enter}")
				EndIf
		EndSwitch
	EndIf
	Return 0
EndFunc

Func OpenFilter($sPath)
	WinActivate($hWnd)
	Switch $sWinClass
		Case "#32770" ; Dialog
			Local $sEdit1Text = ControlGetText($hWnd, "", $sAdrClassNN)
			ControlClick($hWnd, "", $sAdrClassNN)
			ControlSetText($hWnd, "", $sAdrClassNN, $sPath)
			ControlSend($hWnd, "", $sAdrClassNN, "{Enter}")
			Sleep(100) ; It needs extra time on some dialogs or in some cases.
			ControlSetText($hWnd, "", $sAdrClassNN, $sEdit1Text)
		Case "ConsoleWindowClass" ; Command Prompt (thanks to Mr. Milk)
			$sPath = StringReplace($sPath, ";", " ")
			$sPath = "for /R %a in (" & $sPath & ") do @echo %~aa %~ta %~za %~Fa"
			Send("cmd.exe /F:OFF{Enter}")
			Send($sPath)
			Send("{Enter}exit{Enter}")
		Case Else
			If $sOSVersion = "WIN_VISTA" Then ; Vista Explorer (thanks to Mr. Milk)
				If $sPath <> "*.*" Then
					$sPath = StringReplace($sPath, ";", " OR ")
				EndIf
				If $sWinClass = "CabinetWClass" Then
					Send("^e") ; Set focus on searchbox to enable Edit2
				Else
					Send("#f") ; Open vista search
					WinWaitActive("[CLASS:CabinetWClass]", "", 5)
					$hWnd = WinGetHandle("[CLASS:CabinetWClass]")
					Sleep(100)
				EndIf
				Send($sPath)
			ElseIf StringInStr($sWinClass, "bosa_sdm_") Then ; Microsoft Office application
				Local $sEdit1Text = ControlGetText($hWnd, "", $sAdrClassNN)
				ControlClick($hWnd, "", $sAdrClassNN)
				ControlSetText($hWnd, "", $sAdrClassNN, $sPath)
				ControlSend($hWnd, "", $sAdrClassNN, "{Enter}")
				Sleep(100)
				ControlSetText($hWnd, "", $sAdrClassNN, $sEdit1Text)
			Else
				Return 1
			EndIf
	EndSwitch
	Return 0
EndFunc

Func OpenFile($sPath)
	If StringLeft($sPath, 7) = "cmd.exe" Then
		Run($sPath)
	ElseIf StringInStr($sPath, ".exe") Then
		Run($sPath)
	Else
		Local $sDrive, $sDir, $sFName, $sExt
		_PathSplit($sPath, $sDrive, $sDir, $sFName, $sExt)
		ShellExecute($sPath, "", $sDrive & $sDir)
	EndIf
	Return @error
EndFunc

Func OpenUrl($sPath)
	If $sBrowser = "" Then
		ShellExecute($sPath)
	Else
		If StringInStr($sBrowser, "%s") Then
			Run(StringReplace($sBrowser, "%s", $sPath))
		Else
			Run($sBrowser & " " & """" & $sPath & """")
		EndIf
	EndIf
	Return 0
EndFunc

Func OpenReg($sPath)
	Switch StringLeft($sPath, 4)
		Case "HKCR"
			$sPath = StringReplace($sPath, "HKCR", "HKEY_CLASSES_ROOT", 1)
		Case "HKCU"
			$sPath = StringReplace($sPath, "HKCU", "HKEY_CURRENT_USER", 1)
		Case "HKLM"
			$sPath = StringReplace($sPath, "HKLM", "HKEY_LOCAL_MACHINE", 1)
	EndSwitch

	If StringLeft($sPath, 4) = "HKEY" Then
		#cs
			Local $sComputer = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit", "LastKey")
			Local $sDummy
			StringSplit2($sComputer, "\", $sComputer, $sDummy)
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit", "LastKey", "REG_SZ", $sComputer & "\" & $sPath)
			Run("regedit.exe /m") ; thanks to DemoJameson for the /m switch
		#ce
		Run("regedit.exe /m")
		WinWaitActive("[CLASS:RegEdit_RegEdit]", "", 5)
		Local $sItem
		While 1 ; Collapse all
			$sItem = ControlTreeView("[CLASS:RegEdit_RegEdit]", "", "[CLASSNN:SysTreeView321]", "GetSelected", 1)
			$sItem = StringLeft($sItem, StringInStr($sItem, "|", 0, -1) - 1)
			If $sItem = "" Then ExitLoop
			ControlTreeView("[CLASS:RegEdit_RegEdit]", "", "[CLASSNN:SysTreeView321]", "Collapse", $sItem)
		WEnd
		Local $aPath = _StringExplode($sPath, "\")
		$sItem = "#0"
		For $i = 0 To UBound($aPath) - 1
			ControlTreeView("[CLASS:RegEdit_RegEdit]", "", "[CLASSNN:SysTreeView321]", "Expand", $sItem)
			$sItem &= "|" & $aPath[$i]
			ControlTreeView("[CLASS:RegEdit_RegEdit]", "", "[CLASSNN:SysTreeView321]", "Select", $sItem)
		Next
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func OpenUNC($sPath)
	If StringInStr($sPath, "\", 2, 3) Then
		Local $sPathIP = StringMid($sPath, 3, StringInStr($sPath, "\", 2, 3) - 3)
	Else
		Local $sPathIP = StringMid($sPath, 3)
	EndIf
	Ping($sPathIP, 1000) ; 1s timeout
	If @error = 0 Then
		OpenFolder($sPath)
		Return 0
	Else
		Local $sCannotOpenDown = StringReplace($sLang_CannotOpenDown, "%ThisPathIP%", $sPathIP)
		TrayTip($sLang_Error, $sCannotOpenDown, 5, 3)
		Return 1
	EndIf
EndFunc
#endregion Open Item

#region Misc.
Func _WinAPI_CreateSolidBitmap2($hWnd, $iColor, $iWidth, $iHeight) ; reuse background bitmap to save time
	Local $iSize, $tBMI, $hDC, $hBmp
	$iSize = $iWidth * $iHeight
	If $iMenuBkSize < $iSize Then
		$iMenuBkSize = $iSize
		$tMenuBkBits = DllStructCreate("int[" & $iSize & "]")
		For $i = 1 To $iSize
			DllStructSetData($tMenuBkBits, 1, $iColor, $i)
		Next
	EndIf
	$tBMI = DllStructCreate($tagBITMAPINFO)
	DllStructSetData($tBMI, "Size", DllStructGetSize($tBMI) - 4)
	DllStructSetData($tBMI, "Planes", 1)
	DllStructSetData($tBMI, "BitCount", 32)
	DllStructSetData($tBMI, "Width", $iWidth)
	DllStructSetData($tBMI, "Height", $iHeight)
	$hDC = _WinAPI_GetDC($hWnd)
	$hBmp = _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
	_WinAPI_SetDIBits(0, $hBmp, 0, $iHeight, DllStructGetPtr($tMenuBkBits), DllStructGetPtr($tBMI))
	_WinAPI_ReleaseDC($hWnd, $hDC)
	Return $hBmp
EndFunc

Func _WinAPI_GetCommandLineFromPID($iPID)

	Local $aCall = DllCall("kernel32.dll", "handle", "OpenProcess", _
			"dword", 1040, _ ; PROCESS_VM_READ | PROCESS_QUERY_INFORMATION
			"bool", 0, _
			"dword", $iPID)

	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, "")
	EndIf

	Local $hProcess = $aCall[0]

	Local $tPROCESS_BASIC_INFORMATION = DllStructCreate("dword_ptr ExitStatus;" & _
			"ptr PebBaseAddress;" & _
			"dword_ptr AffinityMask;" & _
			"dword_ptr BasePriority;" & _
			"dword_ptr UniqueProcessId;" & _
			"dword_ptr InheritedFromUniqueProcessId")

	$aCall = DllCall("ntdll.dll", "int", "NtQueryInformationProcess", _
			"handle", $hProcess, _
			"dword", 0, _ ; ProcessBasicInformation
			"ptr", DllStructGetPtr($tPROCESS_BASIC_INFORMATION), _
			"dword", DllStructGetSize($tPROCESS_BASIC_INFORMATION), _
			"dword*", 0)

	If @error Then
		DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
		Return SetError(2, 0, "")
	EndIf

	Local $tPEB = DllStructCreate("byte InheritedAddressSpace;" & _
			"byte ReadImageFileExecOptions;" & _
			"byte BeingDebugged;" & _
			"byte Spare;" & _
			"ptr Mutant;" & _
			"ptr ImageBaseAddress;" & _
			"ptr LoaderData;" & _
			"ptr ProcessParameters;" & _
			"ptr SubSystemData;" & _
			"ptr ProcessHeap;" & _
			"ptr FastPebLock;" & _
			"ptr FastPebLockRoutine;" & _
			"ptr FastPebUnlockRoutine;" & _
			"dword EnvironmentUpdateCount;" & _
			"ptr KernelCallbackTable;" & _
			"ptr EventLogSection;" & _
			"ptr EventLog;" & _
			"ptr FreeList;" & _
			"dword TlsExpansionCounter;" & _
			"ptr TlsBitmap;" & _
			"dword TlsBitmapBits[2];" & _
			"ptr ReadOnlySharedMemoryBase;" & _
			"ptr ReadOnlySharedMemoryHeap;" & _
			"ptr ReadOnlyStaticServerData;" & _
			"ptr AnsiCodePageData;" & _
			"ptr OemCodePageData;" & _
			"ptr UnicodeCaseTableData;" & _
			"dword NumberOfProcessors;" & _
			"dword NtGlobalFlag;" & _
			"ubyte Spare2[4];" & _
			"int64 CriticalSectionTimeout;" & _
			"dword HeapSegmentReserve;" & _
			"dword HeapSegmentCommit;" & _
			"dword HeapDeCommitTotalFreeThreshold;" & _
			"dword HeapDeCommitFreeBlockThreshold;" & _
			"dword NumberOfHeaps;" & _
			"dword MaximumNumberOfHeaps;" & _
			"ptr ProcessHeaps;" & _
			"ptr GdiSharedHandleTable;" & _
			"ptr ProcessStarterHelper;" & _
			"ptr GdiDCAttributeList;" & _
			"ptr LoaderLock;" & _
			"dword OSMajorVersion;" & _
			"dword OSMinorVersion;" & _
			"dword OSBuildNumber;" & _
			"dword OSPlatformId;" & _
			"dword ImageSubSystem;" & _
			"dword ImageSubSystemMajorVersion;" & _
			"dword ImageSubSystemMinorVersion;" & _
			"dword GdiHandleBuffer[34];" & _
			"dword PostProcessInitRoutine;" & _
			"dword TlsExpansionBitmap;" & _
			"byte TlsExpansionBitmapBits[128];" & _
			"dword SessionId")

	$aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", _
			"ptr", $hProcess, _
			"ptr", DllStructGetData($tPROCESS_BASIC_INFORMATION, "PebBaseAddress"), _
			"ptr", DllStructGetPtr($tPEB), _
			"dword", DllStructGetSize($tPEB), _
			"dword*", 0)

	If @error Or Not $aCall[0] Then
		DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
		Return SetError(3, 0, "")
	EndIf

	Local $tPROCESS_PARAMETERS = DllStructCreate("dword AllocationSize;" & _
			"dword ActualSize;" & _
			"dword Flags;" & _
			"dword Unknown1;" & _
			"word LengthUnknown2;" & _
			"word MaxLengthUnknown2;" & _
			"ptr Unknown2;" & _
			"handle InputHandle;" & _
			"handle OutputHandle;" & _
			"handle ErrorHandle;" & _
			"word LengthCurrentDirectory;" & _
			"word MaxLengthCurrentDirectory;" & _
			"ptr CurrentDirectory;" & _
			"handle CurrentDirectoryHandle;" & _
			"word LengthSearchPaths;" & _
			"word MaxLengthSearchPaths;" & _
			"ptr SearchPaths;" & _
			"word LengthApplicationName;" & _
			"word MaxLengthApplicationName;" & _
			"ptr ApplicationName;" & _
			"word LengthCommandLine;" & _
			"word MaxLengthCommandLine;" & _
			"ptr CommandLine;" & _
			"ptr EnvironmentBlock;" & _
			"dword Unknown[9];" & _
			"word LengthUnknown3;" & _
			"word MaxLengthUnknown3;" & _
			"ptr Unknown3;" & _
			"word LengthUnknown4;" & _
			"word MaxLengthUnknown4;" & _
			"ptr Unknown4;" & _
			"word LengthUnknown5;" & _
			"word MaxLengthUnknown5;" & _
			"ptr Unknown5;")

	$aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", _
			"ptr", $hProcess, _
			"ptr", DllStructGetData($tPEB, "ProcessParameters"), _
			"ptr", DllStructGetPtr($tPROCESS_PARAMETERS), _
			"dword", DllStructGetSize($tPROCESS_PARAMETERS), _
			"dword*", 0)

	If @error Or Not $aCall[0] Then
		DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
		Return SetError(4, 0, "")
	EndIf

	; Local $aParameters[8]
	; Local $ii = 0
	; $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "ptr", $hProcess, "ptr", DllStructGetData($tPROCESS_PARAMETERS, "Unknown2"        ), "wstr", "", "dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthUnknown2"        ), "dword*", 0)
	; $aParameters[$ii] = $aCall[3]
	; $ii += 1
	; $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "ptr", $hProcess, "ptr", DllStructGetData($tPROCESS_PARAMETERS, "CurrentDirectory"), "wstr", "", "dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthCurrentDirectory"), "dword*", 0)
	; $aParameters[$ii] = $aCall[3]
	; $ii += 1
	; $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "ptr", $hProcess, "ptr", DllStructGetData($tPROCESS_PARAMETERS, "SearchPaths"     ), "wstr", "", "dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthSearchPaths"     ), "dword*", 0)
	; $aParameters[$ii] = $aCall[3]
	; $ii += 1
	; $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "ptr", $hProcess, "ptr", DllStructGetData($tPROCESS_PARAMETERS, "ApplicationName" ), "wstr", "", "dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthApplicationName" ), "dword*", 0)
	; $aParameters[$ii] = $aCall[3]
	; $ii += 1
	; $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "ptr", $hProcess, "ptr", DllStructGetData($tPROCESS_PARAMETERS, "CommandLine"     ), "wstr", "", "dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthCommandLine"     ), "dword*", 0)
	; $aParameters[$ii] = $aCall[3]
	; $ii += 1
	; $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "ptr", $hProcess, "ptr", DllStructGetData($tPROCESS_PARAMETERS, "Unknown3"        ), "wstr", "", "dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthUnknown3"        ), "dword*", 0)
	; $aParameters[$ii] = $aCall[3]
	; $ii += 1
	; $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "ptr", $hProcess, "ptr", DllStructGetData($tPROCESS_PARAMETERS, "Unknown4"        ), "wstr", "", "dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthUnknown4"        ), "dword*", 0)
	; $aParameters[$ii] = $aCall[3]
	; $ii += 1
	; $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "ptr", $hProcess, "ptr", DllStructGetData($tPROCESS_PARAMETERS, "Unknown5"        ), "wstr", "", "dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthUnknown5"        ), "dword*", 0)
	; $aParameters[$ii] = $aCall[3]
	; _ArrayDisplay($aParameters)

	$aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", _
			"ptr", $hProcess, _
			"ptr", DllStructGetData($tPROCESS_PARAMETERS, "CommandLine"), _
			"wstr", "", _
			"dword", DllStructGetData($tPROCESS_PARAMETERS, "MaxLengthCommandLine"), _
			"dword*", 0)

	If @error Or Not $aCall[0] Then
		DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
		Return SetError(5, 0, "")
	EndIf

	DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)

	Return $aCall[3]

EndFunc

Func IsFolder($sPath)
	$sPath = DerefPath($sPath)
	If StringInStr(FileGetAttrib($sPath), "D") Or $sPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func MenuSecondaryDown()
	$fSecondaryDown = 1
EndFunc

Func StringSplit2($sString, $sDelimiter, ByRef $sLeftStr, ByRef $sRightStr)
	Local $iSplitPos = StringInStr($sString, $sDelimiter)
	If $iSplitPos = 0 Then ; Separator not found, L = Str, R = ""
		$sLeftStr = $sString
		$sRightStr = ""
	Else
		$iSplitPos -= 1
		$sLeftStr = StringLeft($sString, $iSplitPos)
		$iSplitPos += StringLen($sDelimiter)
		$sRightStr = StringTrimLeft($sString, $iSplitPos)
	EndIf
	Return
EndFunc

Func SplitIconPath($sIcon, ByRef $sPath, ByRef $iIndex, ByRef $iSize)
	StringSplit2($sIcon, ",", $sPath, $iIndex)
	StringSplit2($iIndex, ",", $iIndex, $iSize)
EndFunc

Func TrimVarName($sString)
	Return StringRegExpReplace($sString, "[\W]", "_")
EndFunc

Func LoadingTip($sText = "", $sTitle = $sLoadingTipTitle, $iIcon = 1)
	If $sText = "" Then $sText = $sLoadingTipText
	If $iLoadingTip = 1 Then
		ToolTip2($sText, $sTitle, $iIcon)
	ElseIf $iLoadingTip = 2 Then
		TrayTip($sTitle, $sText, 5, $iIcon)
	EndIf
EndFunc

Func ToolTip2($sText, $sTitle = "FolderMenu3 EX", $iIcon = 0, $iX = 16, $iY = 16)
	Local $pos = MouseGetPos()
	ToolTip($sText, $pos[0] + $iX, $pos[1] + $iY, $sTitle, $iIcon)
EndFunc

Func DerefPath($sPath)
	If StringRight($sPath, 1) = "\" Then $sPath = StringTrimRight($sPath, 1)
	If StringRight($sPath, 1) = ":" Then $sPath &= "\" ; it a drive root
	If $sPath = "Computer" Then $sPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
	If $sPath = $sLang_Computer Then $sPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
	If $sPath = """::{20D04FE0-3AEA-1069-A2D8-08002B30309D}""" Then $sPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
	Opt('ExpandEnvStrings', 1)
	Opt('ExpandVarStrings', 1)
	$sPath = $sPath
	Opt('ExpandEnvStrings', 0)
	Opt('ExpandVarStrings', 0)
	If StringLeft($sPath, 1) = "." Then $sPath = _PathFull($sPath, @ScriptDir)
	Return $sPath
EndFunc

Func _IsPressedI($iHexKey)
	Local $aRet = DllCall('user32.dll', "int", "GetAsyncKeyState", "int", $iHexKey)
	If Not @error And BitAND($aRet[0], 0x8000) = 0x8000 Then Return 1
	Return 0
EndFunc

Func GetShellWindowObj($hWnd)
	If _WinAPI_GetClassName($hWnd) <> "CabinetWClass" Then Return 0
	Local $oShell = ObjCreate("Shell.Application") ; Get the Windows Shell Object
	Local $oShellWindows = $oShell.Windows ; Get the collection of open shell Windows
	If IsObj($oShellWindows) Then
		For $oWindow In $oShellWindows ; Count all existing shell windows
			If $oWindow.hWnd = $hWnd Then Return $oWindow
		Next
	EndIf
	Return 0
EndFunc

Func _ComErrorHandler()
	Local $HexNumber = Hex($oMyError.number, 8)
	If @error Then Return
	Local $msg = "COM Error!" & @CRLF & @CRLF & _
			"err.description is: " & @TAB & $oMyError.description & @CRLF & _
			"err.windescription:" & @TAB & $oMyError.windescription & @CRLF & _
			"err.number is: " & @TAB & $HexNumber & @CRLF & _
			"err.lastdllerror is: " & @TAB & $oMyError.lastdllerror & @CRLF & _
			"err.scriptline is: " & @TAB & $oMyError.scriptline & @CRLF & _
			"err.source is: " & @TAB & $oMyError.source & @CRLF & _
			"err.helpfile is: " & @TAB & $oMyError.helpfile & @CRLF & _
			"err.helpcontext is: " & @TAB & $oMyError.helpcontext
	MsgBox(0, $sLang_Error, $msg)
	SetError(1)
EndFunc

Func msg($t = "")
	MsgBox(0, "FolderMenu3 EX", $t)
EndFunc

Func _Test()
	Return
EndFunc
#endregion Misc.

#New - February 14, 2013
; If Exe Name Different, Change Configuration to Point at New Executable Name.
; This Is to Fix Problems With Initial Configuration. Icons Point At FolderMenu.exe
; by Default (Default.xml) So If Exe Name Is Different, Embedded Icons Won't Show.
; Only Works For First Time Run. Existing Users Must Manually Edit FolderMenu.xml.
; http://www.autoitscript.com/forum/topic/1674-how-to-search-and-replace-text-in-a-file/
Func ExeNameCheck()
	If @ScriptName == "FolderMenu.exe" Then
	Else
		Local $Config, $ConfigText
		$ConfigText = FileRead($sConfigFile, FileGetSize($sConfigFile))
		$ConfigText = StringReplace($ConfigText, "FolderMenu.exe", @ScriptName)
		FileDelete($sConfigFile)
		FileWrite($sConfigFile, $ConfigText)
	EndIf
EndFunc
