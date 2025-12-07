import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:time_flow/constants/app_colors.dart';
import 'package:time_flow/utils/time_helper.dart';
import 'package:time_flow/utils/water_physics.dart';
import 'package:vibration/vibration.dart';

import '../widgets/spring_water_clipper.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  //Sand falling mechanism colors
  // final Color _baseDarkColor = const Color(0xFF3E2723);
  // final Color _sandLightColor = const Color(0xFFD7CCC8);

  final int _tickRate = 16;

  Duration _selectedDuration = const Duration(minutes: 1);
  Duration _remainingTime = const Duration(minutes: 1);
  Timer? _timer;

  bool _isRunning = false;
  bool _isUpsideDown = false;

  final WaterPhysics _waterPhysics = WaterPhysics();
  double _currentTilt = 0.0;

  late AnimationController _waveController;
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    _initSensors();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    _waveController.dispose();
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
      double targetTilt = event.x / 10.0;
      if (mounted) {
        setState(() {
          _currentTilt = _currentTilt + (targetTilt - _currentTilt) * 0.1;
        });
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
    const Duration(seconds: 2);
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

          Vibration.hasVibrator().then((hasVibrator) {
            if (hasVibrator == true) {
              Vibration.vibrate(duration: 500); // Vibrates for half a second
            }
          });
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

  void _showTimePicker() {
    // We pause the timer while picking to avoid confusion
    bool wasRunning = _isRunning;
    _stopTimer();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: AppColors.baseDarkColor,
          child: SafeArea(
            top: false,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(
                    color: AppColors.fallingLightColor,
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
    bool isDone = _remainingTime.inMilliseconds == 0;
    String displayText;
    double fontSize;
    if (isDone) {
      displayText = "Time's Up"; // <--- The Completion Message
      fontSize = 100; // Slightly smaller to fit two words
    } else {
      displayText = TimeHelper.formatTime(_remainingTime);
      if (_remainingTime.inHours > 0) {
        fontSize = 80; // HH:MM:SS (Needs more space)
      } else if (_remainingTime.inMinutes > 0) {
        fontSize = 120; // MM:SS (Standard big size)
      } else {
        fontSize = 160; // SS (Massive countdown)
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _showTimePicker,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  height: 0.9,
                  letterSpacing: -4.0,
                  color: textColor,
                  // fontFamily: 'Courier',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalMs = _selectedDuration.inMilliseconds.toDouble();
    final double remainingMs = _remainingTime.inMilliseconds.toDouble();

    double progress = totalMs > 0 ? 1.0 - (remainingMs / totalMs) : 0.0;

    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.baseDarkColor,
      body: Center(
        child: AnimatedRotation(
          turns: _isUpsideDown ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: Stack(
            children: [
              // 1. Sand Layer
              // Since "Up" changes meaning, we just keep the sand falling from the "Screen Top".
              Container(
                color: AppColors.baseDarkColor,
                width: double.infinity,
                height: double.infinity,
                child: _buildContent(textColor: AppColors.fallingLightColor),
              ),

              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    _waterPhysics.update(_currentTilt / 2.0);

                    final points = _waterPhysics.getSpringPathPoints(
                      MediaQuery.of(context).size,
                      progress,
                    );
                    return ClipPath(
                      clipper: SpringWaterClipper(
                        points: points,
                        progress: progress,
                      ),
                      child: Container(
                        color: AppColors.fallingLightColor,
                        width: double.infinity,
                        height: double.infinity,
                        // The Text inside here is DARK, creating the negative effect
                        child: _buildContent(
                          textColor: AppColors.baseDarkColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
