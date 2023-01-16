import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bar_chart_page.dart';
import 'firebase_options.dart';

class SessionsInfo extends StatefulWidget {
  const SessionsInfo({Key? key}) : super(key: key);

  @override
  SessionsInfoState createState() => SessionsInfoState();
}

class SessionsInfoState extends State<SessionsInfo> {
  @override
  void initState() {
    super.initState();
    // Initialize Firebase with default values then build the widget
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Driver state Detector'),
        ),
        // if the app is not initialized yet, show a loading indicator
        body: Firebase.apps.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('sessions')
                    .orderBy('Time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Center(
                              child: Row(
                            // center children
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                            children: [
                              // add a lens icon
                              const Icon(Icons.analytics),
                              const Text('Session of: '),
                              Text(
                                snapshot.data!.docs[index].get('Time'),
                              )
                            ],
                          )),
                          // edges of the list tile
                          contentPadding: const EdgeInsets.all(10),
                          // center the text
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SimpleBarChart(
                                  snapshot.data!.docs[index],
                                  true,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return const Text('Error');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ));
  }
}
