@echo off
REM Run With Me - double-click to play
set "GODOT=%USERPROFILE%\Tools\Godot463\Godot_v4.6.3-stable_win64.exe"
if not exist "%GODOT%" (
	echo 找不到 Godot：%GODOT%
	echo 請把 Godot 4.6.3 放到  %USERPROFILE%\Tools\Godot463\  或修改本檔的 GODOT 路徑。
	pause
	exit /b 1
)
start "" "%GODOT%" --path "%~dp0game"
