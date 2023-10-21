@echo off

rem Process all .typ files in /gallery and its subdirectories
for /r gallery %%i in (*.typ) do (
    typst c "%%~fi" "%%~fi.png" --root ../ --format png
    echo Processed file: %%~fi
)