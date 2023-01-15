import 'package:driver_state_detection/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

import './boundary_box.dart';
import 'firebase_options.dart';

class DriverStateFromLiveCamera extends StatefulWidget {
  const DriverStateFromLiveCamera({Key? key}) : super(key: key);

  @override
  DriverStateFromLiveCameraState createState() =>
      DriverStateFromLiveCameraState();
}

class DriverStateFromLiveCameraState extends State<DriverStateFromLiveCamera> {
  late List<CameraDescription> cameras;
  CameraController? cameraController;
  bool isDetecting = false;
  List<dynamic>? _recognitions;
  // ignore: non_constant_identifier_names
  var prev_class = '';
  int _imageHeight = 0;
  int _imageWidth = 0;

  // Dictionary for each class
  Map<String, dynamic> classes = {
    'Time': DateTime.now().toString(),
    'OPERATING RADIO': 0,
    'DRINKING': 0,
    'TEXTING LEFT': 0,
    'TEXTING RIGHT': 0,
    'TALKING TO PASSENGER': 0,
    'SAFE DRIVING': 0,
    'HAIR AND MAKEUP': 0,
    'REACHING BEHIND': 0,
    'TALKING PHONE RIGHT': 0,
    'TALKING PHONE LEFT': 0,
  };

  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    loadModel();
    // Initialize Firebase with default values
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initializeCamera();
  }

  void loadModel() async {
    await Tflite.loadModel(
      model: "assets/ml_trained_model/converted_model.tflite",
      labels: "assets/ml_trained_model/labels.txt",
    );
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController!.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        cameraController!.startImageStream(
          (CameraImage img) {
            if (!isDetecting) {
              isDetecting = true;
              Tflite.runModelOnFrame(
                bytesList: img.planes.map(
                  (plane) {
                    return plane.bytes;
                  },
                ).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then(
                (recognitions) {
                  if (recognitions![0]['label'] != prev_class) {
                    if (prev_class != '') {
                      stopwatch.stop();
                      var prevTime = classes[prev_class];
                      prevTime = prevTime! + stopwatch.elapsedMilliseconds;
                      classes[prev_class] = prevTime;
                      stopwatch.reset();
                    }
                    prev_class = recognitions[0]['label'];
                    stopwatch.start();
                  }
                  setRecognitions(recognitions, img.height, img.width);
                  isDetecting = false;
                },
              );
            }
          },
        );
      },
    );
  }

  void setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Container(
      constraints: const BoxConstraints.expand(),
      child: cameraController == null
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: cameraController!.value.aspectRatio,
                    child: CameraPreview(cameraController!),
                  ),
                ),
                BoundaryBox(
                    _recognitions!,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width),

                // add a button to stop the session on the bottom right
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ElevatedButton(
                    child: const Text('Stop Session'),
                    onPressed: () {
                      // Send the data sessions collection
                      FirebaseFirestore.instance
                          .collection('sessions')
                          .add(classes);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
