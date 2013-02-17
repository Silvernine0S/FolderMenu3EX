; Oringally Folder Menu 3 by rexx
; FolderMenu3EX is Forked from v3.1.2.2
Func ReadLanguage()
	ReadLanguageDefault()
	Global $sLanguage = ReadConfigSetting("/FolderMenu/Settings/Others", "Language", "")
	if $sLanguage <> "" then
		Local $sLangFile = $sLanguage
		if not FileExists($sLangFile) then $sLangFile = @ScriptDir & "\" & $sLanguage
		Local $hFile = FileOpen($sLangFile, 0)
		if $hFile = -1 then
			$sErrorMsg &= "Can Not Open Language File: " & $sLanguage
		else
			Local $sLine, $sName, $sString
			; Read in lines of text until the EOF is reached
			While 1
				$sLine = FileReadLine($hFile)
				If @Error = -1 then ExitLoop
				if StringLeft($sLine, 1) = ";" then ContinueLoop
				StringSplit2($sLine, "=", $sName, $sString)
				$sName = StringStripWS($sName, 3)
				$sString = Unescape(StringStripWS($sString, 3))
				Assign("sLang_" & $sName, $sString, 2)
			WEnd
			FileClose($hFile)
		endif
	endif

	Global $sLoadingTipTitle = "FolderMenu3 EX"
	Local $iLength
	if StringLen($sLang_LoadFav)    > $iLength then $iLength = StringLen($sLang_LoadFav)
	if StringLen($sLang_LoadRecent) > $iLength then $iLength = StringLen($sLang_LoadRecent)
	; if StringLen($sLang_LoadTemp)     > $iLength then $iLength = StringLen($sLang_LoadTemp)
	if StringLen($sLang_LoadDrive)  > $iLength then $iLength = StringLen($sLang_LoadDrive)
	if StringLen($sLang_LoadTC)     > $iLength then $iLength = StringLen($sLang_LoadTC)
	$iLength *= 2
	While StringLen($sLoadingTipTitle) < $iLength + 2
		$sLoadingTipTitle &= " "
	WEnd
	return
EndFunc

Func ReadLanguageDefault()
	; ToolMenu
	Global $sLang_ToolWebsite   = Unescape("&Website")
	Global $sLang_ToolAdd       = Unescape("&Add Favorite")
	Global $sLang_ToolReload    = Unescape("&Restart")
	Global $sLang_ToolOption    = Unescape("&Options")
	Global $sLang_ToolEdit      = Unescape("&Edit")
	Global $sLang_ToolExit      = Unescape("E&xit")

	; MsgBox
	Global $sLang_Error     = Unescape("Error")
	Global $sLang_Warning   = Unescape("Warning")

	Global $sLang_TooManyItems  = Unescape("There Are More Than 500 Items (%ItemCount% items)\n\nDo You Want To Continue?")

	Global $sLang_NewVer            = Unescape("New Version!")
	Global $sLang_CannotConnect     = Unescape("Cannot Connect To The Internet.")
	Global $sLang_NewVerAvailable   = Unescape("There's A New Version v%LatestVer% Available.\n\nDownload It Now?")
	Global $sLang_NewVerUnavailable = Unescape("You Are Using The Latest Version v%CurrentVer%.")
	Global $sLang_NewVerFailed      = Unescape("Download Failed.")
	Global $sLang_NewVerWebsite     = Unescape("Go To Website?")
	Global $sLang_NewVerUpdated     = Unescape("Updated To v%CurrentVer%.")
	Global $sLang_UpdateFolderMenu  = Unescape("Update FolderMenu3 EX")
	Global $sLang_UpdateExit        = Unescape("Exit FolderMenu3 EX Before Continue")
	Global $sLang_UpdateDone        = Unescape("Done")

	Global $sLang_AddApp        = Unescape("Add Application")
	Global $sLang_AddAppTitle   = Unescape("Title:\t[%Title%]\nClass:\t[%Class%]\n\n")
	Global $sLang_AddAppAddr    = Unescape("Is The Red Region The Addressbar Of That Application?")
	Global $sLang_AddAppNoAddr  = Unescape("Addressbar Not Found.")
	Global $sLang_AddAppFocus   = Unescape("Click On The Addressbar and Press OK.")
	Global $sLang_AddAppPrompt  = Unescape("Do You Want To Add This Application?")

	Global $sLang_SaveChange    = Unescape("Would You Like To Save Changes?")
	Global $sLang_EditReload    = Unescape("You Have To Restart Folder Menu To Take Effect After Editing The XML File.")

	Global $sLang_PathExist     = Unescape("This Path Already Exist.\n[%ItemName%]\n(%ItemPath%)\nAdd It Again?")

	; ToolTip
	Global $sLang_LoadFav       = Unescape("Loading Favorites...")
	Global $sLang_LoadRecent    = Unescape("Loading Recent Items...")
	Global $sLang_LoadTemp      = Unescape("Loading Subfolder Items...")
	Global $sLang_LoadDrive     = Unescape("Loading Drive Menu Items...")
	Global $sLang_LoadTC        = Unescape("Loading TC Items...")
	Global $sLang_DownloadUpdate    = Unescape("Downloading Update...")

	; TrayTip
	Global $sLang_CannotOpenBlank   = Unescape("Could Not Open\n[%ItemName%]\nIts Path Is Blank")
	Global $sLang_CannotOpenDown    = Unescape("Could Not Open\n%ThisPathIP%\nServer Down")
	Global $sLang_CannotOpenClip    = Unescape("Could Not Open\n%Clipboard%")
	Global $sLang_FavoriteAdded     = Unescape("[%ItemName%] Added\n(%ItemPath%)")
	Global $sLang_ShowHidden        = Unescape("Show Hidden Files")
	Global $sLang_HideHidden        = Unescape("Hide Hidden Files")
	Global $sLang_ShowFileExt       = Unescape("Show File Extension")
	Global $sLang_HideFileExt       = Unescape("Hide File Extension")
	Global $sLang_SVSDeactivate     = Unescape("Deactivating SVS Layer...")
	Global $sLang_SVSActivate       = Unescape("Activating SVS Layer...")
	Global $sLang_ErrSpecial        = Unescape("""%ItemPath%"" Is Not A Valid Special Item")
	Global $sLang_ErrHotkey         = Unescape("Hotkey [%HotkeyName%] (%HotkeyKey%) Error")
	Global $sLang_Search            = Unescape("Search")

	; OptionsGUI
	Global $sLang_BtnEdit   = Unescape("&Edit")
	Global $sLang_TipEdit   = Unescape("Edit FolderMenu.xml")
	Global $sLang_BtnOK     = Unescape("OK")
	Global $sLang_BtnCancel = Unescape("Cancel")
	Global $sLang_BtnApply  = Unescape("&Apply")

	Global $sLang_Fav       = Unescape("Favorites")
	Global $sLang_App       = Unescape("Applications")
	Global $sLang_Hotkey    = Unescape("Hotkey")
	Global $sLang_Icon      = Unescape("Icon")
	Global $sLang_Menu      = Unescape("Menu")
	Global $sLang_Other     = Unescape("Others")
	Global $sLang_About     = Unescape("About")

	; Favorite
	Global $sLang_Name      = Unescape("Name")
	Global $sLang_Path      = Unescape("Path")
	Global $sLang_Size      = Unescape("Size")
	Global $sLang_Depth     = Unescape("Depth")
	Global $sLang_Submenu   = Unescape("Submenu")
	Global $sLang_Sort      = Unescape("^")
	Global $sLang_Add       = Unescape("+")
	Global $sLang_Del       = Unescape("-")
	Global $sLang_NewItem   = Unescape("New Item")
	Global $sLang_NewMenu   = Unescape("New Menu")
	Global $sLang_SelectFile    = Unescape("Select File")
	Global $sLang_SelectFolder  = Unescape("Select Folder")
	Global $sLang_BrowseFolder  = Unescape("&Browse Folder")
	Global $sLang_BrowseFile    = Unescape("B&rowse File")
	Global $sLang_SpecialItems  = Unescape("&Special Items")
	Global $sLang_Separator     = Unescape("Separator")
	Global $sLang_ColSeparator  = Unescape("Column Separator")
	Global $sLang_Computer      = Unescape("Computer")
	Global $sLang_AddFavorite   = Unescape("Add Favorite")
	Global $sLang_AddHere       = Unescape("Add Favorite Here")
	Global $sLang_Reload        = Unescape("Restart")
	Global $sLang_Options       = Unescape("Options")
	Global $sLang_EditConfig    = Unescape("Edit Config File")
	Global $sLang_Exit          = Unescape("Exit")
	Global $sLang_ToggleHidden  = Unescape("Toggle Hidden Files")
	Global $sLang_ToggleFileExt = Unescape("Toggle Hide File Extension")
	Global $sLang_SystemRecent  = Unescape("System Recent Menu")
	Global $sLang_RecentMenu    = Unescape("Recent Menu")
	Global $sLang_ExplorerMenu  = Unescape("Explorer Menu")
	Global $sLang_DriveMenu     = Unescape("Drive Menu")
	Global $sLang_ToolMenu      = Unescape("Tool Menu")
	Global $sLang_SVSMenu       = Unescape("SVS Menu")
	Global $sLang_TCMenu        = Unescape("TC Menu")

	Global $sLang_TipFavTree 	= Unescape("Drop Files Here To Add Into Favorite\n\nHotkeys:\n  Ins          	Insert Item\n  Del          	Delete Item\n  Shift+Ins 	Insert Menu\n  Shift+Del 	Delete Menu\n  Shift+Up  	Move Up\n  Shift+Down	Move Down")
	Global $sLang_TipFavPath    = Unescape("Browse File/Folder/Special Item")
	Global $sLang_TipFavIcon    = Unescape("Pick Icon")
	Global $sLang_TipFavMenu    = Unescape("Check This To Auto Create Submenu For A Folder Item")
	Global $sLang_TipFavRel     = Unescape("Switch Between Absolute/Relative Path\nHolding Shift To Use Environment Variables")
	Global $sLang_TipFavSort    = Unescape("Sort Selected Menu\nHolding Shift To Sort Recursively")
	Global $sLang_TipFavAdd     = Unescape("Insert A New Item\nHolding Shift To Insert A Submenu")
	Global $sLang_TipFavDel     = Unescape("Delete Selected Item\nHolding Shift To Delete A Submenu")
	Global $sLang_TipFavDepth   = Unescape("Max Depth Of Auto Created Submenu")
	Global $sLang_TipFavExt     = Unescape("List The File Extensions You Want To Show In The Menu\n(Comma Separated)")

	Global $sLang_Setting       = Unescape("Setting")
	Global $sLang_DriveReload   = Unescape("Update When Showing Main Menu")
	Global $sLang_DriveFree     = Unescape("Show Free Space")
	Global $sLang_TCPathExe     = Unescape("TC Exe Path")
	Global $sLang_TCPathIni     = Unescape("TC Ini Path")
	Global $sLang_TCAsMain      = Unescape("Use TC As Main Menu")
	Global $sLang_TCSubmenu     = Unescape("Put TC Items In A Submenu")
	Global $sLang_TCDirMenu     = Unescape("Total Commander Directory Menu")
	Global $sLang_TipTCDirMenu  = Unescape("Use Total Commander To Edit Favorite Folders")
	Global $sLang_TipTCSubmenu  = Unescape("Check This To Put TC Items In A Submenu\nOtherwise TC Items Will be Added In The Menu Where You Add The ""TC Menu"" Item")
	Global $sLang_RecentSize    = Unescape("Recent Size")
	Global $sLang_RecentDate    = Unescape("Show Date")
	Global $sLang_RecentIndex   = Unescape("Show Index")
	Global $sLang_RecentFolder  = Unescape("Keeps Only Folders")
	Global $sLang_RecentFull    = Unescape("Show Full Path")
	Global $sLang_ClearRecent   = Unescape("Clear Recent")

	; Application
	Global $sLang_SupportApplications   = Unescape("Select Applications That You Want To Use Folder Menu")
	Global $sLang_Type      = Unescape("Type")
	Global $sLang_Class     = Unescape("Class")
	Global $sLang_Match     = Unescape("Match")
	Global $sLang_Contain   = Unescape("Contain")
	Global $sLang_Explorer  = Unescape("Explorer")
	Global $sLang_Dialog    = Unescape("Open/Save Dialog")
	Global $sLang_DialogO   = Unescape("MS Office Dialog")
	Global $sLang_Command   = Unescape("Command")
	Global $sLang_Desktop   = Unescape("Desktop")
	Global $sLang_Taskbar   = Unescape("Taskbar")

	Global $sLang_TipAppClass   = Unescape("Can Be Comma Separated Value")
	Global $sLang_TipAppType    = Unescape("""Match"" Means The Classname Must Exactly Match The String.\n""Contain"" Means The Classname Can Contain The String Anywhere")
	Global $sLang_TipAppAdd     = Unescape("Holding Shift To Insert Default Items")

	; Hotkey
	Global $sLang_Action        = Unescape("Action")
	Global $sLang_ShowMenu      = Unescape("Show Menu")
	Global $sLang_OpenSelText   = Unescape("Open Selected Text")
	Global $sLang_LButton       = Unescape("LButton")
	Global $sLang_RButton       = Unescape("RButton")
	Global $sLang_MButton       = Unescape("MButton")
	Global $sLang_XButton1      = Unescape("XButton1")
	Global $sLang_XButton2      = Unescape("XButton2")
	Global $sLang_DoubleClick   = Unescape("Double Click")
	Global $sLang_KeepNative    = Unescape("Keep Native Function")
	Global $sLang_Shift         = Unescape("Shift")
	Global $sLang_Ctrl          = Unescape("Ctrl")
	Global $sLang_Alt           = Unescape("Alt")
	Global $sLang_Win           = Unescape("Win")
	Global $sLang_TipHotkeyMouse    = Unescape("Select A Mouse Button")

	; Icon
	Global $sLang_NoIcon        = Unescape("Don't Use Menu &Icon")
	Global $sLang_GetFavicon    = Unescape("Get Favicon")
	Global $sLang_ShellIcon     = Unescape("Get Shell Icon")
	Global $sLang_IconSize      = Unescape("Icon Size")
	Global $sLang_Extension     = Unescape("Extension")
	Global $sLang_IconPath      = Unescape("Icon Path")

	Global $sLang_Unknown       = Unescape("Unknown File Type")
	Global $sLang_Folder        = Unescape("Folder")
	Global $sLang_FolderS       = Unescape("Folder With Subfolders")
	Global $sLang_Drive         = Unescape("Drive")
	Global $sLang_UNCPath       = Unescape("UNC Path")

	Global $sLang_TipNoIcon     = Unescape("Check This To Load Menu Faster")
	Global $sLang_TipGetFavicon = Unescape("Get Favicon For URL Items\nDownloading Icon May Slow Down Loading Menu")
	Global $sLang_TipShellIcon  = Unescape("Get Shell Icon For Folder Items\nUncheck This To Load Menu A Kittle Faster")
	; Global $sLang_TipIconExt      = Unescape("Extension can be the following special items:\nUnknown   \tUnknown file type\nMenu       \tSubmenu items\nFolder      \tFolder items\nFolderS      \tFolder items which has subfolder\nDrive        \tHDD items\nComputer  \tComputer item\nShare      \tUNC path item\n_????       \tSpecial item\n:????       \tSpecial menu item")
	Global $sLang_TipIconSize   = Unescape("Select Icon Size (In Pixel)") ;\nSet size to 0 for maximum available size")

	; Menu
	Global $sLang_MenuPosition      = Unescape("Menu Position")
	Global $sLang_RelativeToCursor  = Unescape("Relative To Cursor")
	Global $sLang_RelativeToScreen  = Unescape("Relative To Screen")
	Global $sLang_RelativeToWindow  = Unescape("Relative To Window")
	Global $sLang_TempMenu          = Unescape("Subfolder Temp Menu")
	Global $sLang_ShowFile          = Unescape("Show Files")
	Global $sLang_AltFolderIcon     = Unescape("Show Different Icon For Folders Which Has Subfolder")
	Global $sLang_BrowseMode        = Unescape("Use &Browse Mode When Capslock Is Off")
	Global $sLang_DriveType         = Unescape("Drive Type You Want To Show")
	Global $sLang_All               = Unescape("All")
	Global $sLang_Fixed             = Unescape("Fixed")
	Global $sLang_CDROM             = Unescape("CD-ROM")
	Global $sLang_Removable         = Unescape("Removable")
	Global $sLang_Network           = Unescape("Network")
	Global $sLang_RAMDisk           = Unescape("RAM Disk")
	Global $sLang_HideExt           = Unescape("Hide E&xtension")
	Global $sLang_HideLnk           = Unescape("Hide .Lnk .Url")
	Global $sLang_ItemWarn          = Unescape("Warn Me If There Are Too Many Items")

	Global $sLang_TipMenuTempIcon   = Unescape("If A Folder Item Has Subfolder\nShow A Different Icon To Indicate That")
	Global $sLang_TipMenuTempBrowse = Unescape("Check This To Turn On Browse Mode By Default\nand Turn Off Browse Mode When CapsLock Is On")

	; Other
	Global $sLang_Language          = Unescape("Language")
	Global $sLang_StartWithWin      = Unescape("&Start With Windows")
	Global $sLang_NoTray            = Unescape("No &Tray Icon")
	Global $sLang_AddFavAtTop       = Unescape("Add New Item at Top")
	Global $sLang_AddFavCheck       = Unescape("Check Existing Item Path")
	Global $sLang_AddFavSkipGUI     = Unescape("Skip Options Window")
	Global $sLang_AddFavApp         = Unescape("Add Application To Favorite")
	Global $sLang_AddFavAppCmd      = Unescape("Get Command Line")
	Global $sLang_AddFavLnk         = Unescape("Use Target Of Link File")
	Global $sLang_FileManager       = Unescape("File Manager Path")
	Global $sLang_Browser           = Unescape("Browser Path")
	Global $sLang_SearchSel         = Unescape("Search Selected Text")
	Global $sLang_LoadingTip        = Unescape("When Loading Items")
	Global $sLang_LoadingTipNo      = Unescape("Show Nothing")
	Global $sLang_LoadingTipTool    = Unescape("Show ToolTip")
	Global $sLang_LoadingTipTray    = Unescape("Show TrayTip")
	Global $sLang_MainMenu          = Unescape("Main Menu")
;   Global $sLang_TrayIconClick     = Unescape("When clicking On tray icon")

	Global $sLang_TipOtherAddFavPath    = Unescape("Checks If The Path Already Added In Favorite")
	Global $sLang_TipOtherAddFavSkipGui = Unescape("Don't Show Options Window When Adding Favorite")
	Global $sLang_TipOtherAddFavApp     = Unescape("If The Active Window Is Not A Supported Application\nAdd The Application As A Favorite")
	Global $sLang_TipOtherAddFavCmd     = Unescape("Add Command Line Instead Of Only The Application Path")
	Global $sLang_TipOtherAddFavLnk     = Unescape("Add Target Of Shortcut File Instead Of The Shortcut File Itself")
	Global $sLang_TipOtherExplorer      = Unescape("Choose The File Manager To Open Folder Item\nYou can Use %s As The Path")
	Global $sLang_TipOtherBrowser       = Unescape("Choose The Browse To Open URL Item\nYou Can Use %s As The URL")
	Global $sLang_TipOtherSearch        = Unescape("Search The Selected Text If It Can Not Be Opened")

	; About
	Global $sLang_Website           = Unescape("Website")
	Global $sLang_CheckVer          = Unescape("Check Update")
	Global $sLang_CheckVerOnStart   = Unescape("Check Update On Startup")
	Global $sLang_Translate         = Unescape("Translated By rexx")
	Global $sLang_CopyRight         = Unescape("© 2006-2010 rexx")

	;menu item
	Global $sLang_RunSVSAdmin   = Unescape("Run SVS Admin")
	Global $sLang_Empty = Unescape("Empty")
EndFunc

Func Unescape($sString)
	$sString = StringReplace($sString, "\n", @LF)
	$sString = StringReplace($sString, "\t", @Tab)
	return $sString
EndFunc
