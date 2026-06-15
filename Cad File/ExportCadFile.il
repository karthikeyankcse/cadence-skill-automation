axlCmdRegister("ExportCadFile" 'ExportCadFile)
procedure(ExportCadFile()
SrcName1 = "//sng-psrvr06/Cadence_Skills/CadFile/Xtrct.cmd"
SrcName2 = "//sng-psrvr06/Cadence_Skills/CadFile/Xtrct.bat"
SrcName3 = "//sng-psrvr06/Cadence_Skills/CadFile/Xtrct.scr"
SrcName4 = "//sng-psrvr06/Cadence_Skills/CadFile/Xtrctnet.bat"
SrcName5 = "//sng-psrvr06/Cadence_Skills/CadFile/Xtrctnet.cmd"
SrcName6 = "//sng-psrvr06/Cadence_Skills/CadFile/Xtrctnet.scr"
DestName1 = sprintf(nil "%s/%s", axlGetVariable("cwd"), "Xtrct.cmd")
DestName2 = sprintf(nil "%s/%s", axlGetVariable("cwd"), "Xtrct.bat") 
DestName3 = sprintf(nil "%s/%s", axlGetVariable("cwd"), "Xtrct.scr") 
DestName4 = sprintf(nil "%s/%s", axlGetVariable("cwd"), "Xtrctnet.bat") 
DestName5 = sprintf(nil "%s/%s", axlGetVariable("cwd"), "Xtrctnet.cmd") 
DestName6 = sprintf(nil "%s/%s", axlGetVariable("cwd"), "Xtrctnet.scr")  
unless(axlOSFileCopy(SrcName1 DestName1 nil) axlUIConfirm("file copy FAILED"))
unless(axlOSFileCopy(SrcName2 DestName2 nil) axlUIConfirm("file copy FAILED"))
unless(axlOSFileCopy(SrcName3 DestName3 nil) axlUIConfirm("file copy FAILED"))
unless(axlOSFileCopy(SrcName4 DestName4 nil) axlUIConfirm("file copy FAILED"))
unless(axlOSFileCopy(SrcName5 DestName5 nil) axlUIConfirm("file copy FAILED"))
unless(axlOSFileCopy(SrcName6 DestName6 nil) axlUIConfirm("file copy FAILED"))
designName = axlCurrentDesign()
sprintf(cmddata "cmd /C XTRCT %s", designName)
system(cmddata)
deleteFile("Xtrct.cmd")
deleteFile("Xtrct.bat")
deleteFile("Xtrct.scr")
deleteFile("Xtrctnet.bat")
deleteFile("Xtrctnet.cmd")
deleteFile("Xtrctnet.scr")
axlUIConfirm("File Generated Successfully..!")
)