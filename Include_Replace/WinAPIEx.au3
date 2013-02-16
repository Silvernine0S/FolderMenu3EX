#Region Header

#cs

    Title:          WinAPI Extended UDF Library for AutoIt3
    Filename:       WinAPIEx.au3
    Description:    Additional variables, constants and functions for the WinAPI.au3
    Author:         Yashied
    Version:        2.2
    Requirements:   AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
    Uses:           StructureConstants.au3, WinAPI.au3
    Notes:          -

                    http://www.autoitscript.com/forum/index.php?showtopic=98712

    Available functions:

    _WinAPI_AssocQueryString
    _WinAPI_DragFinish
    _WinAPI_DragQueryFileEx
    _WinAPI_GetKeyState
    _WinAPI_GetModuleFileNameEx
    _WinAPI_PathUnExpandEnvStrings
    _WinAPI_PickIconDlg
    _WinAPI_ShellExtractIcons
    _WinAPI_ShellGetFileInfo

   * Available in native AutoIt library
  ** Deprecated

#ce

#Include-once

#Include <StructureConstants.au3>
#Include <WinAPI.au3>

#EndRegion Header

#Region Global Variables and Constants

; ===============================================================================================================================
; _WinAPI_AssocQueryString()
; ===============================================================================================================================

Global Const $ASSOCSTR_DEFAULTICON = 15

Global Const $ASSOCF_INIT_IGNOREUNKNOWN = 0x00000400

; ===============================================================================================================================
; _WinAPI_ShellGetFileInfo()
; ===============================================================================================================================

Global Const $SHGFI_ICONLOCATION = 0x00001000

; ===============================================================================================================================
; *Structure constants
; ===============================================================================================================================

Global Const $tagSHFILEINFO = 'ptr hIcon;int iIcon;dword Attributes;wchar DisplayName[260];wchar TypeName[80]'

#EndRegion Global Variables and Constants

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AssocQueryString
; Description....: Searches for and retrieves a file or protocol association-related string from the registry.
; Syntax.........: _WinAPI_AssocQueryString ( $sAssoc, $iType [, $iFlags [, $sExtra]] )
; Parameters.....: $sAssoc - The string that is used to determine the root key. The following four types of strings can be used.
;
;                            The file name extension, such as .txt.
;                            The class identifier (CLSID) GUID in the standard "{GUID}" format.
;                            The application's ProgID, such as Word.Document.8.
;                            The name of an application's .exe file. The $ASSOCF_OPEN_BYEXENAME flag must be set.
;
;                  $iType  - The value that specifies the type of string that is to be returned. This parameter can be one of the
;                            following values.
;
;                            $ASSOCSTR_COMMAND
;                            $ASSOCSTR_EXECUTABLE
;                            $ASSOCSTR_FRIENDLYDOCNAME
;                            $ASSOCSTR_FRIENDLYAPPNAME
;                            $ASSOCSTR_NOOPEN
;                            $ASSOCSTR_SHELLNEWVALUE
;                            $ASSOCSTR_DDECOMMAND
;                            $ASSOCSTR_DDEIFEXEC
;                            $ASSOCSTR_DDEAPPLICATION
;                            $ASSOCSTR_DDETOPIC
;                            $ASSOCSTR_INFOTIP
;                            $ASSOCSTR_QUICKTIP
;                            $ASSOCSTR_TILEINFO
;                            $ASSOCSTR_CONTENTTYPE
;                            $ASSOCSTR_DEFAULTICON
;                            $ASSOCSTR_SHELLEXTENSION
;
;                  $iFlags - The flags that can be used to control the search. It can be any combination of the following
;                            values, except that only one $ASSOCF_INIT_... value can be included.
;
;                            $ASSOCF_INIT_NOREMAPCLSID
;                            $ASSOCF_INIT_BYEXENAME
;                            $ASSOCF_OPEN_BYEXENAME
;                            $ASSOCF_INIT_DEFAULTTOSTAR
;                            $ASSOCF_INIT_DEFAULTTOFOLDER
;                            $ASSOCF_NOUSERSETTINGS
;                            $ASSOCF_NOTRUNCATE
;                            $ASSOCF_VERIFY
;                            $ASSOCF_REMAPRUNDLL
;                            $ASSOCF_NOFIXUPS
;                            $ASSOCF_IGNOREBASECLASS
;                            $ASSOCF_INIT_IGNOREUNKNOWN
;
;                  $sExtra - The optional string with additional information about the location of the string. It is typically
;                            set to a Shell verb such as open.
; Return values..: Success - The string that contains the requested ($ASSOCSTR_...) information.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ AssocQueryString
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AssocQueryString($sAssoc, $iType, $iFlags = 0, $sExtra = '')

	Local $TypeOfExtra = 'wstr'

	If StringStripWS($sExtra, 3) = '' Then
		$TypeOfExtra = 'ptr'
		$sExtra = 0
	EndIf

	Local $Ret

	$Ret = DllCall('shlwapi.dll', 'int', 'AssocQueryStringW', 'dword', $iFlags, 'dword', $iType, 'wstr', $sAssoc, $TypeOfExtra, $sExtra, 'ptr', 0, 'dword*', 0)
    If (@error) Or (Not ($Ret[0] = 1)) Then
		Return SetError(1, 0, '')
	EndIf

	Local $tData = DllStructCreate('wchar[' & $Ret[6] & ']')

	$Ret = DllCall('shlwapi.dll', 'int', 'AssocQueryStringW', 'dword', $iFlags, 'dword', $iType, 'wstr', $sAssoc, $TypeOfExtra, $sExtra, 'ptr', DllStructGetPtr($tData), 'dword*', $Ret[6])
    If (@error) Or (Not ($Ret[0] = 0)) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_AssocQueryString

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DragFinish
; Description....: Releases memory that the system allocated for use in transferring file names to the application.
; Syntax.........: _WinAPI_DragFinish ( $hDrop )
; Parameters.....: $hDrop  - Handle of the drop structure that describes the dropped file. This parameter is passed to
;                            WM_DROPFILES message with WPARAM parameter.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DragFinish
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DragFinish($hDrop)

	Local $Ret = DllCall('shell32.dll', 'none', 'DragFinish', 'ptr', $hDrop)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DragFinish

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DragQueryFileEx
; Description....: Retrieves the names of dropped files that result from a successful drag-and-drop operation.
; Syntax.........: _WinAPI_DragQueryFileEx ( $hDrop [, $iFlag] )
; Parameters.....: $hDrop  - Handle of the drop structure that describes the dropped file. This parameter is passed to
;                            WM_DROPFILES message with WPARAM parameter.
;                  $iFlag  - The flag that specifies whether to return files folders or both, valid values:
;                  |0 - Return both files and folders. (Default)
;                  |1 - Return files only.
;                  |2 - Return folders only.
; Return values..: Success - The array of the names of a dropped files. The zeroth array element contains the number of file
;                            names in array. If no files that satisfy the condition ($iFlag), the function fails.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DragQueryFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DragQueryFileEx($hDrop, $iFlag = 0)

	Local $Ret, $Count, $Dir, $File, $tData, $aData[1] = [0]

	$Ret = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'ptr', $hDrop, 'uint', -1, 'ptr', 0, 'uint', 0)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$Count = $Ret[0]
	ReDim $aData[$Count + 1]
	For $i = 0 To $Count - 1
		$Ret = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'ptr', $hDrop, 'uint', $i, 'ptr', 0, 'uint', 0)
		$Ret = $Ret[0] + 1
		$tData = DllStructCreate('wchar[' & $Ret & ']')
		$Ret = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'ptr', $hDrop, 'uint', $i, 'ptr', DllStructGetPtr($tData), 'uint', $Ret)
		If Not $Ret[0] Then
			Return SetError(1, 0, 0)
		EndIf
		$File = DllStructGetData($tData, 1)
		$tData = 0
		If $iFlag Then
			$Dir = _WinAPI_PathIsDirectory($File)
			If Not @error Then
				If (($iFlag = 1) And ($Dir)) Or (($iFlag = 2) And (Not $Dir)) Then
					ContinueLoop
				EndIf
			EndIf
		EndIf
		$aData[$i + 1] = $File
		$aData[0] += 1
	Next
	If $aData[0] = 0 Then
		Return SetError(1, 0, 0)
	EndIf
	ReDim $aData[$aData[0] + 1]
	Return $aData
EndFunc   ;==>_WinAPI_DragQueryFileEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyState
; Description....: Retrieves the status of the specified virtual key.
; Syntax.........: _WinAPI_GetKeyState ( $vkCode )
; Parameters.....: $vkCode - Specifies a virtual key ($VK_...). If the desired virtual key is a letter or digit (A through Z,
;                            a through z, or 0 through 9).
; Return values..: Success - The value specifies the status of the specified virtual key. If the high-order bit is 1, the key is
;                            down; otherwise, it is up. If the low-order bit is 1, the key is toggled. A key, such as the
;                            CAPS LOCK key, is toggled if it is turned on. The key is off and untoggled if the low-order bit is 0.
;                            A toggle key's indicator light (if any) on the keyboard will be on when the key is toggled, and off
;                            when the key is untoggled.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The key status returned from this function changes as a process reads key messages from its message queue.
;                  The status does not reflect the interrupt-level state associated with the hardware. Use the _WinAPI_GetAsyncKeyState()
;                  function to retrieve that information.
; Related........:
; Link...........: @@MsdnLink@@ GetKeyState
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetKeyState($vkCode)

	Local $Ret = DllCall('user32.dll', 'int', 'GetKeyState', 'int', $vkCode)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetKeyState

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetModuleFileNameEx
; Description....: Retrieves the fully-qualified path for the file associated with the process.
; Syntax.........: _WinAPI_GetModuleFileNameEx ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The fully-qualified path to the file.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetModuleFileNameEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetModuleFileNameEx($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProc = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000410, 'int', 0, 'dword', $PID)

	If (@error) Or ($hProc[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf

	$hProc = $hProc[0]

	Local $tPath = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('psapi.dll', 'int', 'GetModuleFileNameExW', 'ptr', $hProc, 'ptr', 0, 'ptr', DllStructGetPtr($tPath), 'int', 1024)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProc)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, '')
	EndIf
	Return SetError(0, 0, DllStructGetData($tPath, 1))
EndFunc   ;==>_WinAPI_GetModuleFileNameEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathUnExpandEnvStrings
; Description....: Replaces folder names in a fully-qualified path with their associated environment string.
; Syntax.........: _WinAPI_PathUnExpandEnvStrings ( $sPath )
; Parameters.....: $sPath  - The path to be unexpanded.
; Return values..: Success - The unexpanded string.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathUnExpandEnvStrings
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathUnExpandEnvStrings($sPath)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathUnExpandEnvStringsW', 'wstr', $sPath, 'ptr', DllStructGetPtr($tData), 'uint', 1024)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_PathUnExpandEnvStrings

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PickIconDlg
; Description....: Displays a dialog box that allows the user to choose an icon.
; Syntax.........: _WinAPI_PickIconDlg ( [$sIcon [, $iIndex [, $hParent]]] )
; Parameters.....: $sIcon   - The fully-qualified path of the file that contains the initial icon.
;                  $iIndex  - The index of the initial icon.
;                  $hParent - Handle of the parent window.
; Return values..: Success  - The array containing the following parameters:
;                             [0] - The path of the file that contains the selected icon.
;                             [1] - The index of the selected icon.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function also sets the @error flag to 1 if the icon was not selected.
; Related........:
; Link...........: @@MsdnLink@@ PickIconDlg
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PickIconDlg($sIcon = '', $iIndex = 0, $hParent = 0)

	Local $tIcon = DllStructCreate('wchar[1024]'), $tIndex = DllStructCreate('int')
	Local $Ret, $Error = 1, $Result[2] = [$sIcon, $iIndex]

	DllStructSetData($tIcon, 1, $sIcon)
	DllStructSetData($tIndex, 1, $iIndex)
	$Ret = DllCall('shell32.dll', 'int', 'PickIconDlg', 'hwnd', $hParent, 'ptr', DllStructGetPtr($tIcon), 'int', 1024, 'ptr', DllStructGetPtr($tIndex))
	If (Not @error) And ($Ret[0] > 0) Then
		$Ret = DllCall('kernel32.dll', 'int', 'ExpandEnvironmentStringsW', 'wstr', DllStructGetData($tIcon, 1), 'ptr', DllStructGetPtr($tIcon), 'int', 1024)
		If (Not @error) And ($Ret[0] > 0) Then
			$Result[0] = DllStructGetData($tIcon, 1)
			$Result[1] = DllStructGetData($tIndex, 1)
			$Error = 0
		EndIf
	EndIf
	Return SetError($Error, 0, $Result)
EndFunc   ;==>_WinAPI_PickIconDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellExtractIcons
; Description....: Extracts the icon with the specified dimension from the specified file.
; Syntax.........: _WinAPI_ShellExtractIcons ( $sIcon, $iIndex, $iWidth, $iHeight )
; Parameters.....: $sIcon   - Path and name of the file from which the icon are to be extracted.
;                  $iIndex  - Index of the icon to extract.
;                  $iWidth  - Horizontal icon size wanted.
;                  $iHeight - Vertical icon size wanted.
; Return values..: Success  - Handle to the extracted icon.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the icon with the specified dimension is not found in the file, it will choose the nearest appropriate icon and
;                  change to the specified dimension. When you are finished using the icon, destroy it using the _WinAPI_FreeIcon()
;                  function.
; Related........:
; Link...........: @@MsdnLink@@ SHExtractIcons
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellExtractIcons($sIcon, $iIndex, $iWidth, $iHeight)

	Local $Ret = DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', $sIcon, 'int', $iIndex, 'int', $iWidth, 'int', $iHeight, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)

	If (@error) Or ($Ret[0] = 0) Or ($Ret[5] = Ptr(0)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_ShellExtractIcons

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetFileInfo
; Description....: Retrieves information about an object in the file system.
; Syntax.........: _WinAPI_ShellGetFileInfo ( $sPath, $iFlags [, $iAttributes] )
; Parameters.....: $sPath       - String that contains the absolute or relative path and file name. This string can use either
;                                 short (the 8.3 form) or long file names.
;
;                                 If the $iFlags parameter includes the $SHGFI_PIDL flag, this parameter must be the address of an
;                                 ITEMIDLIST (PIDL) structure that contains the list of item identifiers that uniquely identifies the
;                                 file within the Shell's namespace. The pointer to an item identifier list (PIDL) must be a fully
;                                 qualified PIDL. Relative PIDLs are not allowed.
;
;                                 If the $iFlags parameter includes the $SHGFI_USEFILEATTRIBUTES flag, this parameter does not have
;                                 to be a valid file name. The function will proceed as if the file exists with the specified name and
;                                 with the file attributes passed in the $iAttributes parameter. This allows you to obtain information
;                                 about a file type by passing just the extension for $sPath and passing $FILE_ATTRIBUTE_NORMAL
;                                 in $iAttributes.
;
;                  $iFlags      - The flags that specify the file information to retrieve. This parameter can be a combination of the
;                                 following values.
;
;                                 $SHGFI_ATTR_SPECIFIED
;                                 $SHGFI_ATTRIBUTES
;                                 $SHGFI_DISPLAYNAME
;                                 $SHGFI_EXETYPE
;                                 $SHGFI_ICON
;                                 $SHGFI_ICONLOCATION
;                                 $SHGFI_LARGEICON
;                                 $SHGFI_LINKOVERLAY
;                                 $SHGFI_OPENICON
;                                 $SHGFI_OVERLAYINDEX
;                                 $SHGFI_PIDL
;                                 $SHGFI_SELECTED
;                                 $SHGFI_SHELLICONSIZE
;                                 $SHGFI_SMALLICON
;                                 $SHGFI_SYSICONINDEX
;                                 $SHGFI_TYPENAME
;                                 $SHGFI_USEFILEATTRIBUTES
;
;                  $iAttributes - A combination of one or more file attribute flags ($FILE_ATTRIBUTE_...).
;
;                                 If $iFlags does not include the $SHGFI_USEFILEATTRIBUTES flag, this parameter is ignored. Default is 0x80
;                                 ($FILE_ATTRIBUTE_NORMAL).
;
; Return values..: Success      - $tagSHFILEINFO structure.
;
;                                 If $iFlags contains the $SHGFI_EXETYPE flag, the @extended flag specifies the type of the executable file.
;
;                                 If $iFlags contains the $SHGFI_SYSICONINDEX flag, the @extended flag specifies the handle to the
;                                 system image list.
;
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If this function returns an icon handle in the hIcon member of the $tagSHFILEINFO structure, you are responsible for
;                  freeing it with _WinAPI_FreeIcon() when you no longer need it.
; Related........:
; Link...........: @@MsdnLink@@ SHGetFileInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetFileInfo($sPath, $iFlags, $iAttributes = 0x80)

	Local $tSHFILEINFO = DllStructCreate($tagSHFILEINFO)
	Local $Ret = DllCall('shell32.dll', 'ptr', 'SHGetFileInfoW', 'wstr', $sPath, 'dword', $iAttributes, 'ptr', DllStructGetPtr($tSHFILEINFO), 'int', DllStructGetSize($tSHFILEINFO), 'int', $iFlags)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, $Ret[0], $tSHFILEINFO)
EndFunc   ;==>_WinAPI_ShellGetFileInfo
#EndRegion Public Functions
