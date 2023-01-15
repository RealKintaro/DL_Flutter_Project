import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
    // Initialize Firebase with default values
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Driver state Detector'),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Firebase.apps.isNotEmpty
              ? FirebaseFirestore.instance
                  .collection('sessions')
                  .orderBy('Time', descending: true)
                  .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot != null) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      snapshot.data!.docs[index].get('Time'),
                    ),
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
              return const CircularProgressIndicator();
            }
          },
        ));
  }
}
