#include-once

#include "TreeViewConstants.au3"
#include "GuiImageList.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: TreeView
; AutoIt Version : 3.2.3++
; Language ......: English
; Description ...: Functions that assist with TreeView control management.
;                  A TreeView control is a window that displays a hierarchical list of items, such as the headings in a document,
;                  the entries in an index, or the files and directories on a disk. Each item consists of a label and an optional
;                  bitmapped image, and each item can have a list of subitems associated with it.  By clicking an item, the  user
;                  can expand or collapse the associated list of subitems.
; Author(s) .....: Paul Campbell (PaulIA), Gary Frost (gafrost), Holger Kotsch
; Dll(s) ........: user32.dll, comctl32.dll, shell32.dll
; ===============================================================================================================================

; Default treeview item extended structure
; http://msdn.microsoft.com/en-us/library/bb773459.aspx
; Min.OS: 2K, NT4 with IE 4.0, 98, 95 with IE 4.0

; #VARIABLES# ===================================================================================================================
Global $__ghTVLastWnd
Global $Debug_TV = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__TREEVIEWCONSTANT_ClassName = "SysTreeView32"
Global Const $__TREEVIEWCONSTANT_WM_SETREDRAW = 0x000B
Global Const $__TREEVIEWCONSTANT_DEFAULT_GUI_FONT = 17
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlTreeView_AddChild
;_GUICtrlTreeView_AddChildFirst
;_GUICtrlTreeView_BeginUpdate
;_GUICtrlTreeView_CreateDragImage
;_GUICtrlTreeView_Delete
;_GUICtrlTreeView_DisplayRect
;_GUICtrlTreeView_DisplayRectEx
;_GUICtrlTreeView_EndUpdate
;_GUICtrlTreeView_EnsureVisible
;_GUICtrlTreeView_Expand
;_GUICtrlTreeView_GetExpanded
;_GUICtrlTreeView_GetFirstChild
;_GUICtrlTreeView_GetImageIndex
;_GUICtrlTreeView_GetImageListIconHandle
;_GUICtrlTreeView_GetItemHandle
;_GUICtrlTreeView_GetLastChild
;_GUICtrlTreeView_GetNextSibling
;_GUICtrlTreeView_GetParentHandle
;_GUICtrlTreeView_GetPrevSibling
;_GUICtrlTreeView_GetSelection
;_GUICtrlTreeView_GetState
;_GUICtrlTreeView_GetText
;_GUICtrlTreeView_GetUnicodeFormat
;_GUICtrlTreeView_HitTestEx
;_GUICtrlTreeView_HitTestItem
;_GUICtrlTreeView_InsertItem
;_GUICtrlTreeView_SelectItem
;_GUICtrlTreeView_SetDropTarget
;_GUICtrlTreeView_SetIcon
;_GUICtrlTreeView_SetImageIndex
;_GUICtrlTreeView_SetInsertMark
;_GUICtrlTreeView_SetSelected
;_GUICtrlTreeView_SetState
;_GUICtrlTreeView_SetText
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagTVINSERTSTRUCT
;__GUICtrlTreeView_AddItem
;__GUICtrlTreeView_ExpandItem
;__GUICtrlTreeView_GetItem
;__GUICtrlTreeView_SetItem
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTVINSERTSTRUCT
; Description ...: Contains information used to add a new item to a tree-view control
; Fields ........: Parent        - Handle to the parent item. If this member is $TVI_ROOT, the item is inserted at the root
;                  InsertAfter   - Handle to the item after which the new item is to be inserted, or one of the following values:
;                  |$TVI_FIRST - Inserts the item at the beginning of the list
;                  |$TVI_LAST  - Inserts the item at the end of the list
;                  |$TVI_ROOT  - Add the item as a root item
;                  |$TVI_SORT  - Inserts the item into the list in alphabetical order
;                  Mask          - Flags that indicate which of the other structure members contain valid data:
;                  |$TVIF_CHILDREN      - The Children member is valid
;                  |$TVIF_DI_SETITEM    - The will retain the supplied information and will not request it again
;                  |$TVIF_HANDLE        - The hItem member is valid
;                  |$TVIF_IMAGE         - The Image member is valid
;                  |$TVIF_INTEGRAL      - The Integral member is valid
;                  |$TVIF_PARAM         - The Param member is valid
;                  |$TVIF_SELECTEDIMAGE - The SelectedImage member is valid
;                  |$TVIF_STATE         - The State and StateMask members are valid
;                  |$TVIF_TEXT          - The Text and TextMax members are valid
;                  hItem         - Item to which this structure refers
;                  State         - Set of bit flags and image list indexes that indicate the item's state. When setting the state
;                  +of an item, the StateMask member indicates the bits of this member that are valid.  When retrieving the state
;                  +of an item, this member returns the current state for the bits indicated in  the  StateMask  member.  Bits  0
;                  +through 7 of this member contain the item state flags. Bits 8 through 11 of this member specify the one based
;                  +overlay image index.
;                  StateMask     - Bits of the state member that are valid.  If you are retrieving an item's state, set the  bits
;                  +of the stateMask member to indicate the bits to be returned in the state member. If you are setting an item's
;                  +state, set the bits of the stateMask member to indicate the bits of the state member that you want to set.
;                  Text          - Pointer to a null-terminated string that contains the item text.
;                  TextMax       - Size of the buffer pointed to by the Text member, in characters
;                  Image         - Index in the image list of the icon image to use when the item is in the nonselected state
;                  SelectedImage - Index in the image list of the icon image to use when the item is in the selected state
;                  Children      - Flag that indicates whether the item has associated child items. This member can be one of the
;                  +following values:
;                  |0 - The item has no child items
;                  |1 - The item has one or more child items
;                  Param         - A value to associate with the item
;                  Integral      - Height of the item
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTVINSERTSTRUCT = "handle Parent;handle InsertAfter;" & $tagTVITEM

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_AddChild
; Description ...: Adds a new item
; Syntax.........: _GUICtrlTreeView_AddChild($hWnd, $hParent, $sText[, $iImage = -1[, $iSelImage = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hParent     - Parent item
;                  $sText       - Text of the item
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
; Return values .: Success      - The handle to the new item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The item is added as a child of $hParent.  It is added to the end of $hParent's list of child  items.  If  the
;                  control is sorted, this function inserts the item in the correct sort order position, rather than as the  last
;                  child of $hParent.
; Related .......: _GUICtrlTreeView_AddChildFirst
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_AddChild($hWnd, $hParent, $sText, $iImage = -1, $iSelImage = -1, $iParam = 0) ; <modified by rexx: add $iParam>
	Return __GUICtrlTreeView_AddItem($hWnd, $hParent, $sText, $TVNA_ADDCHILD, $iImage, $iSelImage, $iParam)
EndFunc   ;==>_GUICtrlTreeView_AddChild

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_AddChildFirst
; Description ...: Adds a new item
; Syntax.........: _GUICtrlTreeView_AddChildFirst($hWnd, $hParent, $sText[, $iImage = -1[, $iSelImage = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hParent     - Parent item
;                  $sText       - Text of the item
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
; Return values .: Success      - The handle to the new item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The item is added as the first child of $hParent. Items that appear after the added item are moved down.
; Related .......: _GUICtrlTreeView_AddChild
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_AddChildFirst($hWnd, $hParent, $sText, $iImage = -1, $iSelImage = -1, $iParam = 0) ; <modified by rexx: add $iParam>
	Return __GUICtrlTreeView_AddItem($hWnd, $hParent, $sText, $TVNA_ADDCHILDFIRST, $iImage, $iSelImage, $iParam)
EndFunc   ;==>_GUICtrlTreeView_AddChildFirst

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_AddItem
; Description ...: Add a new item
; Syntax.........: __GUICtrlTreeView_AddItem($hWnd, $hRelative, $sText, $iMethod[, $iImage = -1[, $iSelImage = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hRelative   - Handle to an existing item that will be either parent or sibling to the new item
;                  $sText       - The text for the new item
;                  $iMethod     - The relationship between the new item and the $hRelative item
;                  |$TVNA_ADD           - The item becomes the last sibling of the other item
;                  |$TVNA_ADDFIRST      - The item becomes the first sibling of the other item
;                  |$TVNA_ADDCHILD      - The item becomes the sibling before the other item
;                  |$TVNA_ADDCHILDFIRST - The item becomes the last child of the other item
;                  |$TVNA_INSERT        - The item becomes the first child of the other item
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
;                  $iParam      - Application Defined Data
; Return values .: Success      - The handle to the new item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function is for interall use only and should not normally be called by the end user
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_AddItem($hWnd, $hRelative, $sText, $iMethod, $iImage = -1, $iSelImage = -1, $iParam = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $iAddMode
	Switch $iMethod
		Case $TVNA_ADD, $TVNA_ADDCHILD
			$iAddMode = $TVTA_ADD
		Case $TVNA_ADDFIRST, $TVNA_ADDCHILDFIRST
			$iAddMode = $TVTA_ADDFIRST
		Case Else
			$iAddMode = $TVTA_INSERT
	EndSwitch

	Local $hItem, $hItemID = 0
	If $hRelative <> 0x00000000 Then
		Switch $iMethod
			Case $TVNA_ADD, $TVNA_ADDFIRST
				$hItem = _GUICtrlTreeView_GetParentHandle($hWnd, $hRelative)
			Case $TVNA_ADDCHILD, $TVNA_ADDCHILDFIRST
				$hItem = $hRelative
			Case Else
				$hItem = _GUICtrlTreeView_GetParentHandle($hWnd, $hRelative)
				$hItemID = _GUICtrlTreeView_GetPrevSibling($hWnd, $hRelative)
				If $hItemID = 0x00000000 Then $iAddMode = $TVTA_ADDFIRST
		EndSwitch
	EndIf

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tInsert = DllStructCreate($tagTVINSERTSTRUCT)
	Local $pInsert = DllStructGetPtr($tInsert)
	Switch $iAddMode
		Case $TVTA_ADDFIRST
			DllStructSetData($tInsert, "InsertAfter", $TVI_FIRST)
		Case $TVTA_ADD
			DllStructSetData($tInsert, "InsertAfter", $TVI_LAST)
		Case $TVTA_INSERT
			DllStructSetData($tInsert, "InsertAfter", $hItemID)
	EndSwitch
	Local $iMask = BitOR($TVIF_TEXT, $TVIF_PARAM)
	If $iImage >= 0 Then $iMask = BitOR($iMask, $TVIF_IMAGE)
	If $iSelImage >= 0 Then $iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tInsert, "Parent", $hItem)
	DllStructSetData($tInsert, "Mask", $iMask)
	DllStructSetData($tInsert, "TextMax", $iBuffer)
	DllStructSetData($tInsert, "Image", $iImage)
	DllStructSetData($tInsert, "SelectedImage", $iSelImage)
	DllStructSetData($tInsert, "Param", $iParam)

	Local $hResult
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		DllStructSetData($tInsert, "Text", $pBuffer)
		$hResult = _SendMessage($hWnd, $TVM_INSERTITEMW, 0, $pInsert, 0, "wparam", "ptr", "handle")
	Else
		Local $iInsert = DllStructGetSize($tInsert)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iInsert + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iInsert
		_MemWrite($tMemMap, $pInsert, $pMemory, $iInsert)
		_MemWrite($tMemMap, $pBuffer, $pText, $iBuffer)
		DllStructSetData($tInsert, "Text", $pText)
		If $fUnicode Then
			$hResult = _SendMessage($hWnd, $TVM_INSERTITEMW, 0, $pMemory, 0, "wparam", "ptr", "handle")
		Else
			$hResult = _SendMessage($hWnd, $TVM_INSERTITEMA, 0, $pMemory, 0, "wparam", "ptr", "handle")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $hResult
EndFunc   ;==>__GUICtrlTreeView_AddItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_BeginUpdate
; Description ...: Prevents updating of the control until the EndUpdate function is called
; Syntax.........: _GUICtrlTreeView_BeginUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_EndUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_BeginUpdate($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__TREEVIEWCONSTANT_WM_SETREDRAW) = 0
EndFunc   ;==>_GUICtrlTreeView_BeginUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_CreateDragImage
; Description ...: Creates a dragging bitmap for the specified item
; Syntax.........: _GUICtrlTreeView_CreateDragImage($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - The image list handle to which the dragging bitmap was added
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: If you create the control without an associated image list, you cannot use this function to create  the  image
;                  to display during a drag operation.  You must implement your own method of creating a drag  cursor.   You  are
;                  responsible for destroying the image list when it is no longer needed.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_CreateDragImage($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_CREATEDRAGIMAGE, 0, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_CreateDragImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Delete
; Description ...: Removes an item and all its children
; Syntax.........: _GUICtrlTreeView_Delete($hWnd[, $hItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle/Control ID of item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......: re-written by Holger Kotsch, re-written again by Gary Frost
; Remarks .......:
; Related .......: _GUICtrlTreeView_DeleteAll, _GUICtrlTreeView_DeleteChildren
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Delete($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000

	If IsHWnd($hWnd) Then
		If $hItem = 0x00000000 Then
			$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
			If $hItem <> 0x00000000 Then Return _SendMessage($hWnd, $TVM_DELETEITEM, 0, $hItem, 0, "wparam", "handle", "hwnd") <> 0
			Return False
		Else
			If GUICtrlDelete($hItem) Then Return True
			Return _SendMessage($hWnd, $TVM_DELETEITEM, 0, $hItem, 0, "wparam", "handle", "hwnd") <> 0
		EndIf
	Else
		If $hItem = 0x00000000 Then
			$hItem = GUICtrlSendMsg($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0)
			If $hItem <> 0x00000000 Then Return GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $hItem) <> 0
			Return False
		Else
			If GUICtrlDelete($hItem) Then Return True
			Return GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $hItem) <> 0
		EndIf
	EndIf
EndFunc   ;==>_GUICtrlTreeView_Delete

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_DisplayRect
; Description ...: Returns the bounding rectangle for a tree item
; Syntax.........: _GUICtrlTreeView_DisplayRect($hWnd, $hItem[, $fTextOnly = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item whose rectangle will be returned
;                  $fTextOnly   - If the True, the bounding rectangle includes only the text of the item.  Otherwise, it includes
;                  +the entire line that the item occupies.
; Return values .: Success      - Array with the following format:
;                  |$aRect[0] - X coordinate of the upper left corner of the rectangle
;                  |$aRect[1] - Y coordinate of the upper left corner of the rectangle
;                  |$aRect[2] - X coordinate of the lower right corner of the rectangle
;                  |$aRect[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_DisplayRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_DisplayRect($hWnd, $hItem, $fTextOnly = False)

	Local $tRect = _GUICtrlTreeView_DisplayRectEx($hWnd, $hItem, $fTextOnly)
	If @error Then Return SetError(@error, @error, 0)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlTreeView_DisplayRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_DisplayRectEx
; Description ...: Returns the bounding rectangle for a tree item
; Syntax.........: _GUICtrlTreeView_DisplayRectEx($hWnd, $hItem[, $fTextOnly = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item whose rectangle will be returned
;                  $fTextOnly   - If the True, the bounding rectangle includes only the text of the item.  Otherwise, it includes
;                  +the entire line that the item occupies.
; Return values .: Success      - $tagRECT structure that holds the bounding rectangle.  The coordinates are relative to the upper
;                  +left corner of the control.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_DisplayRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_DisplayRectEx($hWnd, $hItem, $fTextOnly = False)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	Local $pRect = DllStructGetPtr($tRect)
	Local $iRet
	If IsHWnd($hWnd) Then
		; RECT is expected to point to the item in its first member.
		DllStructSetData($tRect, "Left", $hItem)
		If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
			$iRet = _SendMessage($hWnd, $TVM_GETITEMRECT, $fTextOnly, $pRect, 0, "wparam", "ptr")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_MemWrite($tMemMap, $pRect)
			$iRet = _SendMessage($hWnd, $TVM_GETITEMRECT, $fTextOnly, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $pRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	Else
		If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
		; RECT is expected to point to the item in its first member.
		DllStructSetData($tRect, "Left", $hItem)
		$iRet = GUICtrlSendMsg($hWnd, $TVM_GETITEMRECT, $fTextOnly, $pRect)
	EndIf

	; On failure ensure Left is set to 0 and not the item handle.
	If Not $iRet Then DllStructSetData($tRect, "Left", 0)
	Return SetError($iRet = 0, $iRet, $tRect)
EndFunc   ;==>_GUICtrlTreeView_DisplayRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_EndUpdate
; Description ...: Enables screen repainting that was turned off with the BeginUpdate function
; Syntax.........: _GUICtrlTreeView_EndUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_BeginUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_EndUpdate($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__TREEVIEWCONSTANT_WM_SETREDRAW, 1) = 0
EndFunc   ;==>_GUICtrlTreeView_EndUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_EnsureVisible
; Description ...: Ensures that a item is visible, expanding the parent item or scrolling the control if necessary
; Syntax.........: _GUICtrlTreeView_EnsureVisible($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .:  True        - if the system scrolled the items in the tree-view control and no items were expanded
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetVisible
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_EnsureVisible($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_ENSUREVISIBLE, 0, $hItem, 0, "wparam", "handle") <> 0
EndFunc   ;==>_GUICtrlTreeView_EnsureVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Expand
; Description ...: Expands or collapses the list of child items associated with the specified parent item, if any
; Syntax.........: _GUICtrlTreeView_Expand($hWnd[, $hItem = 0[, $fExpand = True]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fExpand     - Expand or Collapse, use the following values:
;                  | True       - Expand items
;                  |False       - Collapse items
; Return values .:
; Author ........: Holger Kotsch
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlTreeView_ExpandedOnce, _GUICtrlTreeView_GetExpanded
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Expand($hWnd, $hItem = 0, $fExpand = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $hItem = 0 Then $hItem = 0x00000000

	If $hItem = 0x00000000 Then
		$hItem = $TVI_ROOT
	Else
		If Not IsHWnd($hItem) Then
			Local $hItem_tmp = GUICtrlGetHandle($hItem)
			If $hItem_tmp <> 0x00000000 Then $hItem = $hItem_tmp
		EndIf
	EndIf

	If $fExpand Then
		__GUICtrlTreeView_ExpandItem($hWnd, $TVE_EXPAND, $hItem)
	Else
		__GUICtrlTreeView_ExpandItem($hWnd, $TVE_COLLAPSE, $hItem)
	EndIf
EndFunc   ;==>_GUICtrlTreeView_Expand

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
; Description ...: Expands/Collapes the item and child(ren), if any
; Syntax.........: __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
; Parameters ....: $hWnd  - Handle to the control
; Return values .:
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
	If Not IsHWnd($hWnd) Then

		If $hItem = 0x00000000 Then
			$hItem = $TVI_ROOT
		Else
			$hItem = GUICtrlGetHandle($hItem)
			If $hItem = 0 Then Return
		EndIf
		$hWnd = GUICtrlGetHandle($hWnd)
	EndIf

	_SendMessage($hWnd, $TVM_EXPAND, $iExpand, $hItem, 0, "wparam", "handle")

	If $iExpand = $TVE_EXPAND And $hItem > 0 Then _SendMessage($hWnd, $TVM_ENSUREVISIBLE, 0, $hItem, 0, "wparam", "handle")

;	<modified by rexx: disable recursive>
;	$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle")

;	While $hItem <> 0x00000000
;		Local $h_child = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle")
;		If $h_child <> 0x00000000 Then __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
;		$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_NEXT, $hItem, 0, "wparam", "handle")
;	WEnd
EndFunc   ;==>__GUICtrlTreeView_ExpandItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetExpanded
; Description ...: Indicates whether the item is expanded
; Syntax.........: _GUICtrlTreeView_GetExpanded($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item is expanded
;                  False        - Item is not expanded
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_Expand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetExpanded($hWnd, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hWnd, $hItem), $TVIS_EXPANDED) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetExpanded

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetFirstChild
; Description ...: Retrieves the first child item of the specified item
; Syntax.........: _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - The handle of the first child item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetLastChild, _GUICtrlTreeView_GetNextChild, _GUICtrlTreeView_GetPrevChild
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)
	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetFirstChild

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetImageIndex
; Description ...: Retrieves the normal state image index
; Syntax.........: _GUICtrlTreeView_GetImageIndex($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Image list index
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetImageIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetImageIndex($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_IMAGE)
	DllStructSetData($tItem, "hItem", $hItem)
	__GUICtrlTreeView_GetItem($hWnd, $tItem)
	Return DllStructGetData($tItem, "Image")
EndFunc   ;==>_GUICtrlTreeView_GetImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetImageListIconHandle
; Description ...: Retrieve ImageList handle
; Syntax.........: _GUICtrlTreeView_GetImageListIconHandle($hWnd, $iIndex)
; Parameters ....: $hWnd  - Handle to the control
;                  $iIndex      - ImageList index to retrieve
; Return values .: Success      - ImageList handle
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetImageListIconHandle($hWnd, $iIndex)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hImageList = _SendMessage($hWnd, $TVM_GETIMAGELIST, 0, 0, 0, "wparam", "lparam", "handle")
	Local $hIcon = DllCall("comctl32.dll", "handle", "ImageList_GetIcon", "handle", $hImageList, "int", $iIndex, "uint", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return $hIcon[0]
EndFunc   ;==>_GUICtrlTreeView_GetImageListIconHandle

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_GetItem
; Description ...: Retrieves some or all of a item's attributes
; Syntax.........: __GUICtrlTreeView_GetItem($hWnd, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $tItem       - $tagTVITEMEX structure used to request/receive item information
;                  +the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function is used internally and should not normally be called by the end user
; Related .......: __GUICtrlTreeView_SetItem
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_GetItem($hWnd, ByRef $tItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)

	Local $pItem = DllStructGetPtr($tItem)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
			$iRet = _SendMessage($hWnd, $TVM_GETITEMW, 0, $pItem, 0, "wparam", "ptr")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
			_MemWrite($tMemMap, $pItem)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $TVM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $TVM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemRead($tMemMap, $pMemory, $pItem, $iItem)
			_MemFree($tMemMap)
		EndIf
	Else
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $TVM_GETITEMW, 0, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $TVM_GETITEMA, 0, $pItem)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>__GUICtrlTreeView_GetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetItemHandle
; Description ...: Retrieve the item handle
; Syntax.........: _GUICtrlTreeView_GetItemHandle($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem       - Item ID
; Return values .: Success      - Item handle
;                  Failure      - 0
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetItemHandle($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000
	If IsHWnd($hWnd) Then
		If $hItem = 0x00000000 Then $hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_ROOT, 0, 0, "wparam", "lparam", "handle")
	Else
		If $hItem = 0x00000000 Then
			$hItem = GUICtrlSendMsg($hWnd, $TVM_GETNEXTITEM, $TVGN_ROOT, 0)
		Else
			Local $hTempItem = GUICtrlGetHandle($hItem)
			If $hTempItem <> 0x00000000 Then $hItem = $hTempItem
		EndIf
	EndIf

	Return $hItem
EndFunc   ;==>_GUICtrlTreeView_GetItemHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetLastChild
; Description ...: Retrieves the last child item of the specified item
; Syntax.........: _GUICtrlTreeView_GetLastChild($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - The handle of the last child item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetFirstChild, _GUICtrlTreeView_GetNextChild, _GUICtrlTreeView_GetPrevChild
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetLastChild($hWnd, $hItem)
	Local $hResult = _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
	If $hResult <> 0x00000000 Then
		Local $hNext = $hResult
		Do
			$hResult = $hNext
			$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hNext)
		Until $hNext = 0x00000000
	EndIf
	Return $hResult
EndFunc   ;==>_GUICtrlTreeView_GetLastChild

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetNextSibling
; Description ...: Returns the next item at the same level as the specified item
; Syntax.........: _GUICtrlTreeView_GetNextSibling($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle to the next sibling item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetNext, _GUICtrlTreeView_GetPrevSibling
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetNextSibling($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_NEXT, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetNextSibling

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetParentHandle
; Description ...: Retrieve the parent handle of item
; Syntax.........: _GUICtrlTreeView_GetParentHandle($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem - item ID/handle
; Return values .: Success      - Handle to Parent item
;                  Failure      - 0
; Author ........: Gary Frost (gafrost), Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetParentHandle($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

;~ 	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $hItem = 0 Then $hItem = 0x00000000

	; get the handle to item selected
	If $hItem = 0x00000000 Then
		If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
		$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
		If $hItem = 0x00000000 Then Return False
	Else
		If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
		If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	EndIf
	; get the handle of the parent item
	Local $hParent = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PARENT, $hItem, 0, "wparam", "handle", "handle")

	Return $hParent
EndFunc   ;==>_GUICtrlTreeView_GetParentHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetPrevSibling
; Description ...: Returns the previous item before the calling item at the same level
; Syntax.........: _GUICtrlTreeView_GetPrevSibling($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle to the previous sibling item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetNextSibling
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetPrevSibling($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PREVIOUS, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetPrevSibling

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetSelection
; Description ...: Retrieves the currently selected item
; Syntax.........: _GUICtrlTreeView_GetSelection($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the currently selected item or 0 in no item is selected
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetSelection($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetSelection

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetState
; Description ...: Retrieve the state of the item
; Syntax.........: _GUICtrlTreeView_GetState($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem - item ID/handle
; Return values .: Success      - The state of the item
;                  Failure      - False
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetState($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000

	$hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If $hItem = 0x00000000 Then Return SetError(1, 1, 0)

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	Local $pItem = DllStructGetPtr($tTVITEM)
	DllStructSetData($tTVITEM, "Mask", $TVIF_STATE)
	DllStructSetData($tTVITEM, "hItem", $hItem)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		_SendMessage($hWnd, $TVM_GETITEMA, 0, $pItem)
	Else
		Local $iSize = DllStructGetSize($tTVITEM)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
		_MemWrite($tMemMap, $pItem)
		_SendMessage($hWnd, $TVM_GETITEMA, 0, $pMemory)
		_MemRead($tMemMap, $pMemory, $pItem, $iSize)
		_MemFree($tMemMap)
	EndIf

	Return DllStructGetData($tTVITEM, "State")
EndFunc   ;==>_GUICtrlTreeView_GetState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetText
; Description ...: Retrieve the item text
; Syntax.........: _GUICtrlTreeView_GetText($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem - item ID/handle
; Return values .: Success      - Text from item
;                  Failure      - Empty string
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetText($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $hItem = 0x00000000 Then Return SetError(1, 1, "")

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	Local $tText
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $fUnicode Then
		$tText = DllStructCreate("wchar Buffer[4096]"); create a text 'area' for receiving the text
	Else
		$tText = DllStructCreate("char Buffer[4096]"); create a text 'area' for receiving the text
	EndIf
	Local $pBuffer = DllStructGetPtr($tText)
	Local $pItem = DllStructGetPtr($tTVITEM)

	DllStructSetData($tTVITEM, "Mask", $TVIF_TEXT)
	DllStructSetData($tTVITEM, "hItem", $hItem)
	DllStructSetData($tTVITEM, "TextMax", 4096)

	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		DllStructSetData($tTVITEM, "Text", $pBuffer)
		_SendMessage($hWnd, $TVM_GETITEMW, 0, $pItem, 0, "wparam", "ptr")
	Else
		Local $iItem = DllStructGetSize($tTVITEM)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + 4096, $tMemMap)
		Local $pText = $pMemory + $iItem
		DllStructSetData($tTVITEM, "Text", $pText)
		_MemWrite($tMemMap, $pItem, $pMemory, $iItem)
		If $fUnicode Then
			_SendMessage($hWnd, $TVM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			_SendMessage($hWnd, $TVM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pText, $pBuffer, 4096)
		_MemFree($tMemMap)
	EndIf

	Return DllStructGetData($tText, "Buffer")
EndFunc   ;==>_GUICtrlTreeView_GetText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag
; Syntax.........: _GUICtrlTreeView_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Control is using Unicode characters
;                  False        - Control is using ANSI characters
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_HitTestEx
; Description ...: Returns information about the location of a point relative to the control
; Syntax.........: _GUICtrlTreeView_HitTestEx($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position to test
;                  $iY          - Y position to test
; Return values .: Success      - $tagTVHITTESTINFO structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_HitTest, _GUICtrlTreeView_HitTestItem, $tagTVHITTESTINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_HitTestEx($hWnd, $iX, $iY)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tHitTest = DllStructCreate($tagTVHITTESTINFO)
	Local $pHitTest = DllStructGetPtr($tHitTest)
	DllStructSetData($tHitTest, "X", $iX)
	DllStructSetData($tHitTest, "Y", $iY)
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		_SendMessage($hWnd, $TVM_HITTEST, 0, $pHitTest, 0, "wparam", "ptr")
	Else
		Local $iHitTest = DllStructGetSize($tHitTest)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iHitTest, $tMemMap)
		_MemWrite($tMemMap, $pHitTest)
		_SendMessage($hWnd, $TVM_HITTEST, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $pHitTest, $iHitTest)
		_MemFree($tMemMap)
	EndIf
	Return $tHitTest
EndFunc   ;==>_GUICtrlTreeView_HitTestEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_HitTestItem
; Description ...: Returns the item at the specified coordinates
; Syntax.........: _GUICtrlTreeView_HitTestItem($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position to test
;                  $iY          - Y position to test
; Return values .: Success      - Handle to the item at the specified point or 0 if no item occupies the point
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_HitTest, _GUICtrlTreeView_HitTestEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_HitTestItem($hWnd, $iX, $iY)
	Local $tHitTest = _GUICtrlTreeView_HitTestEx($hWnd, $iX, $iY)
	Return DllStructGetData($tHitTest, "Item")
EndFunc   ;==>_GUICtrlTreeView_HitTestItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_InsertItem
; Description ...: Insert an item
; Syntax.........: _GUICtrlTreeView_InsertItem($hWnd, $sItem_Text[, $hItem_Parent = 0[, $hItem_After = 0[, $iImage = -1[, $iSelImage = -1]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sItem_Text  - Text of new item
;                  $hItem_Parent- parent item ID/handle/item
;                  $hItem_After - item ID/handle/flag to insert new item after
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
; Return values .: Success      - The new item handle
;                  Failure      - 0
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_InsertItem($hWnd, $sItem_Text, $hItem_Parent = 0, $hItem_After = 0, $iImage = -1, $iSelImage = -1, $iParam = 0) ; <modified by rexx: add $iParam>
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $tTVI = DllStructCreate($tagTVINSERTSTRUCT)
	Local $pInsert = DllStructGetPtr($tTVI)

	Local $iBuffer = StringLen($sItem_Text) + 1
	Local $tText
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $fUnicode Then
		$tText = DllStructCreate("wchar Buffer[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tText = DllStructCreate("char Buffer[" & $iBuffer & "]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tText)

	Local $hItem_tmp
	If $hItem_Parent = 0 Then ; setting to root level
		$hItem_Parent = $TVI_ROOT
	ElseIf Not IsHWnd($hItem_Parent) Then ; control created by autoit create
		$hItem_tmp = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem_Parent)
		If $hItem_tmp Then $hItem_Parent = $hItem_tmp
	EndIf

	If $hItem_After = 0 Then ; using default
		$hItem_After = $TVI_LAST
	ElseIf ($hItem_After <> $TVI_ROOT And _
			$hItem_After <> $TVI_FIRST And _
			$hItem_After <> $TVI_LAST And _
			$hItem_After <> $TVI_SORT) Then ; not using flag
		If Not IsHWnd($hItem_After) Then
			$hItem_tmp = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem_After)
			If Not $hItem_tmp Then ; item not found or invalid flag used
				$hItem_After = $TVI_LAST
			Else ; setting handle
				$hItem_After = $hItem_tmp
			EndIf
		EndIf
	EndIf

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	DllStructSetData($tText, "Buffer", $sItem_Text)

	Local $hIcon
	Local $iMask = $TVIF_TEXT
	If $iImage >= 0 Then
		$iMask = BitOR($iMask, $TVIF_IMAGE)
		$iMask = BitOR($iMask, $TVIF_IMAGE)
		DllStructSetData($tTVI, "Image", $iImage)
	Else
		$hIcon = _GUICtrlTreeView_GetImageListIconHandle($hWnd, 0)
		If $hIcon <> 0x00000000 Then
			$iMask = BitOR($iMask, $TVIF_IMAGE)
			DllStructSetData($tTVI, "Image", 0)
			DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
			; No @error test because results are unimportant.
		EndIf
	EndIf

	If $iSelImage >= 0 Then
		$iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
		$iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
		DllStructSetData($tTVI, "SelectedImage", $iSelImage)
	Else
		$hIcon = _GUICtrlTreeView_GetImageListIconHandle($hWnd, 1)
		If $hIcon <> 0x00000000 Then
			$iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
			DllStructSetData($tTVI, "SelectedImage", 0)
			DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
			; No @error test because results are unimportant.
		EndIf
	EndIf

	DllStructSetData($tTVI, "Parent", $hItem_Parent)
	DllStructSetData($tTVI, "InsertAfter", $hItem_After)
	DllStructSetData($tTVI, "TextMax", $iBuffer)
	$iMask = BitOR($iMask, $TVIF_PARAM)
	DllStructSetData($tTVI, "Param", $iParam) ; <modified by rexx: add $iParam>
	DllStructSetData($tTVI, "Mask", $iMask)


	Local $hItem
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		DllStructSetData($tTVI, "Text", $pBuffer)
		$hItem = _SendMessage($hWnd, $TVM_INSERTITEMW, 0, $pInsert, 0, "wparam", "ptr")

	Else
		Local $iInsert = DllStructGetSize($tTVI)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iInsert + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iInsert
		_MemWrite($tMemMap, $pInsert, $pMemory, $iInsert)
		_MemWrite($tMemMap, $pBuffer, $pText, $iBuffer)
		DllStructSetData($tTVI, "Text", $pText)
		If $fUnicode Then
			$hItem = _SendMessage($hWnd, $TVM_INSERTITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$hItem = _SendMessage($hWnd, $TVM_INSERTITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return Ptr($hItem) ; <modified by rexx: return pointer>
EndFunc   ;==>_GUICtrlTreeView_InsertItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SelectItem
; Description ...: Selects the specified item, scrolls the item into view, or redraws the item
; Syntax.........: _GUICtrlTreeView_SelectItem($hWnd, $hItem[, $iFlag=0])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iFlag       - Action flag:
;                  |$TVGN_CARET        - Sets the selection to the given item
;                  |$TVGN_DROPHILITE   - Redraws the given item in the style used to indicate the target of a drag/drop operation
;                  |$TVGN_FIRSTVISIBLE - Scrolls the tree view vertically so that the given item is the first visible item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SelectItem($hWnd, $hItem, $iFlag = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) And $hItem <> 0 Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $iFlag = 0 Then $iFlag = $TVGN_CARET
	Return _SendMessage($hWnd, $TVM_SELECTITEM, $iFlag, $hItem, 0, "wparam", "handle") <> 0
EndFunc   ;==>_GUICtrlTreeView_SelectItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetDropTarget
; Description ...: Sets whether the item is drawn as a drag and drop target
; Syntax.........: _GUICtrlTreeView_SetDropTarget($hWnd, $hItem[, $fFlag = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fFlag       - Flag setting:
;                  | True - Item is drawn as a drag and drop target
;                  |False - Item is not
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetDropTarget
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetDropTarget($hWnd, $hItem, $fFlag = True)
	If $fFlag Then
		Return _GUICtrlTreeView_SelectItem($hWnd, $hItem, $TVGN_DROPHILITE)
	ElseIf _GUICtrlTreeView_GetDropTarget($hWnd, $hItem) Then
		Return _GUICtrlTreeView_SelectItem($hWnd, 0)
	EndIf
	Return False
EndFunc   ;==>_GUICtrlTreeView_SetDropTarget

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetIcon
; Description ...: Set an item icon
; Syntax.........: _GUICtrlTreeView_SetIcon($hWnd[, $hItem = 0[, $sIconFile =""[, $iIconID = 0[, $iImageMode = 6]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - item ID/handle
;                  $sIconFile   - The file to extract the icon of
;                  $iIconID     - The iconID to extract of the file
;                  $iImageMode  - 2=normal image / 4=seletected image to set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetIcon($hWnd, $hItem = 0, $sIconFile = "", $iIconID = 0, $iImageMode = 6)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000

	If $hItem <> 0x00000000 And Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If $hItem = 0x00000000 Or $sIconFile = "" Then Return SetError(1, 1, False)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)

	Local $tIcon = DllStructCreate("handle")
	Local $i_count = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sIconFile, "int", $iIconID, _
			"handle", 0, "handle", DllStructGetPtr($tIcon), "uint", 1)
	If @error Then Return SetError(@error, @extended, 0)
	If $i_count[0] = 0 Then Return 0

	Local $hImageList = _SendMessage($hWnd, $TVM_GETIMAGELIST, 0, 0, 0, "wparam", "lparam", "handle")
	If $hImageList = 0x00000000 Then
		$hImageList = DllCall("comctl32.dll", "handle", "ImageList_Create", "int", 16, "int", 16, "uint", 0x0021, "int", 0, "int", 1)
		If @error Then Return SetError(@error, @extended, 0)
		$hImageList = $hImageList[0]
		If $hImageList = 0 Then Return SetError(1, 1, False)

		_SendMessage($hWnd, $TVM_SETIMAGELIST, 0, $hImageList, 0, "wparam", "handle")
	EndIf

	Local $hIcon = DllStructGetData($tIcon, 1)
	Local $i_icon = DllCall("comctl32.dll", "int", "ImageList_AddIcon", "handle", $hImageList, "handle", $hIcon)
	$i_icon = $i_icon[0]
	If @error Then
		Local $iError = @error, $iExtended = @extended
		DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
		; No @error test because results are unimportant.
		Return SetError($iError, $iExtended, 0)
	EndIf

	DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
	; No @error test because results are unimportant.

	Local $iMask = BitOR($TVIF_IMAGE, $TVIF_SELECTEDIMAGE)

	If BitAND($iImageMode, 2) Then
		DllStructSetData($tTVITEM, "Image", $i_icon)
		If Not BitAND($iImageMode, 4) Then $iMask = $TVIF_IMAGE
	EndIf

	If BitAND($iImageMode, 4) Then
		DllStructSetData($tTVITEM, "SelectedImage", $i_icon)
		If Not BitAND($iImageMode, 2) Then
			$iMask = $TVIF_SELECTEDIMAGE
		Else
			$iMask = BitOR($TVIF_IMAGE, $TVIF_SELECTEDIMAGE)
		EndIf
	EndIf

	DllStructSetData($tTVITEM, "Mask", $iMask)
	DllStructSetData($tTVITEM, "hItem", $hItem)

	Return __GUICtrlTreeView_SetItem($hWnd, $tTVITEM)
EndFunc   ;==>_GUICtrlTreeView_SetIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetImageIndex
; Description ...: Sets the index into image list for which image is displayed when a item is in its normal state
; Syntax.........: _GUICtrlTreeView_SetImageIndex($hWnd, $hItem, $iIndex)
; Parameters ....: $hWnd       - Handle to the control
;                  $hItem      - Handle to the item
;                  $iIndex     - Image list index
; Return values .: Success     - True
;                  Failure     - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetImageIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetImageIndex($hWnd, $hItem, $iIndex)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	; <modified by rexx: also set selected image>
	DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_IMAGE, $TVIF_SELECTEDIMAGE))
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "Image", $iIndex)
	DllStructSetData($tItem, "SelectedImage", $iIndex)
	Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc   ;==>_GUICtrlTreeView_SetImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetInsertMark
; Description ...: Sets the insertion mark
; Syntax.........: _GUICtrlTreeView_SetInsertMark($hWnd, $hItem[, $fAfter = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Specifies at which item the insertion mark will be placed.  If this is 0, the insertion mark is
;                  +removed.
;                  $fAfter      - Specifies if the insertion mark is placed before or after  the  item.  If  this  is  True,  the
;                  +insertion mark will be placed after the item.  If this is False, the insertion mark will be placed before the
;                  +item.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetInsertMark($hWnd, $hItem, $fAfter = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) And $hItem <> 0 Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_SETINSERTMARK, $fAfter, $hItem, 0, "wparam", "handle") <> 0
EndFunc   ;==>_GUICtrlTreeView_SetInsertMark

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_SetItem
; Description ...: Sets some or all of a items attributes
; Syntax.........: __GUICtrlTreeView_SetItem($hWnd, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $tItem       - $tagTVITEMEX structure that contains the new item attributes
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function is used internally and should not normally be called by the end user
; Related .......: __GUICtrlTreeView_GetItem
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_SetItem($hWnd, ByRef $tItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)

	Local $pItem = DllStructGetPtr($tItem)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		$iRet = _SendMessage($hWnd, $TVM_SETITEMW, 0, $pItem, 0, "wparam", "ptr")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
		_MemWrite($tMemMap, $pItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $TVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $TVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>__GUICtrlTreeView_SetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetSelected
; Description ...: Sets whether the item appears in the selected state
; Syntax.........: _GUICtrlTreeView_SetSelected($hWnd, $hItem[, $fFlag = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fFlag       - True if item is to be selected, otherwise False
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetSelected
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetSelected($hWnd, $hItem, $fFlag = True)
	Return _GUICtrlTreeView_SetState($hWnd, $hItem, $TVIS_SELECTED, $fFlag)
EndFunc   ;==>_GUICtrlTreeView_SetSelected

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetState
; Description ...: Set the state of the specified item
; Syntax.........: _GUICtrlTreeView_SetState($hWnd, $hItem[, $iState = 0[, $iSetState = 0]])
; Parameters ....: $hWnd                - Handle to the control
;                  $hItem               - item ID/handle to set the icon
;                  $iState              - The new item state, can be one or more of the following:
;                  |$TVIS_SELECTED      - Set item selected
;                  |$TVIS_CUT           - Set item as part of a cut-and-paste operation
;                  |$TVIS_DROPHILITED   - Set item as a drag-and-drop target
;                  |$TVIS_BOLD          - Set item as bold
;                  |$TVIS_EXPANDED      - Expand item
;                  |$TVIS_EXPANDEDONCE  - Set item's list of child items has been expanded at least once
;                  |$TVIS_EXPANDPARTIAL - Set item as partially expanded
;                  $iSetState - True if item state is to be set, False remove item state
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......: State values can BitOr'ed together as for example BitOr($TVIS_SELECTED, $TVIS_BOLD).
; Related .......: _GUICtrlTreeView_GetState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetState($hWnd, $hItem, $iState = 0, $iSetState = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If $hItem = 0x00000000 Or ($iState = 0 And $iSetState = False) Then Return False

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	If @error Then Return SetError(1, 1, 0)
	DllStructSetData($tTVITEM, "Mask", $TVIF_STATE)
	DllStructSetData($tTVITEM, "hItem", $hItem)
	If $iSetState Then
		DllStructSetData($tTVITEM, "State", $iState)
	Else
		DllStructSetData($tTVITEM, "State", BitAND($iSetState, $iState))
	EndIf
	DllStructSetData($tTVITEM, "StateMask", $iState)
	If $iSetState Then DllStructSetData($tTVITEM, "StateMask", BitOR($iSetState, $iState))
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return __GUICtrlTreeView_SetItem($hWnd, $tTVITEM)
EndFunc   ;==>_GUICtrlTreeView_SetState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetText
; Description ...: Set the text of an item
; Syntax.........: _GUICtrlTreeView_SetText($hWnd[, $hItem = 0[, $sText = ""]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - item ID/handle to set the icon
;                  $sText       - The new item text
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetText($hWnd, $hItem = 0, $sText = "")
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If $hItem = 0x00000000 Or $sText = "" Then Return SetError(1, 1, 0)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	Local $pItem = DllStructGetPtr($tTVITEM)
	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Buffer[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Buffer[" & $iBuffer & "]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	DllStructSetData($tBuffer, "Buffer", $sText)
	DllStructSetData($tTVITEM, "Mask", BitOR($TVIF_HANDLE, $TVIF_TEXT))
	DllStructSetData($tTVITEM, "hItem", $hItem)
	DllStructSetData($tTVITEM, "TextMax", $iBuffer)
	Local $fResult
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		DllStructSetData($tTVITEM, "Text", $pBuffer)
		$fResult = _SendMessage($hWnd, $TVM_SETITEMW, 0, $pItem, 0, "wparam", "ptr")
	Else
		Local $iItem = DllStructGetSize($tTVITEM)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iItem
		DllStructSetData($tTVITEM, "Text", $pText)
		_MemWrite($tMemMap, $pItem, $pMemory, $iItem)
		_MemWrite($tMemMap, $pBuffer, $pText, $iBuffer)
		If $fUnicode Then
			$fResult = _SendMessage($hWnd, $TVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$fResult = _SendMessage($hWnd, $TVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf

	Return $fResult <> 0
EndFunc   ;==>_GUICtrlTreeView_SetText
