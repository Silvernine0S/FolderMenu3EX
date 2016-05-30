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

**Important News As Of May 2016**. This is probably the end of the road for this program. This last update fixes all the remaining problems that I know about. The features that I introduced should now be stable and reliable (run as admin, support for XYplorer scripting, and various other fixes and modifications from the original code by rexx). The reasons I'm going to put this off even more from now on and that is time and also the complexity of getting this program working with the standard libraries that comes with newer version of AutoIt. rexx heavily modified many of the internal libraries that came with the very old AutoIt and as a result, updating AutoIt for better performance and newer features while making sure FolderMenu3 EX continues to work is challenging because his heavily modified libraries will require significant amount of time to properly merge with the newer updated libraries and I simply cannot give this program any more time than I have now. Currently I have continued to update AutoIt but replaced many of the libraries with his heavily modified libraries so it's not a full updated AutoIt. Anyway, thank you much for all those years and if you continue to use this program, thank you. If you want to find an alternative program, I would definitely suggest to take a look at Quick Access Popup located at http://www.quickaccesspopup.com and https://github.com/JnLlnd/QuickAccessPopup. I have recently ported the feature to allow launching applications with admin privileges (he's currently in the process of merging it) and perhaps I will port the feature to allow it to send scripts to XYplorer too. The program runs great, quick, relatively modern, and is also very much alive and receiving frequent updates and new features. Once again, thank you for everything!

####Most Recent Changes. See Changelog.txt For More.
----------------------------------------------------
	!! Version 3.1.2.2 EX 1.0.3.2 - May 30, 2016
	> Compiled using the latest AutoIt version 3.3.14.2
	! Fixed minor bug. Run favorite application as Admin still wasn't fully working.
	  Should be completely fixed now.
	! Fixed a critical bug. Under Options > Applications, FolderMenu3 EX did not
	  properly save the configuration keys for the toggled applications. For
	  example, if you were to toggle Explorer so that FolderMenu3 EX would run,
	  A key value of "-1" was saved instead of a proper "1". Which means on the
	  next startup of FolderMenu3 EX, it would read "-1" as disabled and Explorer
	  would then be togged off which will not allow FolderMenu3 EX to show up.
	  The current fix is a bit "stupid" as the original author have modified
	  AutoIt3's internal libraries so much that it would require a lot more time
	  to find exactly what's wrong. However, the current fix does work very well.
	> Both a "fix" and an improvement. XYplorer is written in VB6 and as a result,
	  has a form class for its GUI named ThunderRT6FormDC. I wrote the code to find
	  XYplorer assuming that it's the only running program written with VB6. Found out
	  the hard way that Dexpot was also written with VB6 so when Dexpot was running,
	  XYS scripting would be sent to it instead of XYplorer. The code is now fixed
	  and improved so that it will find the proper XYplorer window.

	!! Version 3.1.2.2 EX 1.0.3.1 - November 14, 2013
	! Fixed minor bug. For some systems, XYS scripts refuse to run.
	% Slight code cleanup and change.

	!! Version 3.1.2.2 EX 1.0.3 - November 14, 2013
	+ Added XYplorer Scripting and Admin to Special Items Menu When Adding New Items
		> There are now two XYplorer Scripting Special Items.
		  XYPlorer Scripting - "XYS::" As before, simply tell XYplorer to
		    load a script and run it. XYplorer's window will not be restored
			so if it's minimized, it will stay minimized while running the
			script.
		  XYplorer Scripting With Focus - "XYS_F::" Run the script and restore
		    XYplorer's main window back into view. For example this is useful
			for scripting where you tell XYplorer to go to a certain location:
			XYS_F::Goto "C:\Users\User\Desktop"
			If XYplorer's window is minimized, it will be restored and then go
			to "C:\Users\User\Desktop". If the focus mode is not used, it will
			simply go to the User's Desktop but XYplorer's window will remaind
			minimized.
	> All Commands "XYS::" "XYS_F" and "ADMIN::" Are CASE-INSENSITIVE.
		> xys:: = xYs:: = XYS::
		  admin:: = aDmIn:: = ADMIN::

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
