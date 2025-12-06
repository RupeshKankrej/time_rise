import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const QuickSandTimer());
  });
}

class QuickSandTimer extends StatelessWidget {
  const QuickSandTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const QuickSandScreen(),
    );
  }
}

class QuickSandScreen extends StatefulWidget {
  const QuickSandScreen({super.key});

  @override
  State<QuickSandScreen> createState() => _QuickSandScreenState();
}

class _QuickSandScreenState extends State<QuickSandScreen> {
  final Color _baseDarkColor = const Color(0xFF3E2723);
  final Color _sandLightColor = const Color(0xFFD7CCC8);
  final int _tickRate = 16;

  Duration _selectedDuration = const Duration(minutes: 1);
  Duration _remainingTime = const Duration(minutes: 1);
  Timer? _timer;

  bool _isRunning = false;
  bool _isUpsideDown = false;

  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  void _initSensors() {
    _sensorSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      // Logic:
      // If we are currently "Normal" (False) AND Y < -4.0  -> Flip Detected
      // If we are currently "UpsideDown" (True) AND Y > 1.0 -> Flip Detected

      // We use thresholds to detect the state change
      bool flipToUpsideDown = (!_isUpsideDown && event.y < -4.0);
      bool flipToNormal = (_isUpsideDown && event.y > 1.0);

      // If EITHER flip happens, we Reset and Start.
      if (flipToUpsideDown || flipToNormal) {
        _handleRotationChange(
          flipToUpsideDown,
        ); // Pass true if going UpsideDown
      }
    });
  }

  void _handleRotationChange(bool targetIsUpsideDown) {
    // 1. Stop any existing timer
    _stopTimer();

    setState(() {
      // 2. Update Rotation State (so text flips correctly)
      // If targetIsUpsideDown is true (we flipped down), _isUpsideDown becomes true.
      // If targetIsUpsideDown is false (we flipped up), _isUpsideDown becomes false.
      _isUpsideDown = targetIsUpsideDown ? true : false;

      // 3. Reset Time
      _remainingTime = _selectedDuration;
    });

    // 4. Start Timer Automatically
    _startTimer();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: _tickRate), (timer) {
      setState(() {
        final newMiliSeconds = _remainingTime.inMilliseconds - _tickRate;
        if (newMiliSeconds <= 0) {
          _remainingTime = Duration.zero;
          _stopTimer();
          _remainingTime = _selectedDuration; // Reset for next time
        } else {
          _remainingTime = Duration(milliseconds: newMiliSeconds);
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    if (_isRunning) {
      setState(() {
        _isRunning = false;
      });
    }
  }

  // --- UI HELPERS ---

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    } else if (duration.inMinutes > 0) {
      return "$minutes:$seconds";
    } else {
      return seconds;
    }
  }

  void _showTimePicker() {
    // We pause the timer while picking to avoid confusion
    bool wasRunning = _isRunning;
    _stopTimer();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: _baseDarkColor,
          child: SafeArea(
            top: false,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(
                    color: _sandLightColor,
                    fontSize: 24,
                  ),
                ),
              ),
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hms,
                initialTimerDuration: _selectedDuration,
                onTimerDurationChanged: (Duration newDuration) {
                  if (newDuration.inSeconds > 0) {
                    setState(() {
                      _selectedDuration = newDuration;
                      _remainingTime = newDuration; // Instant Update
                    });
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent({required Color textColor}) {
    return SafeArea(
      child: Center(
        child: AnimatedRotation(
          turns: _isUpsideDown ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showTimePicker,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    _formatTime(_remainingTime),
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: textColor, // <--- Color is dynamic
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalMs = _selectedDuration.inMilliseconds.toDouble();
    final double remainingMs = _remainingTime.inMilliseconds.toDouble();

    double progress = totalMs > 0 ? 1.0 - (remainingMs / totalMs) : 0.0;

    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _baseDarkColor,
      body: Stack(
        children: [
          // 1. Sand Layer
          // Since "Up" changes meaning, we just keep the sand falling from the "Screen Top".
          Container(
            color: _baseDarkColor,
            width: double.infinity,
            height: double.infinity,
            child: _buildContent(textColor: _sandLightColor),
          ),

          // LAYER 2: TOP (Light Sand BG, Dark Text)
          // This layer sits on top but is CLIPPED (hidden) based on progress.
          ClipRect(
            child: Align(
              // If UpsideDown, fill from Bottom. If Normal, fill from Top.
              // This ensures gravity always looks correct.
              alignment: Alignment.topCenter,
              heightFactor: progress, // <--- This reveals the layer!
              child: Container(
                color: _sandLightColor, // The Sand Color
                width: double.infinity,
                height: double.infinity,
                // The Text inside here is DARK, creating the negative effect
                child: _buildContent(textColor: _baseDarkColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
