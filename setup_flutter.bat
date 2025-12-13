@echo off
echo HeaLyri Flutter Setup Script
echo ===========================
echo.

REM Check if Flutter is already installed
where flutter >nul 2>nul
if %ERRORLEVEL% == 0 (
    echo Flutter is already installed.
    flutter --version
    goto :check_dependencies
)

echo Flutter SDK not found. Let's set it up!
echo.

REM Create flutter directory if it doesn't exist
if not exist flutter (
    echo Creating flutter directory...
    mkdir flutter
) else (
    echo Flutter directory already exists.
)

echo.
echo Please download Flutter SDK from:
echo https://flutter.dev/docs/get-started/install/windows
echo.
echo After downloading, extract the zip file to the 'flutter' directory in this project.
echo The structure should be: %CD%\flutter\bin\flutter.bat
echo.
echo Press any key when you have completed this step...
pause >nul

REM Check if Flutter is now available
if exist flutter\bin\flutter.bat (
    echo Flutter SDK found!
    echo Adding Flutter to PATH for this session...
    set PATH=%PATH%;%CD%\flutter\bin
    echo.
    echo Testing Flutter installation...
    flutter --version
    
    if %ERRORLEVEL% == 0 (
        echo Flutter is working correctly!
    ) else (
        echo There was an issue with the Flutter installation.
        echo Please check the Flutter SDK and try again.
        goto :eof
    )
) else (
    echo Flutter SDK not found at %CD%\flutter\bin\flutter.bat
    echo Please make sure you extracted the Flutter SDK correctly.
    goto :eof
)

:check_dependencies
echo.
echo Checking Flutter dependencies...
flutter doctor -v

echo.
echo Setting up project dependencies...
flutter pub get

echo.
echo Setup complete! You can now run the app with:
echo flutter run
echo.
echo For more information, see the README.md and docs/SDK_IDE_setup.md files.
