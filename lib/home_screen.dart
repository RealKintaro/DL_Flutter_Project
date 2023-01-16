import 'package:driver_state_detection/sessions_states.dart';
import 'package:flutter/services.dart';

import 'driver_state_detection_camera.dart';
import 'driver_state_detection_image.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void LandscapeModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver state Detector'),
        // add a button to the app bar
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SessionsInfo(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            // get app icon
            Column(children: const [
              Image(
                image: AssetImage('assets/images/driver.png'),
                height: 150,
                width: 150,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Driver State Detector',
                style: TextStyle(fontSize: 30),
              ),
            ]),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(170, 35),
                  ),
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
                  // size of the button
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(170, 35),
                  ),
                  child: const Text('Detect driver state from Live Camera'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          LandscapeModeOnly();
                          return const DriverStateFromLiveCamera();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ])),
    );
  }
}
