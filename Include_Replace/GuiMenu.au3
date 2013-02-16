#include-once

#include "MenuConstants.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: Menu
; AutoIt Version : 3.2.3++
; Language ......: English
; Description ...: Functions that assist with Menu control management.
;                  A menu is a list of items that specify options or groups of options (a submenu) for an application. Clicking a
;                  menu item opens a submenu or causes the application to carry out a command.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s) ........: user32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlMenu_DeleteMenu
;_GUICtrlMenu_DrawMenuBar
;_GUICtrlMenu_FindParent
;_GUICtrlMenu_GetItemCount
;_GUICtrlMenu_GetItemText
;_GUICtrlMenu_GetMenu
;_GUICtrlMenu_SetItemBmp
;_GUICtrlMenu_SetItemInfo
;_GUICtrlMenu_SetItemSubMenu
;_GUICtrlMenu_SetItemType
;_GUICtrlMenu_SetMenuInfo
;_GUICtrlMenu_SetMenuStyle
;_GUICtrlMenu_TrackPopupMenu
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_DeleteMenu
; Description ...: Deletes an item from the specified menu
; Syntax.........: _GUICtrlMenu_DeleteMenu($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_DestroyMenu
; Link ..........: @@MsdnLink@@ DeleteMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_DeleteMenu($hMenu, $iItem, $fByPos = True)
	Local $iByPos = 0

	If $fByPos Then $iByPos = $MF_BYPOSITION
	Local $aResult = DllCall("User32.dll", "bool", "DeleteMenu", "handle", $hMenu, "uint", $iItem, "uint", $iByPos)
	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] = 0 Then Return SetError(10, 0, False)

	_GUICtrlMenu_DrawMenuBar(_GUICtrlMenu_FindParent($hMenu))
	Return True
EndFunc   ;==>_GUICtrlMenu_DeleteMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_DrawMenuBar
; Description ...: Redraws the menu bar of the specified window
; Syntax.........: _GUICtrlMenu_DrawMenuBar($hWnd)
; Parameters ....: $hWnd        - Handle to the window whose menu bar needs redrawing
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If the menu bar changes after Windows has created the window, this function must be called to draw the menu bar.
; Related .......:
; Link ..........: @@MsdnLink@@ DrawMenuBar
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_DrawMenuBar($hWnd)
	Local $aResult = DllCall("User32.dll", "bool", "DrawMenuBar", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_DrawMenuBar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_FindParent
; Description ...: Retrieves the window to which a menu belongs
; Syntax.........: _GUICtrlMenu_FindParent($hMenu)
; Parameters ....: $hMenu       - Menu handle
; Return values .: Success      - Window handle
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenu
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_FindParent($hMenu)
	Local $hList = _WinAPI_EnumWindowsTop()
	For $iI = 1 To $hList[0][0]
		If _GUICtrlMenu_GetMenu($hList[$iI][0]) = $hMenu Then Return $hList[$iI][0]
	Next
EndFunc   ;==>_GUICtrlMenu_FindParent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemCount
; Description ...: Retrieves the number of items in the specified menu
; Syntax.........: _GUICtrlMenu_GetItemCount($hMenu)
; Parameters ....: $hMenu       - Handle of the menu
; Return values .: Success      - The number of items in the menu
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetMenuItemCount
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemCount($hMenu)
	Local $aResult = DllCall("User32.dll", "int", "GetMenuItemCount", "handle", $hMenu)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_GetItemCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemText
; Description ...: Retrieves the text of the specified menu item
; Syntax.........: _GUICtrlMenu_GetItemText($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Menu item text
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemText
; Link ..........: @@MsdnLink@@ GetMenuString
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemText($hMenu, $iItem, $fByPos = True)
	Local $iByPos = 0

	If $fByPos Then $iByPos = $MF_BYPOSITION
	Local $aResult = DllCall("User32.dll", "int", "GetMenuStringW", "handle", $hMenu, "uint", $iItem, "wstr", 0, "int", 4096, "uint", $iByPos)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $aResult[3])
EndFunc   ;==>_GUICtrlMenu_GetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenu
; Description ...: Retrieves the handle of the menu assigned to the given window
; Syntax.........: _GUICtrlMenu_GetMenu($hWnd)
; Parameters ....: $hWnd        - Identifies the window whose menu handle is retrieved
; Return values .: Success      - The handle of the menu
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: _GUICtrlMenu_GetMenu does not work on floating menu bars.  Floating menu bars are custom controls that mimic standard
;                  menus, but are not menus.
; Related .......: _GUICtrlMenu_SetMenu, _GUICtrlMenu_FindParent
; Link ..........: @@MsdnLink@@ GetMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenu($hWnd)
	Local $aResult = DllCall("User32.dll", "handle", "GetMenu", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_GetMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemBmp
; Description ...: Sets the bitmap displayed for the item
; Syntax.........: _GUICtrlMenu_SetItemBmp($hMenu, $iItem, $hBmp[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $hBmp        - Handle to the item bitmap
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemBmp
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemBmp($hMenu, $iItem, $hBmp, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_BITMAP)
	DllStructSetData($tInfo, "BmpItem", $hBmp)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemBmp

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemInfo
; Description ...: Changes information about a menu item
; Syntax.........: _GUICtrlMenu_SetItemInfo($hMenu, $iItem, ByRef $tInfo[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $tInfo       - $tagMENUITEMINFO structure
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemInfo, $tagMENUITEMINFO
; Link ..........: @@MsdnLink@@ SetMenuItemInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemInfo($hMenu, $iItem, ByRef $tInfo, $fByPos = True)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	Local $aResult = DllCall("User32.dll", "bool", "SetMenuItemInfoW", "handle", $hMenu, "uint", $iItem, "bool", $fByPos, "ptr", DllStructGetPtr($tInfo))
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_SetItemInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemSubMenu
; Description ...: Sets the drop down menu or submenu associated with the menu item
; Syntax.........: _GUICtrlMenu_SetItemSubMenu($hMenu, $iItem, $hSubMenu[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $hSubMenu    - Handle to the drop down menu or submenu
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemSubMenu
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemSubMenu($hMenu, $iItem, $hSubMenu, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_SUBMENU)
	DllStructSetData($tInfo, "SubMenu", $hSubMenu)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemSubMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemType
; Description ...: Sets the menu item type
; Syntax.........: _GUICtrlMenu_SetItemType($hMenu, $iItem, $iType[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $iType       - Menu item type. This can be one or more of the following values:
;                  |$MFT_BITMAP       - Item is displayed using a bitmap
;                  |$MFT_MENUBARBREAK - Item is placed on a new line. A vertical line separates the new column from the old.
;                  |$MFT_MENUBREAK    - Item is placed on a new line. The columns are not separated by a vertical line.
;                  |$MFT_OWNERDRAW    - Item is owner drawn
;                  |$MFT_RADIOCHECK   - Item is displayed using a radio button mark
;                  |$MFT_RIGHTJUSTIFY - Item is right justified
;                  |$MFT_RIGHTORDER   - Item cascades from right to left
;                  |$MFT_SEPARATOR    - Item is a separator
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemType
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemType($hMenu, $iItem, $iType, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_FTYPE)
	DllStructSetData($tInfo, "Type", $iType)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemType

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuInfo
; Description ...: Sets information for a specified menu
; Syntax.........: _GUICtrlMenu_SetMenuInfo($hMenu, ByRef $tInfo)
; Parameters ....: $hMenu       - Menu handle
;                  $tInfo       - $tagMENUINFO structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuInfo, $tagMENUINFO
; Link ..........: @@MsdnLink@@ SetMenuInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuInfo($hMenu, ByRef $tInfo)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	Local $aResult = DllCall("User32.dll", "bool", "SetMenuInfo", "handle", $hMenu, "ptr", DllStructGetPtr($tInfo))
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_SetMenuInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuStyle
; Description ...: Sets the menu style
; Syntax.........: _GUICtrlMenu_SetMenuStyle($hMenu, $iStyle)
; Parameters ....: $hMenu       - Handle of the menu
;                  $iStyle      - Style of the menu. It can be one or more of the following values:
;                  |$MNS_AUTODISMISS - Menu automatically ends when mouse is outside the menu for 10 seconds
;                  |$MNS_CHECKORBMP  - The same space is reserved for the check mark and the bitmap
;                  |$MNS_DRAGDROP    - Menu items are OLE drop targets or drag sources
;                  |$MNS_MODELESS    - Menu is modeless
;                  |$MNS_NOCHECK     - No space is reserved to the left of an item for a check mark
;                  |$MNS_NOTIFYBYPOS - Menu owner receives a $WM_MENUCOMMAND message instead of  a  $WM_COMMAND  message  when  a
;                  +selection is made
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuStyle($hMenu, $iStyle)
	Local $tInfo = DllStructCreate($tagMENUINFO)
	DllStructSetData($tInfo, "Mask", $MIM_STYLE)
	DllStructSetData($tInfo, "Style", $iStyle)
	Return _GUICtrlMenu_SetMenuInfo($hMenu, $tInfo)
EndFunc   ;==>_GUICtrlMenu_SetMenuStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_TrackPopupMenu
; Description ...: Displays a shortcut menu at the specified location
; Syntax.........: _GUICtrlMenu_TrackPopupMenu($hMenu, $hWnd[, $iX = -1[, $iY = -1[, $iAlignX = 1[, $iAlignY = 1[, $iNotify = 0[, $iButtons = 0]]]]]])
; Parameters ....: $hMenu       - Handle to the shortcut menu to be displayed
;                  $hWnd        - Handle to the window that owns the shortcut menu
;                  $iX          - Specifies the horizontal location of the shortcut menu, in screen coordinates.  If this is  -1,
;                  +the current mouse position is used.
;                  $iY          - Specifies the vertical location of the shortcut menu, in screen coordinates. If this is -1, the
;                  +current mouse position is used.
;                  $iAlignX     - Specifies how to position the menu horizontally:
;                  |0 - Center the menu horizontally relative to $iX
;                  |1 - Position the menu so that its left side is aligned with $iX
;                  |2 - Position the menu so that its right side is aligned with $iX
;                  $iAlignY     - Specifies how to position the menu vertically:
;                  |0 - Position the menu so that its bottom side is aligned with $iY
;                  |1 - Position the menu so that its top side is aligned with $iY
;                  |2 - Center the menu vertically relative to $iY
;                  $iNotify     - Use to determine the selection withouta parent window:
;                  |1 - Do not send notification messages
;                  |2 - Return the menu item identifier of the user's selection
;                  $iButtons    - Mouse button the shortcut menu tracks:
;                  |0 - The user can select items with only the left mouse button
;                  |1 - The user can select items with both left and right buttons
; Return values .: Success      - If $iNotify is set to 2, the return value is the menu item identifier  of  the  item  that  the
;                  +user selected. If the user cancels the menu without making a selection or if an error occurs, then the return
;                  +value is zero. If $iNotify is not set to 2, the return value is 1.
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ TrackPopupMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_TrackPopupMenu($hMenu, $hWnd, $iX = -1, $iY = -1, $iAlignX = 1, $iAlignY = 1, $iNotify = 0, $iButtons = 0)
	If $iX = -1 Then $iX = _WinAPI_GetMousePosX()
	If $iY = -1 Then $iY = _WinAPI_GetMousePosY()

	Local $iFlags = 0
	Switch $iAlignX
		Case 1
			$iFlags = BitOR($iFlags, $TPM_LEFTALIGN)
		Case 2
			$iFlags = BitOR($iFlags, $TPM_RIGHTALIGN)
		Case Else
			$iFlags = BitOR($iFlags, $TPM_CENTERALIGN)
	EndSwitch
	Switch $iAlignY
		Case 1
			$iFlags = BitOR($iFlags, $TPM_TOPALIGN)
		Case 2
			$iFlags = BitOR($iFlags, $TPM_VCENTERALIGN)
		Case Else
			$iFlags = BitOR($iFlags, $TPM_BOTTOMALIGN)
	EndSwitch
	If BitAND($iNotify, 1) <> 0 Then $iFlags = BitOR($iFlags, $TPM_NONOTIFY)
	If BitAND($iNotify, 2) <> 0 Then $iFlags = BitOR($iFlags, $TPM_RETURNCMD)
	Switch $iButtons
		Case 1
			$iFlags = BitOR($iFlags, $TPM_RIGHTBUTTON)
		Case Else
			$iFlags = BitOR($iFlags, $TPM_LEFTBUTTON)
	EndSwitch
	Local $aResult = DllCall("User32.dll", "bool", "TrackPopupMenu", "handle", $hMenu, "uint", $iFlags, "int", $iX, "int", $iY, "int", 0, "hwnd", $hWnd, "ptr", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_TrackPopupMenu
