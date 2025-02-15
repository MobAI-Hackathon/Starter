# Drawzy Frontend

A Flutter-based mobile application frontend providing a modern and responsive user interface, utilizing Firebase Firestore and Realtime Database for data storage and synchronization.

## Table of Contents
1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Installation & Setup](#installation--setup)
4. [Usage](#usage)
5. [Assets](#assets)
6. [Platform Support](#platform-support)
7. [Contributing](#contributing)
8. [Sketch Prediction and Game Room Features](#sketch-prediction-and-game-room-features)
9. [Drawing Features](#drawing-features)

## Overview

This Flutter application serves as the frontend interface, supporting multiple platforms including iOS, Android, web, and desktop environments. It leverages Firebase Firestore and Realtime Database for efficient data management and real-time updates.

## Project Structure

```
frontend/
├── lib/             # Main Dart source code
├── assets/          # Static assets
├── asset/
│   └── images/      # Image resources
├── android/         # Android-specific configurations
├── ios/             # iOS-specific configurations
├── web/             # Web platform files
├── windows/         # Windows desktop configuration
├── linux/           # Linux desktop configuration
├── macos/           # macOS desktop configuration
└── pubspec.yaml     # Project dependencies and settings
```

## Installation & Setup

1. **Prerequisites**
   ```bash
   flutter --version   # Ensure Flutter is installed
   ```

2. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd frontend
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the Application**
   ```bash
   flutter run
   ```

## Firebase Integration

### Firebase Setup
1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Register the app for Android, iOS, and Web.
3. Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) and place them in the respective project folders.
4. Add Firebase dependencies in `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: latest_version
     cloud_firestore: latest_version
     firebase_database: latest_version
   ```
5. Initialize Firebase in your Flutter app:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(MyApp());
   }
   ```

### Firestore & Realtime Database Usage
- **Firestore** is used for structured and scalable document storage.
- **Realtime Database** is used for real-time data synchronization, such as live game room updates and collaborative drawing.

## Usage

1. **Development Mode**
   ```bash
   flutter run
   ```

2. **Build Release Version**
   ```bash
   flutter build <platform>
   ```
   Replace `<platform>` with:
   - `apk` for Android
   - `ios` for iOS
   - `web` for web
   - `windows` for Windows
   - `macos` for macOS
   - `linux` for Linux

## Assets

- Images and static resources are stored in the `asset/images/` directory
- Additional assets can be configured in `pubspec.yaml`

## Platform Support

This application is configured to run on:
- Android
- iOS
- Web
- Windows
- Linux
- macOS

Each platform has its specific configuration in its respective directory.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

**Note:** Update the dependencies regularly and ensure compatibility with the latest Flutter version.

## Sketch Prediction and Game Room Features

This project includes innovative features for sketch prediction and game room management, leveraging Firebase for seamless real-time collaboration.

### Features

#### Sketch Prediction
- **Real-time Prediction**: As users draw, the system predicts the sketch in real-time.
- **Deep Learning Model**: Utilizes a pre-trained deep learning model to recognize and predict sketches with enhanced accuracy.
- **Prediction Feedback**: Provides immediate feedback on the predicted sketch, helping users improve their drawings.
- **Accuracy Improvement**: Continuously improves prediction accuracy based on user interactions and corrections.

#### Game Room Management
- **Room Creation**: Users can create game rooms with unique IDs.
- **Room Joining**: Users can join existing game rooms using the room ID.
- **Collaborative Drawing**: Multiple users can draw on the same canvas in a game room.
- **Real-time Synchronization**: Drawings are synchronized in real-time across all users using Firebase Realtime Database.
- **Session Management**: Manages drawing sessions, including start and end times, and participant tracking.
- **Chat Functionality**: Integrated chat feature for users to communicate within the game room.
- **Score Tracking**: Tracks and displays scores for drawing games, encouraging friendly competition.

### Key Components

#### `SketchPredictionService`
- A service responsible for handling sketch prediction logic.
- Interfaces with the machine learning model to predict sketches based on user input.

#### `GameRoomManager`
- Manages the creation, joining, and synchronization of game rooms.
- Handles user sessions, drawing data, and real-time updates in Firebase.

#### `GameRoom`
- A model representing a game room, including room ID, participants, and drawing data.
- Manages the state of the game room and synchronizes data across all participants.

#### `ChatService`
- Provides chat functionality within game rooms.
- Manages sending and receiving messages in real-time via Firebase Realtime Database.

#### `ScoreTracker`
- Tracks and updates scores for drawing games.
- Displays scores to users in the game room.

## Drawing Features

This project includes advanced drawing capabilities that allow users to create and interact with various shapes and freehand drawings.

### Features

#### Freehand Drawing
- Users can draw freehand lines on the canvas.
- The freehand drawing mode supports different stroke widths and colors.

#### Shape Drawing
- Users can draw various shapes, including:
  - Lines
  - Rectangles
  - Circles
  - Triangles
  - Stars
  - Diamonds
  - Arrows
- Shapes can be drawn with both stroke and fill styles.

#### Eraser
- An eraser tool is available to remove parts of the drawing.
- The eraser size can be adjusted.

#### Undo and Redo
- Users can undo and redo their drawing actions.
- The undo and redo stacks are maintained to allow multiple levels of undo and redo.

#### Stroke and Fill Options
- Users can select different stroke widths for their drawings.
- Fill mode can be toggled to fill shapes with color.

#### Color Selection
- A color palette is available for users to choose different colors for their drawings.
- The selected color is applied to both freehand and shape drawings.

#### Drawing Synchronization
- Drawings are synchronized in real-time for collaborative sessions using Firebase Realtime Database.

#### Drawing Preview
- While drawing shapes, a preview of the shape is shown to the user before finalizing the drawing.

#### Drawing Session Management
- Drawing sessions are managed with unique session IDs.
- Users can join and collaborate in drawing sessions.

### Key Components

#### `AdvancedDrawingCanvas`
- The main widget for advanced drawing features.
- Supports freehand drawing, shape drawing, erasing, and real-time synchronization.

#### `DrawingPoint`
- A model representing a point in the drawing, including its position, paint properties, and shape information.

