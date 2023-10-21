@echo off
setlocal

set /p version=Enter the version you're shipping (in SemVer format, e.g., 0.1.0): 

echo Shipping version %version%...

rem Create destination directory
mkdir dist\%version%

rem Copy directories and files
xcopy assets dist\%version%\assets\ /E /I
xcopy src dist\%version%\src\ /E /I
copy manual.pdf dist\%version%\
copy LICENSE dist\%version%\
copy CHANGELOG.md dist\%version%\
copy README.md dist\%version%\
copy typst.toml dist\%version%\

rem Run typst command
typst compile manual.typ

endlocal
