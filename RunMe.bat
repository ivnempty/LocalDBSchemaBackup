@ECHO OFF

ECHO This Script Works On Local DB Server Only

SET savepath=.\DBSchemaBackup

ECHO Exporting Agent Jobs, Linked Servers
PowerShell.exe -ExecutionPolicy Bypass -File .\Script\ExportOthers.ps1 %savepath%

ECHO Exporting Databases
PowerShell.exe -ExecutionPolicy Bypass -File .\Script\ExportDBSchema.ps1 "DB_1" %savepath%
REM PowerShell.exe -ExecutionPolicy Bypass -File .\Script\ExportDBSchema.ps1 "DB_2" %savepath%
REM PowerShell.exe -ExecutionPolicy Bypass -File .\Script\ExportDBSchema.ps1 "DB_3" %savepath%

PAUSE
