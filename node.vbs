Dim shell, fso, scriptDir

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the directory of this script
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Change working directory
shell.CurrentDirectory = scriptDir

' Run npm install silently (hidden CMD)
shell.Run "cmd /c npm install", 0, True
