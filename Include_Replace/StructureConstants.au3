#include-once

; #INDEX# =======================================================================================================================
; Title .........: Structures_Constants
; AutoIt Version : 3.2.++
; Description ...: Constants for Windows API functions.
; Author(s) .....: Paul Campbell (PaulIA), Gary Frost, Jpm
; ===============================================================================================================================

; #LISTING# =====================================================================================================================
;$tagPOINT
;$tagRECT
;$tagNMHDR
;$tagHDITEM
;$tagLVITEM
;$tagTVITEMEX
;$tagTVHITTESTINFO
;$tagNMLVKEYDOWN
;$tagNMTVKEYDOWN
;$tagTOKEN_PRIVILEGES
;$tagMENUINFO
;$tagMENUITEMINFO
;$tagBITMAPINFO
;$tagKBDLLHOOKSTRUCT
;$tagSECURITY_ATTRIBUTES
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagTVITEM
;$tagLVFINDINFO
; ===============================================================================================================================

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagPOINT
; Description ...: Defines the x- and y- coordinates of a point
; Fields ........: X - Specifies the x-coordinate of the point
;                  Y - Specifies the y-coordinate of the point
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagPOINT = "long X;long Y"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagRECT
; Description ...: Defines the coordinates of the upper-left and lower-right corners of a rectangle
; Fields ........: Left   - Specifies the x-coordinate of the upper-left corner of the rectangle
;                  Top    - Specifies the y-coordinate of the upper-left corner of the rectangle
;                  Right  - Specifies the x-coordinate of the lower-right corner of the rectangle
;                  Bottom - Specifies the y-coordinate of the lower-right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagRECT = "long Left;long Top;long Right;long Bottom"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMHDR
; Description ...: Contains information about a notification message
; Fields ........: hWndFrom - Window handle to the control sending a message
;                  IDFrom   - Identifier of the control sending a message
;                  Code     - Notification code (define as UINT in MSDN but tested with negative value)
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMHDR = "hwnd hWndFrom;uint_ptr IDFrom;INT Code"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Header Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagHDITEM
; Description ...: Contains information about an item in a header control
; Fields ........: Mask    - Flags indicating which other structure members contain valid data or must be filled in
;                  XY      - Width or height of the item
;                  Text    - Address of Item string
;                  hBMP    - Handle to the item bitmap
;                  TextMax - Length of the item string
;                  Fmt     - Flags that specify the item's format
;                  Param   - Application-defined item data
;                  Image   - Zero-based index of an image within the image list
;                  Order   - Order in which the item appears within the header control, from left to right
;                  Type    - Type of filter specified by pFilter
;                  pFilter - Address of an application-defined data item
;                  State   - Item state
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagHDITEM = "uint Mask;int XY;ptr Text;handle hBMP;int TextMax;int Fmt;lparam Param;int Image;int Order;uint Type;ptr pFilter;uint State"

; ===============================================================================================================================
; *******************************************************************************************************************************
; ListView Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagLVFINDINFO
; Description ...: Contains information used when searching for a list-view item
; Fields ........: Flags     - Type of search to perform. This member can be set to one or more of the following values:
;                  |$LVFI_PARAM    - Searches for a match between this structure's Param member and the Param member of an item.
;                  +If $LVFI_PARAM is specified, all other flags are ignored.
;                  |$LVFI_PARTIAL  - Checks to see if the item text begins with the string pointed to by the Text  member.  This
;                  +value implies use of $LVFI_STRING.
;                  |$LVFI_STRING   - Searches based on the item text.  Unless additional values are specified, the item text  of
;                  +the matching item must exactly match the string pointed to by the Text member.
;                  |$LVFI_WRAP     - Continues the search at the beginning if no match is found
;                  |LVFI_NEARESTXY - Finds the item nearest to the position specified in the X and Y members, in  the  direction
;                  +specified by the Direction member. This flag is supported only by large icon and small icon modes.
;                  Text      - Address of a string to compare with the item text.  It is valid if $LVFI_STRING or  $LVFI_PARTIAL
;                  +is set in the Flags member.
;                  Param     - Value to compare with the Param member of an item's  $LVITEM  structure.  It  is  valid  only  if
;                  +$LVFI_PARAM is set in the flags member.
;                  X         - Initial X search position. It is valid only if $LVFI_NEARESTXY is set in the Flags member.
;                  Y         - Initial Y search position. It is valid only if $LVFI_NEARESTXY is set in the Flags member.
;                  Direction - Virtual key code that specifies the direction to search. The following codes are supported:
;                  |VK_LEFT
;                  |VK_RIGHT
;                  |VK_UP
;                  |VK_DOWN
;                  |VK_HOME
;                  |VK_END
;                  |VK_PRIOR
;                  |VK_NEXT
;                  |This member is valid only if $LVFI_NEARESTXY is set in the flags member.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVFINDINFO = "uint Flags;ptr Text;lparam Param;" & $tagPOINT & ";uint Direction"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagLVITEM
; Description ...: Specifies or receives the attributes of a list-view item
; Fields ........: Mask      - Set of flags that specify which members of this structure contain data to be set or which members
;                  +are being requested. This member can have one or more of the following flags set:
;                  |$LVIF_COLUMNS     - The Columns member is valid
;                  |$LVIF_DI_SETITEM  - The operating system should store the requested list item information
;                  |$LVIF_GROUPID     - The GroupID member is valid
;                  |$LVIF_IMAGE       - The Image member is valid
;                  |$LVIF_INDENT      - The Indent member is valid
;                  |$LVIF_NORECOMPUTE - The control will not generate LVN_GETDISPINFO to retrieve text information
;                  |$LVIF_PARAM       - The Param member is valid
;                  |$LVIF_STATE       - The State member is valid
;                  |$LVIF_TEXT        - The Text member is valid
;                  Item      - Zero based index of the item to which this structure refers
;                  SubItem   - One based index of the subitem to which this structure refers
;                  State     - Indicates the item's state, state image, and overlay image
;                  StateMask - Value specifying which bits of the state member will be retrieved or modified
;                  Text      - Pointer to a string containing the item text
;                  TextMax   - Number of bytes in the buffer pointed to by Text, including the string terminator
;                  Image     - Index of the item's icon in the control's image list
;                  Param     - Value specific to the item
;                  Indent    - Number of image widths to indent the item
;                  GroupID   - Identifier of the tile view group that receives the item
;                  Columns   - Number of tile view columns to display for this item
;                  pColumns  - Pointer to the array of column indices
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVITEM = "uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & _
		"int Indent;int GroupID;uint Columns;ptr pColumns"

; ===============================================================================================================================
; *******************************************************************************************************************************
; TreeView Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTVITEM
; Description ...: Specifies or receives attributes of a tree-view item
; Fields ........: Mask          - Flags that indicate which of the other structure members contain valid data:
;                  ...
;                  Param         - A value to associate with the item
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTVITEM = "uint Mask;handle hItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;int SelectedImage;" & _
		"int Children;lparam Param"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTVITEMEX
; Description ...: Specifies or receives attributes of a tree-view item
; Fields ........: Mask          - Flags that indicate which of the other structure members contain valid data:
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
Global Const $tagTVITEMEX = $tagTVITEM & ";int Integral"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTVHITTESTINFO
; Description ...: Contains information used to determine the location of a point relative to a tree-view control
; Fields ........: X     - X position, in client coordiantes, to be tested
;                  Y     - Y position, in client coordiantes, to be tested
;                  Flags - Results of a hit test. This member can be one or more of the following values:
;                  |$TVHT_ABOVE           - Above the client area
;                  |$TVHT_BELOW           - Below the client area
;                  |$TVHT_NOWHERE         - In the client area, but below the last item
;                  |$TVHT_ONITEM          - On the bitmap or label associated with an item
;                  |$TVHT_ONITEMBUTTON    - On the button associated with an item
;                  |$TVHT_ONITEMICON      - On the bitmap associated with an item
;                  |$TVHT_ONITEMINDENT    - In the indentation associated with an item
;                  |$TVHT_ONITEMLABEL     - On the label (string) associated with an item
;                  |$TVHT_ONITEMRIGHT     - In the area to the right of an item
;                  |DllStructGetData($TVHT_ONITEMSTATEICON - On the state icon for an item that is in a user-defined state, "")
;                  |$TVHT_TOLEFT          - To the left of the client area
;                  |$TVHT_TORIGHT         - To the right of the client area
;                  Item  - Handle to the item that occupies the position
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTVHITTESTINFO = $tagPOINT & ";uint Flags;handle Item"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMLVKEYDOWN
; Description ...: Contains information used in processing the $LVN_KEYDOWN notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  VKey     - Virtual key code
;                  Flags    - This member must always be zero
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMLVKEYDOWN = $tagNMHDR & ";ptr VKey;uint Flags"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTVKEYDOWN
; Description ...: Contains information about a keyboard event in a tree-view control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  VKey     - Virtual key code
;                  Flags    - Always zero
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMTVKEYDOWN = $tagNMHDR & ";ptr VKey;uint Flags"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Security Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTOKEN_PRIVILEGES
; Description ...: Contains information about a set of privileges for an access token
; Fields ........: Count      - Specifies the number of entries
;                  LUID       - Specifies a LUID value
;                  Attributes - Specifies attributes of the LUID
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTOKEN_PRIVILEGES = "dword Count;int64 LUID;dword Attributes"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Menu Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMENUINFO
; Description ...: Contains information about a menu
; Fields ........: Size          - Specifies the size, in bytes, of the structure
;                  Mask          - Members to retrieve or set. This member can be one or more of the following values:
;                  |$MIM_APPLYTOSUBMENUS - Settings apply to the menu and all of its submenus
;                  |$MIM_BACKGROUND      - Retrieves or sets the hBack member
;                  |$MIM_HELPID          - Retrieves or sets the ContextHelpID member
;                  |$MIM_MAXHEIGHT       - Retrieves or sets the YMax member
;                  |$MIM_MENUDATA        - Retrieves or sets the MenuData member
;                  |$MIM_STYLE           - Retrieves or sets the Style member
;                  Style         - Style of the menu. It can be one or more of the following values:
;                  |$MNS_AUTODISMISS - Menu automatically ends when mouse is outside the menu for approximately 10 seconds
;                  |$MNS_CHECKORBMP  - The same space is reserved for the check mark and the bitmap
;                  |$MNS_DRAGDROP    - Menu items are OLE drop targets or drag sources
;                  |$MNS_MODELESS    - Menu is modeless
;                  |$MNS_NOCHECK     - No space is reserved to the left of an item for a check mark
;                  |$MNS_NOTIFYBYPOS - A WM_MENUCOMMAND message is sent instead of a WM_COMMAND message when a selection is made
;                  YMax          - Maximum height of the menu in pixels
;                  hBack         - Brush to use for the menu's background
;                  ContextHelpID - The context help identifier
;                  MenuData      - An application defined value
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMENUINFO = "dword Size;INT Mask;dword Style;uint YMax;handle hBack;dword ContextHelpID;ulong_ptr MenuData"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMENUITEMINFO
; Description ...: Contains information about a menu item
; Fields ........: Size         - Specifies the size, in bytes, of the structure
;                  Mask         - Members to retrieve or set. This member can be one or more of these values:
;                  |$MIIM_BITMAP     - Retrieves or sets the BmpItem member
;                  |$MIIM_CHECKMARKS - Retrieves or sets the BmpChecked and BmpUnchecked members
;                  |$MIIM_DATA       - Retrieves or sets the ItemData member
;                  |$MIIM_FTYPE      - Retrieves or sets the Type member
;                  |$MIIM_ID         - Retrieves or sets the ID member
;                  |$MIIM_STATE      - Retrieves or sets the State member
;                  |$MIIM_STRING     - Retrieves or sets the TypeData member
;                  |$MIIM_SUBMENU    - Retrieves or sets the SubMenu member
;                  |$MIIM_TYPE       - Retrieves or sets the Type and TypeData members
;                  Type         - Menu item type. This member can be one or more of the following values:
;                  |$MFT_BITMAP       - Displays the menu item using a bitmap
;                  |$MFT_MENUBARBREAK - Places the menu item on a new line or in a new column
;                  |$MFT_MENUBREAK    - Places the menu item on a new line or in a new column
;                  |$MFT_OWNERDRAW    - Assigns responsibility for drawing the menu item to the menu owner
;                  |$MFT_RADIOCHECK   - Displays selected menu items using a radio button mark
;                  |$MFT_RIGHTJUSTIFY - Right justifies the menu item and any subsequent items
;                  |$MFT_RIGHTORDER   - Specifies that menus cascade right to left
;                  |$MFT_SEPARATOR    - Specifies that the menu item is a separator
;                  State        - Menu item state. This member can be one or more of these values:
;                  |$MFS_CHECKED   - Checks the menu item
;                  |$MFS_DEFAULT   - Specifies that the menu item is the default
;                  |$MFS_DISABLED  - Disables the menu item and grays it so that it cannot be selected
;                  |$MFS_ENABLED   - Enables the menu item so that it can be selected
;                  |$MFS_GRAYED    - Disables the menu item and grays it so that it cannot be selected
;                  |$MFS_HILITE    - Highlights the menu item
;                  ID           - Application-defined 16-bit value that identifies the menu item
;                  SubMenu      - Handle to the drop down menu or submenu associated with the menu item
;                  BmpChecked   - Handle to the bitmap to display next to the item if it is selected
;                  BmpUnchecked - Handle to the bitmap to display next to the item if it is not selected
;                  ItemData     - Application-defined value associated with the menu item
;                  TypeData     - Content of the menu item
;                  CCH          - Length of the menu item text
;                  BmpItem      - Handle to the bitmap to be displayed
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMENUITEMINFO = "uint Size;uint Mask;uint Type;uint State;uint ID;handle SubMenu;handle BmpChecked;handle BmpUnchecked;" & _
		"ulong_ptr ItemData;ptr TypeData;uint CCH;handle BmpItem"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagBITMAPINFO
; Description ...: This structure defines the dimensions and color information of a Windows-based device-independent bitmap (DIB).
; Fields ........: Size          - The number of bytes required by the structure, minus the size of the RGBQuad data
;                  Width         - Specifies the width of the bitmap, in pixels
;                  Height        - Specifies the height of the bitmap, in pixels
;                  Planes        - Specifies the number of planes for the target device. This must be set to 1
;                  BitCount      - Specifies the number of bits-per-pixel
;                  Compression   - Specifies the type of compression for a compressed bottom-up bitmap
;                  SizeImage     - Specifies the size, in bytes, of the image
;                  XPelsPerMeter - Specifies the horizontal resolution, in pixels-per-meter, of the target device for the bitmap
;                  YPelsPerMeter - Specifies the vertical resolution, in pixels-per-meter, of the target device for the bitmap
;                  ClrUsed       - Specifies the number of color indexes in the color table that are actually used by the bitmap
;                  ClrImportant  - Specifies the number of color indexes that are required for displaying the bitmap
;                  RGBQuad       - An array of tagRGBQUAD structures. The elements of the array that make up the color table.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagBITMAPINFO = "dword Size;long Width;long Height;word Planes;word BitCount;dword Compression;dword SizeImage;" & _
		"long XPelsPerMeter;long YPelsPerMeter;dword ClrUsed;dword ClrImportant;dword RGBQuad"


; #STRUCTURE# ===================================================================================================================
; Name...........: $tagKBDLLHOOKSTRUCT
; Description ...: Contains information about a low-level keyboard input event
; Fields ........: vkCode               - Specifies a virtual-key code. The code must be a value in the range 1 to 254
;                  scanCode             - Specifies a hardware scan code for the key
;                  flags                - Specifies the extended-key flag, event-injected flag, context code, and transition-state flag. This member is specified as follows.
;                  +  An application can use the following values to test the keystroke flags:
;                  |$LLKHF_EXTENDED     - Test the extended-key flag
;                  |$LLKHF_INJECTED     - Test the event-injected flag
;                  |$LLKHF_ALTDOWN      - Test the context code
;                  |$LLKHF_UP           - Test the transition-state flag
;                  |  0      - Specifies whether the key is an extended key, such as a function key or a key on the numeric keypad
;                  |    The value is 1 if the key is an extended key; otherwise, it is 0
;                  |  1 to 3 - Reserved
;                  |  4      - Specifies whether the event was injected. The value is 1 if the event was injected; otherwise, it is 0
;                  |  5      - Specifies the context code. The value is 1 if the ALT key is pressed; otherwise, it is 0
;                  |  6      - Reserved
;                  |  7      - Specifies the transition state. The value is 0 if the key is pressed and 1 if it is being released
;                  time                 - Specifies the time stamp for this message, equivalent to what GetMessageTime would return for this message
;                  dwExtraInfo          - Specifies extra information associated with the message
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagKBDLLHOOKSTRUCT = "dword vkCode;dword scanCode;dword flags;dword time;ulong_ptr dwExtraInfo"
; ===============================================================================================================================
; *******************************************************************************************************************************
; Authorization Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagSECURITY_ATTRIBUTES
; Description ...: Contains the security descriptor for an object and specifies whether the handle retrieved by specifying this structure is inheritable
; Fields ........: Length        - The size, in bytes, of this structure
;                  Descriptor    - A pointer to a security descriptor for the object that controls the sharing of it
;                  InheritHandle - If True, the new process inherits the handle.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"

; == Leave this line at the end of the file =====================================================================================
