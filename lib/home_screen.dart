import 'package:driver_state_detection/sessions_states.dart';

import 'driver_state_detection_camera.dart';
import 'driver_state_detection_image.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver state Detector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Detect driver state from the Image'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DriverStateFromImage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Detect driver state from Live Camera'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DriverStateFromLiveCamera(),
                  ),
                );
              },
            ),
            ElevatedButton(
                onPressed: (() {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SessionsInfo(),
                    ),
                  );
                }),
                child: const Text('Retreive Sessions'))
          ],
        ),
      ),
    );
  }
}
