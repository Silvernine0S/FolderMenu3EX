#include-once

#include "StructureConstants.au3"
#include "Security.au3"
#include "SendMessage.au3"
#include "WinAPIError.au3"

; #INDEX# =======================================================================================================================
; Title .........: Windows API
; AutoIt Version : 3.2
; Description ...: Windows API calls that have been translated to AutoIt functions.
; Author(s) .....: Paul Campbell (PaulIA), gafrost, Siao, Zedna, arcker, Prog@ndy, PsaltyDS, Raik, jpm
; Dll ...........: kernel32.dll, user32.dll, gdi32.dll, comdlg32.dll, shell32.dll, ole32.dll, winspool.drv
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__gaInProcess_WinAPI[64][2]	= [[0, 0]]
Global $__gaWinList_WinAPI[64][2]	= [[0, 0]]
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; GetWindows Constants
Global Const $__WINAPICONSTANT_GW_HWNDNEXT		= 2
Global Const $__WINAPICONSTANT_GW_CHILD			= 5

; DrawIconEx Constants
Global Const $__WINAPICONSTANT_DI_MASK			= 0x0001
Global Const $__WINAPICONSTANT_DI_IMAGE			= 0x0002
Global Const $__WINAPICONSTANT_DI_NORMAL		= 0x0003
Global Const $__WINAPICONSTANT_DI_COMPAT		= 0x0004
Global Const $__WINAPICONSTANT_DI_DEFAULTSIZE	= 0x0008
Global Const $__WINAPICONSTANT_DI_NOMIRROR		= 0x0010

;Window Hooks
Global Const $WH_CALLWNDPROC		= 4
Global Const $WH_CALLWNDPROCRET		= 12
Global Const $WH_CBT				= 5
Global Const $WH_DEBUG				= 9
Global Const $WH_FOREGROUNDIDLE		= 11
Global Const $WH_GETMESSAGE			= 3
Global Const $WH_JOURNALPLAYBACK	= 1
Global Const $WH_JOURNALRECORD		= 0
Global Const $WH_KEYBOARD			= 2
Global Const $WH_KEYBOARD_LL		= 13
Global Const $WH_MOUSE				= 7
Global Const $WH_MOUSE_LL			= 14
Global Const $WH_MSGFILTER			= -1
Global Const $WH_SHELL				= 10
Global Const $WH_SYSMSGFILTER		= 6

;flags for $tagKBDLLHOOKSTRUCT
Global Const $KF_EXTENDED		= 0x0100
Global Const $KF_ALTDOWN		= 0x2000
Global Const $KF_UP				= 0x8000
Global Const $LLKHF_EXTENDED	= BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_INJECTED	= 0x10
Global Const $LLKHF_ALTDOWN		= BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP			= BitShift($KF_UP, 8)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_WinAPI_CallNextHookEx
;_WinAPI_ClientToScreen
;_WinAPI_CloseHandle
;_WinAPI_CreateCompatibleBitmap
;_WinAPI_CreateCompatibleDC
;_WinAPI_DeleteDC
;_WinAPI_DestroyIcon
;_WinAPI_DrawIconEx
;_WinAPI_EnumWindowsTop
;_WinAPI_ExtractIconEx
;_WinAPI_GetClassName
;_WinAPI_GetDC
;_WinAPI_GetDesktopWindow
;_WinAPI_GetFocus
;_WinAPI_GetModuleHandle
;_WinAPI_GetMousePos
;_WinAPI_GetMousePosY
;_WinAPI_GetSysColor
;_WinAPI_GetWindow
;_WinAPI_GetWindowDC
;_WinAPI_GetWindowThreadProcessId
;_WinAPI_HiWord
;_WinAPI_InProcess
;_WinAPI_IsWindowVisible
;_WinAPI_InvalidateRect
;_WinAPI_LoWord
;_WinAPI_MakeLong
;_WinAPI_PostMessage
;_WinAPI_RegisterWindowMessage
;_WinAPI_ReleaseDC
;_WinAPI_ScreenToClient
;_WinAPI_SelectObject
;_WinAPI_SetDIBits
;_WinAPI_SetWindowsHookEx
;_WinAPI_ShowError
;_WinAPI_UnhookWindowsHookEx
;_WinAPI_WindowFromPoint
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__WinAPI_EnumWindowsAdd
;__WinAPI_EnumWindowsInit
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CallNextHookEx
; Description ...: Passes the hook information to the next hook procedure in the current hook chain
; Syntax.........: _WinAPI_CallNextHookEx($hhk, $iCode, $wParam, $lParam)
; Parameters ....: $hhk - Windows 95/98/ME: Handle to the current hook. An application receives this handle as a result of a previous call to the _WinAPI_SetWindowsHookEx function.
;                  |Windows NT/XP/2003: Ignored
;                  $iCode - Specifies the hook code passed to the current hook procedure. The next hook procedure uses this code to determine how to process the hook information
;                  $wParam  - Specifies the wParam value passed to the current hook procedure.
;                  |The meaning of this parameter depends on the type of hook associated with the current hook chain
;                  $lParam - Specifies the lParam value passed to the current hook procedure.
;                  |The meaning of this parameter depends on the type of hook associated with the current hook chain
; Return values .: Success      - This value is returned by the next hook procedure in the chain
;                  Failure      - -1 and @error is set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_SetWindowsHookEx, $tagKBDLLHOOKSTRUCT
; Link ..........: @@MsdnLink@@ CallNextHookEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CallNextHookEx($hhk, $iCode, $wParam, $lParam)
	Local $aResult = DllCall("user32.dll", "lresult", "CallNextHookEx", "handle", $hhk, "int", $iCode, "wparam", $wParam, "lparam", $lParam)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CallNextHookEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ClientToScreen
; Description ...: Converts the client coordinates of a specified point to screen coordinates
; Syntax.........: _WinAPI_ClientToScreen($hWnd, ByRef $tPoint)
; Parameters ....: $hWnd        - Identifies the window that will be used for the conversion
;                  $tPoint      - $tagPOINT structure that contains the client coordinates to be converted
; Return values .: Success      - $tagPOINT structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The function replaces the client coordinates in the  $tagPOINT  structure  with  the  screen  coordinates.  The
;                  screen coordinates are relative to the upper-left corner of the screen.
; Related .......: _WinAPI_ScreenToClient, $tagPOINT
; Link ..........: @@MsdnLink@@ ClientToScreen
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ClientToScreen($hWnd, ByRef $tPoint)
	Local $pPoint = DllStructGetPtr($tPoint)
	DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $hWnd, "ptr", $pPoint)
	Return SetError(@error, @extended, $tPoint)
EndFunc   ;==>_WinAPI_ClientToScreen

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CloseHandle
; Description ...: Closes an open object handle
; Syntax.........: _WinAPI_CloseHandle($hObject)
; Parameters ....: $hObject     - Handle of object to close
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_CreateFile, _WinAPI_FlushFileBuffers, _WinAPI_GetFileSizeEx, _WinAPI_ReadFile, _WinAPI_SetEndOfFile, _WinAPI_SetFilePointer, _WinAPI_WriteFile
; Link ..........: @@MsdnLink@@ CloseHandle
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CloseHandle($hObject)
	Local $aResult = DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hObject)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CloseHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateCompatibleBitmap
; Description ...: Creates a bitmap compatible with the specified device context
; Syntax.........: _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
; Parameters ....: $hDC         - Identifies a device context
;                  $iWidth      - Specifies the bitmap width, in pixels
;                  $iHeight     - Specifies the bitmap height, in pixels
; Return values .: Success      - The handle to the bitmap
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When you no longer need the bitmap, call the _WinAPI_DeleteObject function to delete it
; Related .......: _WinAPI_DeleteObject, _WinAPI_CreateSolidBitmap
; Link ..........: @@MsdnLink@@ CreateCompatibleBitmap
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateCompatibleBitmap", "handle", $hDC, "int", $iWidth, "int", $iHeight)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateCompatibleBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateCompatibleDC
; Description ...: Creates a memory device context compatible with the specified device
; Syntax.........: _WinAPI_CreateCompatibleDC($hDC)
; Parameters ....: $hDC         - Handle to an existing DC. If this handle is 0, the function creates a memory DC compatible with
;                  +the application's current screen.
; Return values .: Success      - Handle to a memory DC
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When you no longer need the memory DC, call the _WinAPI_DeleteDC function
; Related .......: _WinAPI_DeleteDC
; Link ..........: @@MsdnLink@@ CreateCompatibleDC
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateCompatibleDC($hDC)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateCompatibleDC", "handle", $hDC)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateCompatibleDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeleteDC
; Description ...: Deletes the specified device context
; Syntax.........: _WinAPI_DeleteDC($hDC)
; Parameters ....: $hDC         - Identifies the device context to be deleted
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: An application must not delete a DC whose handle was obtained by calling the _WinAPI_GetDC function.  Instead, it
;                  must call the _WinAPI_ReleaseDC function to free the DC.
; Related .......: _WinAPI_GetDC, _WinAPI_ReleaseDC, _WinAPI_CreateCompatibleDC
; Link ..........: @@MsdnLink@@ DeleteDC
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DeleteDC($hDC)
	Local $aResult = DllCall("gdi32.dll", "bool", "DeleteDC", "handle", $hDC)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DeleteDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DestroyIcon
; Description ...: Destroys an icon and frees any memory the icon occupied
; Syntax.........: _WinAPI_DestroyIcon($hIcon)
; Parameters ....: $hIcon       - Handle to the icon to be destroyed. The icon must not be in use.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_CopyIcon, _WinAPI_LoadShell32Icon
; Link ..........: @@MsdnLink@@ DestroyIcon
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DestroyIcon($hIcon)
	Local $aResult = DllCall("user32.dll", "bool", "DestroyIcon", "handle", $hIcon)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DestroyIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawIconEx
; Description ...: Draws an icon or cursor into the specified device context
; Syntax.........: _WinAPI_DrawIconEx($hDC, $iX, $iY, $hIcon[, $iWidth = 0[, $iHeight = 0[, $iStep = 0[, $hBrush = 0[, $iFlags = 3]]]]])
; Parameters ....: $hDC         - Handle to the device context into which the icon or cursor is drawn
;                  $iX          - X coordinate of the upper-left corner of the icon
;                  $iY          - Y coordinate of the upper-left corner of the icon
;                  $hIcon       - Handle to the icon to be drawn
;                  $iWidth      - Specifies the logical width of the icon or cursor.  If this parameter is zero and the iFlags
;                  +parameter is "default size", the function uses the $SM_CXICON or $SM_CXCURSOR system metric value to set the
;                  +width. If this is zero and "default size" is not used, the function uses the actual resource width.
;                  $iHeight     - Specifies the logical height of the icon or cursor.  If this parameter is zero and the iFlags
;                  +parameter is "default size", the function uses the $SM_CYICON or $SM_CYCURSOR system metric value to set the
;                  +width. If this is zero and "default size" is not used, the function uses the actual resource height.
;                  $iStep       - Specifies the index of the frame to draw if hIcon identifies an animated cursor. This parameter
;                  +is ignored if hIcon does not identify an animated cursor.
;                  $hBrush      - Handle to a brush that the system uses for flicker-free drawing.  If hBrush is a valid brush
;                  +handle, the system creates an offscreen bitmap using the specified brush for the background color, draws the
;                  +icon or cursor into the bitmap, and then copies the bitmap into the device context identified by hDC. If
;                  +hBrush is 0, the system draws the icon or cursor directly into the device context.
;                  $iFlags      - Specifies the drawing flags. This parameter can be one of the following values:
;                  |1 - Draws the icon or cursor using the mask
;                  |2 - Draws the icon or cursor using the image
;                  |3 - Draws the icon or cursor using the mask and image
;                  |4 - Draws the icon or cursor using the system default image rather than the user-specified image
;                  |5 - Draws the icon or cursor using the width and height specified by the system metric values for cursors  or
;                  +icons, if the iWidth and iWidth parameters are set to zero.  If this flag is not  specified  and  iWidth  and
;                  +iWidth are set to zero, the function uses the actual resource size.
;                  |6 - Draws the icon as an unmirrored icon
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_DrawIcon
; Link ..........: @@MsdnLink@@ DrawIconEx
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DrawIconEx($hDC, $iX, $iY, $hIcon, $iWidth = 0, $iHeight = 0, $iStep = 0, $hBrush = 0, $iFlags = 3)
	Local $iOptions

	Switch $iFlags
		Case 1
			$iOptions = $__WINAPICONSTANT_DI_MASK
		Case 2
			$iOptions = $__WINAPICONSTANT_DI_IMAGE
		Case 3
			$iOptions = $__WINAPICONSTANT_DI_NORMAL
		Case 4
			$iOptions = $__WINAPICONSTANT_DI_COMPAT
		Case 5
			$iOptions = $__WINAPICONSTANT_DI_DEFAULTSIZE
		Case Else
			$iOptions = $__WINAPICONSTANT_DI_NOMIRROR
	EndSwitch

	Local $aResult = DllCall("user32.dll", "bool", "DrawIconEx", "handle", $hDC, "int", $iX, "int", $iY, "handle", $hIcon, "int", $iWidth, _
			"int", $iHeight, "uint", $iStep, "handle", $hBrush, "uint", $iOptions)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DrawIconEx

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinAPI_EnumWindowsAdd
; Description ...: Adds window information to the windows enumeration list
; Syntax.........: __WinAPI_EnumWindowsAdd($hWnd[, $sClass = ""])
; Parameters ....: $hWnd        - Handle to the window
;                  $sClass      - Window class name
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally by the windows enumeration functions
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __WinAPI_EnumWindowsAdd($hWnd, $sClass = "")
	If $sClass = "" Then $sClass = _WinAPI_GetClassName($hWnd)
	$__gaWinList_WinAPI[0][0] += 1
	Local $iCount = $__gaWinList_WinAPI[0][0]
	If $iCount >= $__gaWinList_WinAPI[0][1] Then
		ReDim $__gaWinList_WinAPI[$iCount + 64][2]
		$__gaWinList_WinAPI[0][1] += 64
	EndIf
	$__gaWinList_WinAPI[$iCount][0] = $hWnd
	$__gaWinList_WinAPI[$iCount][1] = $sClass
EndFunc   ;==>__WinAPI_EnumWindowsAdd

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinAPI_EnumWindowsInit
; Description ...: Initializes the windows enumeration list
; Syntax.........: __WinAPI_EnumWindowsInit()
; Parameters ....:
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally by the windows enumeration functions
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __WinAPI_EnumWindowsInit()
	ReDim $__gaWinList_WinAPI[64][2]
	$__gaWinList_WinAPI[0][0] = 0
	$__gaWinList_WinAPI[0][1] = 64
EndFunc   ;==>__WinAPI_EnumWindowsInit

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumWindowsTop
; Description ...: Enumerates all top level windows
; Syntax.........: _WinAPI_EnumWindowsTop()
; Parameters ....:
; Return values .: Success      - Array with the following format:
;                  |[0][0] - Number of rows in array (n)
;                  |[1][0] - Window handle
;                  |[1][1] - Window class name
;                  |[n][0] - Window handle
;                  |[n][1] - Window class name
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_EnumWindows, _WinAPI_EnumWindowsPopup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_EnumWindowsTop()
	__WinAPI_EnumWindowsInit()
	Local $hWnd = _WinAPI_GetWindow(_WinAPI_GetDesktopWindow(), $__WINAPICONSTANT_GW_CHILD)
	While $hWnd <> 0
		If _WinAPI_IsWindowVisible($hWnd) Then __WinAPI_EnumWindowsAdd($hWnd)
		$hWnd = _WinAPI_GetWindow($hWnd, $__WINAPICONSTANT_GW_HWNDNEXT)
	WEnd
	Return $__gaWinList_WinAPI
EndFunc   ;==>_WinAPI_EnumWindowsTop

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExtractIconEx
; Description ...: Creates an array of handles to large or small icons extracted from a file
; Syntax.........: _WinAPI_ExtractIconEx($sFile, $iIndex, $pLarge, $pSmall, $iIcons)
; Parameters ....: $sFile       - Name of an executable file, DLL, or icon file from which icons will be extracted
;                  $iIndex      - Specifies the zero-based index of the first icon to extract
;                  $pLarge      - Pointer to an array of icon handles that receives handles to the large icons extracted from the
;                  +file. If this parameter is 0, no large icons are extracted from the file.
;                  $pSmall      - Pointer to an array of icon handles that receives handles to the small icons extracted from the
;                  +file. If this parameter is 0, no small icons are extracted from the file.
;                  $iIcons      - Specifies the number of icons to extract from the file
; Return values .: Success      - If iIndex is -1, pLarge parameter is 0, and pSmall is 0, then the return value is the number of
;                  |icons contained in the specified file.  Otherwise, the return value  is  the  number  of  icons  successfully
;                  |extracted from the file.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ ExtractIconEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ExtractIconEx($sFile, $iIndex, $pLarge, $pSmall, $iIcons)
	Local $aResult = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sFile, "int", $iIndex, "handle", $pLarge, "handle", $pSmall, "uint", $iIcons)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ExtractIconEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClassName
; Description ...: Retrieves the name of the class to which the specified window belongs
; Syntax.........: _WinAPI_GetClassName($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - The window class name
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetClassName
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetClassName($hWnd)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $aResult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
	If @error Then Return SetError(@error, @extended, False)
	Return SetExtended($aResult[0], $aResult[2])
EndFunc   ;==>_WinAPI_GetClassName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDC
; Description ...: Retrieves a handle of a display device context for the client area a window
; Syntax.........: _WinAPI_GetDC($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - The device context for the given window's client area
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: After painting with a common device context, the _WinAPI_ReleaseDC function must be called to release the DC
; Related .......: _WinAPI_DeleteDC, _WinAPI_ReleaseDC
; Link ..........: @@MsdnLink@@ GetDC
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetDC($hWnd)
	Local $aResult = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDesktopWindow
; Description ...: Returns the handle of the Windows desktop window
; Syntax.........: _WinAPI_GetDesktopWindow()
; Parameters ....:
; Return values .: Success      - Handle of the desktop window
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetDesktopWindow
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetDesktopWindow()
	Local $aResult = DllCall("user32.dll", "hwnd", "GetDesktopWindow")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDesktopWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetFocus
; Description ...: Retrieves the handle of the window that has the keyboard focus
; Syntax.........: _WinAPI_GetFocus()
; Parameters ....:
; Return values .: Success      - The handle of the window with the keyboard focus
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetFocus
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetFocus()
	Local $aResult = DllCall("user32.dll", "hwnd", "GetFocus")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetFocus

Func _WinAPI_GetModuleHandle($sModuleName)
	Local $sModuleNameType = "wstr"
	If $sModuleName = "" Then
		$sModuleName = 0
		$sModuleNameType = "ptr"
	EndIf
	Local $aResult = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $sModuleNameType, $sModuleName)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetModuleHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetMousePos
; Description ...: Returns the current mouse position
; Syntax.........: _WinAPI_GetMousePos([$fToClient = False], $hWnd = 0]])
; Parameters ....: $fToClient   - If True, the coordinates will be converted to client coordinates
;                  $hWnd        - Window handle used to convert coordinates if $fToClient is True
; Return values .: Success      - $tagPOINT structure with current mouse position
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function takes into account the current MouseCoordMode setting when  obtaining  the  mouse  position.  It
;                  will also convert screen to client coordinates based on the parameters passed.
; Related .......: $tagPOINT, _WinAPI_GetMousePosX, _WinAPI_GetMousePosY
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetMousePos($fToClient = False, $hWnd = 0)
	Local $iMode = Opt("MouseCoordMode", 1)
	Local $aPos = MouseGetPos()
	Opt("MouseCoordMode", $iMode)
	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $aPos[0])
	DllStructSetData($tPoint, "Y", $aPos[1])
	If $fToClient Then
		_WinAPI_ScreenToClient($hWnd, $tPoint)
		If @error Then Return SetError(@error, @extended, 0)
	EndIf
	Return $tPoint
EndFunc   ;==>_WinAPI_GetMousePos

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetMousePosY
; Description ...: Returns the current mouse Y position
; Syntax.........: _WinAPI_GetMousePosY([$fToClient = False[, $hWnd = 0]])
; Parameters ....: $fToClient   - If True, the coordinates will be converted to client coordinates
;                  $hWnd        - Window handle used to convert coordinates if $fToClient is True
; Return values .: Success      - Mouse Y position
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function takes into account the current MouseCoordMode setting when  obtaining  the  mouse  position.  It
;                  will also convert screen to client coordinates based on the parameters passed.
; Related .......: _WinAPI_GetMousePos
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetMousePosY($fToClient = False, $hWnd = 0)
	Local $tPoint = _WinAPI_GetMousePos($fToClient, $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($tPoint, "Y")
EndFunc   ;==>_WinAPI_GetMousePosY

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSysColor
; Description ...: Retrieves the current color of the specified display element
; Syntax.........: _WinAPI_GetSysColor($iIndex)
; Parameters ....: $iIndex      - The display element whose color is to be retrieved. Can be one of the following:
;                  |$COLOR_3DDKSHADOW              - Dark shadow for three-dimensional display elements.
;                  |$COLOR_3DFACE                  - Face color for three-dimensional display elements and for dialog box backgrounds.
;                  |$COLOR_3DHIGHLIGHT             - Highlight color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_3DHILIGHT               - Highlight color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_3DLIGHT                 - Light color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_3DSHADOW                - Shadow color for three-dimensional display elements (for edges facing away from the light source).
;                  |$COLOR_ACTIVEBORDER            - Active window border.
;                  |$COLOR_ACTIVECAPTION           - Active window title bar.
;                  |  Specifies the left side color in the color gradient of an active window's title bar if the gradient effect is enabled.
;                  |$COLOR_APPWORKSPACE            - Background color of multiple document interface (MDI) applications.
;                  |$COLOR_BACKGROUND              - Desktop.
;                  |$COLOR_BTNFACE                 - Face color for three-dimensional display elements and for dialog box backgrounds.
;                  |$COLOR_BTNHIGHLIGHT            - Highlight color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_BTNHILIGHT              - Highlight color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_BTNSHADOW               - Shadow color for three-dimensional display elements (for edges facing away from the light source).
;                  |$COLOR_BTNTEXT                 - Text on push buttons.
;                  |$COLOR_CAPTIONTEXT             - Text in caption, size box, and scroll bar arrow box.
;                  |$COLOR_DESKTOP                 - Desktop.
;                  |$COLOR_GRADIENTACTIVECAPTION   - Right side color in the color gradient of an active window's title bar.
;                  |  $COLOR_ACTIVECAPTION specifies the left side color.
;                  |  Use SPI_GETGRADIENTCAPTIONS with the SystemParametersInfo function to determine whether the gradient effect is enabled.
;                  |$COLOR_GRADIENTINACTIVECAPTION - Right side color in the color gradient of an inactive window's title bar.
;                  |  $COLOR_INACTIVECAPTION specifies the left side color.
;                  |$COLOR_GRAYTEXT                - Grayed (disabled) text. This color is set to 0 if the current display driver does not support a solid gray color.
;                  |$COLOR_HIGHLIGHT               - Item(s) selected in a control.
;                  |$COLOR_HIGHLIGHTTEXT           - Text of item(s) selected in a control.
;                  |$COLOR_HOTLIGHT                - Color for a hyperlink or hot-tracked item.
;                  |$COLOR_INACTIVEBORDER          - Inactive window border.
;                  |$COLOR_INACTIVECAPTION         - Inactive window caption.
;                  |  Specifies the left side color in the color gradient of an inactive window's title bar if the gradient effect is enabled.
;                  |$COLOR_INACTIVECAPTIONTEXT     - Color of text in an inactive caption.
;                  |$COLOR_INFOBK                  - Background color for tooltip controls.
;                  |$COLOR_INFOTEXT                - Text color for tooltip controls.
;                  |$COLOR_MENU                    - Menu background.
;                  |$COLOR_MENUHILIGHT             - The color used to highlight menu items when the menu appears as a flat menu.
;                  |  The highlighted menu item is outlined with $COLOR_HIGHLIGHT.
;                  |  Windows 2000:  This value is not supported.
;                  |$COLOR_MENUBAR                 - The background color for the menu bar when menus appear as flat menus.
;                  |  However, $COLOR_MENU continues to specify the background color of the menu popup.
;                  |  Windows 2000:  This value is not supported.
;                  |$COLOR_MENUTEXT                - Text in menus.
;                  |$COLOR_SCROLLBAR               - Scroll bar gray area.
;                  |$COLOR_WINDOW                  - Window background.
;                  |$COLOR_WINDOWFRAME             - Window frame.
;                  |$COLOR_WINDOWTEXT              - Text in windows.
; Return values .: Success      - The red, green, blue (RGB) color value of the given element
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Requires WindowsConstants.au3 for above constants.
; Related .......: _WinAPI_SetSysColors
; Link ..........: @@MsdnLink@@ GetSysColor
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetSysColor($iIndex)
	Local $aResult = DllCall("user32.dll", "dword", "GetSysColor", "int", $iIndex)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetSysColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindow
; Description ...: Retrieves the handle of a window that has a specified relationship to the specified window
; Syntax.........: _WinAPI_GetWindow($hWnd, $iCmd)
; Parameters ....: $hWnd        - Handle of the window
;                  $iCmd        - Specifies the relationship between the specified window and the window whose handle  is  to  be
;                  +retrieved. This parameter can be one of the following values:
;                  |$GW_CHILD    - The retrieved handle identifies the child window at the top of the Z order, if  the  specified
;                  +window is a parent window; otherwise, the retrieved handle is 0.  The function examines only child windows of
;                  +the specified window. It does not examine descendant windows.
;                  |$GW_HWNDFIRST - The retrieved handle identifies the window of the same type that is highest in the  Z  order.
;                  +If the specified window is a topmost window, the handle identifies the topmost window that is highest in  the
;                  +Z order.  If the specified window is a top-level window, the handle identifies the top level window  that  is
;                  +highest in the Z order.  If the specified window is a child window, the handle identifies the sibling  window
;                  +that is highest in the Z order.
;                  |$GW_HWNDLAST - The retrieved handle identifies the window of the same type that is lowest in the Z order.  If
;                  +the specified window is a topmost window, the handle identifies the topmost window that is lowest  in  the  Z
;                  +order. If the specified window is a top-level window the handle identifies the top-level window that's lowest
;                  +in the Z order.  If the specified window is a child window, the handle identifies the sibling window  that is
;                  +lowest in the Z order.
;                  |$GW_HWNDNEXT - The retrieved handle identifies the window below the specified window in the Z order.   If the
;                  +specified window is a topmost window, the handle identifies the topmost window below the specified window. If
;                  +the specified window is a top-level window, the handle identifies the top-level  window  below  the specified
;                  +window.  If the specified window is a child window  the  handle  identifies  the  sibling  window  below  the
;                  +specified window.
;                  |$GW_HWNDPREV - The retrieved handle identifies the window above the specified window in the Z order.   If the
;                  +specified window is a topmost window, the handle identifies the topmost window above the specified window. If
;                  +the specified window is a top-level window, the handle identifies the top-level window  above  the  specified
;                  +window.  If the specified window is a child window, the  handle  identifies  the  sibling  window  above  the
;                  +specified window.
;                  |$GW_OWNER    - The retrieved handle identifies the specified window's owner window if any
; Return values .: Success      - The window handle
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Needs Constants.au3 for pre-defined constants
; Related .......:
; Link ..........: @@MsdnLink@@ GetWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindow($hWnd, $iCmd)
	Local $aResult = DllCall("user32.dll", "hwnd", "GetWindow", "hwnd", $hWnd, "uint", $iCmd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowDC
; Description ...: Retrieves the device context (DC) for the entire window
; Syntax.........: _WinAPI_GetWindowDC($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - The handle of a device context for the specified window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: GetWindowDC is intended for special painting effects within a window's nonclient area.  Painting in  nonclient
;                  areas of any window is normally not recommended.  The GetSystemMetrics function can be used  to  retrieve  the
;                  dimensions of various parts of the nonclient area, such as  the  title  bar,  menu,  and  scroll  bars.  After
;                  painting is complete, the _WinAPI_ReleaseDC function must be called to release the device context.  Not releasing
;                  the window device context has serious effects on painting requested by applications.
; Related .......: _WinAPI_ReleaseDC
; Link ..........: @@MsdnLink@@ GetWindowDC
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowDC($hWnd)
	Local $aResult = DllCall("user32.dll", "handle", "GetWindowDC", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindowDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowThreadProcessId
; Description ...: Retrieves the identifier of the thread that created the specified window
; Syntax.........: _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
; Parameters ....: $hWnd        - Window handle
;                  $iPID        - Process ID of the specified window
; Return values .: Success      - Thread ID of the specified window
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_GetCurrentProcessID
; Link ..........: @@MsdnLink@@ GetWindowThreadProcessId
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
	Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	$iPID = $aResult[2]
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindowThreadProcessId

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_HiWord
; Description ...: Returns the high word of a longword value
; Syntax.........: _WinAPI_HiWord($iLong)
; Parameters ....: $iLong       - Longword value
; Return values .: Success      - High order word of the longword value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_LoWord, _WinAPI_MakeLong
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_HiWord($iLong)
	Return BitShift($iLong, 16)
EndFunc   ;==>_WinAPI_HiWord

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InProcess
; Description ...: Determines whether a window belongs to the current process
; Syntax.........: _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
; Parameters ....: $hWnd        - Window handle to be tested
;                  $hLastWnd    - Last window tested. If $hWnd = $hLastWnd, this process will immediately return True. Otherwise,
;                  +_WinAPI_InProcess will be called. If $hWnd is in process, $hLastWnd will be set to $hWnd on return.
; Return values .: True         - Window handle belongs to the current process
;                  False        - Window handle does not belong to the current process
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This is one of the key functions to the control memory mapping technique.  It checks the process ID of the
;                  window to determine if it belongs to the current process, which means it can be accessed without mapping the control memory.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
	If $hWnd = $hLastWnd Then Return True
	For $iI = $__gaInProcess_WinAPI[0][0] To 1 Step -1
		If $hWnd = $__gaInProcess_WinAPI[$iI][0] Then
			If $__gaInProcess_WinAPI[$iI][1] Then
				$hLastWnd = $hWnd
				Return True
			Else
				Return False
			EndIf
		EndIf
	Next
	Local $iProcessID
	_WinAPI_GetWindowThreadProcessId($hWnd, $iProcessID)
	Local $iCount = $__gaInProcess_WinAPI[0][0] + 1
	If $iCount >= 64 Then $iCount = 1
	$__gaInProcess_WinAPI[0][0] = $iCount
	$__gaInProcess_WinAPI[$iCount][0] = $hWnd
	$__gaInProcess_WinAPI[$iCount][1] = ($iProcessID = @AutoItPID)
	Return $__gaInProcess_WinAPI[$iCount][1]
EndFunc   ;==>_WinAPI_InProcess

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsWindowVisible
; Description ...: Retrieves the visibility state of the specified window
; Syntax.........: _WinAPI_IsWindowVisible($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: True         - Window is visible
;                  Failse       - Window is not visible
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The visibility state of a window is indicated by the $WS_VISIBLE style bit. When $WS_VISIBLE is set, the window
;                  is displayed and subsequent drawing into it is displayed as long as the window has the $WS_VISIBLE style.
; Related .......:
; Link ..........: @@MsdnLink@@ IsWindowVisible
; Example .......:
; ===============================================================================================================================
Func _WinAPI_IsWindowVisible($hWnd)
	Local $aResult = DllCall("user32.dll", "bool", "IsWindowVisible", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_IsWindowVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InvalidateRect
; Description ...: Adds a rectangle to the specified window's update region
; Syntax.........: _WinAPI_InvalidateRect($hWnd[, $tRect = 0[, $fErase = True]])
; Parameters ....: $hWnd        - Handle to windows
;                  $tRect       - $tagRECT structure that contains the client coordinates of the rectangle  to  be  added  to  the
;                  +update region. If this parameter is 0 the entire client area is added to the update region.
;                  $fErase      - Specifies whether the background within the update region is  to  be  erased  when  the  update
;                  +region is processed.  If this parameter is True the background is erased  when  the  BeginPaint  function  is
;                  +called. If this parameter is False, the background remains unchanged.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagRECT
; Link ..........: @@MsdnLink@@ InvalidateRect
; Example .......:
; ===============================================================================================================================
Func _WinAPI_InvalidateRect($hWnd, $tRect = 0, $fErase = True)
	Local $pRect = 0
	If IsDllStruct($tRect) Then $pRect = DllStructGetPtr($tRect)
	Local $aResult = DllCall("user32.dll", "bool", "InvalidateRect", "hwnd", $hWnd, "ptr", $pRect, "bool", $fErase)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_InvalidateRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoWord
; Description ...: Returns the low word of a longword
; Syntax.........: _WinAPI_LoWord($iLong)
; Parameters ....: $iLong       - Longword value
; Return values .: Success      - Low order word of the longword value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_HiWord, _WinAPI_MakeLong
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_LoWord($iLong)
	Return BitAND($iLong, 0xFFFF)
EndFunc   ;==>_WinAPI_LoWord

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MakeLong
; Description ...: Returns a longint value from two int values
; Syntax.........: _WinAPI_MakeLong($iLo, $iHi)
; Parameters ....: $iLo         - Low word
;                  $iHi         - Hi word
; Return values .: Success      - Longint value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_HiWord, _WinAPI_LoWord
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MakeLong($iLo, $iHi)
	Return BitOR(BitShift($iHi, -16), BitAND($iLo, 0xFFFF))
EndFunc   ;==>_WinAPI_MakeLong

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PostMessage
; Description ...: Places a message in the message queue and then returns
; Syntax.........: _WinAPI_PostMessage($hWnd, $iMsg, $iwParam, $ilParam)
; Parameters ....: $hWnd        - Identifies the window whose window procedure will receive the message.  If this parameter is
;                  +0xFFFF (HWND_BROADCAST), the message is sent to all top-level windows in the system, including disabled or invisible
;                  +unowned windows, overlapped windows, and pop-up windows; but the message is not sent to child windows.
;                  $iMsg        - Specifies the message to be sent
;                  $iwParam     - First message parameter
;                  $ilParam     - Second message parameter
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ PostMessageA
; Example .......:
; ===============================================================================================================================
Func _WinAPI_PostMessage($hWnd, $iMsg, $iwParam, $ilParam)
	Local $aResult = DllCall("user32.dll", "bool", "PostMessage", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iwParam, "lparam", $ilParam)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_PostMessage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegisterWindowMessage
; Description ...: Defines a new window message that is guaranteed to be unique throughout the system
; Syntax.........: _WinAPI_RegisterWindowMessage($sMessage)
; Parameters ....: $sMessage    - String that specifies the message to be registered
; Return values .: Success      - A message identifier in the range 0xC000 through 0xFFFF
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The RegisterWindowMessage function is used to register messages  for  communicating  between  two  cooperating
;                  applications. If two different applications register the same message string, the applications return the same
;                  message  value. The message remains registered until the session ends.
; Related .......:
; Link ..........: @@MsdnLink@@ RegisterWindowMessage
; Example .......:
; ===============================================================================================================================
Func _WinAPI_RegisterWindowMessage($sMessage)
	Local $aResult = DllCall("user32.dll", "uint", "RegisterWindowMessageW", "wstr", $sMessage)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_RegisterWindowMessage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReleaseDC
; Description ...: Releases a device context
; Syntax.........: _WinAPI_ReleaseDC($hWnd, $hDC)
; Parameters ....: $hWnd        - Handle of window
;                  $hDC         - Identifies the device context to be released
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The application must call the _WinAPI_ReleaseDC function for each call to the _WinAPI_GetWindowDC function  and  for
;                  each call to the _WinAPI_GetDC function that retrieves a common device context.
; Related .......: _WinAPI_GetDC, _WinAPI_GetWindowDC, _WinAPI_DeleteDC
; Link ..........: @@MsdnLink@@ ReleaseDC
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ReleaseDC($hWnd, $hDC)
	Local $aResult = DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "handle", $hDC)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ReleaseDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ScreenToClient
; Description ...: Converts screen coordinates of a specified point on the screen to client coordinates
; Syntax.........: _WinAPI_ScreenToClient($hWnd, ByRef $tPoint)
; Parameters ....: $hWnd        - Identifies the window that be used for the conversion
;                  $tPoint      - $tagPOINT structure that contains the screen coordinates to be converted
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The function uses the window identified by the $hWnd  parameter  and  the  screen  coordinates  given  in  the
;                  $tagPOINT structure to compute client coordinates.  It then replaces the screen  coordinates  with  the  client
;                  coordinates. The new coordinates are relative to the upper-left corner of the specified window's client area.
; Related .......: _WinAPI_ClientToScreen, $tagPOINT
; Link ..........: @@MsdnLink@@ ScreenToClient
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ScreenToClient($hWnd, ByRef $tPoint)
	Local $aResult = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hWnd, "ptr", DllStructGetPtr($tPoint))
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ScreenToClient

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SelectObject
; Description ...: Selects an object into the specified device context
; Syntax.........: _WinAPI_SelectObject($hDC, $hGDIObj)
; Parameters ....: $hDC         - Identifies the device context
;                  $hGDIObj     - Identifies the object to be selected
; Return values .: Success      - The handle of the object being replaced
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_CreatePen, _WinAPI_DrawLine, _WinAPI_GetBkMode, _WinAPI_LineTo, _WinAPI_MoveTo, _WinAPI_SetBkMode
; Link ..........: @@MsdnLink@@ SelectObject
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SelectObject($hDC, $hGDIObj)
	Local $aResult = DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hDC, "handle", $hGDIObj)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SelectObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDIBits
; Description ...: Sets the pixels in a compatible bitmap using the color data found in a DIB
; Syntax.........: _WinAPI_SetDIBits($hDC, $hBmp, $iStartScan, $iScanLines, $pBits, $pBMI[, $iColorUse = 0])
; Parameters ....: $hDC         - Handle to a device context
;                  $hBmp        - Handle to the compatible bitmap (DDB) that is to be altered using the color data from the DIB
;                  $iStartScan  - Specifies the starting scan line for the device-independent color data in the array pointed  to
;                  +by the pBits parameter.
;                  $iScanLines  - Specifies the number of scan lines found in the array containing device-independent color data
;                  $pBits       - Pointer to the DIB color data, stored as an array of bytes.  The format of  the  bitmap  values
;                  +depends on the biBitCount member of the $tagBITMAPINFO structure pointed to by the pBMI parameter.
;                  $pBMI        - Pointer to a $tagBITMAPINFO structure that contains information about the DIB
;                  $iColorUse   - Specifies whether the iColors member of the $tagBITMAPINFO structure was provided  and,  if  so,
;                  +whether iColors contains explicit red, green, blue (RGB) values or palette indexes.  The iColorUse  parameter
;                  +must be one of the following values:
;                  |0 - The color table is provided and contains literal RGB values
;                  |1 - The color table consists of an array of 16-bit indexes into the logical palette of hDC
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The device context identified by the hDC parameter is used only if the iColorUse is set to 1, otherwise it  is
;                  ignored.  The bitmap identified by the hBmp parameter must not be selected into a  device  context  when  this
;                  function is called. The scan lines must be aligned on a DWORD except for RLE compressed  bitmaps.  The  origin
;                  for bottom up DIBs is the lower left corner of the bitmap; the origin for top down  DIBs  is  the  upper  left
;                  corner of the bitmap.
; Related .......: $tagBITMAPINFO
; Link ..........: @@MsdnLink@@ SetDIBits
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetDIBits($hDC, $hBmp, $iStartScan, $iScanLines, $pBits, $pBMI, $iColorUse = 0)
	Local $aResult = DllCall("gdi32.dll", "int", "SetDIBits", "handle", $hDC, "handle", $hBmp, "uint", $iStartScan, "uint", $iScanLines, _
			"ptr", $pBits, "ptr", $pBMI, "uint", $iColorUse)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetDIBits

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetWindowsHookEx
; Description ...: Installs an application-defined hook procedure into a hook chain
; Syntax.........: _WinAPI_SetWindowsHookEx($idHook, $lpfn, $hmod[, $dwThreadId = 0])
; Parameters ....: $idHook  - Specifies the type of hook procedure to be installed. This parameter can be one of the following values:
;                  |$WH_CALLWNDPROC     - Installs a hook procedure that monitors messages before the system sends them to the destination window procedure
;                  |$WH_CALLWNDPROCRET  - Installs a hook procedure that monitors messages after they have been processed by the destination window procedure
;                  |$WH_CBT             - Installs a hook procedure that receives notifications useful to a computer-based training (CBT) application
;                  |$WH_DEBUG           - Installs a hook procedure useful for debugging other hook procedures
;                  |$WH_FOREGROUNDIDLE  - Installs a hook procedure that will be called when the application's foreground thread is about to become idle
;                  |$WH_GETMESSAGE      - Installs a hook procedure that monitors messages posted to a message queue
;                  |$WH_JOURNALPLAYBACK - Installs a hook procedure that posts messages previously recorded by a $WH_JOURNALRECORD hook procedure
;                  |$WH_JOURNALRECORD   - Installs a hook procedure that records input messages posted to the system message queue
;                  |$WH_KEYBOARD        - Installs a hook procedure that monitors keystroke messages
;                  |$WH_KEYBOARD_LL     - Windows NT/2000/XP: Installs a hook procedure that monitors low-level keyboard input events
;                  |$WH_MOUSE           - Installs a hook procedure that monitors mouse messages
;                  |$WH_MOUSE_LL        - Windows NT/2000/XP: Installs a hook procedure that monitors low-level mouse input events
;                  |$WH_MSGFILTER       - Installs a hook procedure that monitors messages generated as a result of an input event in a dialog box, message box, menu, or scroll bar
;                  |$WH_SHELL           - Installs a hook procedure that receives notifications useful to shell applications
;                  |$WH_SYSMSGFILTER    - Installs a hook procedure that monitors messages generated as a result of an input event in a dialog box, message box, menu, or scroll bar
;                  $lpfn  - Pointer to the hook procedure. If the $dwThreadId parameter is zero or specifies the identifier of a thread created by a different process,
;                  + the $lpfn parameter must point to a hook procedure in a DLL.
;                  |Otherwise, $lpfn can point to a hook procedure in the code associated with the current process
;                  $hmod  - Handle to the DLL containing the hook procedure pointed to by the $lpfn parameter.
;                  |The $hMod parameter must be set to NULL if the $dwThreadId parameter specifies a thread created by the current process and if the hook procedure is within the
;                  + code associated with the current process
;                  $dwThreadId - Specifies the identifier of the thread with which the hook procedure is to be associated.
;                  |If this parameter is zero, the hook procedure is associated with all existing threads running in the same desktop as the calling thread
; Return values .: Success      - Handle to the hook procedure
;                  Failure      - 0 and @error is set
; Author ........: Gary Frost
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_UnhookWindowsHookEx, _WinAPI_CallNextHookEx, DllCallbackRegister, DllCallbackGetPtr, DllCallbackFree
; Link ..........: @@MsdnLink@@ SetWindowsHookEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetWindowsHookEx($idHook, $lpfn, $hmod, $dwThreadId = 0)
	Local $aResult = DllCall("user32.dll", "handle", "SetWindowsHookEx", "int", $idHook, "ptr", $lpfn, "handle", $hmod, "dword", $dwThreadId)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetWindowsHookEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShowError
; Description ...: Displays an error message box with an optional exit
; Syntax.........: _WinAPI_ShowError($sText[, $fExit = True])
; Parameters ....: $sText       - Error text to display
;                  $fExit       - Specifies whether to exit after the display:
;                  |True  - Exit program after display
;                  |False - Return normally after display
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_ShowMsg, _WinAPI_MsgBox
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_ShowError($sText, $fExit = True)
	_WinAPI_MsgBox(266256, "Error", $sText)
	If $fExit Then Exit
EndFunc   ;==>_WinAPI_ShowError

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnhookWindowsHookEx
; Description ...: Removes a hook procedure installed in a hook chain by the _WinAPI_SetWindowsHookEx function
; Syntax.........: _WinAPI_UnhookWindowsHookEx($hhk)
; Parameters ....: $hhk - Handle to the hook to be removed
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_SetWindowsHookEx, DllCallbackFree
; Link ..........: @@MsdnLink@@ UnhookWindowsHookEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_UnhookWindowsHookEx($hhk)
	Local $aResult = DllCall("user32.dll", "bool", "UnhookWindowsHookEx", "handle", $hhk)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_UnhookWindowsHookEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WindowFromPoint
; Description ...: Retrieves the handle of the window that contains the specified point
; Syntax.........: _WinAPI_WindowFromPoint(ByRef $tPoint)
; Parameters ....: $tPoint      - $tagPOINT structure that defines the point to be checked
; Return values .: Success      - The handle of the window thatcontains the point
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: The WindowFromPoint function does not retrieve the handle of a hidden or disabled window, even if the point is
;                  within the window.
; Related .......: $tagPOINT
; Link ..........: @@MsdnLink@@ WindowFromPoint
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WindowFromPoint(ByRef $tPoint)
	; The point data must be packed into an int64 in order to work on x64.  On
	; x64 it is not possible to pass two 32-bit integers to the function because
	; of how stack based parameters are aligned.  On x64 they are qword
	; aligned which means the Y coordinate is truncated.  It works on x86
	; because the stack is dword aligned.  By packing the data into int64 the
	; proper POINT alignment is maintained on both x86 and x64.
	Local $tPointCast = DllStructCreate("int64", DllStructGetPtr($tPoint))
	Local $aResult = DllCall("user32.dll", "hwnd", "WindowFromPoint", "int64", DllStructGetData($tPointCast, 1))
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WindowFromPoint
