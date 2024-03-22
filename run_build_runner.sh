#!/bin/bash

cd feature/home
echo "Running build_runner at 'home'..."
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

cd ../..

cd feature/detail
echo "Running build_runner at 'detail'..."
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

cd ../..

echo "Dependencies finished."
