@echo off
set "GODOT=C:\Ishant\Valuto Royale\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (
  echo Open godot\project.godot in Godot 4 and press F5.
  pause
  exit /b 1
)
start "Battle of Buxar" "%GODOT%" --path "%~dp0godot"
