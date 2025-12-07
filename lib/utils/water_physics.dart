import 'dart:ui';

class WaterPhysics {
  final int springCount = 100;
  final double spread = 0.25;
  final double tension = 0.02;
  final double dampening = 0.04;

  List<double> springs = [];
  List<double> velocities = [];
  List<double> leftDeltas = [];
  List<double> rightDeltas = [];

  WaterPhysics() {
    springs = List.filled(springCount, 0.0);
    velocities = List.filled(springCount, 0.0);
    leftDeltas = List.filled(springCount, 0.0);
    rightDeltas = List.filled(springCount, 0.0);
  }

  //Update the spring physics for one frame
  //[tilt]: Current tilt of device (-1.0 to 1.0)
  //[baseHeight]: Standard height of the water (0.0 to 1.0)
  void update(double tilt) {
    for (int i = 0; i < springCount; i++) {
      double pct = i / springCount;
      double xOffset = pct - 0.5;

      double targetHeight = xOffset * (tilt * 200);

      double displacement = springs[i] - targetHeight;
      double force = -tension * displacement - dampening * velocities[i];
      velocities[i] += force;
      springs[i] += velocities[i];
    }

    for (int j = 0; j < 8; j++) {
      for (int i = 0; i < springCount; i++) {
        if (i > 0) {
          leftDeltas[i] = spread * (springs[i] - springs[i - 1]);
          velocities[i - 1] += leftDeltas[i];
        }
        if (i < springCount - 1) {
          rightDeltas[i] = spread * (springs[i] - springs[i + 1]);
          velocities[i + 1] += rightDeltas[i];
        }
      }

      for (int i = 0; i < springCount; i++) {
        if (i > 0) {
          springs[i - 1] += leftDeltas[i];
        }
        if (i < springCount - 1) {
          springs[i + 1] += rightDeltas[i];
        }
      }
    }
  }

  List<Offset> getSpringPathPoints(Size size, double baseWaterLevel) {
    List<Offset> points = [];
    double widthStep = size.width / (springCount - 1);
    for (int i = 0; i < springCount; i++) {
      double x = i * widthStep;
      double y = (size.height * (1 - baseWaterLevel)) + springs[i];
      points.add(Offset(x, y));
    }
    return points;
  }
}
