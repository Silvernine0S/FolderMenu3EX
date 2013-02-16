#include-once

; #INDEX# =======================================================================================================================
; Title .........: File
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Functions that assist with files and directories.
; Author(s) .....: Brian Keene, SolidSnake, erifash, Jon, JdeB, Jeremy Landes, MrCreatoR, cdkid, Valik,Erik Pilsits, Kurt, Dale
; Dll(s) ........: shell32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_PathFull
;_PathGetRelative
;_PathSplit
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _PathFull
; Description ...: Creates a path based on the relative path you provide. The newly created absolute path is returned
; Syntax.........: _PathFull($sRelativePath)
; Parameters ....: $sRelativePath - The relative path to be created
; Return values .: Success - Returns the newly created absolute path.
; Author ........: Valik (Original function and modification to rewrite), tittoproject (Rewrite)
; Modified.......:
; Remarks .......:
; Related .......: _PathMake, _PathSplit, .DirCreate, .FileChangeDir
; Link ..........:
; Example .......: Yes
; Notes .........: UNC paths are supported.
;                  Pass "\" to get the root drive of $sBasePath.
;                  Pass "" or "." to return $sBasePath.
;                  A relative path will be built relative to $sBasePath.  To bypass this behavior, use an absolute path.
; ===============================================================================================================================
Func _PathFull($sRelativePath, $sBasePath = @WorkingDir)
	If Not $sRelativePath Or $sRelativePath = "." Then Return $sBasePath

	; Normalize slash direction.
	Local $sFullPath = StringReplace($sRelativePath, "/", "\") ; Holds the full path (later, minus the root)
	Local Const $sFullPathConst = $sFullPath ; Holds a constant version of the full path.
	Local $sPath ; Holds the root drive/server
	Local $bRootOnly = StringLeft($sFullPath, 1) = "\" And StringMid($sFullPath, 2, 1) <> "\"

	; Check for UNC paths or local drives.  We run this twice at most.  The
	; first time, we check if the relative path is absolute.  If it's not, then
	; we use the base path which should be absolute.
	For $i = 1 To 2
		$sPath = StringLeft($sFullPath, 2)
		If $sPath = "\\" Then
			$sFullPath = StringTrimLeft($sFullPath, 2)
			Local $nServerLen = StringInStr($sFullPath, "\") -1
			$sPath = "\\" & StringLeft($sFullPath, $nServerLen)
			$sFullPath = StringTrimLeft($sFullPath, $nServerLen)
			ExitLoop
		ElseIf StringRight($sPath, 1) = ":" Then
			$sFullPath = StringTrimLeft($sFullPath, 2)
			ExitLoop
		Else
			$sFullPath = $sBasePath & "\" & $sFullPath
		EndIf
	Next

	; If this happens, we've found a funky path and don't know what to do
	; except for get out as fast as possible.  We've also screwed up our
	; variables so we definitely need to quit.
	If $i = 3 Then Return ""

	; A path with a drive but no slash (e.g. C:Path\To\File) has the following
	; behavior.  If the relative drive is the same as the $BasePath drive then
	; insert the base path.  If the drives differ then just insert a leading
	; slash to make the path valid.
	If StringLeft($sFullPath, 1) <> "\" Then
		If StringLeft($sFullPathConst, 2) = StringLeft($sBasePath, 2) Then
			$sFullPath = $sBasePath & "\" & $sFullPath
		Else
			$sFullPath = "\" & $sFullPath
		EndIf
	EndIf

	; Build an array of the path parts we want to use.
	Local $aTemp = StringSplit($sFullPath, "\")
	Local $aPathParts[$aTemp[0]], $j = 0
	For $i = 2 To $aTemp[0]
		If $aTemp[$i] = ".." Then
			If $j Then $j -= 1
		ElseIf Not ($aTemp[$i] = "" And $i <> $aTemp[0]) And $aTemp[$i] <> "." Then
			$aPathParts[$j] = $aTemp[$i]
			$j += 1
		EndIf
	Next

	; Here we re-build the path from the parts above.  We skip the
	; loop if we are only returning the root.
	$sFullPath = $sPath
	If Not $bRootOnly Then
		For $i = 0 To $j - 1
			$sFullPath &= "\" & $aPathParts[$i]
		Next
	Else
		$sFullPath &= $sFullPathConst
		; If we detect more relative parts, remove them by calling ourself recursively.
		If StringInStr($sFullPath, "..") Then $sFullPath = _PathFull($sFullPath)
	EndIf

	; Clean up the path.
	While StringInStr($sFullPath, ".\")
		$sFullPath = StringReplace($sFullPath, ".\", "\")
	WEnd
	Return $sFullPath
EndFunc   ;==>_PathFull

; #FUNCTION# ====================================================================================================================
; Name...........: _PathGetRelative
; Description ...: Returns the relative path to a directory
; Syntax.........: _PathGetRelative($sFrom, $sTo)
; Parameters ....: $sFrom  - Path to the source directory
;                  $sTo    - Path to the destination file or directory
; Return values .: Success - Relative path to the destination.
;                  Failure - Returns the destination and Sets @Error:
;                  |1 - $sFrom equlas $sTo
;                  |2 - Root drives of $sFrom and $sTo are different, a relative path is impossible.
; Author ........: Erik Pilsits
; Modified.......:
; Remarks .......: The returned path will not have a trailing "\", even if it is a root
;                  drive returned after a failure.
; Related .......:
; Link ..........:
; Example .......: Yes
; Notes .........: Original function by Yann Perrin <yann.perrin+clef@gmail.com> and
;                  Lahire Biette <tuxmouraille@gmail.com>, authors of C.A.F.E. Mod.
; ===============================================================================================================================
Func _PathGetRelative($sFrom, $sTo)
	If StringRight($sFrom, 1) <> "\" Then $sFrom &= "\" ; add missing trailing \ to $sFrom path
	If StringRight($sTo, 1) <> "\" Then $sTo &= "\" ; add trailing \ to $sTo
	If $sFrom = $sTo Then Return SetError(1, 0, StringTrimRight($sTo, 1)) ; $sFrom equals $sTo
	Local $asFrom = StringSplit($sFrom, "\")
	Local $asTo = StringSplit($sTo, "\")
	If $asFrom[1] <> $asTo[1] Then Return SetError(2, 0, StringTrimRight($sTo, 1)) ; drives are different, rel path not possible
	; create rel path
	Local $i = 2
	Local $iDiff = 1
	While 1
		If $asFrom[$i] <> $asTo[$i] Then
			$iDiff = $i
			ExitLoop
		EndIf
		$i += 1
	WEnd
	$i = 1
	Local $sRelPath = ""
	For $j = 1 To $asTo[0]
		If $i >= $iDiff Then
			$sRelPath &= "\" & $asTo[$i]
		EndIf
		$i += 1
	Next
	$sRelPath = StringTrimLeft($sRelPath, 1)
	$i = 1
	For $j = 1 To $asFrom[0]
		If $i > $iDiff Then
			$sRelPath = "..\" & $sRelPath
		EndIf
		$i += 1
	Next
	If StringRight($sRelPath, 1) == "\" Then $sRelPath = StringTrimRight($sRelPath, 1) ; remove trailing \
	Return $sRelPath
EndFunc   ;==>_PathGetRelative

; #FUNCTION# ====================================================================================================================
; Name...........: _PathSplit
; Description ...: Splits a path into the drive, directory, file name and file extension parts. An empty string is set if a part is missing.
; Syntax.........: _PathSplit($szPath, ByRef $szDrive, ByRef $szDir, ByRef $szFName, ByRef $szExt)
; Parameters ....: $szPath  - The path to be split (Can contain a UNC server or drive letter)
;                  $szDrive - String to hold the drive
;                  $szDir   - String to hold the directory
;                  $szFName - String to hold the file name
;                  $szExt   - String to hold the file extension
; Return values .: Success - Returns an array with 5 elements where 0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
; Author ........: Valik
; Modified.......:
; Remarks .......: This function does not take a command line string. It works on paths, not paths with arguments.
; Related .......: _PathFull, _PathMake
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _PathSplit($szPath, ByRef $szDrive, ByRef $szDir, ByRef $szFName, ByRef $szExt)
	; Set local strings to null (We use local strings in case one of the arguments is the same variable)
	Local $drive = ""
	Local $dir = ""
	Local $fname = ""
	Local $ext = ""
	Local $pos

	; Create an array which will be filled and returned later
	Local $array[5]
	$array[0] = $szPath; $szPath can get destroyed, so it needs set now

	; Get drive letter if present (Can be a UNC server)
	If StringMid($szPath, 2, 1) = ":" Then
		$drive = StringLeft($szPath, 2)
		$szPath = StringTrimLeft($szPath, 2)
	ElseIf StringLeft($szPath, 2) = "\\" Then
		$szPath = StringTrimLeft($szPath, 2) ; Trim the \\
		$pos = StringInStr($szPath, "\")
		If $pos = 0 Then $pos = StringInStr($szPath, "/")
		If $pos = 0 Then
			$drive = "\\" & $szPath; Prepend the \\ we stripped earlier
			$szPath = ""; Set to null because the whole path was just the UNC server name
		Else
			$drive = "\\" & StringLeft($szPath, $pos - 1) ; Prepend the \\ we stripped earlier
			$szPath = StringTrimLeft($szPath, $pos - 1)
		EndIf
	EndIf

	; Set the directory and file name if present
	Local $nPosForward = StringInStr($szPath, "/", 0, -1)
	Local $nPosBackward = StringInStr($szPath, "\", 0, -1)
	If $nPosForward >= $nPosBackward Then
		$pos = $nPosForward
	Else
		$pos = $nPosBackward
	EndIf
	$dir = StringLeft($szPath, $pos)
	$fname = StringRight($szPath, StringLen($szPath) - $pos)

	; If $szDir wasn't set, then the whole path must just be a file, so set the filename
	If StringLen($dir) = 0 Then $fname = $szPath

	$pos = StringInStr($fname, ".", 0, -1)
	If $pos Then
		$ext = StringRight($fname, StringLen($fname) - ($pos - 1))
		$fname = StringLeft($fname, $pos - 1)
	EndIf

	; Set the strings and array to what we found
	$szDrive = $drive
	$szDir = $dir
	$szFName = $fname
	$szExt = $ext
	$array[1] = $drive
	$array[2] = $dir
	$array[3] = $fname
	$array[4] = $ext
	Return $array
EndFunc   ;==>_PathSplit
