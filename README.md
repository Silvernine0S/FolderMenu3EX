##FolderMenu3 EX
FolderMenu3 EX is a fork of the original Folder Menu v3 by rexx. So what is Folder Menu?
> "Folder Menu is a folder switching tool. You can quickly jump
to your favorite folders in explorer, open/save dialog or
command prompt...and more. You can also launch your favorite
folders, files or urls." -rexx http://foldermenu.sourceforge.net/

**DO NOT EXPECT UPDATES**. I am doing this on my spare time which I
don't have much of. Furthermore I'm new to programming in general
so please don't expect too much from me. I'm only doing what I
can do and share it with everyone. Enjoy!  

####Most Recent Changes. See Changelog.txt For More. 
----------------------------------------------------

	!! Version 3.1.2.2 EX 1.0.1 - March 22, 2013
	* Removed "Run Elevated Apps Without Requiring FolderMenu to Be Elevated Itself"
		> Was not working well and did not allow program parameters. Will find a
		  workaround later. For now, if you want to be able to run an app with admin
		  capability, append "cmd.exe /c" to the path before the path to the application.
		  Make sure the program already have "Run this program as an administrator"
		  checked under the Compatibility tab of its file property for cmd.exe to
		  actually elevate the application.

	!! Version 3.1.2.2 EX 1.0.0 - February 15, 2013
	+ Working Internally Referenced Icons at First Start Even if File Name is
	  Different From the Default FolderMenu.exe
		> For FIRST TIME RUN ONLY. Basically allows you to rename the file name
		  to whatever you want and the new FolderMenu.xml will correctly points
		  to the filename which mean internal icons should show up correctly on
		  first run. Previously on first run, if the file is renamed,
		  FolderMenu.xml settings will still reference FolderMenu.exe even thought
		  the name is now different. The result is certain icons in the menu and
		  Options won't show up.
	* Run Elevated Apps Without Requiring FolderMenu to Be Elevated Itself
		> FolderMenu runs as a Standard User. However, when launching a program that
		  requires admin privileges, there is no UAC prompt and the program will
		  silently fail to run. The only way to fix this is to run FolderMenu with
		  admin privileges. Now FolderMenu still run as a Standard User but when
		  a program that requires admin privileges is launched, a UAC prompt appears
		  and the program can then run without the need to elevate FolderMenu.
	* Changed Options GUI Font to Tahoma Size 10
	% Changed Options GUI to Accommodate Font Change
	> Converted to using tab characters only for indentations. Spaces character
	  Used only for spacing and alignment. Trim trailing spaces. Remove all empty
	  Limes more than two. Applied to all files.
	> Updated Default Configuration File. Added Drive List and "Toggle Hide File
	  Extensions" by Default. Added More File Types to Filters.
	> Original application name is Folder Menu 3. Renamed to FolderMenu3 EX.
	  Internally changed to new name. Compiled executable still named as
	  FolderMenu.exe as before. x64 however is named as FolderMenu_x64.exe.
	> Compiled using the latest AutoIt version 3.3.8.1. Used together with
	  SciTE4AutoIt 6/10/2012.
	---- New Build (MINOR) #1 - February 15, 2013
	> Small language changes (capitilization, tabs and spaces) and GUI adjustments.
	---- New Build #2 - February 15, 2013
	* Language files management. If there are any other language files
	  (with ext lng), FolderMenu3EX (and the original as well) adds them to
	  the Language Option Menu even though the language files does not belong
	  to it. Fixed by changing language file format from ".lng" to ".fmlng".
	---- New Build #3 - February 16, 2013
	> Forgot to mention that the original Folder Menu 3 named its configuration
	  file as Config.xml which can get confusing since some programs also used
	  the same file name and extension for its configuration file. To prevent
	  that from happening, the configuration file will now be named as
	  FolderMenu.xml. For previous users, please rename Config.xml to FolderMenu.xml.
	* Updated "Check Update". Program now check for updates from GitHub.
	! When introducing thew new ability for FolderMenu to launch elevated programs
	  without the need for FolderMenu to be elevated itself, "Command Prompt" and
	  "Command Prompt Here" broke. Fixed.
	---- New Build #4 - February 16, 2013
	! Check for Update did not work as expected. Fixed.
	> Executables are now zipped before uploading.
	---- New Build #4 - February 16, 2013
	! Check for Update really fixed this time.

####To Do
---------
	! GUI Design. Currrently when switching to to other languages, the texts
	  sometimes get hidden or overlap under other GUI controls due to their
	  length. This has low priority at this point since it will require a lot
	  of work and time which I don't have. So far it seems that English,
	  Korean and both Simplfied Chinese and Traditional Chinese does not have
	  this problem.
	! Decide on how to do version number or build number.
