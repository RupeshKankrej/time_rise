# ⏳ Quicksand Timer

A minimalist, physics-based productivity timer built with Flutter. 

Unlike standard digital timers, Quicksand Timer utilizes the device's **accelerometer sensors** to create a tactile experience. The UI mimics an hourglass: flipping the phone 180° resets the gravity, rotates the interface, and starts a fresh session.

## 📱 Features
* **Physics-Driven Interaction:** Uses `sensors_plus` to detect device orientation (Y-axis gravity) for starting and resetting the timer.
* **Dynamic Visuals:** Custom "falling sand" animation that creates a liquid progress effect.
* **Smart Contrast Masking:** Implements complex layer masking (using `ClipRect` and `Stack`) to dynamically invert text color as the sand passes over it.
* **Gesture Controls:** Tap-to-edit time picker with hour/minute/second precision.
* **Adaptive UI:** The interface automatically rotates 180° when the phone is flipped, ensuring readability regardless of orientation.

## 🛠 Tech Stack
* **Framework:** Flutter & Dart
* **State Management:** `setState` & `Timer.periodic` (High-precision loop)
* **Hardware Sensors:** `sensors_plus` (Accelerometer event streams)
* **UI/UX:** `AnimatedRotation`, `CupertinoTimerPicker`, `Custom Custom Layouts`

## 🧩 How It Works
The app locks the device orientation to Portrait to prevent OS interference. It then listens to the accelerometer stream:
1.  **Gravity Detection:** When the Y-axis value drops below `-4.0` (Upside Down), the app triggers a "Flip" state.
2.  **State Logic:** This stops the current timer, resets the duration, and starts the sand flow immediately.
3.  **Visual Rendering:** The screen renders two stacked layers (Dark text on Light bg / Light text on Dark bg). As time progresses, a `ClipRect` reveals the top layer pixel-by-pixel, creating a seamless color-change effect on the numbers.

## 🚀 Getting Started
1.  Clone the repository:
    ```bash
    git clone [https://github.com/yourusername/quicksand-timer.git](https://github.com/yourusername/quicksand-timer.git)
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run on a physical device (Sensors required):
    ```bash
    flutter run
    ```
