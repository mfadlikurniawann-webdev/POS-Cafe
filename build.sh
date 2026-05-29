#!/bin/bash

# Install Flutter if it doesn't exist
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to path for this script
export PATH="$PATH:`pwd`/flutter/bin"

# Enable Web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build Web
flutter build web --release
