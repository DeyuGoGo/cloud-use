@echo off
setlocal EnableExtensions DisableDelayedExpansion
REM Run With Me - Godot override, asset preparation, then play.
set "M1_GODOT=%~1"
if defined M1_GODOT goto validate
if defined GODOT_EXE (
    set "M1_GODOT=%GODOT_EXE%"
    goto validate
)
set "M1_GODOT=%USERPROFILE%\Tools\Godot463\Godot_v4.6.3-stable_win64.exe"
if exist "%M1_GODOT%" goto validate
set "M1_GODOT="
for %%G in (godot.exe godot4.exe) do (
    for /f "delims=" %%P in ('where %%G 2^>nul') do if not defined M1_GODOT set "M1_GODOT=%%P"
)

:validate
if not defined M1_GODOT goto missing
if not exist "%M1_GODOT%" goto missing
"%M1_GODOT%" --headless --editor --import --path "%~dp0game"
if errorlevel 1 (
    echo Asset preparation failed. Open game\project.godot in Godot for details.
    pause
    exit /b 1
)
if /i "%~2"=="--prepare-only" exit /b 0
start "" "%M1_GODOT%" --path "%~dp0game"
exit /b 0

:missing
echo Godot 4.6.3 was not found.
echo Open game\project.godot in Godot, or set GODOT_EXE to its full executable path.
echo You can also drag the Godot executable onto this launcher.
pause
exit /b 1
