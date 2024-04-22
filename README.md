# study_buddy_fl

# Project Name: Study Buddy

The folder structure of this project is as follows:

- All the produced code is in the lib folder. This folder is structured in a way for easy navigation. It has folders as for the different UI pages, for example login, message, profile, search etc..
- The main function to execute the application is in main.dart uneder the lib folder.
- All the images are in the asset folder

## Introduction

This document provides the instructions necessary to set up and run the Study Buddy Flutter application. Follow these steps to ensure that the application is configured and runs correctly on your system.

## Prerequisites

For this project, only the Android version of the application has been tested, the iOS version has not been tested because of the unavailability of Xcode, which only runs on Mac.
Before you begin, ensure you have met the following requirements:

- **Flutter SDK**: Installed and configured. [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).
  Choose Windows as the platform, then choose Android as the type of application. After this follow the instructions on how to install the Flutter SDK and update the Windows path variable
- **Android Studio**: For Android emulation. [Android Studio Download](https://developer.android.com/studio)
- **Xcode**: For iOS emulation (Mac only). [Xcode Download](https://developer.apple.com/xcode/)
- **Visual Studio Code**: Optional, recommended for code editing. [VS Code Download](https://code.visualstudio.com/)

## Setup Instructions

### 1. Install Flutter SDK

Download and install the Flutter SDK from the Flutter official website. Add the Flutter tool to your path as described in the installation guide linked above.

### 2. Extract the Project

Unzip the project file to your preferred directory:

### 3. Install Dependencies

Navigate to the project directory in your terminal and run the following command to install all the necessary dependencies: flutter pub get
Or if you use Visual Studio Code, you can open the unzipped folder of the application, go to the terminal within VS Code, and run: flutter pub get

### 4. Set Up Emulators

- **Android Emulator**:
  - Open Android Studio.
  - Click on More Actions
  - Click on Virtual Device Manager
  - Press the add icon on the left and select the device you want to add. Pixel devices are recommended, such as Pixel 7, as that was the device I tested the application
  - Once the android emulator has been created, you need to click on the start button on the right to run the emulator.
- **iOS Simulator** (Mac only):
  - Open Xcode.
  - Go to Preferences > Components and install your preferred simulators.

## Running the Application

### Using Command Line

Run the following command in your terminal within the project directory: flutter run.
Or if using VS Code, you need to select the emulator first, using the bottom line in VS Code window, then click on Run from the top Menu, and click Run without debugging.
Wait a couple of minutes so that the application can build and enjoy the show.

## Additional Information

- **Troubleshooting**: If you encounter any issues during the setup, refer to the [Flutter Troubleshooting Guide](https://flutter.dev/docs/testing/troubleshooting).
- **Updating Flutter**: To ensure compatibility, you might need to update Flutter to its latest version. Use `flutter upgrade` to update Flutter.

Thank you for testing the Study Buddy application. Please report any issues or feedback to the development team. Contact sykat12@gmail.com.
