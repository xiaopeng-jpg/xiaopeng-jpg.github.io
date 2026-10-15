@echo off
setlocal
cd /d "%~dp0"
echo ==========================================
echo   Publish this folder to GitHub Pages
echo ==========================================
where git >nul 2>nul
if errorlevel 1 (
  echo.
  echo [X] Git not found.
  echo     Install it first: https://git-scm.com/download/win
  echo     Or use GitHub Desktop / the web upload steps in README.md
  echo.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
echo.
pause
