Dim shell, fso, scriptDir, nodeInstalled, nodeCheck, nodeInstaller

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Get script directory
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
shell.CurrentDirectory = scriptDir

' Check if Node.js is installed
nodeInstalled = True
On Error Resume Next
nodeCheck = shell.Exec("cmd /c node -v").StdOut.ReadAll
If Err.Number <> 0 Then
    nodeInstalled = False
    Err.Clear
End If
On Error GoTo 0

' Install Node.js if not installed
If nodeInstalled = False Then
    nodeInstaller = scriptDir & "\nodejs.msi"

    ' Download Node.js LTS installer
    shell.Run "cmd /c powershell -Command ""Invoke-WebRequest https://nodejs.org/dist/v18.19.0/node-v18.19.0-x64.msi -OutFile '" & nodeInstaller & "'""", 0, True

    ' Install Node.js silently
    shell.Run "msiexec /i """ & nodeInstaller & """ /quiet /norestart", 0, True
End If

' Run npm install (or install a specific module)
shell.Run "cmd /c npm install", 0, True
