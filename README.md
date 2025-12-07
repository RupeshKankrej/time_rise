# 🌊 Time Flow

**Time Flow** is an immersive, physics-based productivity timer built with Flutter.

Instead of a standard countdown, it visualizes time as a **liquid** that reacts to your physical movements. By simulating spring-mass physics and using device accelerometers, the water sloshes, tilts, and settles just like real liquid in a glass.

## ✨ Features

* **💧 Real-Time Fluid Physics:** Uses a custom spring-mass physics engine (`water_physics.dart`) to simulate tension, dampening, and spread, creating realistic water jiggle and splash effects.
* **📱 Gravity-Aware Tilt:** Tilt your phone left or right, and the water surface adjusts angle instantly using the device's **accelerometer**.
* **🔄 Flip-to-Reset:** A tactile interaction model—flip your phone upside down to instantly reset the timer and start a new session.
* **📳 Haptic Feedback:** Uses the `vibration` package to provide a heavy impact buzz when the timer hits zero.
* **🎨 Edge-to-Edge UI:** Features a completely immersive design that draws behind the Android/iOS status bars and notches.
* **🌑 Adaptive Text:** Smart layer masking ensures the timer text remains visible by dynamically changing color as the water level passes over it.

## 🛠️ Tech Stack

* **Framework:** Flutter & Dart
* **Sensors:** `sensors_plus` (Accelerometer events)
* **Haptics:** `vibration` (Hardware control)
* **Rendering:** `CustomClipper` & `Canvas` (Low-level drawing)
* **Architecture:** Modular file structure (Separated Logic, Physics, and UI)

## 📂 Project Structure

The project has been refactored for professional maintainability:

```text
lib/
├── main.dart                   # Entry point (Orientation lock & System UI config)
├── constants/
│   └── app_colors.dart         # Theme colors (Navy & Cyan)
├── screens/
│   └── timer_screen.dart       # Main UI logic (Sensors, Timer Loop, State)
├── utils/
│   ├── water_physics.dart      # The Spring-Mass physics simulation engine
│   └── time_helper.dart        # Duration formatting logic
└── widgets/
    └── spring_water_clipper.dart # Custom Painter that draws the water shape
```

## 🚀 Getting Started

1.  Clone the repository:
    ```bash
    git clone [https://github.com/RupeshKankrej/time_rise.git](https://github.com/RupeshKankrej/time_rise.git)
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run on a physical device (Sensors required):
    ```bash
    flutter run
    ```