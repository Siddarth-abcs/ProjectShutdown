' delay.vbs
' Waits 20 seconds, then shuts down silently

Set shell = CreateObject("WScript.Shell")

WScript.Sleep 10000  ' 10 seconds
shell.Run "shutdown /s /f /t 0", 0, False
