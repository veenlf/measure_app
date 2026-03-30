import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Measure',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ARMeasureScreen(),
    );
  }
}

class ARMeasureScreen extends StatefulWidget {
  const ARMeasureScreen({super.key});

  @override
  State<ARMeasureScreen> createState() => _ARMeasureScreenState();
}

class _ARMeasureScreenState extends State<ARMeasureScreen> {
  List<Measurement> measurements = [];
  bool isMeasuring = false;
  String currentStatus = "Ready to measure";
  double currentDistance = 0.0;
  int measurementStep = 0; // 0 = not measuring, 1 = waiting for first tap, 2 = waiting for second tap

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Measure Tool'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                measurements.clear();
                currentDistance = 0;
                measurementStep = 0;
                currentStatus = "Ready to measure";
              });
              _showSnackBar('All measurements cleared');
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Column(
        children: [
          // AR Camera View (Simulated for Web)
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    // Camera placeholder
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey[900]!, Colors.grey[800]!],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Tap anywhere to measure',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Point A → Point B = Distance',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Crosshair
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.center_focus_strong,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),

                    // Current measurement display
                    if (currentDistance > 0 && measurementStep == 0)
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Last Measurement',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${currentDistance.toStringAsFixed(1)} cm',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Measuring status
                    if (measurementStep > 0)
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                measurementStep == 1 ? '📍 Tap to place Point A' : '📍 Tap to place Point B',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              LinearProgressIndicator(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Status
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentStatus,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Recent Measurements
          if (measurements.isNotEmpty)
            Container(
              height: 120,
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Recent Measurements',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: measurements.length,
                      itemBuilder: (context, index) {
                        final m = measurements[index];
                        return Container(
                          width: 130,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.straighten, size: 28, color: Colors.blue),
                              const SizedBox(height: 8),
                              Text(
                                '${m.distance.toStringAsFixed(1)} cm',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${m.dateTime.hour}:${m.dateTime.minute.toString().padLeft(2, '0')}:${m.dateTime.second.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Control Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: measurementStep == 0 ? _startMeasurement : null,
                        icon: const Icon(Icons.tap_and_play),
                        label: Text(measurementStep == 0 ? 'Start Measuring' : 'Measuring...'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: measurementStep == 0 ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openARGuide,
                        icon: const Icon(Icons.view_in_ar),
                        label: const Text('AR Guide'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showHelp,
                        icon: const Icon(Icons.info),
                        label: const Text('Help'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap() {
    if (measurementStep == 1) {
      // First tap - Place Point A
      setState(() {
        measurementStep = 2;
        currentStatus = 'Tap again to place Point B';
      });
      _showSnackBar('📍 Point A placed');
    }
    else if (measurementStep == 2) {
      // Second tap - Place Point B and calculate distance
      final simulatedDistance = 15.0 + (DateTime.now().millisecondsSinceEpoch % 500) / 10;

      setState(() {
        currentDistance = simulatedDistance;
        measurementStep = 0;
        currentStatus = 'Measurement complete! ${simulatedDistance.toStringAsFixed(1)} cm';

        // Save measurement
        measurements.insert(
          0,
          Measurement(
            id: DateTime.now().millisecondsSinceEpoch,
            distance: simulatedDistance,
            dateTime: DateTime.now(),
          ),
        );
      });

      _showSnackBar('📏 Measured: ${simulatedDistance.toStringAsFixed(1)} cm');
    }
  }

  void _startMeasurement() {
    setState(() {
      measurementStep = 1;
      currentStatus = 'Tap screen to place Point A';
    });
    _showSnackBar('Tap anywhere on the camera view to start measuring');
  }

  void _openARGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AR on iPhone'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To view 3D models in AR on your iPhone:'),
            SizedBox(height: 12),
            Text('1. Open this app in Safari'),
            Text('2. Visit this URL:'),
            SizedBox(height: 8),
            SelectableText(
              'https://developer.apple.com/augmented-reality/quick-look/',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
            SizedBox(height: 12),
            Text('3. Tap any .usdz file'),
            Text('4. Tap "View in AR"'),
            SizedBox(height: 16),
            Text('💡 For true AR measurement, you would need:'),
            Text('• A Mac computer'),
            Text('• Xcode installed'),
            Text('• Native iOS Flutter app with ARKit'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Measure'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📏 How it works:'),
            SizedBox(height: 8),
            Text('1. Tap "Start Measuring"'),
            Text('2. Tap camera view to place Point A'),
            Text('3. Tap again to place Point B'),
            Text('4. Distance is calculated automatically'),
            SizedBox(height: 12),
            Text('📊 Features:'),
            Text('• Save measurement history'),
            Text('• View recent measurements'),
            Text('• Clear all measurements'),
            SizedBox(height: 12),
            Text('⚠️ Note: This is a simulation.'),
            Text('For real AR measurements:'),
            Text('• Use iPhone\'s built-in Measure app'),
            Text('• Or build native ARKit app on a Mac'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class Measurement {
  final int id;
  final double distance;
  final DateTime dateTime;

  Measurement({
    required this.id,
    required this.distance,
    required this.dateTime,
  });
}

//sAS