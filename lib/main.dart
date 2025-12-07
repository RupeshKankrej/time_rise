import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_flow/screens/timer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const WaterTimerApp());
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Removes the black bar
      statusBarIconBrightness: Brightness.light, // White icons (battery, time)
      systemNavigationBarColor: Colors.transparent, // Transparent bottom nav
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

class WaterTimerApp extends StatelessWidget {
  const WaterTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TimerScreen(),
    );
  }
}
