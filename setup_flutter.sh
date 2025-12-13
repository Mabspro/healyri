#!/bin/bash

echo "HeaLyri Flutter Setup Script"
echo "==========================="
echo

# Check if Flutter is already installed
if command -v flutter &> /dev/null; then
    echo "Flutter is already installed."
    flutter --version
    CHECK_DEPENDENCIES=true
else
    echo "Flutter SDK not found. Let's set it up!"
    echo

    # Create flutter directory if it doesn't exist
    if [ ! -d "flutter" ]; then
        echo "Creating flutter directory..."
        mkdir flutter
    else
        echo "Flutter directory already exists."
    fi

    echo
    echo "Please download Flutter SDK from:"
    echo "https://flutter.dev/docs/get-started/install/macos"
    echo
    echo "After downloading, extract the zip file to the 'flutter' directory in this project."
    echo "The structure should be: $(pwd)/flutter/bin/flutter"
    echo
    echo "Press Enter when you have completed this step..."
    read

    # Check if Flutter is now available
    if [ -f "flutter/bin/flutter" ]; then
        echo "Flutter SDK found!"
        echo "Adding Flutter to PATH for this session..."
        export PATH="$PATH:$(pwd)/flutter/bin"
        echo
        echo "Testing Flutter installation..."
        flutter --version
        
        if [ $? -eq 0 ]; then
            echo "Flutter is working correctly!"
            CHECK_DEPENDENCIES=true
        else
            echo "There was an issue with the Flutter installation."
            echo "Please check the Flutter SDK and try again."
            exit 1
        fi
    else
        echo "Flutter SDK not found at $(pwd)/flutter/bin/flutter"
        echo "Please make sure you extracted the Flutter SDK correctly."
        exit 1
    fi
fi

if [ "$CHECK_DEPENDENCIES" = true ]; then
    echo
    echo "Checking Flutter dependencies..."
    flutter doctor -v

    echo
    echo "Setting up project dependencies..."
    flutter pub get

    echo
    echo "Setup complete! You can now run the app with:"
    echo "flutter run"
    echo
    echo "For more information, see the README.md and docs/SDK_IDE_setup.md files."
    
    # Add Flutter to PATH permanently
    echo
    echo "Would you like to add Flutter to your PATH permanently? (y/n)"
    read ADD_TO_PATH
    
    if [ "$ADD_TO_PATH" = "y" ] || [ "$ADD_TO_PATH" = "Y" ]; then
        SHELL_PROFILE=""
        if [ -f "$HOME/.zshrc" ]; then
            SHELL_PROFILE="$HOME/.zshrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_PROFILE="$HOME/.bash_profile"
        elif [ -f "$HOME/.bashrc" ]; then
            SHELL_PROFILE="$HOME/.bashrc"
        fi
        
        if [ -n "$SHELL_PROFILE" ]; then
            echo "export PATH=\"\$PATH:$(pwd)/flutter/bin\"" >> "$SHELL_PROFILE"
            echo "Flutter has been added to your PATH in $SHELL_PROFILE"
            echo "Please restart your terminal or run 'source $SHELL_PROFILE' to apply the changes."
        else
            echo "Could not find shell profile file. Please add the following line to your shell profile manually:"
            echo "export PATH=\"\$PATH:$(pwd)/flutter/bin\""
        fi
    fi
fi
