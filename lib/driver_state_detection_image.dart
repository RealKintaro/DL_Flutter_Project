import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class DriverStateFromImage extends StatefulWidget {
  const DriverStateFromImage({Key? key}) : super(key: key);

  @override
  DriverStateFromImageState createState() => DriverStateFromImageState();
}

class DriverStateFromImageState extends State<DriverStateFromImage> {
  File? _image;
  // ignore: unused_field
  late int _imageWidth;
  // ignore: unused_field
  late int _imageHeight;
  bool _loading = false;
  List? _recognitions;

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/ml_trained_model/converted_model.tflite",
      labels: "assets/ml_trained_model/labels.txt",
    );
  }

  selectFromImagePicker() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final File imageFile = File(image.path);
    // print on debug console the path of the image
    if (kDebugMode) {
      print(image.path);
    }
    setState(() {
      _loading = true;
      _image = imageFile;
    });
    predictImage(imageFile);
  }

  predictImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    FileImage(image).resolve(const ImageConfiguration()).addListener(
          (ImageStreamListener(
            (ImageInfo info, bool _) {
              setState(
                () {
                  _imageWidth = info.image.width;
                  _imageHeight = info.image.height;
                },
              );
            },
          )),
        );

    setState(() {
      _loading = false;
      _recognitions = recognitions!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver state Detector'),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Pick Image from gallery",
        onPressed: selectFromImagePicker,
        child: const Icon(Icons.image),
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image == null
                      // ignore: avoid_unnecessary_containers
                      ? Container(
                          child: const Text(
                            "No image has been selected",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )
                      : Image.file(
                          _image!,
                          height: 300,
                          width: 300,
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  _recognitions != null
                      ? Text(
                          "${_recognitions![0]["label"]}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
    );
  }
}
