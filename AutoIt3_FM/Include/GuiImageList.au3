#include-once

#include "ImageListConstants.au3"
#include "WinAPI.au3"

; #INDEX# =======================================================================================================================
; Title .........: ImageList
; Description ...: Functions that assist with ImageList control management.
;                  An image list is a collection of images of the same size, each of which can be referred to by its index. Image
;                  lists are used to efficiently manage large sets of icons or bitmaps. All images in an image list are contained
;                  in a single, wide bitmap in screen device format.  An image list can also include  a  monochrome  bitmap  that
;                  contains masks used to draw images transparently (icon style).
; Author(s)......: Paul Campbell (PaulIA)
; Dll(s) ........: comctl32.dll
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__IMAGELISTCONSTANT_IMAGE_BITMAP = 0
Global Const $__IMAGELISTCONSTANT_LR_LOADFROMFILE = 0x0010
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUIImageList_AddIcon
;_GUIImageList_Create
;_GUIImageList_Destroy
;_GUIImageList_Draw
;_GUIImageList_ReplaceIcon
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_AddIcon
; Description ...: Adds an icon to an image list
; Syntax.........: _GUIImageList_AddIcon($hWnd, $sFile[, $iIndex=0[, $fLarge = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $sFile       - Path to the icon that contains the image
;                  $iIndex      - Specifies the zero-based index of the icon to extract
;                  $fLarge      - Extract Large Icon
; Return values .: Success      - The index of the image
;                  Failrue      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Add, _GUIImageList_AddBitmap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_AddIcon($hWnd, $sFile, $iIndex = 0, $fLarge = False)
	Local $iRet, $tIcon = DllStructCreate("handle Handle")
	If $fLarge Then
		$iRet = _WinAPI_ExtractIconEx($sFile, $iIndex, DllStructGetPtr($tIcon), 0, 1)
	Else
		$iRet = _WinAPI_ExtractIconEx($sFile, $iIndex, 0, DllStructGetPtr($tIcon), 1)
	EndIf
	If $iRet <= 0 Then Return SetError(-1, $iRet, 0)

	Local $hIcon = DllStructGetData($tIcon, "Handle")
	$iRet = _GUIImageList_ReplaceIcon($hWnd, -1, $hIcon)
	_WinAPI_DestroyIcon($hIcon)
	If $iRet = -1 Then Return SetError(-2, $iRet, 0)
	Return $iRet
EndFunc   ;==>_GUIImageList_AddIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Create
; Description ...: Create an ImageList control
; Syntax.........: _GUIImageList_Create([$iCX=16[, $iCY=16[, $iColor=4[, $iOptions=0[, $iInitial=4[, $iGrow=4]]]]]])
; Parameters ....: $iCX         - Width, in pixels, of each image
;                  $iCY         - Height, in pixels, of each image
;                  $iColor      - Image color depth:
;                  |0 - Use the default behavior
;                  |1 - Use a  4 bit DIB section
;                  |2 - Use a  8 bit DIB section
;                  |3 - Use a 16 bit DIB section
;                  |4 - Use a 24 bit DIB section
;                  |5 - Use a 32 bit DIB section
;                  |6 - Use a device-dependent bitmap
;                  $iOptions    - Option flags.  Can be a combination of the following:
;                  |1 - Use a mask
;                  |2 - The images in the lists are mirrored
;                  |4 - The image list contains a strip of images
;                  $iInitial    - Number of images that the image list initially contains
;                  $iGrow       - Number of images by which the image list can grow when the system needs to make  room  for  new
;                  +images. This parameter represents the number of new images that the resized image list can contain.
; Return values .: Success      - Handle to the new control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Create($iCX = 16, $iCY = 16, $iColor = 4, $iOptions = 0, $iInitial = 4, $iGrow = 4)
	Local Const $aColor[7] = [$ILC_COLOR, $ILC_COLOR4, $ILC_COLOR8, $ILC_COLOR16, $ILC_COLOR24, $ILC_COLOR32, $ILC_COLORDDB]
	Local $iFlags = 0

	If BitAND($iOptions, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MASK)
	If BitAND($iOptions, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MIRROR)
	If BitAND($iOptions, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILC_PERITEMMIRROR)
	$iFlags = BitOR($iFlags, $aColor[$iColor])
	Local $aResult = DllCall("comctl32.dll", "handle", "ImageList_Create", "int", $iCX, "int", $iCY, "uint", $iFlags, "int", $iInitial, "int", $iGrow)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Destroy
; Description ...: Destroys an image list
; Syntax.........: _GUIImageList_Destroy($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Destroy($hWnd)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_Destroy", "handle", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Draw
; Description ...: Draws an image list item in the specified device context
; Syntax.........: _GUIImageList_Draw($hWnd, $iIndex, $hDC, $iX, $iY[, $iStyle=0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the image to draw
;                  $hDC         - Handle to the destination device context
;                  $iX          - X coordinate where the image will be drawn
;                  $iY          - Y coordinate where the image will be drawn
;                  $iStyle      - Drawing style and overlay image:
;                  |1 - Draws the image transparently using the mask, regardless of the background color
;                  |2 - Draws the image, blending 25 percent with the system highlight color
;                  |4 - Draws the image, blending 50 percent with the system highlight color
;                  |8 - Draws the mask
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_DrawEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Draw($hWnd, $iIndex, $hDC, $iX, $iY, $iStyle = 0)
	Local $iFlags = 0

	If BitAND($iStyle, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILD_TRANSPARENT)
	If BitAND($iStyle, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILD_BLEND25)
	If BitAND($iStyle, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILD_BLEND50)
	If BitAND($iStyle, 8) <> 0 Then $iFlags = BitOR($iFlags, $ILD_MASK)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_Draw", "handle", $hWnd, "int", $iIndex, "handle", $hDC, "int", $iX, "int", $iY, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_Draw

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_ReplaceIcon
; Description ...: Replaces an image with an icon or cursor
; Syntax.........: _GUIImageList_ReplaceIcon($hWnd, $iIndex, $hIcon)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the image to replace. If -1, the function appends the image to the end of the list.
;                  $hIcon       - Handle to the icon or cursor that contains the bitmap and mask for the new image
; Return values .: Success      - The index of the image
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (GaryFrost) changed return type from hwnd to int
; Remarks .......: Because the system does not save hIcon you can destroy it after the function returns if the icon or cursor was
;                  created by the CreateIcon function. You do not need to destroy hIcon if it was loaded by the LoadIcon function
;                  the system automatically frees an icon resource when it is no longer needed.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_ReplaceIcon($hWnd, $iIndex, $hIcon)
	Local $aResult = DllCall("comctl32.dll", "int", "ImageList_ReplaceIcon", "handle", $hWnd, "int", $iIndex, "handle", $hIcon)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_ReplaceIcon
