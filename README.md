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
	!! Version 3.1.2.2 EX 1.0.2 - November 11, 2013
	+ Added Support for XYplorer Script Commands. Thanks to Marco.
		> FolderMenu3 EX can now run XYplorer (a powerful and portable file manager)
		  script commands. All you need is XYplorer running and for any command you
		  want to use, in the file path, prefix the command with "xys::". Examples:
		  xys::msg "FolderMenu3EX & XYplorer!"
		  xys::goto "C:\Users\User\Desktop"
	+ Application With Admin Elevations Requirement Can Be Used Again!
		> "Run Elevated Apps Without Requiring FolderMenu to Be Elevated Itself"
		  once again can be used. No need to use "cmd.exe /c" since you can now just
		  use the prefix "admin::". Examples:
		  admin::C:\Path\To\Program.exe
		  Once again, make sure the program already have "Run this program as an
		  administrator" checked under the Compatibility tab for programs that does
		  not automatically pop up a UAC (since they do not have the Admin flag in
		  their manifest so that Windows will automatically prompt a UAC).
		  NOTE: Program parameters are still not supported since they way this code
		  works is by running the program using the shell. If parameters are needed,
		  you will still need to use "cmd.exe /c". Maybe a better way will be used
		  once I figured it out.
	+ Assigning of Icons for XYplorer Commands and Admin Required Applications
		> XYplorer Commands will automatically assign a XYplorer icon to it if an
		  icon is not manually assigned. Admin "admin::" will use the right icon
		  from the program that you want to elevate as admin.
	* Fixed Spacings in Drive Menu
	% Small tweaks and changed in clarity of comments in code. Also slight GUI change
	  for the About menu.

	!! Version 3.1.2.2 EX 1.0.1 - March 22, 2013
	* Removed "Run Elevated Apps Without Requiring FolderMenu to Be Elevated Itself"
		> Was not working well and did not allow program parameters. Will find a
		  workaround later. For now, if you want to be able to run an app with admin
		  capability, append "cmd.exe /c" to the path before the path to the application.
		  Make sure the program already have "Run this program as an administrator"
		  checked under the Compatibility tab of its file property for cmd.exe to
		  actually elevate the application.
	
	See Changelog.txt For More Past Changes.

####To Do
---------
	! GUI Design. Currrently when switching to to other languages, the texts
	  sometimes get hidden or overlap under other GUI controls due to their
	  length. This has low priority at this point since it will require a lot
	  of work and time which I don't have. So far it seems that English,
	  Korean and both Simplfied Chinese and Traditional Chinese does not have
	  this problem.
	! Decide on how to do version number or build number.
