; Oringally Folder Menu 3 by rexx
; FolderMenu3EX is Forked from v3.1.2.2
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <TreeViewConstants.au3>
#include <GuiTreeView.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <GuiComboBox.au3>
#include <string.au3>
Opt("GUIOnEventMode", 1)
Global Const $WM_DROPFILES = 0x233

Func CreateOptionsGui()
	Global $iGuiMinWidth = 580, $iGuiMinHeight = 538
	#region ### START Koda GUI section ###
	Local $Options = GUICreate($sLang_Options, 564, 500, -1, -1, BitOR($WS_MAXIMIZEBOX, $WS_MINIMIZEBOX, $WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU, $WS_CAPTION, $WS_OVERLAPPEDWINDOW, $WS_TILEDWINDOW, $WS_POPUP, $WS_POPUPWINDOW, $WS_GROUP, $WS_TABSTOP, $WS_BORDER, $WS_CLIPSIBLINGS), BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE))
	GUISetFont(9, 400, 0, "Tahoma")
	GUISetOnEvent($GUI_EVENT_CLOSE, "OptionsClose")
	GUISetOnEvent($GUI_EVENT_MAXIMIZE, "OptionsResized")
	GUISetOnEvent($GUI_EVENT_RESIZED, "OptionsResized")
	GUISetOnEvent($GUI_EVENT_RESTORE, "OptionsResized")
	GUISetOnEvent($GUI_EVENT_DROPPED, "OptionsDropped")
	GUISetOnEvent($GUI_EVENT_MOUSEMOVE, "OptionsMouseMove")
	GUISetOnEvent($GUI_EVENT_PRIMARYUP, "OptionsPrimaryUp")
	Global $Tab1 = GUICtrlCreateTab(16, 16, 534, 432)
	GUICtrlSetResizing($Tab1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
	TabFavCreate()
	TabAppCreate()
	TabKeyCreate()
	TabIconCreate()
	TabMenuCreate()
	TabOtherCreate()
	TabAboutCreate()
	GUICtrlCreateTabItem("")
	; GUICtrlSetOnEvent($Tab1, "Tab1Change")
	Local $ButtonEdit = GUICtrlCreateButton($sLang_BtnEdit, 16, 460, 80, 24, $WS_GROUP)
	GUICtrlSetResizing($ButtonEdit, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonEdit, "ButtonEditClick")
	Local $ButtonOK = GUICtrlCreateButton($sLang_BtnOK, 292 + 88, 460, 80, 24, $WS_GROUP)
	GUICtrlSetResizing($ButtonOK, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonOK, "ButtonOKClick")
	Local $ButtonCancel = GUICtrlCreateButton($sLang_BtnCancel, 380 + 88, 460, 80, 24, $WS_GROUP)
	GUICtrlSetResizing($ButtonCancel, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonCancel, "ButtonCancelClick")
	; Local $ButtonApply = GUICtrlCreateButton($sLang_BtnApply, 304, 460, 80, 24, $WS_GROUP)
	; GUICtrlSetResizing($ButtonApply, $GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ButtonApply, "ButtonApplyClick")
	; GUISetState(@SW_SHOW)
	#endregion ### END Koda GUI section ###
	GUICtrlSetTip($ButtonEdit, $sLang_TipEdit)

	#region initialize settings
	TabFavSet()
	TabAppSet()
	TabKeySet()
	TabIconSet()
	TabMenuSet()
	TabOtherSet()
	TabAboutSet()
	#endregion initialize settings

	GUICtrlSetState($ButtonOK, $GUI_DEFBUTTON)

	#region CtrlTab Hotkey
	Local $TabRight = GUICtrlCreateDummy()
	Local $TabLeft = GUICtrlCreateDummy()
	Local $ShiftUp = GUICtrlCreateDummy()
	Local $ShiftDown = GUICtrlCreateDummy()
	Local $aAccelerator[4][2]
	$aAccelerator[0][0] = '^{TAB}'
	$aAccelerator[0][1] = $TabRight
	$aAccelerator[1][0] = '^+{TAB}'
	$aAccelerator[1][1] = $TabLeft
	$aAccelerator[2][0] = '+{Up}'
	$aAccelerator[2][1] = $ShiftUp
	$aAccelerator[3][0] = '+{Down}'
	$aAccelerator[3][1] = $ShiftDown
	GUICtrlSetOnEvent($TabRight, "TabRight")
	GUICtrlSetOnEvent($TabLeft, "TabLeft")
	GUICtrlSetOnEvent($ShiftUp, "ShiftUp")
	GUICtrlSetOnEvent($ShiftDown, "ShiftDown")
	GUISetAccelerators($aAccelerator, $Options)
	#endregion CtrlTab Hotkey

	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES")
	GUIRegisterMsg($WM_GETMINMAXINFO, "WM_GETMINMAXINFO")
	Return $Options
EndFunc

#region WM
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $wParam
		Case $TreeViewFav
			Switch $iCode
				Case $TVN_SELCHANGEDA, $TVN_SELCHANGEDW
					TreeView_ItemChanged()
				Case $TVN_KEYDOWN
					TreeView_KeyDown($lParam)
				Case $TVN_BEGINDRAGA, $TVN_BEGINDRAGW
					$hTreeDragItem = TreeItemFromPoint($hWndFrom)
					Local $iDragItem = TreeViewFavGetItemID($hTreeDragItem)
					If $iDragItem <> 0 And $iDragItem <> $FavItemRoot And $FavItemType[$iDragItem - 10000] <> "ItemSetting" Then
						$fTreeDrag = True
						_GUICtrlTreeView_SetSelected($hWndFrom, _GUICtrlTreeView_GetSelection($hWndFrom), False)
						$hTreeDragImage = _GUICtrlTreeView_CreateDragImage($hWndFrom, $hTreeDragItem)
					EndIf
			EndSwitch
		Case $ListViewApp
			Switch $iCode
				Case $LVN_ITEMCHANGED
					ListViewApp_ItemChanged()
				Case $LVN_KEYDOWN
					ListViewApp_KeyDown($lParam)
			EndSwitch
		Case $ListViewKey
			Switch $iCode
				Case $LVN_ITEMCHANGED
					ListViewKey_ItemChanged()
				Case $LVN_KEYDOWN
					ListViewKey_KeyDown($lParam)
			EndSwitch
		Case $ListViewIcon
			Switch $iCode
				Case $LVN_ITEMCHANGED
					ListViewIcon_ItemChanged()
				Case $LVN_KEYDOWN
					ListViewIcon_KeyDown($lParam)
				Case $LVN_ITEMACTIVATE
					ListViewIcon_ItemActivate($lParam)
			EndSwitch
		Case Else
	EndSwitch
	$tNMHDR = 0
	Return $GUI_RUNDEFMSG
EndFunc
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Local $iCode = _WinAPI_HiWord($wParam)
	Local $iID = _WinAPI_LoWord($wParam)
	Local $hCtrl = $lParam
	If $iCode = $EN_CHANGE Then
		Switch $iID
			Case $InputFavName, $InputFavPath, $InputFavIcon, $InputFavDepth, $InputFavExt
				InputFavChange($iID)
			Case $InputAppName, $InputAppClass
				InputAppChange($iID)
			Case $InputHotkeyKey
				InputHotkeyChange($iID)
			Case $InputIconExt, $InputIconIcon
				InputIconChange($iID)
		EndSwitch
	ElseIf $iCode = $CBN_EDITCHANGE Or $iCode = $CBN_SELCHANGE Then
		Switch $iID
			Case $ComboFavSize
				ComboFavSizeChange()
			Case $ComboIconSize
				ComboIconSizeChange()
		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc
Func WM_DROPFILES($hWnd, $iMsg, $wParam, $lParam)
	Global $hDrop = $wParam
	Global $aDropFiles = _WinAPI_DragQueryFileEx($hDrop)
	Return $GUI_RUNDEFMSG
EndFunc
Func WM_GETMINMAXINFO($hWnd, $iMsg, $wParam, $lParam)
	Local $tagMaxInfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $lParam)
	DllStructSetData($tagMaxInfo, 7, $iGuiMinWidth) ; min X
	DllStructSetData($tagMaxInfo, 8, $iGuiMinHeight) ; min Y
	Return 0
EndFunc
#endregion WM

#region Favorite
Func TabFavCreate()
	Global $fTreeViewFavUpdate = False, $fTreeDrag = False, $hTreeDragItem, $hTreeDragImage, $iTreeMovePos
	Global $TabSheetFav = GUICtrlCreateTabItem($sLang_Fav)
	#region Main
	Global $TreeViewFav = GUICtrlCreateTreeView(36, 56, 492, 304, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_SHOWSELALWAYS, $WS_GROUP, $WS_TABSTOP), $WS_EX_CLIENTEDGE)
	GUICtrlSetResizing($TreeViewFav, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
	; GUICtrlSetOnEvent($TreeViewFav, "TreeViewFavClick")
	Global $LabelFavName = GUICtrlCreateLabel($sLang_Name, 36, 372, -1, 17)
	GUICtrlSetResizing($LabelFavName, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavName, "LabelFavNameClick")
	Global $InputFavName = GUICtrlCreateInput("", 78, 368, 353, 21)
	GUICtrlSetResizing($InputFavName, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavName, "InputFavNameChange")
	Global $LabelFavPath = GUICtrlCreateLabel($sLang_Path, 36, 396, -1, 17)
	GUICtrlSetResizing($LabelFavPath, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavPath, "LabelFavPathClick")
	Global $InputFavPath = GUICtrlCreateInput("", 78, 392, 353, 21)
	GUICtrlSetResizing($InputFavPath, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavPath, "InputFavPathChange")
	Global $ButtonFavPath = GUICtrlCreateButton("&...", 435, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavPath, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavPath, "ButtonFavPathClick")
	Global $ButtonFavRel = GUICtrlCreateButton("&<>", 459, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavRel, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavRel, "ButtonFavRelClick")
	Global $LabelFavIcon = GUICtrlCreateLabel($sLang_Icon, 36, 420, -1, 17)
	GUICtrlSetResizing($LabelFavIcon, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavIcon, "LabelFavIconClick")
	Global $InputFavIcon = GUICtrlCreateInput("", 78, 416, 353, 21)
	GUICtrlSetResizing($InputFavIcon, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavIcon, "InputFavIconChange")
	Global $ButtonFavIcon = GUICtrlCreateButton("...", 435, 416, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavIcon, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavIcon, "ButtonFavIconClick")
	Global $ComboFavSize = GUICtrlCreateCombo("", 461, 416, 42, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $CBS_SORT))
	GUICtrlSetData($ComboFavSize, "16|32|48|64")
	GUICtrlSetResizing($ComboFavSize, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboFavSize, "ComboFavSizeChange")
	Global $CheckboxFavMenu = GUICtrlCreateCheckbox($sLang_Submenu, 439, 369, -1, 17)
	GUICtrlSetResizing($CheckboxFavMenu, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxFavMenu, "CheckboxFavMenuClick")
	Global $ButtonFavAdd = GUICtrlCreateButton($sLang_Add, 483, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavAdd, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavAdd, "ButtonFavAddClick")
	Global $ButtonFavDel = GUICtrlCreateButton($sLang_Del, 507, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavDel, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavDel, "ButtonFavDelClick")
	Global $ButtonFavSort = GUICtrlCreateButton($sLang_Sort, 507, 416, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavSort, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavSort, "ButtonFavSortClick")
	#endregion Main
	#region Submenu
	Global $LabelFavDepth = GUICtrlCreateLabel($sLang_Depth, 36, 372, -1, 17)
	GUICtrlSetResizing($LabelFavDepth, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavDepth, "LabelFavDepthClick")
	Global $InputFavDepth = GUICtrlCreateInput("", 84, 368, 48, 21, BitOR($ES_AUTOHSCROLL, $ES_NUMBER))
	GUICtrlSetResizing($InputFavDepth, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavDepth, "InputFavDepthChange")
	Global $CheckboxFavShowFile = GUICtrlCreateCheckbox($sLang_ShowFile, 36, 393, -1, 17)
	GUICtrlSetResizing($CheckboxFavShowFile, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxFavShowFile, "CheckboxFavShowFileClick")
	Global $InputFavExt = GUICtrlCreateInput("", 204, 392, 160, 21)
	GUICtrlSetResizing($InputFavExt, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavExt, "InputFavExtChange")
	Global $LabelFavDrive = GUICtrlCreateLabel($sLang_DriveType, 36, 420, -1, 17)
	GUICtrlSetResizing($LabelFavDrive, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavDrive, "LabelFavDriveClick")
	Global $ComboFavDrive = GUICtrlCreateCombo("", 204, 416, 160, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData($ComboFavDrive, $sLang_All & "|" & $sLang_Fixed & "|" & $sLang_CDROM & "|" & $sLang_Removable & "|" & $sLang_Network & "|" & $sLang_RAMDisk, $sLang_All)
	GUICtrlSetResizing($ComboFavDrive, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ComboFavDrive, "ComboFavDriveChange")
	#endregion Submenu
	#region SystemRecent
	Global $LabelFavSRecentSize = GUICtrlCreateLabel($sLang_RecentSize, 36, 372, -1, 17)
	GUICtrlSetResizing($LabelFavSRecentSize, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavSRecentSize, "LabelFavSRecentSizeClick")
	Global $InputFavSRecentSize = GUICtrlCreateInput("", 148, 368, 48, 21, BitOR($ES_AUTOHSCROLL, $ES_NUMBER))
	GUICtrlSetResizing($InputFavSRecentSize, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavSRecentSize, "InputFavSRecentSizeChange")
	Global $CheckboxFavSRecentDate = GUICtrlCreateCheckbox($sLang_RecentDate, 36, 393, -1, 17)
	GUICtrlSetResizing($CheckboxFavSRecentDate, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavSRecentDate, "CheckboxFavSRecentDateClick")
	Global $CheckboxFavSRecentIndex = GUICtrlCreateCheckbox($sLang_RecentIndex, 204, 393, -1, 17)
	GUICtrlSetResizing($CheckboxFavSRecentIndex, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavSRecentIndex, "CheckboxFavSRecentIndexClick")
	Global $CheckboxFavSRecentFolder = GUICtrlCreateCheckbox($sLang_RecentFolder, 36, 417, -1, 17)
	GUICtrlSetResizing($CheckboxFavSRecentFolder, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavSRecentFolder, "CheckboxFavSRecentFolderClick")
	Global $CheckboxFavSRecentFull = GUICtrlCreateCheckbox($sLang_RecentFull, 204, 417, -1, 17)
	GUICtrlSetResizing($CheckboxFavSRecentFull, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavSRecentFull, "CheckboxFavSRecentFullClick")
	#endregion SystemRecent
	#region Recent
	Global $LabelFavRecentSize = GUICtrlCreateLabel($sLang_RecentSize, 36, 372, -1, 17)
	GUICtrlSetResizing($LabelFavRecentSize, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavRecentSize, "LabelFavRecentSizeClick")
	Global $InputFavRecentSize = GUICtrlCreateInput("", 148, 368, 48, 21, BitOR($ES_AUTOHSCROLL, $ES_NUMBER))
	GUICtrlSetResizing($InputFavRecentSize, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavRecentSize, "InputFavRecentSizeChange")
	Global $CheckboxFavRecentDate = GUICtrlCreateCheckbox($sLang_RecentDate, 36, 393, -1, 17)
	GUICtrlSetResizing($CheckboxFavRecentDate, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavRecentDate, "CheckboxFavRecentDateClick")
	Global $CheckboxFavRecentIndex = GUICtrlCreateCheckbox($sLang_RecentIndex, 204, 393, -1, 17)
	GUICtrlSetResizing($CheckboxFavRecentIndex, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavRecentIndex, "CheckboxFavRecentIndexClick")
	Global $CheckboxFavRecentFolder = GUICtrlCreateCheckbox($sLang_RecentFolder, 36, 417, -1, 17)
	GUICtrlSetResizing($CheckboxFavRecentFolder, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavRecentFolder, "CheckboxFavRecentFolderClick")
	Global $CheckboxFavRecentFull = GUICtrlCreateCheckbox($sLang_RecentFull, 204, 417, -1, 17)
	GUICtrlSetResizing($CheckboxFavRecentFull, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavRecentFull, "CheckboxFavRecentFullClick")
	Global $ButtonFavRecentClear = GUICtrlCreateButton($sLang_ClearRecent, 204, 368, -1, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavRecentClear, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavRecentClear, "_ClearRecent")
	#endregion Recent
	#region Drive
	Global $CheckboxFavDriveReload = GUICtrlCreateCheckbox($sLang_DriveReload, 36, 369, -1, 17)
	GUICtrlSetResizing($CheckboxFavDriveReload, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavDriveReload, "CheckboxFavDriveReloadClick")
	Global $CheckboxFavDriveFree = GUICtrlCreateCheckbox($sLang_DriveFree, 36, 393, -1, 17)
	GUICtrlSetResizing($CheckboxFavDriveFree, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavDriveFree, "CheckboxFavDriveFreeClick")
	Global $LabelFavDriveType = GUICtrlCreateLabel($sLang_DriveType, 36, 420, -1, 17)
	GUICtrlSetResizing($LabelFavDriveType, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavDriveType, "LabelFavDriveTypeClick")
	Global $ComboFavDriveType = GUICtrlCreateCombo("", 275, 416, 160, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData($ComboFavDriveType, $sLang_All & "|" & $sLang_Fixed & "|" & $sLang_CDROM & "|" & $sLang_Removable & "|" & $sLang_Network & "|" & $sLang_RAMDisk, $sLang_All)
	GUICtrlSetResizing($ComboFavDriveType, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboFavDriveType, "ComboFavDriveTypeChange")
	#endregion Drive
	#region TC
	Global $LabelFavTCPathExe = GUICtrlCreateLabel($sLang_TCPathExe, 36, 372, -1, 17)
	GUICtrlSetResizing($LabelFavTCPathExe, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavTCPathExe, "LabelFavTCPathExeClick")
	Global $InputFavTCPathExe = GUICtrlCreateInput("", 120, 368, 215, 21)
	GUICtrlSetResizing($InputFavTCPathExe, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavTCPathExe, "InputFavTCPathExeChange")
	Global $ButtonFavTCPathExe = GUICtrlCreateButton("...", 340, 368, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavTCPathExe, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavTCPathExe, "ButtonFavTCPathExeClick")
	Global $LabelFavTCPathIni = GUICtrlCreateLabel($sLang_TCPathIni, 36, 396, -1, 17)
	GUICtrlSetResizing($LabelFavTCPathIni, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelFavTCPathIni, "LabelFavTCPathIniClick")
	Global $InputFavTCPathIni = GUICtrlCreateInput("", 120, 392, 215, 21)
	GUICtrlSetResizing($InputFavTCPathIni, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputFavTCPathIni, "InputFavTCPathIniChange")
	Global $ButtonFavTCPathIni = GUICtrlCreateButton("...", 340, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonFavTCPathIni, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonFavTCPathIni, "ButtonFavTCPathIniClick")
	Global $CheckboxFavTCAsMain = GUICtrlCreateCheckbox($sLang_TCAsMain, 36, 417, -1, 17)
	GUICtrlSetResizing($CheckboxFavTCAsMain, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavTCAsMain, "CheckboxFavTCAsMainClick")
	Global $CheckboxFavTCSubmenu = GUICtrlCreateCheckbox($sLang_TCSubmenu, 180, 417, -1, 17)
	GUICtrlSetResizing($CheckboxFavTCSubmenu, $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxFavTCSubmenu, "CheckboxFavTCSubmenuClick")
	#endregion TC
	#region SetTip
	If $fTCAsMain = 1 Then
		GUICtrlSetTip($TreeViewFav, $sLang_TipTCDirMenu)
	Else
		GUICtrlSetTip($TreeViewFav, $sLang_TipFavTree)
	EndIf
	GUICtrlSetTip($ButtonFavPath, $sLang_TipFavPath)
	GUICtrlSetTip($ButtonFavIcon, $sLang_TipFavIcon)
	GUICtrlSetTip($ComboFavSize, $sLang_TipIconSize)
	GUICtrlSetTip($CheckboxFavMenu, $sLang_TipFavMenu)
	GUICtrlSetTip($ButtonFavRel, $sLang_TipFavRel)
	GUICtrlSetTip($ButtonFavSort, $sLang_TipFavSort)
	GUICtrlSetTip($ButtonFavAdd, $sLang_TipFavAdd)
	GUICtrlSetTip($ButtonFavDel, $sLang_TipFavDel)
	GUICtrlSetTip($InputFavDepth, $sLang_TipFavDepth)
	GUICtrlSetTip($InputFavExt, $sLang_TipFavExt)
	GUICtrlSetTip($CheckboxFavTCSubmenu, $sLang_TipTCSubmenu)
	#endregion SetTip
EndFunc
Func TabFavSet()
	GUICtrlSetState($TreeViewFav, $GUI_DROPACCEPTED)
	GUICtrlSetState($InputFavName, $GUI_DISABLE)
	GUICtrlSetState($InputFavPath, $GUI_DISABLE)
	GUICtrlSetState($ButtonFavPath, $GUI_DISABLE)
	GUICtrlSetState($InputFavIcon, $GUI_DISABLE)
	GUICtrlSetState($ButtonFavIcon, $GUI_DISABLE)
	GUICtrlSetState($ComboFavSize, $GUI_DISABLE)
	GUICtrlSetState($CheckboxFavMenu, $GUI_DISABLE)
	GUICtrlSetState($ButtonFavRel, $GUI_DISABLE)
	GUICtrlSetState($ButtonFavSort, $GUI_DISABLE)
	GUICtrlSetState($ButtonFavAdd, $GUI_DISABLE)
	GUICtrlSetState($ButtonFavDel, $GUI_DISABLE)
	MenuFavPathCreate()
	TabFavShowSubmenu($GUI_HIDE)
	TabFavShowSRecent($GUI_HIDE)
	TabFavShowRecent($GUI_HIDE)
	TabFavShowDrive($GUI_HIDE)
	TabFavShowTC($GUI_HIDE)
	If $fTCAsMain = 1 Then
		TreeViewFavCreateTC()
		TabFavShowMain($GUI_HIDE)
		TabFavShowTC($GUI_SHOW)
	Else
		TreeViewFavCreate()
	EndIf
	If Eval("sLang_" & $sDriveType) <> "" Then GUICtrlSetData($ComboFavDriveType, Eval("sLang_" & $sDriveType))
	If $fDriveReload = 1 Then GUICtrlSetState($CheckboxFavDriveReload, $GUI_CHECKED)
	If $fDriveFree = 1 Then GUICtrlSetState($CheckboxFavDriveFree, $GUI_CHECKED)
	GUICtrlSetData($InputFavTCPathExe, $sTCPathExe)
	GUICtrlSetData($InputFavTCPathIni, $sTCPathIni)
	If $fTCAsMain = 1 Then GUICtrlSetState($CheckboxFavTCAsMain, $GUI_CHECKED)
	If $fTCSubmenu = 1 Then GUICtrlSetState($CheckboxFavTCSubmenu, $GUI_CHECKED)
	GUICtrlSetData($InputFavSRecentSize, $iSRecentSize)
	If $fSRecentDate = 1 Then GUICtrlSetState($CheckboxFavSRecentDate, $GUI_CHECKED)
	If $fSRecentIndex = 1 Then GUICtrlSetState($CheckboxFavSRecentIndex, $GUI_CHECKED)
	If $fSRecentFolder = 1 Then GUICtrlSetState($CheckboxFavSRecentFolder, $GUI_CHECKED)
	If $fSRecentFull = 1 Then GUICtrlSetState($CheckboxFavSRecentFull, $GUI_CHECKED)
	GUICtrlSetData($InputFavRecentSize, $iRecentSize)
	If $fRecentDate = 1 Then GUICtrlSetState($CheckboxFavRecentDate, $GUI_CHECKED)
	If $fRecentIndex = 1 Then GUICtrlSetState($CheckboxFavRecentIndex, $GUI_CHECKED)
	If $fRecentFolder = 1 Then GUICtrlSetState($CheckboxFavRecentFolder, $GUI_CHECKED)
	If $fRecentFull = 1 Then GUICtrlSetState($CheckboxFavRecentFull, $GUI_CHECKED)
EndFunc
Func TabFavShowMain($SHOW)
	GUICtrlSetState($LabelFavName, $SHOW)
	GUICtrlSetState($InputFavName, $SHOW)
	GUICtrlSetState($LabelFavPath, $SHOW)
	GUICtrlSetState($InputFavPath, $SHOW)
	GUICtrlSetState($ButtonFavPath, $SHOW)
	; GUICtrlSetState($LabelFavSize     , $SHOW)
	GUICtrlSetState($ComboFavSize, $SHOW)
	GUICtrlSetState($LabelFavIcon, $SHOW)
	GUICtrlSetState($InputFavIcon, $SHOW)
	GUICtrlSetState($ButtonFavIcon, $SHOW)
	GUICtrlSetState($CheckboxFavMenu, $SHOW)
	GUICtrlSetState($ButtonFavRel, $SHOW)
	GUICtrlSetState($ButtonFavSort, $SHOW)
	GUICtrlSetState($ButtonFavAdd, $SHOW)
	GUICtrlSetState($ButtonFavDel, $SHOW)
EndFunc
Func TabFavShowSubmenu($SHOW)
	GUICtrlSetState($CheckboxFavShowFile, $SHOW)
	GUICtrlSetState($InputFavExt, $SHOW)
	GUICtrlSetState($LabelFavDrive, $SHOW)
	GUICtrlSetState($ComboFavDrive, $SHOW)
	GUICtrlSetState($LabelFavDepth, $SHOW)
	GUICtrlSetState($InputFavDepth, $SHOW)
EndFunc
Func TabFavShowSRecent($SHOW)
	GUICtrlSetState($LabelFavSRecentSize, $SHOW)
	GUICtrlSetState($InputFavSRecentSize, $SHOW)
	GUICtrlSetState($CheckboxFavSRecentDate, $SHOW)
	GUICtrlSetState($CheckboxFavSRecentIndex, $SHOW)
	GUICtrlSetState($CheckboxFavSRecentFolder, $SHOW)
	GUICtrlSetState($CheckboxFavSRecentFull, $SHOW)
EndFunc
Func TabFavShowRecent($SHOW)
	GUICtrlSetState($LabelFavRecentSize, $SHOW)
	GUICtrlSetState($InputFavRecentSize, $SHOW)
	GUICtrlSetState($CheckboxFavRecentDate, $SHOW)
	GUICtrlSetState($CheckboxFavRecentIndex, $SHOW)
	GUICtrlSetState($CheckboxFavRecentFolder, $SHOW)
	GUICtrlSetState($CheckboxFavRecentFull, $SHOW)
	GUICtrlSetState($ButtonFavRecentClear, $SHOW)
EndFunc
Func TabFavShowDrive($SHOW)
	GUICtrlSetState($LabelFavDriveType, $SHOW)
	GUICtrlSetState($ComboFavDriveType, $SHOW)
	GUICtrlSetState($CheckboxFavDriveReload, $SHOW)
	GUICtrlSetState($CheckboxFavDriveFree, $SHOW)
EndFunc
Func TabFavShowTC($SHOW)
	GUICtrlSetState($LabelFavTCPathExe, $SHOW)
	GUICtrlSetState($InputFavTCPathExe, $SHOW)
	GUICtrlSetState($ButtonFavTCPathExe, $SHOW)
	GUICtrlSetState($LabelFavTCPathIni, $SHOW)
	GUICtrlSetState($InputFavTCPathIni, $SHOW)
	GUICtrlSetState($ButtonFavTCPathIni, $SHOW)
	GUICtrlSetState($CheckboxFavTCAsMain, $SHOW)
	GUICtrlSetState($CheckboxFavTCSubmenu, $SHOW)
EndFunc
Func TabFavGet()
	If _GUICtrlTreeView_GetText($TreeViewFav, $FavItemHandle[$FavItemRoot - 10000]) = $sLang_Menu Then
		_XMLDeleteNode("/FolderMenu/Menu/Item")
		TreeViewFavWrite($FavItemHandle[0], "/FolderMenu/Menu")
	EndIf
	Switch GUICtrlRead($ComboFavDriveType)
		Case $sLang_All
			$sDriveType = "All"
		Case $sLang_Fixed
			$sDriveType = "Fixed"
		Case $sLang_CDROM
			$sDriveType = "CDROM"
		Case $sLang_Removable
			$sDriveType = "Removable"
		Case $sLang_Network
			$sDriveType = "Network"
		Case $sLang_RAMDisk
			$sDriveType = "RAMDisk"
	EndSwitch
	$fDriveReload = BitAND(GUICtrlRead($CheckboxFavDriveReload), $GUI_CHECKED)
	$fDriveFree = BitAND(GUICtrlRead($CheckboxFavDriveFree), $GUI_CHECKED)
	$sTCPathExe = GUICtrlRead($InputFavTCPathExe)
	$sTCPathIni = GUICtrlRead($InputFavTCPathIni)
	$fTCAsMain = BitAND(GUICtrlRead($CheckboxFavTCAsMain), $GUI_CHECKED)
	$fTCSubmenu = BitAND(GUICtrlRead($CheckboxFavTCSubmenu), $GUI_CHECKED)
	$iSRecentSize = GUICtrlRead($InputFavSRecentSize)
	$fSRecentDate = BitAND(GUICtrlRead($CheckboxFavSRecentDate), $GUI_CHECKED)
	$fSRecentIndex = BitAND(GUICtrlRead($CheckboxFavSRecentIndex), $GUI_CHECKED)
	$fSRecentFolder = BitAND(GUICtrlRead($CheckboxFavSRecentFolder), $GUI_CHECKED)
	$fSRecentFull = BitAND(GUICtrlRead($CheckboxFavSRecentFull), $GUI_CHECKED)
	$iRecentSize = GUICtrlRead($InputFavRecentSize)
	$fRecentDate = BitAND(GUICtrlRead($CheckboxFavRecentDate), $GUI_CHECKED)
	$fRecentIndex = BitAND(GUICtrlRead($CheckboxFavRecentIndex), $GUI_CHECKED)
	$fRecentFolder = BitAND(GUICtrlRead($CheckboxFavRecentFolder), $GUI_CHECKED)
	$fRecentFull = BitAND(GUICtrlRead($CheckboxFavRecentFull), $GUI_CHECKED)
EndFunc

Func TreeViewFavWriteItem($hItem, $sXPath)
	Local $iID = TreeViewFavGetItemID($hItem) - 10000
	Local $sType = $FavItemType[$iID]
	Switch $sType
		Case "ItemSetting"
			Return
		Case "Separator", "ColSeparator"
			Local $asAtt[2], $asVal[2]
			$asAtt[0] = "Type"
			$asAtt[1] = "Name"
			$asVal[0] = $sType
			$asVal[1] = _GUICtrlTreeView_GetText($TreeViewFav, $hItem)
			_XMLCreateChildWAttr($sXPath, "Item", $asAtt, $asVal)
		Case "Item"
			Local $asAtt[5], $asVal[5]
			$asAtt[0] = "Type"
			$asAtt[1] = "Name"
			$asAtt[2] = "Path"
			$asAtt[3] = "Icon"
			$asAtt[4] = "Size"
			$asVal[0] = $sType
			$asVal[1] = _GUICtrlTreeView_GetText($TreeViewFav, $hItem)
			$asVal[2] = $FavItemPath[$iID]
			$asVal[3] = $FavItemIcon[$iID]
			$asVal[4] = $FavItemSize[$iID]
			_XMLCreateChildWAttr($sXPath, "Item", $asAtt, $asVal)
		Case "ItemMenu"
			Local $asAtt[9], $asVal[9]
			$asAtt[0] = "Type"
			$asAtt[1] = "Name"
			$asAtt[2] = "Path"
			$asAtt[3] = "Icon"
			$asAtt[4] = "Size"
			$asAtt[5] = "Depth"
			$asAtt[6] = "File"
			$asAtt[7] = "Ext"
			$asAtt[8] = "Drive"
			$asVal[0] = $sType
			$asVal[1] = _GUICtrlTreeView_GetText($TreeViewFav, $hItem)
			$asVal[2] = $FavItemPath[$iID]
			$asVal[3] = $FavItemIcon[$iID]
			$asVal[4] = $FavItemSize[$iID]
			$asVal[5] = $FavItemDepth[$iID]
			$asVal[6] = $FavItemFile[$iID]
			$asVal[7] = $FavItemExt[$iID]
			$asVal[8] = $FavItemDrive[$iID]
			_XMLCreateChildWAttr($sXPath, "Item", $asAtt, $asVal)
		Case "Menu"
			Local $asAtt[5], $asVal[5]
			$asAtt[0] = "ID"
			$asAtt[1] = "Type"
			$asAtt[2] = "Name"
			$asAtt[3] = "Icon"
			$asAtt[4] = "Size"
			$asVal[0] = $iID
			$asVal[1] = $sType
			$asVal[2] = _GUICtrlTreeView_GetText($TreeViewFav, $hItem)
			$asVal[3] = $FavItemIcon[$iID]
			$asVal[4] = $FavItemSize[$iID]
			_XMLCreateChildWAttr($sXPath, "Item", $asAtt, $asVal)
			TreeViewFavWrite($hItem, $sXPath & "/Item[@ID='" & $iID & "']")
	EndSwitch
EndFunc
Func TreeViewFavWrite($hRoot, $sXPath)
	Local $hItem = _GUICtrlTreeView_GetFirstChild($TreeViewFav, $hRoot)
	While $hItem <> 0
		TreeViewFavWriteItem($hItem, $sXPath)
		$hItem = _GUICtrlTreeView_GetNextSibling($TreeViewFav, $hItem)
	WEnd
EndFunc
Func TreeViewFavCreateTC()
	Global $FavItemHandle[1]
	Global $FavItemRoot = 10000

	Local $sMenuIconPath = GetIcon("Menu")
	Local $i, $iIconSize
	SplitIconPath($sMenuIconPath, $sMenuIconPath, $i, $iIconSize)
	$sMenuIconPath = DerefPath($sMenuIconPath)

	$FavItemHandle[0] = _GUICtrlTreeView_AddChild($TreeViewFav, 0, $sLang_TCDirMenu)
	_GUICtrlTreeView_SetIcon($TreeViewFav, $FavItemHandle[0], $sFolderMenuExe, 1) ; index 0 - blank Icon as default
	_GUICtrlTreeView_SetIcon($TreeViewFav, $FavItemHandle[0], $sFolderMenuExe, -206) ; index 1 - separator
	_GUICtrlTreeView_SetIcon($TreeViewFav, $FavItemHandle[0], $sMenuIconPath, $i) ; index 2 - menu icon
	_GUICtrlTreeView_SetIcon($TreeViewFav, $FavItemHandle[0], $sTCPathExe, 0) ; index 3 - tc icon

	$sTCPathIni = IniRead($sTCPathIni, "DirMenu", "RedirectSection", $sTCPathIni) ; read redirect info
	$sTCPathIni = DerefPath($sTCPathIni)
	If Not FileExists($sTCPathIni) Then Return

	Local $i = 1
	Local $hParent = $FavItemHandle[0]
	Local $sItemName, $sItemPath, $hItem
	While 1
		$sItemName = IniRead($sTCPathIni, "DirMenu", "menu" & $i, "")
		If $sItemName = "" Then ExitLoop
		If $sItemName = "-" Then ; separator
			$hItem = _GUICtrlTreeView_AddChild($TreeViewFav, $hParent, "- - - - -")
			_GUICtrlTreeView_SetImageIndex($TreeViewFav, $hItem, 1)
		ElseIf $sItemName = "--" Then ; out of a submenu
			If Eval("hParent" & $hParent) <> 0 Then $hParent = Eval("hParent" & $hParent)
		ElseIf StringLeft($sItemName, 1) = "-" Then ; into a submenu
			$sItemName = StringTrimLeft($sItemName, 1)
			$hItem = _GUICtrlTreeView_AddChild($TreeViewFav, $hParent, $sItemName)
			_GUICtrlTreeView_SetImageIndex($TreeViewFav, $hItem, 2)
			Assign("hParent" & $hItem, $hParent, 1)
			$hParent = $hItem
		Else
			$sItemPath = IniRead($sTCPathIni, "DirMenu", "cmd" & $i, "")
			If StringRight($sItemPath, 1) = "\" Then $sItemPath = StringTrimRight($sItemPath, 1)
			If StringLeft($sItemPath, 3) = "cd " Then $sItemPath = StringTrimLeft($sItemPath, 3)
			$hItem = _GUICtrlTreeView_AddChild($TreeViewFav, $hParent, $sItemName)
			TreeViewFavSetItemIcon($hItem, $sItemPath)
		EndIf
		$i += 1
	WEnd
	_GUICtrlTreeView_Expand($TreeViewFav, $FavItemHandle[$FavItemRoot - 10000])
	Return
EndFunc
Func TreeViewFavCreate()
	Global $FavItemLast = 10000
	Global $FavItemHandle[2]
	Global $FavItemType[2]
	Global $FavItemPath[2]
	Global $FavItemIcon[2]
	Global $FavItemSize[2]
	Global $FavItemDepth[2]
	Global $FavItemFile[2]
	Global $FavItemExt[2]
	Global $FavItemDrive[2]

	Local $sMenuIconPath = GetIcon("Menu")
	Local $i, $iIconSize
	SplitIconPath($sMenuIconPath, $sMenuIconPath, $i, $iIconSize)
	$sMenuIconPath = DerefPath($sMenuIconPath)

	Global $FavItemRoot = TreeViewFavAddItem(10000, $sLang_Menu)
	$FavItemType[$FavItemRoot - 10000] = "Menu"
	_GUICtrlTreeView_SetIcon($TreeViewFav, $FavItemHandle[$FavItemRoot - 10000], $sFolderMenuExe, 1) ; index 0 - blank Icon as default
	_GUICtrlTreeView_SetIcon($TreeViewFav, $FavItemHandle[$FavItemRoot - 10000], $sFolderMenuExe, -206) ; index 1 - separator
	_GUICtrlTreeView_SetIcon($TreeViewFav, $FavItemHandle[$FavItemRoot - 10000], $sMenuIconPath, $i) ; index 2 - menu icon
	_GUICtrlTreeView_SetIcon($TreeViewFav, $FavItemHandle[$FavItemRoot - 10000], $sFolderMenuExe, 0) ; index 3 - folder menu icon
	TreeViewFavCreateXML($FavItemRoot, "/FolderMenu/Menu")
	_GUICtrlTreeView_Expand($TreeViewFav, $FavItemHandle[$FavItemRoot - 10000])
EndFunc
Func TreeViewFavCreateXML($iParent, $sXPath)
	Local $iItemCount = _XMLGetNodeCount($sXPath & "/Item")
	If $iItemCount < 1 Then Return
	Local $iItem
	Local $sItemType, $sItemName, $sItemPath, $sItemIcon, $sItemSize, $sItemDepth, $sItemFile, $sItemExt, $sItemDrive
	For $i = 1 To $iItemCount
		$sItemType = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Type")
		$sItemName = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Name")
		$iItem = TreeViewFavAddItem($iParent, $sItemName)
		$FavItemType[$iItem - 10000] = $sItemType
		If $sItemType = "Separator" Then
			_GUICtrlTreeView_SetImageIndex($TreeViewFav, $FavItemHandle[$iItem - 10000], 1)
			$FavItemPath[$iItem - 10000] = "Separator"
		ElseIf $sItemType = "ColSeparator" Then
			_GUICtrlTreeView_SetImageIndex($TreeViewFav, $FavItemHandle[$iItem - 10000], 1)
			$FavItemPath[$iItem - 10000] = "ColSeparator"
		ElseIf $sItemType = "Item" Then
			$sItemPath = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Path")
			$sItemIcon = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Icon")
			$sItemSize = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Size")
			$FavItemPath[$iItem - 10000] = $sItemPath
			$FavItemIcon[$iItem - 10000] = $sItemIcon
			$FavItemSize[$iItem - 10000] = $sItemSize
			If StringRight($sItemPath, 1) = "\" Then $sItemPath = StringTrimRight($sItemPath, 1)
			Switch $sItemPath
				Case "_SystemRecent", ":RecentMenu", ":DriveMenu", ":TCMenu"
					TreeViewFavAddItemSetting($iItem)
					If $sItemPath = ":RecentMenu" Then TreeViewFavAddItemSetting($iItem, $sLang_SystemRecent, GetIcon("_SystemRecent"))
			EndSwitch
			TreeViewFavSetItemIcon($iItem, $sItemPath, $sItemIcon)
		ElseIf $sItemType = "ItemMenu" Then
			$sItemPath = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Path")
			$sItemIcon = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Icon")
			$sItemSize = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Size")
			$sItemDepth = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Depth")
			$sItemFile = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "File")
			$sItemExt = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Ext")
			$sItemDrive = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Drive")
			$FavItemPath[$iItem - 10000] = $sItemPath
			$FavItemIcon[$iItem - 10000] = $sItemIcon
			$FavItemSize[$iItem - 10000] = $sItemSize
			$FavItemDepth[$iItem - 10000] = $sItemDepth
			$FavItemFile[$iItem - 10000] = $sItemFile
			$FavItemExt[$iItem - 10000] = $sItemExt
			$FavItemDrive[$iItem - 10000] = $sItemDrive
			TreeViewFavSetItemIcon($iItem, $sItemPath, $sItemIcon)
			TreeViewFavAddItemSetting($iItem)
		ElseIf $sItemType = "Menu" Then
			$sItemIcon = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Icon")
			$sItemSize = _XMLGetAttrib($sXPath & "/Item[" & $i & "]", "Size")
			$FavItemPath[$iItem - 10000] = "Menu"
			$FavItemIcon[$iItem - 10000] = $sItemIcon
			$FavItemSize[$iItem - 10000] = $sItemSize
			If $sItemIcon = "" Then
				_GUICtrlTreeView_SetImageIndex($TreeViewFav, $FavItemHandle[$iItem - 10000], 2)
			Else
				TreeViewFavSetItemIcon($iItem, "Menu", $sItemIcon)
			EndIf
			TreeViewFavCreateXML($iItem, $sXPath & "/Item[" & $i & "]")
		EndIf
	Next
	Return
EndFunc
Func TreeViewFavAddItem($hDest, $sText, $iImage = -1, $iPos = 0) ; $iPos = -1:first child, 0:last child, 1:after
	If Not IsPtr($hDest) Then $hDest = $FavItemHandle[$hDest - 10000]
	Local $hItem
	Switch $iPos
		Case -1 ; add as first child of dest
			$hItem = _GUICtrlTreeView_AddChildFirst($TreeViewFav, $hDest, $sText, $iImage, $iImage, $FavItemLast)
		Case 0 ; add as last child of dest
			$hItem = _GUICtrlTreeView_AddChild($TreeViewFav, $hDest, $sText, $iImage, $iImage, $FavItemLast)
		Case 1 ; add after dest
			Local $hParent = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hDest)
			$hItem = _GUICtrlTreeView_InsertItem($TreeViewFav, $sText, $hParent, $hDest, $iImage, $iImage, $FavItemLast)
		Case Else
			Return 0
	EndSwitch
	If $hItem = 0 Then Return 0
	$FavItemHandle[$FavItemLast - 10000] = $hItem

	$FavItemLast += 1
	Local $iCapacity = UBound($FavItemHandle)
	If $FavItemLast - 10000 >= $iCapacity Then
		ReDim $FavItemHandle[2 * $iCapacity]
		ReDim $FavItemType[2 * $iCapacity]
		ReDim $FavItemPath[2 * $iCapacity]
		ReDim $FavItemIcon[2 * $iCapacity]
		ReDim $FavItemSize[2 * $iCapacity]
		ReDim $FavItemDepth[2 * $iCapacity]
		ReDim $FavItemFile[2 * $iCapacity]
		ReDim $FavItemExt[2 * $iCapacity]
		ReDim $FavItemDrive[2 * $iCapacity]
		; _ArrayDisplay($FavItemHandle)
	EndIf
	Return $FavItemLast - 1
EndFunc
Func TreeViewFavAddPath($sPath)
	Local $iItem = GUICtrlRead($TreeViewFav)
	If $iItem = 0 Then $iItem = $FavItemRoot
	Local $hItem = $FavItemHandle[$iItem - 10000]
	Local $sName = GetName($sPath)
	Local $iNew
	If $FavItemType[$iItem - 10000] = "Menu" Then
		; if _GUICtrlTreeView_GetExpanded($TreeViewFav, $hItem) or $iItem = $FavItemRoot then
		; add into menu
		If $fAddFavAtTop = 1 Then
			$iNew = TreeViewFavAddItem($hItem, $sName, -1, -1)
		Else
			$iNew = TreeViewFavAddItem($hItem, $sName, -1, 0)
		EndIf
		; else
		; add after
		; $iNew = TreeViewFavAddItem($hItem, $sName, -1, 1)
		; endif
	Else
		If $FavItemType[$iItem - 10000] = "ItemSetting" Then $hItem = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hItem)
		; add after
		$iNew = TreeViewFavAddItem($hItem, $sName, -1, 1)
	EndIf
	_GUICtrlTreeView_SelectItem($TreeViewFav, $FavItemHandle[$iNew - 10000])
	$FavItemType[$iNew - 10000] = "Item"
	$FavItemPath[$iNew - 10000] = $sPath
	TreeViewFavSetItemIcon($iNew, $sPath)
	TreeView_ItemChanged()
EndFunc
Func TreeViewFavAddItemSetting($iParent, $sName = $sLang_Setting, $sIcon = "")
	If $sIcon = "" Then $sIcon = GetIcon("_Options")
	Local $iItem = TreeViewFavAddItem($iParent, $sName)
	TreeViewFavSetItemIcon($iItem, "", $sIcon)
	$FavItemType[$iItem - 10000] = "ItemSetting"
	Return $iItem
EndFunc
Func TreeViewFavCopyItem($hItem, $hDest, $iPos) ; $iPos = -1:before, 0:into, 1:after
	If $hItem = 0 Or $hDest = 0 Then Return 0
	Local $iItem = TreeViewFavGetItemID($hItem)
	If $iItem = 0 Or $iItem = $FavItemRoot Then Return 0

	;make sure parent can't be dropped onto one of its descendants
	Local $hTest = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hDest)
	While $hTest <> 0
		If $hTest = $hItem Then Return 0
		$hTest = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hTest)
	WEnd

	; drop into its parent, don't do anything
	If $hDest = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hItem) And $iPos = 0 Then Return 0

	Local $fExpend = _GUICtrlTreeView_GetExpanded($TreeViewFav, $hItem)
	Local $sName = _GUICtrlTreeView_GetText($TreeViewFav, $hItem)
	Local $iImage = _GUICtrlTreeView_GetImageIndex($TreeViewFav, $hItem)
	Local $hParent = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hDest)
	Local $hPrev, $hNew

	Switch $iPos
		Case -1 ; copy before dest
			$hPrev = _GUICtrlTreeView_GetPrevSibling($TreeViewFav, $hDest)
			If $hPrev = 0 Then
				$hNew = _GUICtrlTreeView_AddChildFirst($TreeViewFav, $hParent, $sName, $iImage, $iImage, $iItem)
			Else
				$hNew = _GUICtrlTreeView_InsertItem($TreeViewFav, $sName, $hParent, $hPrev, $iImage, $iImage, $iItem)
			EndIf
		Case 0 ; copy into dest
			$hNew = _GUICtrlTreeView_AddChild($TreeViewFav, $hDest, $sName, $iImage, $iImage, $iItem)
		Case 1 ; copy after dest
			$hNew = _GUICtrlTreeView_InsertItem($TreeViewFav, $sName, $hParent, $hDest, $iImage, $iImage, $iItem)
		Case Else
			Return 0
	EndSwitch
	$FavItemHandle[$iItem - 10000] = $hNew

	Local $hChild = _GUICtrlTreeView_GetFirstChild($TreeViewFav, $hItem)
	While $hChild <> 0
		TreeViewFavCopyItem($hChild, $hNew, 0)
		$hChild = _GUICtrlTreeView_GetNextSibling($TreeViewFav, $hChild)
	WEnd

	_GUICtrlTreeView_Expand($TreeViewFav, $hNew, $fExpend)
	Return $hNew
EndFunc
Func TreeViewFavSetItemIcon($hItem, $sItemPath, $sItemIcon = "")
	If Not IsPtr($hItem) Then $hItem = $FavItemHandle[$hItem - 10000]
	If $sItemIcon = "" Then $sItemIcon = GetIcon($sItemPath)
	Local $sIconPath, $iIconIndex, $iIconSize
	SplitIconPath($sItemIcon, $sIconPath, $iIconIndex, $iIconSize)
	If $sIconPath = "%1" Or $sIconPath = """%1""" Then
		$sIconPath = StringReplace($sItemPath, """", "")
		$sIconPath = StringStripWS($sIconPath, 3)
	EndIf
	_GUICtrlTreeView_SetIcon($TreeViewFav, $hItem, DerefPath($sIconPath), $iIconIndex)
EndFunc
Func TreeViewFavGetItemID($hItem)
	If $hItem = 0 Then Return 0
	For $i = $FavItemRoot To $FavItemLast - 1
		If $FavItemHandle[$i - 10000] = $hItem Then Return $i
	Next
	Return 0
EndFunc
Func MenuFavPathCreate()
	Local $Dummy = GUICtrlCreateDummy()
	Global $MenuFavPath = GUICtrlCreateContextMenu($Dummy)
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($MenuFavPath), $MNS_CHECKORBMP)
	MenuFavPathAddItem($sLang_BrowseFolder, $MenuFavPath, GetIcon("Folder"), "MenuFavPathBrowseFolder")
	MenuFavPathAddItem($sLang_BrowseFile, $MenuFavPath, GetIcon("Unknown"), "MenuFavPathBrowseFile")
	Local $MenuSpecial = GUICtrlCreateMenu($sLang_SpecialItems, $MenuFavPath)
	SetMenuItemIcon($MenuFavPath, $MenuSpecial, "", GetIcon("Menu"))
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($MenuSpecial), $MNS_CHECKORBMP)
	MenuFavPathAddItem($sLang_Separator, $MenuSpecial, GetIcon("Separator"), "MenuFavPathSpecial", "Separator")
	MenuFavPathAddItem($sLang_ColSeparator, $MenuSpecial, GetIcon("Separator"), "MenuFavPathSpecial", "ColSeparator")
	GUICtrlCreateMenuItem("", $MenuSpecial)
	; MenuFavPathAddItem($sLang_Computer        , $MenuSpecial, GetIcon("Computer")         , "MenuFavPathSpecial", "Computer"      )
	; GUICtrlCreateMenuItem("", $MenuSpecial)
	MenuFavPathAddItem($sLang_Website, $MenuSpecial, GetIcon("_GoWebsite"), "MenuFavPathSpecial", "_GoWebsite")
	MenuFavPathAddItem($sLang_CheckVer, $MenuSpecial, GetIcon("_CheckUpdate"), "MenuFavPathSpecial", "_CheckUpdate")
	MenuFavPathAddItem($sLang_AddFavorite, $MenuSpecial, GetIcon("_AddFavorite"), "MenuFavPathSpecial", "_AddFavorite")
	MenuFavPathAddItem($sLang_AddHere, $MenuSpecial, GetIcon("_AddHere"), "MenuFavPathSpecial", "_AddHere")
	MenuFavPathAddItem($sLang_Reload, $MenuSpecial, GetIcon("_Reload"), "MenuFavPathSpecial", "_Reload")
	MenuFavPathAddItem($sLang_Options, $MenuSpecial, GetIcon("_Options"), "MenuFavPathSpecial", "_Options")
	MenuFavPathAddItem($sLang_EditConfig, $MenuSpecial, GetIcon("_Edit"), "MenuFavPathSpecial", "_Edit")
	MenuFavPathAddItem($sLang_Exit, $MenuSpecial, GetIcon("_Exit"), "MenuFavPathSpecial", "_Exit")
	MenuFavPathAddItem($sLang_ToggleHidden, $MenuSpecial, GetIcon("_ToggleHidden"), "MenuFavPathSpecial", "_ToggleHidden")
	MenuFavPathAddItem($sLang_ToggleFileExt, $MenuSpecial, GetIcon("_ToggleFileExt"), "MenuFavPathSpecial", "_ToggleFileExt")
	MenuFavPathAddItem($sLang_SystemRecent, $MenuSpecial, GetIcon("_SystemRecent"), "MenuFavPathSpecial", "_SystemRecent")
	GUICtrlCreateMenuItem("", $MenuSpecial)
	MenuFavPathAddItem($sLang_RecentMenu, $MenuSpecial, GetIcon(":RecentMenu"), "MenuFavPathSpecial", ":RecentMenu")
	MenuFavPathAddItem($sLang_ExplorerMenu, $MenuSpecial, GetIcon(":ExplorerMenu"), "MenuFavPathSpecial", ":ExplorerMenu")
	MenuFavPathAddItem($sLang_DriveMenu, $MenuSpecial, GetIcon(":DriveMenu"), "MenuFavPathSpecial", ":DriveMenu")
	MenuFavPathAddItem($sLang_ToolMenu, $MenuSpecial, GetIcon(":ToolMenu"), "MenuFavPathSpecial", ":ToolMenu")
	MenuFavPathAddItem($sLang_SVSMenu, $MenuSpecial, GetIcon(":SVSMenu"), "MenuFavPathSpecial", ":SVSMenu")
	MenuFavPathAddItem($sLang_TCMenu, $MenuSpecial, GetIcon(":TCMenu"), "MenuFavPathSpecial", ":TCMenu")
EndFunc
Func MenuFavPathAddItem($sName, $iParent, $sIcon, $sFunc, $sPath = "")
	Local $iItem = GUICtrlCreateMenuItem($sName, $iParent)
	GUICtrlSetOnEvent($iItem, $sFunc)
	SetMenuItemIcon($iParent, $iItem, "", $sIcon)
	If $sPath <> "" Then
		Assign("SpecialName" & $iItem, $sName, 2)
		Assign("SpecialPath" & $iItem, $sPath, 2)
	EndIf
	Return $iItem
EndFunc
Func MenuFavPathBrowseFolder()
	Local $iItem = GUICtrlRead($TreeViewFav)
	#cs
		Local $sPath = $FavItemPath[$iItem - 10000]
		Local $sStartPath = DerefPath($sPath)
		if not IsFolder($sStartPath) then
		Local $sDrive, $sDir, $sFName, $sExt
		_PathSplit($sStartPath, $sDrive, $sDir, $sFName, $sExt)
		$sStartPath = $sDrive & $sDir
		endif
		$sPath = FileSelectFolder($sLang_SelectFolder, "", 2, $sStartPath)
		if $sPath = "" then return
	#ce
	Local $oShell = ObjCreate("Shell.Application")
	Local $oFolder = $oShell.BrowseForFolder(0, $sLang_SelectFolder, 0)
	If IsObj($oFolder) Then
		Local $sName = $oFolder.Self.Name
		Local $sPath = $oFolder.Self.Path
		If $sPath = "" Then Return
	Else
		Return
	EndIf
	CheckboxFavMenuClick()
	_GUICtrlTreeView_SetText($TreeViewFav, $FavItemHandle[$iItem - 10000], $sName)
	$FavItemPath[$iItem - 10000] = $sPath
	TreeViewFavSetItemIcon($iItem, $sPath)
	TreeView_ItemChanged()
EndFunc
Func MenuFavPathBrowseFile()
	Local $iItem = GUICtrlRead($TreeViewFav)
	GUICtrlSetState($CheckboxFavMenu, $GUI_UNCHECKED)
	Local $sPath = $FavItemPath[$iItem - 10000]
	Local $sStartPath = DerefPath($sPath)
	If Not IsFolder($sStartPath) Then
		Local $sDrive, $sDir, $sFName, $sExt
		_PathSplit($sStartPath, $sDrive, $sDir, $sFName, $sExt)
		$sStartPath = $sDrive & $sDir
	EndIf
	$sPath = FileOpenDialog($sLang_SelectFile, $sStartPath, "(*.*)", 1)
	If $sPath = "" Then Return
	CheckboxFavMenuClick()
	_GUICtrlTreeView_SetText($TreeViewFav, $FavItemHandle[$iItem - 10000], GetName($sPath))
	$FavItemPath[$iItem - 10000] = $sPath
	TreeViewFavSetItemIcon($iItem, $sPath)
	TreeView_ItemChanged()
EndFunc
Func MenuFavPathSpecial()
	Local $iItem = GUICtrlRead($TreeViewFav)
	GUICtrlSetState($CheckboxFavMenu, $GUI_UNCHECKED)
	CheckboxFavMenuClick()
	Local $sName = Eval("SpecialName" & @GUI_CtrlId)
	Local $sPath = Eval("SpecialPath" & @GUI_CtrlId)
	Local $hItem = $FavItemHandle[$iItem - 10000]
	Switch $sPath
		Case "Separator"
			_GUICtrlTreeView_SetText($TreeViewFav, $hItem, "- - - - -")
			$FavItemType[$iItem - 10000] = "Separator"
			$FavItemPath[$iItem - 10000] = "Separator"
			_GUICtrlTreeView_SetImageIndex($TreeViewFav, $hItem, 1)
		Case "ColSeparator"
			_GUICtrlTreeView_SetText($TreeViewFav, $hItem, "|")
			$FavItemType[$iItem - 10000] = "ColSeparator"
			$FavItemPath[$iItem - 10000] = "ColSeparator"
			_GUICtrlTreeView_SetImageIndex($TreeViewFav, $hItem, 1)
		Case "_SystemRecent", ":RecentMenu", ":DriveMenu", ":TCMenu"
			_GUICtrlTreeView_SetText($TreeViewFav, $hItem, $sName)
			$FavItemType[$iItem - 10000] = "Item"
			$FavItemPath[$iItem - 10000] = $sPath
			TreeViewFavSetItemIcon($iItem, $sPath)
			TreeViewFavAddItemSetting($iItem)
			If $sPath = ":RecentMenu" Then TreeViewFavAddItemSetting($iItem, $sLang_SystemRecent, GetIcon("_SystemRecent"))
			_GUICtrlTreeView_Expand($TreeViewFav, $hItem)
		Case Else
			_GUICtrlTreeView_SetText($TreeViewFav, $hItem, $sName)
			$FavItemType[$iItem - 10000] = "Item"
			$FavItemPath[$iItem - 10000] = $sPath
			TreeViewFavSetItemIcon($iItem, $sPath)
	EndSwitch
	TreeView_ItemChanged()
EndFunc

Func ButtonFavTCPathExeClick()
	Local $sPath = GUICtrlRead($InputFavTCPathExe)
	Local $sStartPath = DerefPath($sPath)
	If Not IsFolder($sStartPath) Then
		Local $sDrive, $sDir, $sFName, $sExt
		_PathSplit($sStartPath, $sDrive, $sDir, $sFName, $sExt)
		$sStartPath = $sDrive & $sDir
	EndIf
	$sPath = FileOpenDialog($sLang_SelectFile, $sStartPath, "(*.exe)", 1)
	If $sPath = "" Then Return
	GUICtrlSetData($InputFavTCPathExe, $sPath)
EndFunc
Func ButtonFavTCPathIniClick()
	Local $sPath = GUICtrlRead($InputFavTCPathIni)
	Local $sStartPath = DerefPath($sPath)
	If Not IsFolder($sStartPath) Then
		Local $sDrive, $sDir, $sFName, $sExt
		_PathSplit($sStartPath, $sDrive, $sDir, $sFName, $sExt)
		$sStartPath = $sDrive & $sDir
	EndIf
	$sPath = FileOpenDialog($sLang_SelectFile, $sStartPath, "(*.ini)", 1)
	If $sPath = "" Then Return
	GUICtrlSetData($InputFavTCPathIni, $sPath)
EndFunc
Func ButtonFavPathClick()
	ShowButtonMenu($hGuiOptions, $ButtonFavPath, $MenuFavPath)
EndFunc
Func ButtonFavIconClick()
	Local $iItem = GUICtrlRead($TreeViewFav)
	Local $sIconPath, $iIconIndex
	StringSplit2($FavItemIcon[$iItem - 10000], ",", $sIconPath, $iIconIndex)
	Local $asIcon = _WinAPI_PickIconDlg(DerefPath($sIconPath), $iIconIndex)
	If @error Then Return
	$FavItemIcon[$iItem - 10000] = $asIcon[0] & "," & $asIcon[1]
	TreeViewFavSetItemIcon($iItem, "", $asIcon[0] & "," & $asIcon[1])
	TreeView_ItemChanged()
EndFunc
Func ButtonFavAddClick()
	Local $iItem = GUICtrlRead($TreeViewFav)
	If $iItem = 0 Then $iItem = $FavItemRoot
	Local $hItem = $FavItemHandle[$iItem - 10000]
	Local $iNew
	If $FavItemType[$iItem - 10000] = "Menu" Then
		; if _GUICtrlTreeView_GetExpanded($TreeViewFav, $hItem) or $iItem = $FavItemRoot then
		; add into menu
		If $fAddFavAtTop = 1 Then
			$iNew = TreeViewFavAddItem($hItem, $sLang_NewItem, -1, -1)
		Else
			$iNew = TreeViewFavAddItem($hItem, $sLang_NewItem, -1, 0)
		EndIf
		; else
		; add after
		; $iNew = TreeViewFavAddItem($hItem, $sLang_NewItem, -1, 1)
		; endif
	Else
		If $FavItemType[$iItem - 10000] = "ItemSetting" Then $hItem = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hItem)
		; add after
		$iNew = TreeViewFavAddItem($hItem, $sLang_NewItem, -1, 1)
	EndIf
	_GUICtrlTreeView_SelectItem($TreeViewFav, $FavItemHandle[$iNew - 10000])

	If _IsPressedI($VK_SHIFT) Then
		_GUICtrlTreeView_SetText($TreeViewFav, $FavItemHandle[$iNew - 10000], $sLang_NewMenu)
		$FavItemType[$iNew - 10000] = "Menu"
		$FavItemPath[$iNew - 10000] = "Menu"
		TreeViewFavSetItemIcon($iNew, "Menu")
	Else
		$FavItemType[$iNew - 10000] = "Item"
		; show select path menu if not by insert key
		If Not _IsPressedI($VK_INSERT) Then ShowButtonMenu($hGuiOptions, $ButtonFavAdd, $MenuFavPath)
	EndIf
	TreeView_ItemChanged()
EndFunc
Func ButtonFavDelClick()
	Local $iItem = GUICtrlRead($TreeViewFav)
	If $iItem = 0 Or $iItem = $FavItemRoot Then Return
	Switch $FavItemType[$iItem - 10000]
		Case "Menu"
			If Not _IsPressedI($VK_SHIFT) Then Return
		Case "ItemSetting"
			Return
	EndSwitch
	Local $hItem = $FavItemHandle[$iItem - 10000]
	$FavItemHandle[$iItem - 10000] = ""
	$FavItemType[$iItem - 10000] = ""
	$FavItemPath[$iItem - 10000] = ""
	$FavItemIcon[$iItem - 10000] = ""
	$FavItemSize[$iItem - 10000] = ""
	$FavItemDepth[$iItem - 10000] = ""
	$FavItemFile[$iItem - 10000] = ""
	$FavItemExt[$iItem - 10000] = ""
	$FavItemDrive[$iItem - 10000] = ""
	_GUICtrlTreeView_Delete($TreeViewFav, $hItem)
	TreeView_ItemChanged()
EndFunc
Func ButtonFavRelClick()
	Local $sPath = GUICtrlRead($InputFavPath)
	If StringLeft($sPath, 1) = "%" Or StringLeft($sPath, 1) = "." Then
		$sPath = DerefPath($sPath)
	Else
		If _IsPressedI($VK_SHIFT) Then ; get environment variables
			$sPath = _WinAPI_PathUnExpandEnvStrings($sPath)
		Else ; get relative path
			$sPath = _PathGetRelative(@ScriptDir, $sPath)
			If @error = 2 Then ; failed, different drive
				; $sPath = $sPath
			ElseIf @error = 1 Then ; the path is script dir
				$sPath = ".\"
			ElseIf StringLeft($sPath, 2) <> ".." Then ; the path is in the script dir, add ".\" in front of the path
				$sPath = ".\" & $sPath
			EndIf
		EndIf
	EndIf
	If $sPath <> "" Then GUICtrlSetData($InputFavPath, $sPath)
	Return
EndFunc
Func ButtonFavSortClick()
	Local $hItem = _GUICtrlTreeView_GetSelection($TreeViewFav)
	_GUICtrlTreeView_BeginUpdate($TreeViewFav)
	If _IsPressedI($VK_SHIFT) Then
		_GUICtrlTreeView_SortSubtree($TreeViewFav, $hItem, 1)
	Else
		_GUICtrlTreeView_SortSubtree($TreeViewFav, $hItem, 0)
	EndIf
	_GUICtrlTreeView_EnsureVisible($TreeViewFav, $hItem)
	_GUICtrlTreeView_EndUpdate($TreeViewFav)
EndFunc
Func _GUICtrlTreeView_SortSubtree($hWnd, $hItem, $fRecursive = 0)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If Not IsPtr($hItem) Then $hItem = GUICtrlGetHandle($hItem)
	DllCall('user32.dll', 'int', 'SendMessage', 'hwnd', $hWnd, 'uint', $TVM_SORTCHILDREN, 'wparam', True, 'lparam', $hItem)
	_GUICtrlTreeView_Expand($hWnd, $hItem)
	If $fRecursive = 1 Then
		Local $hChild = _GUICtrlTreeView_GetFirstChild($hWnd, $hItem), $iChild
		While $hChild <> 0
			$iChild = TreeViewFavGetItemID($hChild)
			If $iChild <> 0 And $FavItemType[$iChild - 10000] = "Menu" Then _GUICtrlTreeView_SortSubtree($hWnd, $hChild, 1)
			$hChild = _GUICtrlTreeView_GetNextSibling($hWnd, $hChild)
		WEnd
	EndIf
EndFunc
Func CheckboxFavMenuClick()
	Local $iState = GUICtrlRead($CheckboxFavMenu)
	Local $iItem = GUICtrlRead($TreeViewFav)
	If $iState = $GUI_CHECKED Then
		$FavItemType[$iItem - 10000] = "ItemMenu"
		$iItem = TreeViewFavAddItemSetting($iItem)
		_GUICtrlTreeView_SelectItem($TreeViewFav, $FavItemHandle[$iItem - 10000])
		GUICtrlSetData($InputFavExt, "*")
	Else ;if $iState = $GUI_UNCHECKED then
		$FavItemType[$iItem - 10000] = "Item"
		Local $hChild = _GUICtrlTreeView_GetFirstChild($TreeViewFav, $FavItemHandle[$iItem - 10000])
		While $hChild <> 0
			_GUICtrlTreeView_Delete($TreeViewFav, $hChild)
			$hChild = _GUICtrlTreeView_GetFirstChild($TreeViewFav, $FavItemHandle[$iItem - 10000])
		WEnd
	EndIf
EndFunc
Func CheckboxFavShowFileClick()
	Local $iState = GUICtrlRead($CheckboxFavShowFile)
	Local $iItem = GUICtrlRead($TreeViewFav)
	; selected item is an itemsetting, so get its parent which is the real item.
	$iItem = TreeViewFavGetItemID(_GUICtrlTreeView_GetParentHandle($TreeViewFav, $FavItemHandle[$iItem - 10000]))
	If $iItem = 0 Then Return
	If $iState = $GUI_CHECKED Then
		$FavItemFile[$iItem - 10000] = 1
		GUICtrlSetState($InputFavExt, $GUI_ENABLE)
	ElseIf $iState = $GUI_UNCHECKED Then
		$FavItemFile[$iItem - 10000] = 0
		GUICtrlSetState($InputFavExt, $GUI_DISABLE)
	EndIf
EndFunc
Func ComboFavDriveChange()
	Local $iItem = GUICtrlRead($TreeViewFav)
	$iItem = TreeViewFavGetItemID(_GUICtrlTreeView_GetParentHandle($TreeViewFav, $FavItemHandle[$iItem - 10000]))
	If $iItem = 0 Then Return
	Local $sText = GUICtrlRead($ComboFavDrive)
	Switch $sText
		Case $sLang_All
			$sText = "All"
		Case $sLang_Fixed
			$sText = "Fixed"
		Case $sLang_CDROM
			$sText = "CDROM"
		Case $sLang_Removable
			$sText = "Removable"
		Case $sLang_Network
			$sText = "Network"
		Case $sLang_RAMDisk
			$sText = "RAMDisk"
	EndSwitch
	$FavItemDrive[$iItem - 10000] = $sText
EndFunc
Func ComboFavSizeChange()
	Local $iItem = GUICtrlRead($TreeViewFav)
	Local $sText = Int(GUICtrlRead($ComboFavSize))
	If $sText = 0 Then $sText = ""
	$FavItemSize[$iItem - 10000] = $sText
EndFunc
Func InputFavChange($iInput)
	Local $iItem = GUICtrlRead($TreeViewFav)
	Local $sType = $FavItemType[$iItem - 10000]
	If $sType = "ItemSetting" Then $iItem = TreeViewFavGetItemID(_GUICtrlTreeView_GetParentHandle($TreeViewFav, $FavItemHandle[$iItem - 10000]))
	If $iItem = 0 Then Return
	Local $sText = GUICtrlRead($iInput)
	Switch $iInput
		Case $InputFavName
			_GUICtrlTreeView_SetText($TreeViewFav, $FavItemHandle[$iItem - 10000], $sText)
		Case $InputFavPath
			$FavItemPath[$iItem - 10000] = $sText
		Case $InputFavIcon
			$FavItemIcon[$iItem - 10000] = $sText
		Case $InputFavDepth
			$FavItemDepth[$iItem - 10000] = $sText
		Case $InputFavExt
			$FavItemExt[$iItem - 10000] = $sText
	EndSwitch
EndFunc
Func TreeView_KeyDown($lParam)
	If GUICtrlRead($Tab1, 1) <> $TabSheetFav Then Return ; prevent delete item when the tree is not visible
	Local $tNMTVKEYDOWN = DllStructCreate($tagNMTVKEYDOWN, $lParam)
	Local $iVKey = BitAND(DllStructGetData($tNMTVKEYDOWN, "VKey"), 0xFF)
	Switch $iVKey
		Case $VK_INSERT
			ButtonFavAddClick()
		Case $VK_DELETE
			ButtonFavDelClick()
	EndSwitch
EndFunc
Func TreeView_ItemChanged()
	If $fTreeViewFavUpdate Then Return
	If $fTCAsMain = 1 Then Return
	Local $iItem = GUICtrlRead($TreeViewFav)
	If $iItem = 0 Then Return
	Local $sType = $FavItemType[$iItem - 10000]
	Local $sName, $sPath, $sIcon, $iSize, $iDepth, $fFile, $sExt, $sDrive
	If $sType = "ItemSetting" Then
		TabFavShowSubmenu($GUI_HIDE)
		TabFavShowSRecent($GUI_HIDE)
		TabFavShowRecent($GUI_HIDE)
		TabFavShowDrive($GUI_HIDE)
		TabFavShowTC($GUI_HIDE)
		TabFavShowMain($GUI_HIDE + $GUI_DISABLE)
		$sName = _GUICtrlTreeView_GetText($TreeViewFav, $FavItemHandle[$iItem - 10000])
		If $sName = $sLang_SystemRecent Then
			$sPath = "_SystemRecent"
		Else
			$iItem = TreeViewFavGetItemID(_GUICtrlTreeView_GetParentHandle($TreeViewFav, $FavItemHandle[$iItem - 10000]))
			If $iItem = 0 Then Return
			$sName = _GUICtrlTreeView_GetText($TreeViewFav, $FavItemHandle[$iItem - 10000])
			$sPath = $FavItemPath[$iItem - 10000]
		EndIf
		Switch $sPath
			Case "_SystemRecent"
				TabFavShowSRecent($GUI_SHOW)
			Case ":RecentMenu"
				TabFavShowRecent($GUI_SHOW)
			Case ":DriveMenu"
				TabFavShowDrive($GUI_SHOW)
			Case ":TCMenu"
				TabFavShowTC($GUI_SHOW)
			Case Else
				If $FavItemType[$iItem - 10000] = "ItemMenu" Then
					$iDepth = $FavItemDepth[$iItem - 10000]
					$fFile = $FavItemFile[$iItem - 10000]
					$sExt = $FavItemExt[$iItem - 10000]
					$sDrive = Eval("sLang_" & $FavItemDrive[$iItem - 10000])
					If $sDrive = "" Then $sDrive = $sLang_Fixed
					GUICtrlSetData($InputFavDepth, $iDepth)
					GUICtrlSetData($InputFavExt, $sExt)
					GUICtrlSetData($ComboFavDrive, $sDrive)
					If $fFile = 1 Then
						GUICtrlSetState($CheckboxFavShowFile, $GUI_CHECKED)
						GUICtrlSetState($InputFavExt, $GUI_ENABLE)
					Else
						GUICtrlSetState($CheckboxFavShowFile, $GUI_UNCHECKED)
						GUICtrlSetState($InputFavExt, $GUI_DISABLE)
					EndIf
				EndIf
				TabFavShowSubmenu($GUI_SHOW)
		EndSwitch
	Else
		$sName = _GUICtrlTreeView_GetText($TreeViewFav, $FavItemHandle[$iItem - 10000])
		$sPath = $FavItemPath[$iItem - 10000]
		$sIcon = $FavItemIcon[$iItem - 10000]
		$iSize = $FavItemSize[$iItem - 10000]
		GUICtrlSetData($InputFavName, $sName)
		GUICtrlSetData($InputFavPath, $sPath)
		GUICtrlSetData($InputFavIcon, $sIcon)
		_GUICtrlComboBox_SetEditText($ComboFavSize, $iSize)
		If _GUICtrlComboBox_SelectString($ComboFavSize, $iSize) = -1 Then
			If $iSize <> "" Then _GUICtrlComboBox_SetCurSel($ComboFavSize, _GUICtrlComboBox_AddString($ComboFavSize, $iSize))
		EndIf
		If BitAND(GUICtrlGetState($LabelFavName), $GUI_HIDE) Then
			TabFavShowSubmenu($GUI_HIDE)
			TabFavShowSRecent($GUI_HIDE)
			TabFavShowRecent($GUI_HIDE)
			TabFavShowDrive($GUI_HIDE)
			TabFavShowTC($GUI_HIDE)
			TabFavShowMain($GUI_SHOW + $GUI_ENABLE)
		EndIf
		If $sType = "ItemMenu" Then
			GUICtrlSetState($CheckboxFavMenu, $GUI_CHECKED)
		Else
			GUICtrlSetState($CheckboxFavMenu, $GUI_UNCHECKED)
		EndIf
		If Not IsFolder($sPath) Then
			GUICtrlSetState($CheckboxFavMenu, $GUI_DISABLE)
		Else
			GUICtrlSetState($CheckboxFavMenu, $GUI_ENABLE)
		EndIf
		If StringLeft($sPath, 1) = "_" Or StringLeft($sPath, 1) = ":" Then
			GUICtrlSetColor($InputFavPath, 0x0000FF)
		Else
			GUICtrlSetColor($InputFavPath, 0x000000)
		EndIf
		If $iItem = $FavItemRoot Then; root
			GUICtrlSetState($InputFavName, $GUI_DISABLE)
			GUICtrlSetState($InputFavPath, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavPath, $GUI_DISABLE)
			GUICtrlSetState($InputFavIcon, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavIcon, $GUI_DISABLE)
			GUICtrlSetState($ComboFavSize, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavRel, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavSort, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavAdd, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavDel, $GUI_DISABLE)
		ElseIf $sType = "Separator" Or $sType = "ColSeparator" Then
			GUICtrlSetState($InputFavName, $GUI_ENABLE)
			GUICtrlSetState($InputFavPath, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavPath, $GUI_ENABLE)
			GUICtrlSetState($InputFavIcon, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavIcon, $GUI_DISABLE)
			GUICtrlSetState($ComboFavSize, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavRel, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavSort, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavAdd, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavDel, $GUI_ENABLE)
		ElseIf $sType = "Menu" Then
			GUICtrlSetState($InputFavName, $GUI_ENABLE)
			GUICtrlSetState($InputFavPath, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavPath, $GUI_DISABLE)
			GUICtrlSetState($InputFavIcon, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavIcon, $GUI_ENABLE)
			GUICtrlSetState($ComboFavSize, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavRel, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavSort, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavAdd, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavDel, $GUI_ENABLE)
		Else
			GUICtrlSetState($InputFavName, $GUI_ENABLE)
			GUICtrlSetState($InputFavPath, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavPath, $GUI_ENABLE)
			GUICtrlSetState($InputFavIcon, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavIcon, $GUI_ENABLE)
			GUICtrlSetState($ComboFavSize, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavRel, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavSort, $GUI_DISABLE)
			GUICtrlSetState($ButtonFavAdd, $GUI_ENABLE)
			GUICtrlSetState($ButtonFavDel, $GUI_ENABLE)
		EndIf
	EndIf
	; tooltip("Type :   " & $sType  & @LF & _
	; "Name    :   " & $sName  & @LF & _
	; "Path    :   " & $sPath  & @LF & _
	; "Icon    :   " & $sIcon  & @LF & _
	; "Size    :   " & $iSize  & @LF & _
	; "Depth   :   " & $iDepth & @LF & _
	; "File    :   " & $fFile  & @LF & _
	; "Exten   :   " & $sExt   & @LF & _
	; "Drive   :   " & $sDrive & @LF & _
	; "Read    :   " & GUICtrlRead($TreeViewFav), 811, 203)
EndFunc
#endregion Favorite

#region Application
Func TabAppCreate()
	Global $TabSheetApp = GUICtrlCreateTabItem($sLang_App)
	Local $LabelApp = GUICtrlCreateLabel($sLang_SupportApplications, 36, 48, -1, 17)
	GUICtrlSetResizing($LabelApp, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelApp, "LabelAppClick")
	Global $ListViewApp = GUICtrlCreateListView($sLang_Name & "|" & $sLang_Type & "|" & $sLang_Class & "|" & "ClassNN", 36, 72, 492, 310, -1, BitOR($WS_EX_CLIENTEDGE, $LVS_EX_CHECKBOXES, $LVS_EX_FULLROWSELECT))
	GUICtrlSetResizing($ListViewApp, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
	GUICtrlSetOnEvent($ListViewApp, "ListViewAppClick")
	Local $LabelAppName = GUICtrlCreateLabel($sLang_Name, 36, 396, -1, 17)
	GUICtrlSetResizing($LabelAppName, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelAppName, "LabelAppNameClick")
	Global $InputAppName = GUICtrlCreateInput("", 84, 392, 232, 21)
	GUICtrlSetResizing($InputAppName, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputAppName, "InputAppNameChange")
	Local $LabelAppClass = GUICtrlCreateLabel($sLang_Class, 36, 420, -1, 17)
	GUICtrlSetResizing($LabelAppClass, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelAppClass, "LabelAppClassClick")
	Global $InputAppClass = GUICtrlCreateInput("", 84, 416, 176, 21)
	GUICtrlSetResizing($InputAppClass, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputAppClass, "InputAppClassChange")
	Global $ComboAppType = GUICtrlCreateCombo("", 268, 416, 96, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData($ComboAppType, $sLang_Match & "|" & $sLang_Contain, $sLang_Match)
	GUICtrlSetResizing($ComboAppType, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ComboAppType, "ComboAppTypeChange")
	Global $ButtonAppAdd = GUICtrlCreateButton($sLang_Add, 320, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonAppAdd, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonAppAdd, "ButtonAppAddClick")
	Global $ButtonAppDel = GUICtrlCreateButton($sLang_Del, 344, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonAppDel, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonAppDel, "ButtonAppDelClick")
	GUICtrlSetTip($InputAppClass, $sLang_TipAppClass)
	GUICtrlSetTip($ComboAppType, $sLang_TipAppType)
	GUICtrlSetTip($ButtonAppAdd, $sLang_TipAppAdd)
EndFunc
Func TabAppSet()
	Global $fAppDontChange = 0
	_GUICtrlListView_RegisterSortCallBack($ListViewApp)
	ListViewAppCreate()
	MenuAppAddCreate()
EndFunc
Func TabAppGet()
	$iAppsCount = _GUICtrlListView_GetItemCount($ListViewApp)
	If $iAppsCount < 1 Then Return
	ReDim $asAppName[$iAppsCount]
	ReDim $asAppType[$iAppsCount]
	ReDim $asAppClass[$iAppsCount]
	ReDim $asAppClassNN[$iAppsCount]
	ReDim $afAppCheck[$iAppsCount]
	For $i = 0 To $iAppsCount - 1
		Local $a = _GUICtrlListView_GetItemTextArray($ListViewApp, $i)
		If $a[2] = $sLang_Contain Then
			$asAppType[$i] = "C"
		Else
			$asAppType[$i] = "M"
		EndIf
		$afAppCheck[$i] = _GUICtrlListView_GetItemChecked($ListViewApp, $i)
		$asAppName[$i] = $a[1]
		$asAppClass[$i] = $a[3]
		$asAppClassNN[$i] = $a[4]
	Next
EndFunc
Func ListViewAppCreate()
	Local $ListViewApp_Item
	If $iAppsCount > 0 Then
		For $i = 0 To $iAppsCount - 1
			If $asAppType[$i] = "C" Then
				$ListViewApp_Item = GUICtrlCreateListViewItem($asAppName[$i] & "|" & $sLang_Contain & "|" & $asAppClass[$i] & "|" & $asAppClassNN[$i], $ListViewApp)
			Else
				$ListViewApp_Item = GUICtrlCreateListViewItem($asAppName[$i] & "|" & $sLang_Match & "|" & $asAppClass[$i] & "|" & $asAppClassNN[$i], $ListViewApp)
			EndIf
			If $afAppCheck[$i] = 1 Then GUICtrlSetState($ListViewApp_Item, $GUI_CHECKED)
		Next
	EndIf
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func MenuAppAddCreate()
	Local $Dummy = GUICtrlCreateDummy()
	Global $MenuAppAdd = GUICtrlCreateContextMenu($Dummy)
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($MenuAppAdd), $MNS_CHECKORBMP)
	MenuAppAddAddItem($sLang_Explorer, $sLang_Match, "CabinetWClass,ExploreWClass", "Edit1")
	MenuAppAddAddItem($sLang_Dialog, $sLang_Match, "#32770", "Edit1")
	MenuAppAddAddItem($sLang_DialogO, $sLang_Contain, "bosa_sdm_", "RichEdit20W2")
	MenuAppAddAddItem($sLang_Command, $sLang_Match, "ConsoleWindowClass", "Edit1")
	MenuAppAddAddItem($sLang_Desktop, $sLang_Match, "Progman,WorkerW", "Edit1")
	MenuAppAddAddItem($sLang_Taskbar, $sLang_Match, "Shell_TrayWnd", "Edit1")
	MenuAppAddAddItem("TotalCommander", $sLang_Match, "TTOTAL_CMD", "Edit1")
	MenuAppAddAddItem("UnrealCommander", $sLang_Match, "TxUNCOM", "Edit1")
	MenuAppAddAddItem("FreeCommander", $sLang_Match, "TfcForm", "Edit1")
	MenuAppAddAddItem("Emacs", $sLang_Match, "Emacs", "Edit1")
	MenuAppAddAddItem("rxvt", $sLang_Contain, "rxvt", "Edit1")
EndFunc
Func MenuAppAddAddItem($sName, $sType, $sClass, $sClassNN)
	Local $iItem = GUICtrlCreateMenuItem($sName, $MenuAppAdd)
	GUICtrlSetOnEvent($iItem, "MenuAppAddClick")
	Assign("AppAddName" & $iItem, $sName, 2)
	Assign("AppAddType" & $iItem, $sType, 2)
	Assign("AppAddClass" & $iItem, $sClass, 2)
	Assign("AppAddClassNN" & $iItem, $sClassNN, 2)
	Return $iItem
EndFunc
Func MenuAppAddClick()
	Local $sName = Eval("AppAddName" & @GUI_CtrlId)
	Local $sType = Eval("AppAddType" & @GUI_CtrlId)
	Local $sClass = Eval("AppAddClass" & @GUI_CtrlId)
	Local $sClassNN = Eval("AppAddClassNN" & @GUI_CtrlId)
	GUICtrlSetState(GUICtrlCreateListViewItem($sName & "|" & $sType & "|" & $sClass & "|" & $sClassNN, $ListViewApp), $GUI_CHECKED)
	Local $iIndex = _GUICtrlListView_GetItemCount($ListViewApp) - 1
	_GUICtrlListView_SetItemSelected($ListViewApp, $iIndex, True, True)
	_GUICtrlListView_EnsureVisible($ListViewApp, $iIndex, False)
	ListViewApp_ItemChanged()
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc

Func ButtonAppAddClick()
	If _IsPressedI($VK_SHIFT) Then
		ShowButtonMenu($hGuiOptions, $ButtonAppAdd, $MenuAppAdd)
	Else
		GUICtrlSetState(GUICtrlCreateListViewItem("|" & $sLang_Match, $ListViewApp), $GUI_CHECKED)
		Local $iIndex = _GUICtrlListView_GetItemCount($ListViewApp) - 1
		_GUICtrlListView_SetItemSelected($ListViewApp, $iIndex, True, True)
		_GUICtrlListView_EnsureVisible($ListViewApp, $iIndex, False)
		ListViewApp_ItemChanged()
		GUICtrlSetState($InputAppName, $GUI_FOCUS)
	EndIf
EndFunc
Func ButtonAppDelClick()
	GUICtrlDelete(GUICtrlRead($ListViewApp))
	_GUICtrlListView_SetItemSelected($ListViewApp, _GUICtrlListView_GetNextItem($ListViewApp, -1, 0, 4))
	ListViewApp_ItemChanged()
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func ComboAppTypeChange()
	If $fAppDontChange = 1 Then Return
	Local $iItem = GUICtrlRead($ListViewApp)
	If $iItem = 0 Then Return
	Switch GUICtrlRead($ComboAppType)
		Case $sLang_Match
			GUICtrlSetData($iItem, "|" & $sLang_Match)
		Case $sLang_Contain
			GUICtrlSetData($iItem, "|" & $sLang_Contain)
	EndSwitch
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func InputAppChange($iInput)
	If $fAppDontChange = 1 Then Return
	Local $iItem = GUICtrlRead($ListViewApp)
	If $iItem = 0 Then Return
	Local $sText = GUICtrlRead($iInput)
	Switch $iInput
		Case $InputAppName
			GUICtrlSetData($iItem, $sText)
		Case $InputAppClass
			GUICtrlSetData($iItem, "||" & $sText)
	EndSwitch
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewApp, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func ListViewAppClick()
	_GUICtrlListView_SortItems($ListViewApp, GUICtrlGetState($ListViewApp))
EndFunc
Func ListViewApp_KeyDown($lParam)
	If GUICtrlRead($Tab1, 1) <> $TabSheetApp Then Return
	Local $tNMLVKEYDOWN = DllStructCreate($tagNMLVKEYDOWN, $lParam)
	Local $iVKey = BitAND(DllStructGetData($tNMLVKEYDOWN, "VKey"), 0xFF)
	Switch $iVKey
		Case $VK_INSERT
			ButtonAppAddClick()
		Case $VK_DELETE
			ButtonAppDelClick()
	EndSwitch
EndFunc
Func ListViewApp_ItemChanged()
	Local $iItem = GUICtrlRead($ListViewApp)
	Local $sData = GUICtrlRead($iItem)
	Local $aData = _StringExplode($sData, "|")
	If UBound($aData) = 5 Then
		$fAppDontChange = 1
		If GUICtrlRead($InputAppName) <> $aData[0] Then GUICtrlSetData($InputAppName, $aData[0])
		If GUICtrlRead($InputAppClass) <> $aData[2] Then GUICtrlSetData($InputAppClass, $aData[2])
		If $aData[1] = $sLang_Contain Then
			GUICtrlSetData($ComboAppType, $sLang_Contain)
		Else
			GUICtrlSetData($ComboAppType, $sLang_Match)
		EndIf
		$fAppDontChange = 0
	EndIf
EndFunc
#endregion Application

#region Hotkey
Func TabKeyCreate()
	Global $TabSheetHotkey = GUICtrlCreateTabItem($sLang_Hotkey)
	Global $ListViewKey = GUICtrlCreateListView("K|" & $sLang_Hotkey & "|" & $sLang_Action, 36, 56, 492, 304, -1, BitOR($WS_EX_CLIENTEDGE, $LVS_EX_FULLROWSELECT))
	GUICtrlSetResizing($ListViewKey, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
	GUICtrlSetOnEvent($ListViewKey, "ListViewKeyClick")
	Local $LabelHotkeyKey = GUICtrlCreateLabel($sLang_Hotkey, 36, 372, -1, 17)
	GUICtrlSetResizing($LabelHotkeyKey, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelHotkeyKey, "LabelHotkeyKeyClick")
	Global $CheckboxHotkeyD = GUICtrlCreateCheckbox($sLang_DoubleClick, 100, 369, -1, 17)
	GUICtrlSetResizing($CheckboxHotkeyD, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxHotkeyD, "CheckboxHotkeyDClick")
	Global $CheckboxHotkeyN = GUICtrlCreateCheckbox($sLang_KeepNative, 196, 369, -1, 17)
	GUICtrlSetResizing($CheckboxHotkeyN, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxHotkeyN, "CheckboxHotkeyNClick")
	Global $CheckboxHotkeyS = GUICtrlCreateCheckbox($sLang_Shift, 196, 369, -1, 17)
	GUICtrlSetResizing($CheckboxHotkeyS, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxHotkeyS, "CheckboxHotkeySClick")
	Global $CheckboxHotkeyC = GUICtrlCreateCheckbox($sLang_Ctrl, 244, 369, -1, 17)
	GUICtrlSetResizing($CheckboxHotkeyC, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxHotkeyC, "CheckboxHotkeyCClick")
	Global $CheckboxHotkeyA = GUICtrlCreateCheckbox($sLang_Alt, 284, 369, -1, 17)
	GUICtrlSetResizing($CheckboxHotkeyA, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxHotkeyA, "CheckboxHotkeyAClick")
	Global $CheckboxHotkeyW = GUICtrlCreateCheckbox($sLang_Win, 324, 369, -1, 17)
	GUICtrlSetResizing($CheckboxHotkeyW, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxHotkeyW, "CheckboxHotkeyWClick")
	Global $InputHotkeyKey = _GUICtrlCreateHotKeyInput(0, 92, 392, 200, 21)
	GUICtrlSetResizing($InputHotkeyKey, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputHotkeyKey, "InputHotkeyKeyChange")
	Global $ButtonHotkeyMouse = GUICtrlCreateButton("M", 296, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonHotkeyMouse, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonHotkeyMouse, "ButtonHotkeyMouseClick")
	Local $LabelHotkeyAction = GUICtrlCreateLabel($sLang_Action, 36, 420, -1, 17)
	GUICtrlSetResizing($LabelHotkeyAction, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelHotkeyAction, "LabelHotkeyActionClick")
	Global $ComboHotkeyAction = GUICtrlCreateCombo("", 92, 416, 272, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData($ComboHotkeyAction, $sLang_ShowMenu & " 1" & "|" & $sLang_ShowMenu & " 1.5" & "|" & $sLang_ShowMenu & " 2" & "|" & $sLang_OpenSelText & "|" & $sLang_AddApp & "|" & $sLang_Website & "|" & $sLang_CheckVer & "|" & $sLang_AddFavorite & "|" & $sLang_Reload & "|" & $sLang_Options & "|" & $sLang_EditConfig & "|" & $sLang_Exit & "|" & $sLang_ToggleHidden & "|" & $sLang_ToggleFileExt & "|" & $sLang_SystemRecent & "|" & $sLang_RecentMenu & "|" & $sLang_ExplorerMenu & "|" & $sLang_DriveMenu & "|" & $sLang_ToolMenu & "|" & $sLang_SVSMenu & "|" & $sLang_TCMenu, $sLang_ShowMenu & " 1")
	GUICtrlSetResizing($ComboHotkeyAction, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ComboHotkeyAction, "ComboHotkeyActionChange")
	Local $ButtonHotkeyAdd = GUICtrlCreateButton($sLang_Add, 320, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonHotkeyAdd, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonHotkeyAdd, "ButtonHotkeyAddClick")
	Global $ButtonHotkeyDel = GUICtrlCreateButton($sLang_Del, 344, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonHotkeyDel, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonHotkeyDel, "ButtonHotkeyDelClick")
	GUICtrlSetTip($ButtonHotkeyMouse, $sLang_TipHotkeyMouse)
EndFunc
Func TabKeySet()
	Global $fHotkeyDontChange = 0
	_GUICtrlListView_RegisterSortCallBack($ListViewKey)
	MenuKeyMouseCreate()
	ListViewKeyCreate()
	GUICtrlSetState($CheckboxHotkeyS, $GUI_HIDE)
	GUICtrlSetState($CheckboxHotkeyC, $GUI_HIDE)
	GUICtrlSetState($CheckboxHotkeyA, $GUI_HIDE)
	GUICtrlSetState($CheckboxHotkeyW, $GUI_HIDE)
	; GUICtrlSetState($InputHotkeyKey   , $GUI_DISABLE)
	; GUICtrlSetState($ButtonHotkeyMouse, $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyD  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyN  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyS  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyC  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyA  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyW  , $GUI_DISABLE)
	; GUICtrlSetState($ComboHotkeyAction, $GUI_DISABLE)
	; GUICtrlSetState($ButtonHotkeyDel  , $GUI_DISABLE)
EndFunc
Func TabKeyGet()
	$iHotkeysCount = _GUICtrlListView_GetItemCount($ListViewKey)
	If $iHotkeysCount < 1 Then Return
	ReDim $aiHotkeyKey[$iHotkeysCount]
	ReDim $asHotkeyFunc[$iHotkeysCount]
	For $i = 0 To $iHotkeysCount - 1
		Local $a = _GUICtrlListView_GetItemTextArray($ListViewKey, $i)
		$aiHotkeyKey[$i] = $a[1]
		$asHotkeyFunc[$i] = HotkeyName2Func($a[3])
	Next
EndFunc
Func ListViewKeyCreate()
	Local $ListViewKey_Item
	If $iHotkeysCount > 0 Then
		For $i = 0 To $iHotkeysCount - 1
			GUICtrlCreateListViewItem($aiHotkeyKey[$i] _
					 & "|" & _KeyToStr($aiHotkeyKey[$i]) _
					 & "|" & HotkeyFunc2Name($asHotkeyFunc[$i]) _
					, $ListViewKey)
		Next
	EndIf
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 0, 0) ;$LVSCW_AUTOSIZE_USEHEADER) ; Hotkey value
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER) ; Name
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER) ; Action
EndFunc
Func MenuKeyMouseCreate()
	Local $Dummy = GUICtrlCreateDummy()
	Global $MenuKeyMouse = GUICtrlCreateContextMenu($Dummy)
	Global $MenuKeyMouseL = GUICtrlCreateMenuItem($sLang_LButton, $MenuKeyMouse)
	Global $MenuKeyMouseR = GUICtrlCreateMenuItem($sLang_RButton, $MenuKeyMouse)
	Global $MenuKeyMouseM = GUICtrlCreateMenuItem($sLang_MButton, $MenuKeyMouse)
	Global $MenuKeyMouseX1 = GUICtrlCreateMenuItem($sLang_XButton1, $MenuKeyMouse)
	Global $MenuKeyMouseX2 = GUICtrlCreateMenuItem($sLang_XButton2, $MenuKeyMouse)
	GUICtrlSetOnEvent($MenuKeyMouseL, "SetKeyMouse")
	GUICtrlSetOnEvent($MenuKeyMouseR, "SetKeyMouse")
	GUICtrlSetOnEvent($MenuKeyMouseM, "SetKeyMouse")
	GUICtrlSetOnEvent($MenuKeyMouseX1, "SetKeyMouse")
	GUICtrlSetOnEvent($MenuKeyMouseX2, "SetKeyMouse")
EndFunc
Func SetKeyMouse()
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sDummy, $iKey = GUICtrlRead($iItem)
	StringSplit2($iKey, "|", $iKey, $sDummy)
	$iKey = BitAND($iKey, 0x0F00) ; keep only modifiers
	Switch @GUI_CtrlId
		Case $MenuKeyMouseL
			$iKey += 1
		Case $MenuKeyMouseR
			$iKey += 2
		Case $MenuKeyMouseM
			$iKey += 4
		Case $MenuKeyMouseX1
			$iKey += 5
		Case $MenuKeyMouseX2
			$iKey += 6
	EndSwitch
	GUICtrlSetData($iItem, $iKey & "|" & _KeyToStr($iKey))
	ListViewKey_ItemChanged()
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc

Func CheckboxHotkeyDClick()
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sData = GUICtrlRead($iItem)
	Local $aData = _StringExplode($sData, "|")
	If UBound($aData) = 4 Then
		Local $iKey = $aData[0]
		Local $fDouble = BitAND(GUICtrlRead($CheckboxHotkeyD), $GUI_CHECKED)
		If $fDouble = 0 Then
			GUICtrlSetData($iItem, BitAND($iKey, BitNOT(0x1000)))
		Else
			GUICtrlSetData($iItem, BitOR($iKey, 0x1000))
		EndIf
		ListViewKey_ItemChanged()
	EndIf
EndFunc
Func CheckboxHotkeyNClick()
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sData = GUICtrlRead($iItem)
	Local $aData = _StringExplode($sData, "|")
	If UBound($aData) = 4 Then
		Local $iKey = $aData[0]
		Local $fNative = BitAND(GUICtrlRead($CheckboxHotkeyN), $GUI_CHECKED)
		If $fNative = 0 Then
			GUICtrlSetData($iItem, BitAND($iKey, BitNOT(0x2000)))
		Else
			GUICtrlSetData($iItem, BitOR($iKey, 0x2000))
		EndIf
		ListViewKey_ItemChanged()
	EndIf
EndFunc
Func CheckboxHotkeySClick()
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sDummy, $iKey = GUICtrlRead($iItem)
	StringSplit2($iKey, "|", $iKey, $sDummy)
	If GUICtrlRead($CheckboxHotkeyS) = 1 Then
		$iKey = BitOR($iKey, $CK_SHIFT)
	Else
		$iKey = BitAND($iKey, BitNOT($CK_SHIFT))
	EndIf
	GUICtrlSetData($iItem, $iKey & "|" & _KeyToStr($iKey))
	ListViewKey_ItemChanged()
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func CheckboxHotkeyCClick()
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sDummy, $iKey = GUICtrlRead($iItem)
	StringSplit2($iKey, "|", $iKey, $sDummy)
	If GUICtrlRead($CheckboxHotkeyC) = 1 Then
		$iKey = BitOR($iKey, $CK_CONTROL)
	Else
		$iKey = BitAND($iKey, BitNOT($CK_CONTROL))
	EndIf
	GUICtrlSetData($iItem, $iKey & "|" & _KeyToStr($iKey))
	ListViewKey_ItemChanged()
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func CheckboxHotkeyAClick()
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sDummy, $iKey = GUICtrlRead($iItem)
	StringSplit2($iKey, "|", $iKey, $sDummy)
	If GUICtrlRead($CheckboxHotkeyA) = 1 Then
		$iKey = BitOR($iKey, $CK_ALT)
	Else
		$iKey = BitAND($iKey, BitNOT($CK_ALT))
	EndIf
	GUICtrlSetData($iItem, $iKey & "|" & _KeyToStr($iKey))
	ListViewKey_ItemChanged()
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func CheckboxHotkeyWClick()
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sDummy, $iKey = GUICtrlRead($iItem)
	StringSplit2($iKey, "|", $iKey, $sDummy)
	If GUICtrlRead($CheckboxHotkeyW) = 1 Then
		$iKey = BitOR($iKey, $CK_WIN)
	Else
		$iKey = BitAND($iKey, BitNOT($CK_WIN))
	EndIf
	GUICtrlSetData($iItem, $iKey & "|" & _KeyToStr($iKey))
	ListViewKey_ItemChanged()
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func ButtonHotkeyAddClick()
	GUICtrlCreateListViewItem("0|None|" & $sLang_ShowMenu & " 1", $ListViewKey)
	Local $iIndex = _GUICtrlListView_GetItemCount($ListViewKey) - 1
	_GUICtrlListView_SetItemSelected($ListViewKey, $iIndex, True, True)
	_GUICtrlListView_EnsureVisible($ListViewKey, $iIndex, False)
	ListViewKey_ItemChanged()
	GUICtrlSetState($InputHotkeyKey, $GUI_FOCUS)
EndFunc
Func ButtonHotkeyDelClick()
	GUICtrlDelete(GUICtrlRead($ListViewKey))
	_GUICtrlListView_SetItemSelected($ListViewKey, _GUICtrlListView_GetNextItem($ListViewKey, -1, 0, 4))
	ListViewKey_ItemChanged()
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func ButtonHotkeyMouseClick()
	ShowButtonMenu($hGuiOptions, $ButtonHotkeyMouse, $MenuKeyMouse)
EndFunc
Func ComboHotkeyActionChange()
	If $fHotkeyDontChange = 1 Then Return
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sText = GUICtrlRead($ComboHotkeyAction)
	GUICtrlSetData($iItem, "||" & $sText)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func InputHotkeyChange($iInput)
	If $fHotkeyDontChange = 1 Then Return
	Local $iItem = GUICtrlRead($ListViewKey)
	If $iItem = 0 Then Return
	Local $sDummy, $sKey = GUICtrlRead($iItem)
	StringSplit2($sKey, "|", $sDummy, $sKey)
	StringSplit2($sKey, "|", $sKey, $sDummy)
	Local $sKeyNew = GUICtrlRead($InputHotkeyKey)

	If $sKeyNew = $sKey Then Return

	Local $iKey = _GUICtrlReadHotKeyInput($InputHotkeyKey)
	$fHotkeyDontChange = 1
	GUICtrlSetData($iItem, $iKey & "|" & $sKeyNew)
	$fHotkeyDontChange = 0
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewKey, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)

	GUICtrlSetState($CheckboxHotkeyN, $GUI_SHOW)
	GUICtrlSetState($CheckboxHotkeyS, $GUI_HIDE)
	GUICtrlSetState($CheckboxHotkeyC, $GUI_HIDE)
	GUICtrlSetState($CheckboxHotkeyA, $GUI_HIDE)
	GUICtrlSetState($CheckboxHotkeyW, $GUI_HIDE)
EndFunc
Func ListViewKeyClick()
	_GUICtrlListView_SortItems($ListViewKey, GUICtrlGetState($ListViewKey))
EndFunc
Func ListViewKey_KeyDown($lParam)
	If GUICtrlRead($Tab1, 1) <> $TabSheetHotkey Then Return
	Local $tNMLVKEYDOWN = DllStructCreate($tagNMLVKEYDOWN, $lParam)
	Local $iVKey = BitAND(DllStructGetData($tNMLVKEYDOWN, "VKey"), 0xFF)
	Switch $iVKey
		Case $VK_INSERT
			ButtonHotkeyAddClick()
		Case $VK_DELETE
			ButtonHotkeyDelClick()
	EndSwitch
EndFunc
Func ListViewKey_ItemChanged()
	If $fHotkeyDontChange = 1 Then Return
	Local $iItem = GUICtrlRead($ListViewKey)
	; if $iItem = 0 then
	; GUICtrlSetData($InputHotkeyKey   , "")
	; GUICtrlSetState($InputHotkeyKey   , $GUI_DISABLE)
	; GUICtrlSetState($ButtonHotkeyMouse, $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyD  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyN  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyS  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyC  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyA  , $GUI_DISABLE)
	; GUICtrlSetState($CheckboxHotkeyW  , $GUI_DISABLE)
	; GUICtrlSetState($ComboHotkeyAction, $GUI_DISABLE)
	; GUICtrlSetState($ButtonHotkeyDel  , $GUI_DISABLE)
	; return
	; else
	; GUICtrlSetState($InputHotkeyKey   , $GUI_ENABLE)
	; GUICtrlSetState($ButtonHotkeyMouse, $GUI_ENABLE)
	; GUICtrlSetState($CheckboxHotkeyD  , $GUI_ENABLE)
	; GUICtrlSetState($CheckboxHotkeyN  , $GUI_ENABLE)
	; GUICtrlSetState($CheckboxHotkeyS  , $GUI_ENABLE)
	; GUICtrlSetState($CheckboxHotkeyC  , $GUI_ENABLE)
	; GUICtrlSetState($CheckboxHotkeyA  , $GUI_ENABLE)
	; GUICtrlSetState($CheckboxHotkeyW  , $GUI_ENABLE)
	; GUICtrlSetState($ComboHotkeyAction, $GUI_ENABLE)
	; GUICtrlSetState($ButtonHotkeyDel  , $GUI_ENABLE)
	; endif
	Local $sData = GUICtrlRead($iItem)
	Local $aData = _StringExplode($sData, "|")
	If UBound($aData) = 4 Then
		Local $iKey = $aData[0]
		Local $fDouble = BitAND($iKey, 0x1000)
		Local $fNative = BitAND($iKey, 0x2000)
		If BitAND($iKey, 0xFF) > 0 And BitAND($iKey, 0xFF) < 7 Then
			GUICtrlSetState($CheckboxHotkeyN, $GUI_HIDE)
			GUICtrlSetState($CheckboxHotkeyS, $GUI_SHOW)
			GUICtrlSetState($CheckboxHotkeyC, $GUI_SHOW)
			GUICtrlSetState($CheckboxHotkeyA, $GUI_SHOW)
			GUICtrlSetState($CheckboxHotkeyW, $GUI_SHOW)
		Else
			GUICtrlSetState($CheckboxHotkeyN, $GUI_SHOW)
			GUICtrlSetState($CheckboxHotkeyS, $GUI_HIDE)
			GUICtrlSetState($CheckboxHotkeyC, $GUI_HIDE)
			GUICtrlSetState($CheckboxHotkeyA, $GUI_HIDE)
			GUICtrlSetState($CheckboxHotkeyW, $GUI_HIDE)
		EndIf
		If BitAND($iKey, $CK_SHIFT) <> 0 Then
			GUICtrlSetState($CheckboxHotkeyS, $GUI_CHECKED)
		Else
			GUICtrlSetState($CheckboxHotkeyS, $GUI_UNCHECKED)
		EndIf
		If BitAND($iKey, $CK_CONTROL) <> 0 Then
			GUICtrlSetState($CheckboxHotkeyC, $GUI_CHECKED)
		Else
			GUICtrlSetState($CheckboxHotkeyC, $GUI_UNCHECKED)
		EndIf
		If BitAND($iKey, $CK_ALT) <> 0 Then
			GUICtrlSetState($CheckboxHotkeyA, $GUI_CHECKED)
		Else
			GUICtrlSetState($CheckboxHotkeyA, $GUI_UNCHECKED)
		EndIf
		If BitAND($iKey, $CK_WIN) <> 0 Then
			GUICtrlSetState($CheckboxHotkeyW, $GUI_CHECKED)
		Else
			GUICtrlSetState($CheckboxHotkeyW, $GUI_UNCHECKED)
		EndIf
		$fHotkeyDontChange = 1
		_GUICtrlSetHotKeyInput($InputHotkeyKey, $iKey)
		GUICtrlSetData($ComboHotkeyAction, $aData[2])
		$fHotkeyDontChange = 0
		If $fDouble = 0 Then
			GUICtrlSetState($CheckboxHotkeyD, $GUI_UNCHECKED)
		Else
			GUICtrlSetState($CheckboxHotkeyD, $GUI_CHECKED)
		EndIf
		If $fNative = 0 Then
			GUICtrlSetState($CheckboxHotkeyN, $GUI_UNCHECKED)
		Else
			GUICtrlSetState($CheckboxHotkeyN, $GUI_CHECKED)
		EndIf
	EndIf
EndFunc
#endregion Hotkey

#region Icon
Func TabIconCreate()
	Global $TabSheetIcon = GUICtrlCreateTabItem($sLang_Icon)
	Global $CheckboxIcon = GUICtrlCreateCheckbox($sLang_NoIcon, 36, 57, -1, 17)
	GUICtrlSetResizing($CheckboxIcon, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxIcon, "CheckboxIconClick")
	Local $LabelIconSizeGlobal = GUICtrlCreateLabel($sLang_IconSize, 204, 60, -1, 17)
	GUICtrlSetResizing($LabelIconSizeGlobal, $GUI_DOCKTOP + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelIconSizeGlobal, "LabelIconSizeGlobalClick")
	Global $ComboIconSizeGlobal = GUICtrlCreateCombo("", 270, 56, 44, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $CBS_SORT))
	GUICtrlSetData($ComboIconSizeGlobal, "16|32|48|64")
	GUICtrlSetResizing($ComboIconSizeGlobal, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboIconSizeGlobal, "ComboIconSizeGlobalChange")
	Global $CheckboxIconFavicon = GUICtrlCreateCheckbox($sLang_GetFavicon, 36, 81, -1, 17)
	GUICtrlSetResizing($CheckboxIconFavicon, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxIconFavicon, "CheckboxIconFaviconClick")
	Global $CheckboxIconShell = GUICtrlCreateCheckbox($sLang_ShellIcon, 204, 81, -1, 17)
	GUICtrlSetResizing($CheckboxIconShell, $GUI_DOCKTOP + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxIconShell, "CheckboxIconShellClick")
	Global $ListViewIcon = GUICtrlCreateListView("|" & $sLang_Extension & "|" & $sLang_Size & "|" & $sLang_IconPath, 36, 104, 492, 280, -1, BitOR($WS_EX_CLIENTEDGE, $LVS_EX_FULLROWSELECT))
	GUICtrlSetResizing($ListViewIcon, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
	GUICtrlSetOnEvent($ListViewIcon, "ListViewIconClick")
	Local $LabelIconExt = GUICtrlCreateLabel($sLang_Extension, 36, 396, -1, 17)
	GUICtrlSetResizing($LabelIconExt, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelIconExt, "LabelIconExtClick")
	Global $InputIconExt = GUICtrlCreateInput("", 96, 392, 230, 21)
	GUICtrlSetResizing($InputIconExt, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputIconExt, "InputIconExtChange")
	Global $ButtonIconExt = GUICtrlCreateButton("...", 326, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonIconExt, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonIconExt, "ButtonIconExtClick")
	Local $LabelIconIcon = GUICtrlCreateLabel($sLang_Icon, 36, 420, -1, 17)
	GUICtrlSetResizing($LabelIconIcon, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelIconIcon, "LabelIconIconClick")
	Global $InputIconIcon = GUICtrlCreateInput("", 96, 416, 230, 21)
	GUICtrlSetResizing($InputIconIcon, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputIconIcon, "InputIconIconChange")
	Global $ButtonIconIcon = GUICtrlCreateButton("...", 326, 416, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonIconIcon, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonIconIcon, "ButtonIconIconClick")
	Global $ComboIconSize = GUICtrlCreateCombo("", 350, 416, 44, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $CBS_SORT))
	GUICtrlSetData($ComboIconSize, "16|32|48|64")
	GUICtrlSetResizing($ComboIconSize, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboIconSize, "ComboIconSizeChange")
	Global $ButtonIconAdd = GUICtrlCreateButton($sLang_Add, 350, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonIconAdd, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonIconAdd, "ButtonIconAddClick")
	Global $ButtonIconDel = GUICtrlCreateButton($sLang_Del, 374, 392, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonIconDel, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonIconDel, "ButtonIconDelClick")
	GUICtrlSetTip($CheckboxIcon, $sLang_TipNoIcon)
	GUICtrlSetTip($CheckboxIconFavicon, $sLang_TipGetFavicon)
	GUICtrlSetTip($CheckboxIconShell, $sLang_TipShellIcon)
	GUICtrlSetTip($ComboIconSizeGlobal, $sLang_TipIconSize)
	; GUICtrlSetTip($InputIconExt           , $sLang_TipIconExt   )
	GUICtrlSetTip($ComboIconSize, $sLang_TipIconSize)
EndFunc
Func TabIconSet()
	Global $fIconDontChange = 0
	GUICtrlSetState($CheckboxIcon, $fNoMenuIcon)
	GUICtrlSetState($CheckboxIconFavicon, $fGetFavIcon)
	GUICtrlSetState($CheckboxIconShell, $fShellIcon)
	CheckboxIconClick()
	_GUICtrlComboBox_SetEditText($ComboIconSizeGlobal, $iIconSizeG)
	If _GUICtrlComboBox_SelectString($ComboIconSizeGlobal, $iIconSizeG) = -1 Then
		If $iIconSizeG <> "" Then _GUICtrlComboBox_SetCurSel($ComboIconSizeGlobal, _GUICtrlComboBox_AddString($ComboIconSizeGlobal, $iIconSizeG))
	EndIf
	_GUICtrlListView_RegisterSortCallBack($ListViewIcon)
	ListViewIconCreate()
	MenuIconExtCreate()
EndFunc
Func TabIconGet()
	$iIconSizeG = Int(GUICtrlRead($ComboIconSizeGlobal))
	If $iIconSizeG = 0 Then $iIconSizeG = 16
	$fNoMenuIcon = BitAND(GUICtrlRead($CheckboxIcon), $GUI_CHECKED)
	$fGetFavIcon = BitAND(GUICtrlRead($CheckboxIconFavicon), $GUI_CHECKED)
	$fShellIcon = BitAND(GUICtrlRead($CheckboxIconShell), $GUI_CHECKED)
	$iIconsCount = _GUICtrlListView_GetItemCount($ListViewIcon)
	If $iIconsCount < 1 Then Return
	ReDim $asIconExt[$iIconsCount]
	ReDim $asIconIcon[$iIconsCount]
	For $i = 0 To $iIconsCount - 1
		Local $a = _GUICtrlListView_GetItemTextArray($ListViewIcon, $i)
		$asIconExt[$i] = $a[2]
		$asIconIcon[$i] = $a[4] & "," & $a[3]
	Next
EndFunc
Func ListViewIconCreate()
	Global $hImageListIcon = _GUIImageList_Create(16, 16, 5)
	_GUICtrlListView_SetImageList($ListViewIcon, $hImageListIcon, 1)
	Local $ListViewIcon_Item, $hIcon
	If $iIconsCount > 0 Then
		Local $sPath, $iIndex, $iSize
		For $i = 0 To $iIconsCount - 1
			SplitIconPath($asIconIcon[$i], $sPath, $iIndex, $iSize)
			$ListViewIcon_Item = GUICtrlCreateListViewItem("|" & $asIconExt[$i] & "|" & $iSize & "|" & $sPath & "," & $iIndex, $ListViewIcon)
			$hIcon = _GUIImageList_AddIcon($hImageListIcon, DerefPath($sPath), $iIndex)
			If @error Then
				SplitIconPath(GetIcon("Error"), $sPath, $iIndex, $iSize)
				$hIcon = _GUIImageList_AddIcon($hImageListIcon, DerefPath($sPath), $iIndex)
				GUICtrlSetBkColor($ListViewIcon_Item, 0xFFDDDD)
			EndIf
			_GUICtrlListView_SetItemImage($ListViewIcon, $i, $hIcon)
		Next
	EndIf
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func MenuIconExtCreate()
	Local $Dummy = GUICtrlCreateDummy()
	Global $MenuIconExt = GUICtrlCreateContextMenu($Dummy)
	_GUICtrlMenu_SetMenuStyle(GUICtrlGetHandle($MenuIconExt), $MNS_CHECKORBMP)
	MenuIconExtAddItem($sLang_Unknown, "Unknown")
	MenuIconExtAddItem($sLang_Menu, "Menu")
	MenuIconExtAddItem($sLang_Folder, "Folder")
	MenuIconExtAddItem($sLang_FolderS, "FolderS")
	MenuIconExtAddItem($sLang_Drive, "Drive")
	MenuIconExtAddItem($sLang_Computer, "Computer")
	MenuIconExtAddItem($sLang_UNCPath, "Share")
	GUICtrlCreateMenuItem("", $MenuIconExt)
	MenuIconExtAddItem($sLang_Website, "_GoWebsite")
	MenuIconExtAddItem($sLang_CheckVer, "_CheckUpdate")
	MenuIconExtAddItem($sLang_AddFavorite, "_AddFavorite")
	MenuIconExtAddItem($sLang_AddHere, "_AddHere")
	MenuIconExtAddItem($sLang_Reload, "_Reload")
	MenuIconExtAddItem($sLang_Options, "_Options")
	MenuIconExtAddItem($sLang_EditConfig, "_Edit")
	MenuIconExtAddItem($sLang_Exit, "_Exit")
	MenuIconExtAddItem($sLang_ToggleHidden, "_ToggleHidden")
	MenuIconExtAddItem($sLang_ToggleFileExt, "_ToggleFileExt")
	MenuIconExtAddItem($sLang_SystemRecent, "_SystemRecent")
	GUICtrlCreateMenuItem("", $MenuIconExt)
	MenuIconExtAddItem($sLang_RecentMenu, ":RecentMenu")
	MenuIconExtAddItem($sLang_ExplorerMenu, ":ExplorerMenu")
	MenuIconExtAddItem($sLang_DriveMenu, ":DriveMenu")
	MenuIconExtAddItem($sLang_ToolMenu, ":ToolMenu")
	MenuIconExtAddItem($sLang_SVSMenu, ":SVSMenu")
	MenuIconExtAddItem($sLang_TCMenu, ":TCMenu")
EndFunc
Func MenuIconExtAddItem($sName, $sExt)
	Local $iItem = GUICtrlCreateMenuItem($sName, $MenuIconExt)
	GUICtrlSetOnEvent($iItem, "MenuIconExtClick")
	SetMenuItemIcon($MenuIconExt, $iItem, "", GetIcon($sExt))
	Assign("SpecialExt" & $iItem, $sExt, 2)
	Return $iItem
EndFunc
Func MenuIconExtClick()
	Local $sExt = Eval("SpecialExt" & @GUI_CtrlId)
	GUICtrlSetData($InputIconExt, $sExt)
EndFunc

Func ButtonIconAddClick()
	GUICtrlCreateListViewItem("", $ListViewIcon)
	Local $iIndex = _GUICtrlListView_GetItemCount($ListViewIcon) - 1
	_GUICtrlListView_SetItemSelected($ListViewIcon, $iIndex, True, True)
	_GUICtrlListView_EnsureVisible($ListViewIcon, $iIndex, False)
	GUICtrlSetState($InputIconExt, $GUI_FOCUS)
	ListViewIcon_ItemChanged()
EndFunc
Func ButtonIconDelClick()
	GUICtrlDelete(GUICtrlRead($ListViewIcon))
	_GUICtrlListView_SetItemSelected($ListViewIcon, _GUICtrlListView_GetNextItem($ListViewIcon, -1, 0, 4))
	ListViewIcon_ItemChanged()
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func ButtonIconExtClick()
	ShowButtonMenu($hGuiOptions, $ButtonIconExt, $MenuIconExt)
EndFunc
Func ButtonIconIconClick()
	Local $iItem = GUICtrlRead($ListViewIcon)
	Local $iItemIndex = _GUICtrlListView_GetNextItem($ListViewIcon, -1, 0, 4)
	If $iItem = 0 Then Return
	Local $sIcon, $iIndex, $iSize
	StringSplit2(GUICtrlRead($InputIconIcon), ",", $sIcon, $iIndex)
	Local $asIcon = _WinAPI_PickIconDlg(DerefPath($sIcon), $iIndex)
	If @error Then Return
	Local $hIcon = _GUIImageList_AddIcon($hImageListIcon, $asIcon[0], $asIcon[1])
	If @error Then
		SplitIconPath(GetIcon("Error"), $sIcon, $iIndex, $iSize)
		$hIcon = _GUIImageList_AddIcon($hImageListIcon, DerefPath($sIcon), $iIndex)
		GUICtrlSetBkColor($iItem, 0xFFDDDD)
	Else
		GUICtrlSetBkColor($iItem, $GUI_BKCOLOR_TRANSPARENT)
	EndIf
	_GUICtrlListView_SetItemImage($ListViewIcon, $iItemIndex, $hIcon)
	GUICtrlSetData($iItem, "|||" & $asIcon[0] & "," & $asIcon[1])
	ListViewIcon_ItemChanged()
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func ComboIconSizeChange()
	If $fIconDontChange = 1 Then Return
	Local $iItem = GUICtrlRead($ListViewIcon)
	Local $sText = Int(GUICtrlRead($ComboIconSize))
	If $sText = 0 Then $sText = ""
	GUICtrlSetData($iItem, "||" & $sText)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func CheckboxIconClick()
	If GUICtrlRead($CheckboxIcon) = 1 Then
		GUICtrlSetState($ButtonIconAdd, $GUI_DISABLE)
		GUICtrlSetState($ButtonIconDel, $GUI_DISABLE)
		GUICtrlSetState($ButtonIconIcon, $GUI_DISABLE)
		GUICtrlSetState($CheckboxIconFavicon, $GUI_DISABLE)
		GUICtrlSetState($CheckboxIconShell, $GUI_DISABLE)
		GUICtrlSetState($InputIconExt, $GUI_DISABLE)
		GUICtrlSetState($InputIconIcon, $GUI_DISABLE)
		GUICtrlSetState($ComboIconSize, $GUI_DISABLE)
		GUICtrlSetState($ComboIconSizeGlobal, $GUI_DISABLE)
		GUICtrlSetState($ListViewIcon, $GUI_DISABLE)
	Else
		GUICtrlSetState($ButtonIconAdd, $GUI_ENABLE)
		GUICtrlSetState($ButtonIconDel, $GUI_ENABLE)
		GUICtrlSetState($ButtonIconIcon, $GUI_ENABLE)
		GUICtrlSetState($CheckboxIconFavicon, $GUI_ENABLE)
		GUICtrlSetState($CheckboxIconShell, $GUI_ENABLE)
		GUICtrlSetState($InputIconExt, $GUI_ENABLE)
		GUICtrlSetState($InputIconIcon, $GUI_ENABLE)
		GUICtrlSetState($ComboIconSize, $GUI_ENABLE)
		GUICtrlSetState($ComboIconSizeGlobal, $GUI_ENABLE)
		GUICtrlSetState($ListViewIcon, $GUI_ENABLE)
	EndIf
EndFunc
Func InputIconChange($iInput)
	If $fIconDontChange = 1 Then Return
	Local $iItem = GUICtrlRead($ListViewIcon)
	If $iItem = 0 Then Return
	Local $sText = GUICtrlRead($iInput)
	Switch $iInput
		Case $InputIconExt
			GUICtrlSetData($iItem, "|" & $sText)
		Case $InputIconIcon
			GUICtrlSetData($iItem, "|||" & $sText)
	EndSwitch
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 0, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 1, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 2, $LVSCW_AUTOSIZE_USEHEADER)
	GUICtrlSendMsg($ListViewIcon, $LVM_SETCOLUMNWIDTH, 3, $LVSCW_AUTOSIZE_USEHEADER)
EndFunc
Func ListViewIconClick()
	_GUICtrlListView_SortItems($ListViewIcon, GUICtrlGetState($ListViewIcon))
EndFunc
Func ListViewIcon_ItemActivate($lParam)
	ButtonIconIconClick()
EndFunc
Func ListViewIcon_KeyDown($lParam)
	If GUICtrlRead($Tab1, 1) <> $TabSheetIcon Then Return
	Local $tNMLVKEYDOWN = DllStructCreate($tagNMLVKEYDOWN, $lParam)
	Local $iVKey = BitAND(DllStructGetData($tNMLVKEYDOWN, "VKey"), 0xFF)
	Switch $iVKey
		Case $VK_INSERT
			ButtonIconAddClick()
		Case $VK_DELETE
			ButtonIconDelClick()
	EndSwitch
EndFunc
Func ListViewIcon_ItemChanged()
	Local $iItem = GUICtrlRead($ListViewIcon)
	; if $iItem = 0 then
	; GUICtrlSetData($InputIconExt  , "")
	; GUICtrlSetData($InputIconIcon , "")
	; GUICtrlSetState($InputIconExt  , $GUI_DISABLE)
	; GUICtrlSetState($ComboIconSize , $GUI_DISABLE)
	; GUICtrlSetState($InputIconIcon , $GUI_DISABLE)
	; GUICtrlSetState($ButtonIconIcon, $GUI_DISABLE)
	; GUICtrlSetState($ButtonIconDel , $GUI_DISABLE)
	; return
	; else
	; GUICtrlSetState($InputIconExt  , $GUI_ENABLE)
	; GUICtrlSetState($ComboIconSize , $GUI_ENABLE)
	; GUICtrlSetState($InputIconIcon , $GUI_ENABLE)
	; GUICtrlSetState($ButtonIconIcon, $GUI_ENABLE)
	; GUICtrlSetState($ButtonIconDel , $GUI_ENABLE)
	; endif
	Local $sData = GUICtrlRead($iItem)
	Local $aData = _StringExplode($sData, "|")
	If UBound($aData) = 5 Then
		$fIconDontChange = 1
		If GUICtrlRead($InputIconExt) <> $aData[1] Then GUICtrlSetData($InputIconExt, $aData[1])
		If GUICtrlRead($ComboIconSize) <> $aData[2] Then ; GUICtrlSetData($ComboIconSize, $aData[2])
			_GUICtrlComboBox_SetEditText($ComboIconSize, $aData[2])
			If _GUICtrlComboBox_SelectString($ComboIconSize, $aData[2]) = -1 Then
				If $aData[2] <> "" Then _GUICtrlComboBox_SetCurSel($ComboIconSize, _GUICtrlComboBox_AddString($ComboIconSize, $aData[2]))
			EndIf
		EndIf
		If GUICtrlRead($InputIconIcon) <> $aData[3] Then GUICtrlSetData($InputIconIcon, $aData[3])
		$fIconDontChange = 0
	EndIf
EndFunc
#endregion Icon

#region Menu
Func TabMenuCreate()
	Local $TabSheetMenu = GUICtrlCreateTabItem($sLang_Menu)
	Local $GroupMenuPos = GUICtrlCreateGroup($sLang_MenuPosition, 36, 56, 492, 56)
	GUICtrlSetResizing($GroupMenuPos, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	Local $LabelMenuPosX = GUICtrlCreateLabel("X", 52, 84, -1, 17)
	GUICtrlSetResizing($LabelMenuPosX, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelMenuPosX, "LabelMenuPosXClick")
	Global $InputMenuPosX = GUICtrlCreateInput("", 68, 80, 40, 21, BitOR($ES_AUTOHSCROLL, $ES_NUMBER))
	GUICtrlSetResizing($InputMenuPosX, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputMenuPosX, "InputMenuPosXChange")
	Local $LabelMenuPosY = GUICtrlCreateLabel("Y", 124, 84, -1, 17)
	GUICtrlSetResizing($LabelMenuPosY, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelMenuPosY, "LabelMenuPosYClick")
	Global $InputMenuPosY = GUICtrlCreateInput("", 140, 80, 40, 21, BitOR($ES_AUTOHSCROLL, $ES_NUMBER))
	GUICtrlSetResizing($InputMenuPosY, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputMenuPosY, "InputMenuPosYChange")
	Global $ComboMenuPos = GUICtrlCreateCombo("", 360, 80, 152, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData($ComboMenuPos, $sLang_RelativeToCursor & "|" & $sLang_RelativeToScreen & "|" & $sLang_RelativeToWindow, $sLang_RelativeToCursor)
	GUICtrlSetResizing($ComboMenuPos, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboMenuPos, "ComboMenuPosChange")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $GroupMenuTemp = GUICtrlCreateGroup($sLang_TempMenu, 36, 128, 492, 129)
	GUICtrlSetResizing($GroupMenuTemp, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	Global $CheckboxMenuTempShowFile = GUICtrlCreateCheckbox($sLang_ShowFile, 52, 153, -1, 17)
	GUICtrlSetResizing($CheckboxMenuTempShowFile, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxMenuTempShowFile, "CheckboxMenuTempShowFileClick")
	Global $InputMenuTempExt = GUICtrlCreateInput("", 360, 152, 152, 21)
	GUICtrlSetResizing($InputMenuTempExt, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputMenuTempExt, "InputMenuTempExtChange")
	Global $CheckboxMenuTempIcon = GUICtrlCreateCheckbox($sLang_AltFolderIcon, 52, 177, -1, 17)
	GUICtrlSetResizing($CheckboxMenuTempIcon, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxMenuTempIcon, "CheckboxMenuTempIconClick")
	Global $CheckboxMenuTempBrowse = GUICtrlCreateCheckbox($sLang_BrowseMode, 52, 201, -1, 17)
	GUICtrlSetResizing($CheckboxMenuTempBrowse, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxMenuTempBrowse, "CheckboxMenuTempBrowseClick")
	Local $LabelMenuTempDrive = GUICtrlCreateLabel($sLang_DriveType, 52, 228, -1, 17)
	GUICtrlSetResizing($LabelMenuTempDrive, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelMenuTempDrive, "LabelMenuTempDriveClick")
	Global $ComboMenuTempDrive = GUICtrlCreateCombo("", 360, 224, 152, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData($ComboMenuTempDrive, $sLang_All & "|" & $sLang_Fixed & "|" & $sLang_CDROM & "|" & $sLang_Removable & "|" & $sLang_Network & "|" & $sLang_RAMDisk, $sLang_All)
	GUICtrlSetResizing($ComboMenuTempDrive, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboMenuTempDrive, "ComboMenuTempDriveChange")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $CheckboxMenuHideExt = GUICtrlCreateCheckbox($sLang_HideExt, 36, 273, -1, 17)
	GUICtrlSetResizing($CheckboxMenuHideExt, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxMenuHideExt, "CheckboxMenuHideExtClick")
	Global $CheckboxMenuHideLnk = GUICtrlCreateCheckbox($sLang_HideLnk, 196, 273, -1, 17)
	GUICtrlSetResizing($CheckboxMenuHideLnk, $GUI_DOCKTOP + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxMenuHideLnk, "CheckboxMenuHideLnkClick")
	Global $CheckboxMenuItemWarn = GUICtrlCreateCheckbox($sLang_ItemWarn, 36, 297, -1, 17)
	GUICtrlSetResizing($CheckboxMenuItemWarn, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxMenuItemWarn, "CheckboxMenuItemWarnClick")
	GUICtrlSetTip($InputMenuTempExt, $sLang_TipFavExt)
	GUICtrlSetTip($CheckboxMenuTempIcon, $sLang_TipMenuTempIcon)
	GUICtrlSetTip($CheckboxMenuTempBrowse, $sLang_TipMenuTempBrowse)
EndFunc
Func TabMenuSet()
	GUICtrlSetData($InputMenuPosX, $iMenuPositionX)
	GUICtrlSetData($InputMenuPosY, $iMenuPositionY)
	If $iMenuPosition = 0 Then GUICtrlSetData($ComboMenuPos, $sLang_RelativeToCursor)
	If $iMenuPosition = 1 Then GUICtrlSetData($ComboMenuPos, $sLang_RelativeToScreen)
	If $iMenuPosition = 2 Then GUICtrlSetData($ComboMenuPos, $sLang_RelativeToWindow)
	GUICtrlSetState($CheckboxMenuTempShowFile, $fTempShowFile)
	GUICtrlSetData($InputMenuTempExt, $sTempShowFExt)
	CheckboxMenuTempShowFileClick()
	GUICtrlSetState($CheckboxMenuTempIcon, $fAltFolderIcon)
	GUICtrlSetState($CheckboxMenuTempBrowse, $fBrowseMode)
	If Eval("sLang_" & $sTempDriveType) <> "" Then GUICtrlSetData($ComboMenuTempDrive, Eval("sLang_" & $sTempDriveType))
	GUICtrlSetState($CheckboxMenuHideExt, $fHideExt)
	GUICtrlSetState($CheckboxMenuHideLnk, $fHideLnk)
	GUICtrlSetState($CheckboxMenuItemWarn, $fItemWarn)
EndFunc
Func TabMenuGet()
	$iMenuPositionX = GUICtrlRead($InputMenuPosX)
	$iMenuPositionY = GUICtrlRead($InputMenuPosY)
	$iMenuPosition = _GUICtrlComboBox_GetCurSel($ComboMenuPos)
	$fTempShowFile = BitAND(GUICtrlRead($CheckboxMenuTempShowFile), $GUI_CHECKED)
	$sTempShowFExt = GUICtrlRead($InputMenuTempExt)
	$fAltFolderIcon = BitAND(GUICtrlRead($CheckboxMenuTempIcon), $GUI_CHECKED)
	$fBrowseMode = BitAND(GUICtrlRead($CheckboxMenuTempBrowse), $GUI_CHECKED)
	Switch GUICtrlRead($ComboMenuTempDrive)
		Case $sLang_All
			$sTempDriveType = "All"
		Case $sLang_Fixed
			$sTempDriveType = "Fixed"
		Case $sLang_CDROM
			$sTempDriveType = "CDROM"
		Case $sLang_Removable
			$sTempDriveType = "Removable"
		Case $sLang_Network
			$sTempDriveType = "Network"
		Case $sLang_RAMDisk
			$sTempDriveType = "RAMDisk"
	EndSwitch
	$fHideExt = BitAND(GUICtrlRead($CheckboxMenuHideExt), $GUI_CHECKED)
	$fHideLnk = BitAND(GUICtrlRead($CheckboxMenuHideLnk), $GUI_CHECKED)
	$fItemWarn = BitAND(GUICtrlRead($CheckboxMenuItemWarn), $GUI_CHECKED)
	; msg( _
	; "iMenuPositionX" & $iMenuPositionX & @LF & _
	; "iMenuPositionY" & $iMenuPositionY & @LF & _
	; "iMenuPosition " & $iMenuPosition  & @LF & _
	; "fTempShowFile " & $fTempShowFile  & @LF & _
	; "sTempShowFExt " & $sTempShowFExt  & @LF & _
	; "fAltFolderIcon" & $fAltFolderIcon & @LF & _
	; "fBrowseMode   " & $fBrowseMode    & @LF & _
	; "sTempDriveType" & $sTempDriveType & @LF & _
	; "fHideExt      " & $fHideExt       & @LF & _
	; "fHideLnk      " & $fHideLnk       & @LF & _
	; "fItemWarn     " & $fItemWarn)
EndFunc
Func CheckboxMenuTempShowFileClick()
	Local $iState = GUICtrlRead($CheckboxMenuTempShowFile)
	If $iState = $GUI_CHECKED Then
		GUICtrlSetState($InputMenuTempExt, $GUI_ENABLE)
	ElseIf $iState = $GUI_UNCHECKED Then
		GUICtrlSetState($InputMenuTempExt, $GUI_DISABLE)
	EndIf
EndFunc
#endregion Menu

#region Other
Func TabOtherCreate()
	Local $TabSheetOther = GUICtrlCreateTabItem($sLang_Other)
	Local $LabelOtherLang = GUICtrlCreateLabel($sLang_Language, 118, 60, -1, 17)
	GUICtrlSetResizing($LabelOtherLang, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelOtherLang, "LabelOtherLangClick")
	Global $ComboOtherLang = GUICtrlCreateCombo("", 246, 56, 176, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetResizing($ComboOtherLang, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboOtherLang, "ComboOtherLangChange")
	Local $ButtonOtherLang = GUICtrlCreateButton("...", 426, 56, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonOtherLang, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonOtherLang, "ButtonOtherLangClick")
	Global $CheckboxOtherStart = GUICtrlCreateCheckbox($sLang_StartWithWin, 118, 89, -1, 17)
	GUICtrlSetResizing($CheckboxOtherStart, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxOtherStart, "CheckboxOtherStartClick")
	Global $CheckboxOtherTray = GUICtrlCreateCheckbox($sLang_NoTray, 294, 89, -1, 17)
	GUICtrlSetResizing($CheckboxOtherTray, $GUI_DOCKTOP + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxOtherTray, "CheckboxOtherTrayClick")
	Local $GroupOtherAddFav = GUICtrlCreateGroup($sLang_AddFavorite, 100, 120, 370, 153)
	GUICtrlSetResizing($GroupOtherAddFav, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	Global $CheckboxOtherAddFavAtTop = GUICtrlCreateCheckbox($sLang_AddFavAtTop, 124, 145, -1, 17)
	GUICtrlSetResizing($CheckboxOtherAddFavAtTop, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxOtherAddFavAtTop, "CheckboxOtherAddFavAtTopClick")
	Global $CheckboxOtherAddFavPath = GUICtrlCreateCheckbox($sLang_AddFavCheck, 124, 169, -1, 17)
	GUICtrlSetResizing($CheckboxOtherAddFavPath, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxOtherAddFavPath, "CheckboxOtherAddFavPathClick")
	Global $CheckboxOtherAddFavSkipGui = GUICtrlCreateCheckbox($sLang_AddFavSkipGUI, 124, 193, -1, 17)
	GUICtrlSetResizing($CheckboxOtherAddFavSkipGui, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxOtherAddFavSkipGui, "CheckboxOtherAddFavSkipGuiClick")
	Global $CheckboxOtherAddFavApp = GUICtrlCreateCheckbox($sLang_AddFavApp, 124, 217, -1, 17)
	GUICtrlSetResizing($CheckboxOtherAddFavApp, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxOtherAddFavApp, "CheckboxOtherAddFavAppClick")
	Global $CheckboxOtherAddFavCmd = GUICtrlCreateCheckbox($sLang_AddFavAppCmd, 310, 217, -1, 17)
	GUICtrlSetResizing($CheckboxOtherAddFavCmd, $GUI_DOCKTOP + $GUI_DOCKHCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxOtherAddFavCmd, "CheckboxOtherAddFavCmdClick")
	Global $CheckboxOtherAddFavLnk = GUICtrlCreateCheckbox($sLang_AddFavLnk, 124, 241, -1, 17)
	GUICtrlSetResizing($CheckboxOtherAddFavLnk, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxOtherAddFavLnk, "CheckboxOtherAddFavLnkClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $LabelOtherExplorer = GUICtrlCreateLabel($sLang_FileManager, 36, 292, -1, 17)
	GUICtrlSetResizing($LabelOtherExplorer, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelOtherExplorer, "LabelOtherExplorerClick")
	Global $InputOtherExplorer = GUICtrlCreateInput("", 200, 288, 300, 21)
	GUICtrlSetResizing($InputOtherExplorer, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputOtherExplorer, "InputOtherExplorerChange")
	Local $ButtonOtherExplorer = GUICtrlCreateButton("...", 508, 288, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonOtherExplorer, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonOtherExplorer, "ButtonOtherExplorerClick")
	Local $LabelOtherBrowser = GUICtrlCreateLabel($sLang_Browser, 36, 324, -1, 17)
	GUICtrlSetResizing($LabelOtherBrowser, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelOtherBrowser, "LabelOtherBrowserClick")
	Global $InputOtherBrowser = GUICtrlCreateInput("", 200, 320, 300, 21)
	GUICtrlSetResizing($InputOtherBrowser, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputOtherBrowser, "InputOtherBrowserChange")
	Local $ButtonOtherBrowser = GUICtrlCreateButton("...", 508, 320, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonOtherBrowser, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonOtherBrowser, "ButtonOtherBrowserClick")
	Global $CheckboxOtherSearch = GUICtrlCreateCheckbox($sLang_SearchSel, 36, 353, -1, 17)
	GUICtrlSetResizing($CheckboxOtherSearch, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($CheckboxOtherSearch, "CheckboxOtherSearchClick")
	Global $InputOtherSearch = GUICtrlCreateInput("", 200, 352, 300, 21)
	GUICtrlSetResizing($InputOtherSearch, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($InputOtherSearch, "InputOtherSearchChange")
	Local $LabelOtherLoading = GUICtrlCreateLabel($sLang_LoadingTip, 36, 388, -1, 17)
	GUICtrlSetResizing($LabelOtherLoading, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelOtherLoading, "LabelOtherLoadingClick")
	Global $ComboOtherLoading = GUICtrlCreateCombo("", 200, 384, 300, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData($ComboOtherLoading, $sLang_LoadingTipNo & "|" & $sLang_LoadingTipTool & "|" & $sLang_LoadingTipTray, $sLang_LoadingTipNo)
	GUICtrlSetResizing($ComboOtherLoading, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboOtherLoading, "ComboOtherLoadingChange")
	; Local $LabelOtherTray = GUICtrlCreateLabel($sLang_TrayIconClick, 36, 420, -1, 17)
	; GUICtrlSetResizing($LabelOtherTray, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelOtherTray, "LabelOtherTrayClick")
	; Global $ComboOtherTray = GUICtrlCreateCombo("", 164, 416, 176, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
	; GUICtrlSetData($ComboOtherTray, $sLang_ShowMenu & " 1|" & $sLang_ShowMenu & " 1.5|" & $sLang_ShowMenu & " 2", $sLang_ShowMenu & " 1")
	; GUICtrlSetResizing($ComboOtherTray, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($ComboOtherTray, "ComboOtherTrayChange")
	Global $ButtonOtherLoading = GUICtrlCreateButton("...", 508, 384, 21, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonOtherLoading, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonOtherLoading, "ButtonOtherLoadingClick")
	GUICtrlSetTip($CheckboxOtherAddFavPath, $sLang_TipOtherAddFavPath)
	GUICtrlSetTip($CheckboxOtherAddFavSkipGui, $sLang_TipOtherAddFavSkipGui)
	GUICtrlSetTip($CheckboxOtherAddFavApp, $sLang_TipOtherAddFavApp)
	GUICtrlSetTip($CheckboxOtherAddFavCmd, $sLang_TipOtherAddFavCmd)
	GUICtrlSetTip($CheckboxOtherAddFavLnk, $sLang_TipOtherAddFavLnk)
	GUICtrlSetTip($InputOtherExplorer, $sLang_TipOtherExplorer)
	GUICtrlSetTip($InputOtherBrowser, $sLang_TipOtherBrowser)
	GUICtrlSetTip($CheckboxOtherSearch, $sLang_TipOtherSearch)
EndFunc
Func TabOtherSet()
	ComboOtherLangCreate()
	GUICtrlSetState($CheckboxOtherStart, $fStartWithWin)
	GUICtrlSetState($CheckboxOtherTray, $fNoTray)
	GUICtrlSetState($CheckboxOtherAddFavAtTop, $fAddFavAtTop)
	GUICtrlSetState($CheckboxOtherAddFavPath, $fAddFavCheck)
	GUICtrlSetState($CheckboxOtherAddFavSkipGui, $fAddFavSkipGui)
	GUICtrlSetState($CheckboxOtherAddFavApp, $fAddFavApp)
	GUICtrlSetState($CheckboxOtherAddFavCmd, $fAddFavAppCmd)
	GUICtrlSetState($CheckboxOtherAddFavLnk, $fAddFavLnk)
	GUICtrlSetState($CheckboxOtherSearch, $fSearchSel)
	CheckboxOtherAddFavAppClick()
	CheckboxOtherSearchClick()
	GUICtrlSetData($InputOtherExplorer, $sFileManager)
	GUICtrlSetData($InputOtherBrowser, $sBrowser)
	GUICtrlSetData($InputOtherSearch, $sSearchSelUrl)
	If $iLoadingTip = 0 Then GUICtrlSetData($ComboOtherLoading, $sLang_LoadingTipNo)
	If $iLoadingTip = 1 Then GUICtrlSetData($ComboOtherLoading, $sLang_LoadingTipTool)
	If $iLoadingTip = 2 Then GUICtrlSetData($ComboOtherLoading, $sLang_LoadingTipTray)
	; GUICtrlSetData($ComboOtherTray, $sLang_ShowMenu & " " & $iTrayIconClick)
	MenuOtherLoadingCreate()
EndFunc
Func TabOtherGet()
	$sLanguage = $asLangList[_GUICtrlComboBox_GetCurSel($ComboOtherLang)][0]
	$fStartWithWin = BitAND(GUICtrlRead($CheckboxOtherStart), $GUI_CHECKED)
	$fNoTray = BitAND(GUICtrlRead($CheckboxOtherTray), $GUI_CHECKED)
	$fAddFavAtTop = BitAND(GUICtrlRead($CheckboxOtherAddFavAtTop), $GUI_CHECKED)
	$fAddFavCheck = BitAND(GUICtrlRead($CheckboxOtherAddFavPath), $GUI_CHECKED)
	$fAddFavSkipGui = BitAND(GUICtrlRead($CheckboxOtherAddFavSkipGui), $GUI_CHECKED)
	$fAddFavApp = BitAND(GUICtrlRead($CheckboxOtherAddFavApp), $GUI_CHECKED)
	$fAddFavAppCmd = BitAND(GUICtrlRead($CheckboxOtherAddFavCmd), $GUI_CHECKED)
	$fAddFavLnk = BitAND(GUICtrlRead($CheckboxOtherAddFavLnk), $GUI_CHECKED)
	$sFileManager = GUICtrlRead($InputOtherExplorer)
	$sBrowser = GUICtrlRead($InputOtherBrowser)
	$fSearchSel = BitAND(GUICtrlRead($CheckboxOtherSearch), $GUI_CHECKED)
	$sSearchSelUrl = GUICtrlRead($InputOtherSearch)
	$iLoadingTip = _GUICtrlComboBox_GetCurSel($ComboOtherLoading)
	; $iTrayIconClick = StringReplace(GUICtrlRead($ComboOtherTray), $sLang_ShowMenu & " ", "")
	; msg( _
	; "sLanguage      " & $sLanguage      & @LF & _
	; "fStartWithWin  " & $fStartWithWin  & @LF & _
	; "fNoTray        " & $fNoTray        & @LF & _
	; "fAddFavAtTop   " & $fAddFavAtTop   & @LF & _
	; "fAddFavCheck   " & $fAddFavCheck   & @LF & _
	; "fAddFavSkipGui " & $fAddFavSkipGui & @LF & _
	; "fAddFavApp     " & $fAddFavApp     & @LF & _
	; "fAddFavAppCmd  " & $fAddFavAppCmd  & @LF & _
	; "fAddFavLnk     " & $fAddFavLnk     & @LF & _
	; "fSearchSel     " & $fSearchSel     & @LF & _
	; "iTrayIconClick " & $iTrayIconClick & @LF & _
	; "iLoadingTip    " & $iLoadingTip    & @LF & _
	; "sFileManager   " & $sFileManager   & @LF & _
	; "sBrowser       " & $sBrowser       & @LF & _
	; "sSearchSelUrl  " & $sSearchSelUrl)
	$iLoadingTipFor = 0
	If BitAND(GUICtrlRead($MenuOtherLoadingM), $GUI_CHECKED) <> 0 Then $iLoadingTipFor = $iLoadingTipFor + 1
	If BitAND(GUICtrlRead($MenuOtherLoadingT), $GUI_CHECKED) <> 0 Then $iLoadingTipFor = $iLoadingTipFor + 2
	If BitAND(GUICtrlRead($MenuOtherLoadingR), $GUI_CHECKED) <> 0 Then $iLoadingTipFor = $iLoadingTipFor + 4
	If BitAND(GUICtrlRead($MenuOtherLoadingD), $GUI_CHECKED) <> 0 Then $iLoadingTipFor = $iLoadingTipFor + 8
	If BitAND(GUICtrlRead($MenuOtherLoadingC), $GUI_CHECKED) <> 0 Then $iLoadingTipFor = $iLoadingTipFor + 16
EndFunc
Func ComboOtherLangCreate()
	Local $aList[1]
	GetLanguageList("", $aList)
	Global $asLangList[$aList[0] + 1][2]
	$asLangList[0][0] = ""
	$asLangList[0][1] = "English"
	Local $sLanguageList = "English"
	Local $iCurSel = -1
	For $i = 1 To $aList[0]
		$asLangList[$i][0] = $aList[$i]
		If $asLangList[$i][0] = $sLanguage Then $iCurSel = $i
		$asLangList[$i][1] = IniRead(@ScriptDir & "\" & $asLangList[$i][0], "Info", "LanguageName", $asLangList[$i][0])
		$sLanguageList &= "|" & $asLangList[$i][1]
	Next
	GUICtrlSetData($ComboOtherLang, $sLanguageList)
	If $iCurSel = -1 Then
		If $sLanguage = "" Then
			$iCurSel = 0
		Else
			Local $i = UBound($asLangList)
			ReDim $asLangList[$i + 1][2]
			$asLangList[$i][0] = $sLanguage
			$asLangList[$i][1] = IniRead($sLanguage, "Info", "LanguageName", $asLangList[$i][0])
			$iCurSel = _GUICtrlComboBox_AddString(GUICtrlGetHandle($ComboOtherLang), $asLangList[$i][1])
		EndIf
	EndIf
	_GUICtrlComboBox_SetCurSel($ComboOtherLang, $iCurSel)
EndFunc
Func GetLanguageList($sPath, ByRef $aList) ; $sPath includes trailing "\"
	Local $hSearch = FileFindFirstFile(@ScriptDir & "\" & $sPath & "*.*")
	Local $sFile
	While 1
		$sFile = FileFindNextFile($hSearch)
		If @error Then ExitLoop
		If StringInStr(FileGetAttrib(@ScriptDir & "\" & $sPath & $sFile), "D") Then GetLanguageList($sPath & $sFile & "\", $aList)
		If StringRight($sFile, 6) = ".fmlng" Then
			If UBound($aList) <= $aList[0] + 1 Then ReDim $aList[UBound($aList) * 2]
			$aList[$aList[0] + 1] = $sPath & $sFile
			$aList[0] += 1
		EndIf
	WEnd
	FileClose($hSearch)
	If $aList[0] <> 0 Then ReDim $aList[$aList[0] + 1] ; Trim unused slots
EndFunc
Func MenuOtherLoadingCreate()
	Local $Dummy = GUICtrlCreateDummy()
	Global $MenuOtherLoading = GUICtrlCreateContextMenu($Dummy)
	Global $MenuOtherLoadingM = MenuOtherLoadingAddItem($sLang_MainMenu, $MenuOtherLoading, $fLoadingTipForM)
	Global $MenuOtherLoadingT = MenuOtherLoadingAddItem($sLang_TempMenu, $MenuOtherLoading, $fLoadingTipForT)
	Global $MenuOtherLoadingR = MenuOtherLoadingAddItem($sLang_RecentMenu, $MenuOtherLoading, $fLoadingTipForR)
	Global $MenuOtherLoadingD = MenuOtherLoadingAddItem($sLang_DriveMenu, $MenuOtherLoading, $fLoadingTipForD)
	Global $MenuOtherLoadingC = MenuOtherLoadingAddItem($sLang_TCMenu, $MenuOtherLoading, $fLoadingTipForC)
EndFunc
Func MenuOtherLoadingAddItem($sName, $iParent, $fChecked)
	Local $iItem = GUICtrlCreateMenuItem($sName, $iParent)
	If $fChecked <> 0 Then GUICtrlSetState($iItem, $GUI_CHECKED)
	GUICtrlSetOnEvent($iItem, "MenuOtherLoadingClick")
	Return $iItem
EndFunc
Func MenuOtherLoadingClick()
	Local $iState = GUICtrlRead(@GUI_CtrlId)
	If BitAND($iState, $GUI_CHECKED) <> 0 Then ; checked
		GUICtrlSetState(@GUI_CtrlId, $GUI_UNCHECKED)
	Else
		GUICtrlSetState(@GUI_CtrlId, $GUI_CHECKED)
	EndIf
EndFunc

Func ButtonOtherLangClick()
	Local $sPath = FileOpenDialog($sLang_SelectFile, @ScriptDir, "(*.fmlng)", 1)
	If $sPath = "" Then Return
	Local $i = UBound($asLangList)
	ReDim $asLangList[$i + 1][2]
	$asLangList[$i][0] = $sPath
	$asLangList[$i][1] = IniRead($sPath, "Info", "LanguageName", $asLangList[$i][0])
	_GUICtrlComboBox_SetCurSel($ComboOtherLang, _GUICtrlComboBox_AddString(GUICtrlGetHandle($ComboOtherLang), $asLangList[$i][1]))
EndFunc
Func ButtonOtherExplorerClick()
	Local $sPath = FileOpenDialog($sLang_SelectFile, @ProgramFilesDir, "(*.exe)", 1)
	If $sPath = "" Then Return
	GUICtrlSetData($InputOtherExplorer, $sPath)
EndFunc
Func ButtonOtherBrowserClick()
	Local $sPath = FileOpenDialog($sLang_SelectFile, @ProgramFilesDir, "(*.exe)", 1)
	If $sPath = "" Then Return
	GUICtrlSetData($InputOtherBrowser, $sPath)
EndFunc
Func ButtonOtherLoadingClick()
	ShowButtonMenu($hGuiOptions, $ButtonOtherLoading, $MenuOtherLoading)
EndFunc
Func CheckboxOtherAddFavAppClick()
	Local $iState = GUICtrlRead($CheckboxOtherAddFavApp)
	If $iState = $GUI_CHECKED Then
		GUICtrlSetState($CheckboxOtherAddFavCmd, $GUI_ENABLE)
	ElseIf $iState = $GUI_UNCHECKED Then
		GUICtrlSetState($CheckboxOtherAddFavCmd, $GUI_DISABLE)
	EndIf
EndFunc
Func CheckboxOtherSearchClick()
	Local $iState = GUICtrlRead($CheckboxOtherSearch)
	If $iState = $GUI_CHECKED Then
		GUICtrlSetState($InputOtherSearch, $GUI_ENABLE)
	ElseIf $iState = $GUI_UNCHECKED Then
		GUICtrlSetState($InputOtherSearch, $GUI_DISABLE)
	EndIf
EndFunc
#endregion Other

#region About
Func TabAboutCreate()
	Local $TabSheetAbout = GUICtrlCreateTabItem($sLang_About)
	Global $IconAbout = GUICtrlCreateIcon($sFolderMenuExe, -1, 150, 152, 32, 32, BitOR($SS_NOTIFY, $WS_GROUP))
	GUICtrlSetResizing($IconAbout, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($IconAbout, "IconAboutClick")
	Global $LabelAboutFM = GUICtrlCreateLabel("FolderMenu3 EX", 200, 156, 200, 31)
	GUICtrlSetFont($LabelAboutFM, 18, 500, 0, "Tahoma")
	GUICtrlSetResizing($LabelAboutFM, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelAboutFM, "LabelAboutFMClick")
	Local $LabelAboutMe = GUICtrlCreateLabel($sLang_CopyRight, 190, 184, 92, 17)
	GUICtrlSetResizing($LabelAboutMe, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelAboutMe, "LabelAboutMeClick")
	If @AutoItX64 Then
		Local $LabelAboutVer = GUICtrlCreateLabel("v3.1.2.2 EX " & $iCurrentVer & " (64-Bit)", 286, 184, -1, 17)
	Else
		Local $LabelAboutVer = GUICtrlCreateLabel("v3.1.2.2 EX " & $iCurrentVer, 286, 184, -1, 17)
	EndIf
	GUICtrlSetResizing($LabelAboutVer, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelAboutVer, "LabelAboutVerClick")
	Local $ButtonAboutSite = GUICtrlCreateButton($sLang_Website, 200, 216, -1, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonAboutSite, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonAboutSite, "ButtonAboutSiteClick")
	Global $ButtonAboutCheck = GUICtrlCreateButton($sLang_CheckVer, 200, 248, -1, 21, $WS_GROUP)
	GUICtrlSetResizing($ButtonAboutCheck, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlSetOnEvent($ButtonAboutCheck, "ButtonAboutCheckClick")
	Global $CheckboxAboutCheck = GUICtrlCreateCheckbox($sLang_CheckVerOnStart, 200, 282, -1, 17)
	GUICtrlSetResizing($CheckboxAboutCheck, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($CheckboxAboutCheck, "CheckboxAboutCheckClick")
	Local $LabelAboutTranslate = GUICtrlCreateLabel($sLang_Translate, 200, 312, -1, -1)
	GUICtrlSetResizing($LabelAboutTranslate, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelAboutTranslate, "LabelAboutTranslateClick")
	Local $LabelAboutEX = GUICtrlCreateLabel("FolderMenu3 EX By Silvernine0S", 200, 325, -1, -1)
	GUICtrlSetResizing($LabelAboutEX, $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	; GUICtrlSetOnEvent($LabelAboutTranslate, "LabelAboutTranslateClick")
EndFunc
Func TabAboutSet()
	GUICtrlSetState($CheckboxAboutCheck, $fCheckVersion)
EndFunc
Func TabAboutGet()
	$fCheckVersion = BitAND(GUICtrlRead($CheckboxAboutCheck), $GUI_CHECKED)
	; msg($fCheckVersion)
EndFunc
Func IconAboutClick()
	Local $arPos = ControlGetPos($hGuiOptions, "", $IconAbout), $d = 16, $x
	For $i = 0 To $d
		GUICtrlSetPos($IconAbout, $arPos[0] - $i, $arPos[1] - $i, 32 + $i * 2, 32 + $i * 2)
		Sleep(50)
	Next
	Sleep(250)
	For $i = $d To 0 Step -2
		GUICtrlSetPos($IconAbout, $arPos[0] - $i, $arPos[1] - $i, 32 + $i * 2, 32 + $i * 2)
		Sleep(10)
	Next
	For $i = -8 To $d Step 4
		$x = ($d - Abs($i * 2 - $d)) / 4
		GUICtrlSetPos($IconAbout, $arPos[0] - $x / 2, $arPos[1] - $x / 2, 32 + $x, 32 + $x)
		Sleep(20)
	Next
	; For $i = 1 to $d
	; $x = ($d-abs($i*2-$d))
	; GUICtrlSetPos($IconAbout, $arPos[0]+$x/2, $arPos[1]+$x/2, 32-$x, 32-$x)
	; Sleep(20)
	; Next
	; For $i = 1 to $d
	; $x = ($d-abs($i*2-$d))
	; GUICtrlSetPos($IconAbout, $arPos[0], $arPos[1]-$x/2, 32, 32)
	; Sleep(20)
	; Next
	; For $i = 1 to $d
	; $x = ($d-abs($i*2-$d))
	; GUICtrlSetPos($IconAbout, $arPos[0]-$x/2, $arPos[1], 32, 32)
	; Sleep(20)
	; Next
	; For $i = 1 to $d
	; $x = ($d-abs($i*2-$d))
	; GUICtrlSetPos($IconAbout, $arPos[0], $arPos[1]+$x/2, 32, 32)
	; Sleep(20)
	; Next
	; For $i = 1 to $d
	; $x = ($d-abs($i*2-$d))
	; GUICtrlSetPos($IconAbout, $arPos[0]+$x/2, $arPos[1], 32, 32)
	; Sleep(20)
	; Next
	; Local $pi = 3.14159265358979
	; For $i = 1 to $d
	; GUICtrlSetPos($IconAbout, $arPos[0]+4*cos($i*$pi/8)-4, $arPos[1]+4*sin($i*$pi/8)+1, 32, 32)
	; Sleep(20)
	; Next
	; For $i = 1 to $d
	; GUICtrlSetPos($IconAbout, $arPos[0]-4*cos(-$i*$pi/8)+4, $arPos[1]-4*sin(-$i*$pi/8)+1, 32, 32)
	; Sleep(20)
	; Next
	; For $i = 1 to $d
	; GUICtrlSetPos($IconAbout, $arPos[0]+4*cos(-$i*$pi/8)-4, $arPos[1]+4*sin(-$i*$pi/8), 32, 32)
	; Sleep(20)
	; Next
	; For $i = 1 to $d
	; GUICtrlSetPos($IconAbout, $arPos[0]-4*cos($i*$pi/8)+4, $arPos[1]-4*sin($i*$pi/8), 32, 32)
	; Sleep(20)
	; Next
EndFunc
Func ButtonAboutCheckClick()
	GUICtrlSetData($ButtonAboutCheck, "...")
	CheckVersion()
	GUICtrlSetData($ButtonAboutCheck, $sLang_CheckVer)
EndFunc
Func ButtonAboutSiteClick()
	_GoWebsite()
EndFunc
#endregion About

#region Main
Func DrawDragImage(ByRef $hControl, ByRef $aDrag)
	; Draw drag image by Gary Frost (gafrost) (?)
	Local $tPoint, $hDC
	$hDC = _WinAPI_GetWindowDC($hControl)
	$tPoint = _WinAPI_GetMousePos(True, $hControl)
	_WinAPI_InvalidateRect($hControl)
	_GUIImageList_Draw($aDrag, 0, $hDC, DllStructGetData($tPoint, "X") - 10, DllStructGetData($tPoint, "Y") - 8)
	_WinAPI_ReleaseDC($hControl, $hDC)
EndFunc
Func TreeItemFromPoint($hWnd)
	; Returns handle of tree item under mouse
	Local $tMPos = _WinAPI_GetMousePos(True, $hWnd)
	Return _GUICtrlTreeView_HitTestItem($hWnd, DllStructGetData($tMPos, 1), DllStructGetData($tMPos, 2))
EndFunc
Func OptionsMouseMove()
	Local $hTreeViewFav = GUICtrlGetHandle($TreeViewFav)
	If $fTreeDrag = False Then Return
	Local $tPoint = DllStructCreate("int;int")
	DllStructSetData($tPoint, 1, MouseGetPos(0))
	DllStructSetData($tPoint, 2, MouseGetPos(1))
	Local $hWndPoint = _WinAPI_WindowFromPoint($tPoint)
	;cancel drag in progress and cleanup if moved outside treeview:
	If $hWndPoint <> $hTreeViewFav Then
		$fTreeDrag = False
		_WinAPI_InvalidateRect($hTreeViewFav)
		_GUIImageList_Destroy($hTreeDragImage) ;delete drag image
		_GUICtrlTreeView_SetDropTarget($hTreeViewFav, 0) ;remove DropTarget
		_GUICtrlTreeView_SetInsertMark($hTreeViewFav, 0, 0) ;remove InsertMark
		Return
	EndIf
	Local $hHoverItem = TreeItemFromPoint($hTreeViewFav)
	If $hHoverItem <> 0 Then
		Local $aRect = _GUICtrlTreeView_DisplayRect($hTreeViewFav, $hHoverItem)
		Local $iItemHeight = $aRect[3] - $aRect[1]
		Local $iTreeY = _WinAPI_GetMousePosY(True, $hTreeViewFav)
		Local $iHoverItem = TreeViewFavGetItemID($hHoverItem)
		If $iHoverItem = 0 Then
			_GUICtrlTreeView_SetDropTarget($hTreeViewFav, 0) ;remove DropTarget
			_GUICtrlTreeView_SetInsertMark($hTreeViewFav, 0, 0) ;remove InsertMark
		ElseIf $iHoverItem = $FavItemRoot Then
			_GUICtrlTreeView_SetDropTarget($hTreeViewFav, $hHoverItem) ;add DropTarget
			_GUICtrlTreeView_SetInsertMark($hTreeViewFav, 0, 0) ;remove InsertMark
			$iTreeMovePos = 0
		ElseIf $FavItemType[$iHoverItem - 10000] = "Menu" Then
			Switch $iTreeY
				Case $aRect[1] To $aRect[1] + Int($iItemHeight / 3)
					_GUICtrlTreeView_SetDropTarget($hTreeViewFav, 0) ;remove DropTarget
					_GUICtrlTreeView_SetInsertMark($hTreeViewFav, $hHoverItem, 0) ;add InsertMark before item
					$iTreeMovePos = -1
				Case 1 + $aRect[1] + Int($iItemHeight / 3) To $aRect[1] + Int($iItemHeight * 2 / 3)
					_GUICtrlTreeView_SetDropTarget($hTreeViewFav, $hHoverItem) ;add DropTarget
					_GUICtrlTreeView_SetInsertMark($hTreeViewFav, 0, 0) ;remove InsertMark
					$iTreeMovePos = 0
				Case 1 + $aRect[1] + Int($iItemHeight * 2 / 3) To $aRect[3]
					_GUICtrlTreeView_SetDropTarget($hTreeViewFav, 0) ;remove DropTarget
					_GUICtrlTreeView_SetInsertMark($hTreeViewFav, $hHoverItem, 1) ;add InsertMark after item
					$iTreeMovePos = 1
			EndSwitch
		ElseIf $FavItemType[$iHoverItem - 10000] = "ItemSetting" Then
			_GUICtrlTreeView_SetDropTarget($hTreeViewFav, 0) ;remove DropTarget
			_GUICtrlTreeView_SetInsertMark($hTreeViewFav, 0, 0) ;remove InsertMark
		Else
			Switch $iTreeY
				Case $aRect[1] To $aRect[1] + Int($iItemHeight / 2)
					_GUICtrlTreeView_SetDropTarget($hTreeViewFav, 0) ;remove DropTarget
					_GUICtrlTreeView_SetInsertMark($hTreeViewFav, $hHoverItem, 0) ;add InsertMark before item
					$iTreeMovePos = -1
				Case 1 + $aRect[1] + Int($iItemHeight / 2) To $aRect[3]
					_GUICtrlTreeView_SetDropTarget($hTreeViewFav, 0) ;remove DropTarget
					_GUICtrlTreeView_SetInsertMark($hTreeViewFav, $hHoverItem, 1) ;add InsertMark after item
					$iTreeMovePos = 1
			EndSwitch
		EndIf
	EndIf
	DrawDragImage($hTreeViewFav, $hTreeDragImage)
EndFunc
Func OptionsPrimaryUp()
	Local $hTreeViewFav = GUICtrlGetHandle($TreeViewFav)
	If $fTreeDrag Then
		_WinAPI_InvalidateRect($hTreeViewFav)
		$fTreeDrag = False
		_GUIImageList_Destroy($hTreeDragImage) ;delete drag image
		_GUICtrlTreeView_SetDropTarget($hTreeViewFav, 0) ;remove DropTarget
		_GUICtrlTreeView_SetInsertMark($hTreeViewFav, 0) ;remove InsertMark
		Local $hHoverItem = TreeItemFromPoint($hTreeViewFav)
		If $hHoverItem = $hTreeDragItem Then Return
		Local $iHoverItem = TreeViewFavGetItemID($hHoverItem)
		If $iHoverItem = 0 Then Return
		If $FavItemType[$iHoverItem - 10000] = "ItemSetting" Then Return
		If $hHoverItem = $hTreeDragItem Then Return
		;move item
		_GUICtrlTreeView_BeginUpdate($TreeViewFav)
		Local $hItem = TreeViewFavCopyItem($hTreeDragItem, $hHoverItem, $iTreeMovePos)
		If $hItem <> 0 Then
			_GUICtrlTreeView_SelectItem($TreeViewFav, $hItem)
			_GUICtrlTreeView_Delete($TreeViewFav, $hTreeDragItem)
		EndIf
		_GUICtrlTreeView_EndUpdate($TreeViewFav)
		If $hItem <> 0 Then _GUICtrlTreeView_EnsureVisible($TreeViewFav, $hItem)
	EndIf
EndFunc
Func OptionsDropped()
	If @GUI_DropId = $TreeViewFav Then
		_GUICtrlTreeView_BeginUpdate($TreeViewFav)
		$fTreeViewFavUpdate = True
		For $i = 1 To $aDropFiles[0]
			If $fAddFavLnk = 1 Then
				Local $aLink = FileGetShortcut($aDropFiles[$i])
				If Not @error And $aLink[0] <> "" Then $aDropFiles[$i] = $aLink[0]
			EndIf
			TreeViewFavAddPath($aDropFiles[$i])
		Next
		$fTreeViewFavUpdate = False
		_GUICtrlTreeView_EndUpdate($TreeViewFav)
		_GUICtrlTreeView_EnsureVisible($TreeViewFav, _GUICtrlTreeView_GetSelection($TreeViewFav))
		TreeView_ItemChanged()
	EndIf
	_WinAPI_DragFinish($hDrop)
EndFunc
Func OptionsResized()
	Local $arPos = ControlGetPos($hGuiOptions, "", $LabelAboutFM)
	GUICtrlSetPos($IconAbout, $arPos[0] - 40, $arPos[1] - 4)
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
EndFunc
Func OptionsClose()
	_GUICtrlReleaseHotKeyInput()
	$fGuiOptionsMax = BitAND(WinGetState($hGuiOptions), 32)
	If $fGuiOptionsMax = 0 Then $aGuiOptionsPos = WinGetPos($hGuiOptions)
	GUIDelete($hGuiOptions)
	$hGuiOptions = 0
	_XMLDeleteNode("/FolderMenu/Settings/GUI")
	_XMLCreateChildNode("/FolderMenu/Settings", "GUI")
	WriteConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosX", $aGuiOptionsPos[0])
	WriteConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosY", $aGuiOptionsPos[1])
	WriteConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosW", $aGuiOptionsPos[2])
	WriteConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosH", $aGuiOptionsPos[3])
	WriteConfigSetting("/FolderMenu/Settings/GUI", "OptionsPosM", $fGuiOptionsMax)
	_XMLTransform()
	_XMLSaveDoc("", 1)
EndFunc
Func ButtonEditClick()
	If MsgBox($MB_YESNO + $MB_ICONQUESTION, "FolderMenu3 EX", $sLang_SaveChange) = $IDYES Then
		ButtonOKClick()
	Else
		ButtonCancelClick()
	EndIf
	MsgBox($MB_ICONASTERISK, "FolderMenu3 EX", $sLang_EditReload)
	_Edit()
EndFunc
Func ButtonOKClick()
	_HotKeyDisable()
	TabFavGet()
	TabAppGet()
	TabKeyGet()
	TabIconGet()
	TabMenuGet()
	TabOtherGet()
	TabAboutGet()
	WriteConfig()
	OptionsClose()
	SetConfig()
	ReadLanguage()
	CreateTrayMenu()
	CreateMainMenu()
	If $iRecentMenuID <> 0 Then CreateRecentMenu($iRecentMenuID)
	If $iExplorerMenuID <> 0 Then CreateExplorerMenu($iExplorerMenuID)
	If $iDriveMenuID <> 0 Then CreateDriveMenu($iDriveMenuID)
	If $iToolMenuID <> 0 Then CreateToolMenu($iToolMenuID)
	If $iSVSMenuID <> 0 Then CreateSVSMenu($iSVSMenuID)
	If $iTCMenuID <> 0 Then CreateTCMenu($iTCMenuID)
	SetHotkey()
	If $sErrorMsg <> "" Then
		TrayTip("!", $sErrorMsg, 5, 1)
		$sErrorMsg = ""
	EndIf
	_HotKeyEnable()
EndFunc
Func ButtonCancelClick()
	OptionsClose()
EndFunc
Func TabRight()
	Local $iIndex = GUICtrlRead($Tab1) + 1
	If $iIndex >= 7 Then $iIndex = 0
	GUICtrlSendMsg($Tab1, $TCM_SETCURFOCUS, $iIndex, 0)
EndFunc
Func TabLeft()
	Local $iIndex = GUICtrlRead($Tab1) - 1
	If $iIndex < 0 Then $iIndex = 7 - 1
	GUICtrlSendMsg($Tab1, $TCM_SETCURFOCUS, $iIndex, 0)
EndFunc
Func ShiftUp()
	If GUICtrlRead($Tab1, 1) <> $TabSheetFav Then Return

	Local $iItem = GUICtrlRead($TreeViewFav)
	If $iItem = 0 Or $iItem = $FavItemRoot Then Return
	If $FavItemType[$iItem - 10000] = "ItemSetting" Then Return

	Local $iPos = -1
	Local $hItem = $FavItemHandle[$iItem - 10000]
	Local $hDest = _GUICtrlTreeView_GetPrevSibling($TreeViewFav, $hItem)
	If $hDest = 0 Then ; no prev sibling, move up out of menu
		$hDest = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hItem) ; before parent
		If $hDest = $FavItemHandle[$FavItemRoot - 10000] Then Return ; don't move out of root
	Else
		If _GUICtrlTreeView_GetExpanded($TreeViewFav, $hDest) Then ; move up into menu if the menu is expanded
			Local $iDest = TreeViewFavGetItemID($hDest)
			If $iDest = 0 Then Return
			If $FavItemType[$iDest - 10000] = "Menu" Then ; prevent move into itemsetting
				$hDest = _GUICtrlTreeView_GetLastChild($TreeViewFav, $hDest) ; after last child
				$iPos = 1
			EndIf
		EndIf
	EndIf

	_GUICtrlTreeView_BeginUpdate($TreeViewFav)
	Local $hNew = TreeViewFavCopyItem($hItem, $hDest, $iPos)
	If $hNew <> 0 Then
		_GUICtrlTreeView_SelectItem($TreeViewFav, $hNew)
		_GUICtrlTreeView_Delete($TreeViewFav, $hItem)
	EndIf
	_GUICtrlTreeView_EndUpdate($TreeViewFav)
	If $hNew <> 0 Then _GUICtrlTreeView_EnsureVisible($TreeViewFav, $hNew)
EndFunc
Func ShiftDown()
	If GUICtrlRead($Tab1, 1) <> $TabSheetFav Then Return

	Local $iItem = GUICtrlRead($TreeViewFav)
	If $iItem = 0 Or $iItem = $FavItemRoot Then Return
	If $FavItemType[$iItem - 10000] = "ItemSetting" Then Return

	Local $iPos = 1
	Local $hItem = $FavItemHandle[$iItem - 10000]
	Local $hDest = _GUICtrlTreeView_GetNextSibling($TreeViewFav, $hItem)
	If $hDest = 0 Then ; no next sibling, move down out of menu
		$hDest = _GUICtrlTreeView_GetParentHandle($TreeViewFav, $hItem) ; after parent
		If $hDest = $FavItemHandle[$FavItemRoot - 10000] Then Return ; don't move out of root
	Else
		If _GUICtrlTreeView_GetExpanded($TreeViewFav, $hDest) Then ; move down into menu if the menu is expanded
			Local $iDest = TreeViewFavGetItemID($hDest)
			If $iDest = 0 Then Return
			If $FavItemType[$iDest - 10000] = "Menu" Then ; prevent move into itemsetting
				$hDest = _GUICtrlTreeView_GetFirstChild($TreeViewFav, $hDest) ; before first child
				$iPos = -1
			EndIf
		EndIf
	EndIf

	_GUICtrlTreeView_BeginUpdate($TreeViewFav)
	Local $hNew = TreeViewFavCopyItem($hItem, $hDest, $iPos)
	If $hNew <> 0 Then
		_GUICtrlTreeView_SelectItem($TreeViewFav, $hNew)
		_GUICtrlTreeView_Delete($TreeViewFav, $hItem)
	EndIf
	_GUICtrlTreeView_EndUpdate($TreeViewFav)
	If $hNew <> 0 Then _GUICtrlTreeView_EnsureVisible($TreeViewFav, $hNew)
EndFunc
#endregion Main

#region WriteConfig
Func WriteConfig()
	_XMLDeleteNode("/FolderMenu/Settings")
	_XMLCreateChildNode("/FolderMenu", "Settings")
	WriteConfigApp()
	WriteConfigKey()
	WriteConfigIcon()
	WriteConfigMenu()
	WriteConfigOther()
	_XMLTransform()
	_XMLSaveDoc("", 1)
EndFunc
Func WriteConfigApp()
	_XMLCreateChildNode("/FolderMenu/Settings", "Applications")
	_XMLCreateChildWAttr("/FolderMenu/Settings/Applications", "Setting", "Name", "ApplicationList")
	Local $asAtt[5], $asVal[5]
	If $iAppsCount > 0 Then
		For $i = 0 To $iAppsCount - 1
			$asAtt[0] = "Check"
			$asAtt[1] = "Type"
			$asAtt[2] = "Name"
			$asAtt[3] = "Class"
			$asAtt[4] = "ClassNN"
			$asVal[0] = $afAppCheck[$i]
			$asVal[1] = $asAppType[$i]
			$asVal[2] = $asAppName[$i]
			$asVal[3] = $asAppClass[$i]
			$asVal[4] = $asAppClassNN[$i]
			_XMLCreateChildWAttr("/FolderMenu/Settings/Applications/Setting[@Name='ApplicationList']", "Application", $asAtt, $asVal)
		Next
	EndIf
EndFunc
Func WriteConfigKey()
	_XMLCreateChildNode("/FolderMenu/Settings", "Hotkeys")
	_XMLCreateChildWAttr("/FolderMenu/Settings/Hotkeys", "Setting", "Name", "HotkeyList")
	Local $asAtt[2], $asVal[2]
	If $iHotkeysCount > 0 Then
		For $i = 0 To $iHotkeysCount - 1
			$asAtt[0] = "Key"
			$asAtt[1] = "Func"
			$asVal[0] = $aiHotkeyKey[$i]
			$asVal[1] = $asHotkeyFunc[$i]
			_XMLCreateChildWAttr("/FolderMenu/Settings/Hotkeys/Setting[@Name='HotkeyList']", "Hotkey", $asAtt, $asVal)
		Next
	EndIf
EndFunc
Func WriteConfigIcon()
	_XMLCreateChildNode("/FolderMenu/Settings", "Icons")
	WriteConfigSetting("/FolderMenu/Settings/Icons", "NoMenuIcon", $fNoMenuIcon)
	WriteConfigSetting("/FolderMenu/Settings/Icons", "GetFavIcon", $fGetFavIcon)
	WriteConfigSetting("/FolderMenu/Settings/Icons", "ShellIcon", $fShellIcon)
	WriteConfigSetting("/FolderMenu/Settings/Icons", "IconSizeG", $iIconSizeG)
	_XMLCreateChildWAttr("/FolderMenu/Settings/Icons", "Setting", "Name", "IconList")
	Local $asAtt[4], $asVal[4]
	If $iIconsCount > 0 Then
		Local $sPath, $iIndex, $iSize
		For $i = 0 To $iIconsCount - 1
			SplitIconPath($asIconIcon[$i], $sPath, $iIndex, $iSize)
			$asAtt[0] = "Ext"
			$asAtt[1] = "Size"
			$asAtt[2] = "Path"
			$asAtt[3] = "Index"
			$asVal[0] = $asIconExt[$i]
			$asVal[1] = $iSize
			$asVal[2] = $sPath
			$asVal[3] = $iIndex
			_XMLCreateChildWAttr("/FolderMenu/Settings/Icons/Setting[@Name='IconList']", "Icon", $asAtt, $asVal)
		Next
	EndIf
EndFunc
Func WriteConfigMenu()
	_XMLCreateChildNode("/FolderMenu/Settings", "Menus")
	WriteConfigSetting("/FolderMenu/Settings/Menus", "MenuPositionX", $iMenuPositionX)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "MenuPositionY", $iMenuPositionY)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "MenuPosition", $iMenuPosition)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "TempShowFile", $fTempShowFile)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "TempShowFExt", $sTempShowFExt)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "AltFolderIcon", $fAltFolderIcon)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "BrowseMode", $fBrowseMode)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "TempDriveType", $sTempDriveType)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "HideExt", $fHideExt)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "HideLnk", $fHideLnk)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "ItemWarn", $fItemWarn)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "DriveType", $sDriveType)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "DriveReload", $fDriveReload)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "DriveFree", $fDriveFree)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "TCPathExe", $sTCPathExe)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "TCPathIni", $sTCPathIni)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "TCAsMain", $fTCAsMain)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "TCSubmenu", $fTCSubmenu)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "SRecentSize", $iSRecentSize)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "SRecentDate", $fSRecentDate)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "SRecentIndex", $fSRecentIndex)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "SRecentFolder", $fSRecentFolder)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "SRecentFull", $fSRecentFull)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "RecentSize", $iRecentSize)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "RecentDate", $fRecentDate)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "RecentIndex", $fRecentIndex)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "RecentFolder", $fRecentFolder)
	WriteConfigSetting("/FolderMenu/Settings/Menus", "RecentFull", $fRecentFull)
	_XMLCreateChildWAttr("/FolderMenu/Settings/Menus", "Setting", "Name", "RecentList")
	ReDim $asRecentDate[$iRecentSize]
	ReDim $asRecentPath[$iRecentSize]
	For $i = 0 To $iRecentSize - 1
		Local $asAtt[2], $asVal[2]
		$asAtt[0] = "Date"
		$asAtt[1] = "Path"
		$asVal[0] = $asRecentDate[$i]
		$asVal[1] = $asRecentPath[$i]
		_XMLCreateChildWAttr("/FolderMenu/Settings/Menus/Setting[@Name='RecentList']", "Recent", $asAtt, $asVal)
	Next
EndFunc
Func WriteConfigOther()
	_XMLCreateChildNode("/FolderMenu/Settings", "Others")
	WriteConfigSetting("/FolderMenu/Settings/Others", "Language", $sLanguage)
	WriteConfigSetting("/FolderMenu/Settings/Others", "StartWithWin", $fStartWithWin)
	WriteConfigSetting("/FolderMenu/Settings/Others", "NoTray", $fNoTray)
	WriteConfigSetting("/FolderMenu/Settings/Others", "AddFavAtTop", $fAddFavAtTop)
	WriteConfigSetting("/FolderMenu/Settings/Others", "AddFavCheck", $fAddFavCheck)
	WriteConfigSetting("/FolderMenu/Settings/Others", "AddFavSkipGui", $fAddFavSkipGui)
	WriteConfigSetting("/FolderMenu/Settings/Others", "AddFavApp", $fAddFavApp)
	WriteConfigSetting("/FolderMenu/Settings/Others", "AddFavAppCmd", $fAddFavAppCmd)
	WriteConfigSetting("/FolderMenu/Settings/Others", "AddFavLnk", $fAddFavLnk)
	WriteConfigSetting("/FolderMenu/Settings/Others", "FileManager", $sFileManager)
	WriteConfigSetting("/FolderMenu/Settings/Others", "Browser", $sBrowser)
	WriteConfigSetting("/FolderMenu/Settings/Others", "SearchSel", $fSearchSel)
	WriteConfigSetting("/FolderMenu/Settings/Others", "SearchSelUrl", $sSearchSelUrl)
	WriteConfigSetting("/FolderMenu/Settings/Others", "LoadingTip", $iLoadingTip)
	WriteConfigSetting("/FolderMenu/Settings/Others", "LoadingTipFor", $iLoadingTipFor)
	; WriteConfigSetting("/FolderMenu/Settings/Others", "TrayIconClick", $iTrayIconClick)
	WriteConfigSetting("/FolderMenu/Settings/Others", "CheckVersion", $fCheckVersion)
	WriteConfigSetting("/FolderMenu/Settings/Others", "CurrentVer", $iCurrentVer)
EndFunc
Func WriteConfigSetting($sXPath, $sName, $sValue)
	Local $asAtt[2], $asVal[2]
	$asAtt[0] = "Name"
	$asAtt[1] = "Value"
	$asVal[0] = $sName
	$asVal[1] = $sValue
	_XMLCreateChildWAttr($sXPath, "Setting", $asAtt, $asVal)
EndFunc
#endregion WriteConfig

Func ShowButtonMenu($hWnd, $Button, $Menu)
	Local $hMenu = GUICtrlGetHandle($Menu)
	Local $arPos = ControlGetPos($hWnd, "", $Button)
	Local $x = $arPos[0]
	Local $y = $arPos[1] + $arPos[3]
	Local $tPoint = DllStructCreate("int;int")
	DllStructSetData($tPoint, 1, $x)
	DllStructSetData($tPoint, 2, $y)
	_WinAPI_ClientToScreen($hWnd, $tPoint)
	$x = DllStructGetData($tPoint, 1)
	$y = DllStructGetData($tPoint, 2)
	$tPoint = 0
	_GUICtrlMenu_TrackPopupMenu($hMenu, $hWnd, $x, $y)
EndFunc
