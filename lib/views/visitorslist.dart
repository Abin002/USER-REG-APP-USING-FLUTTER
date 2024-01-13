import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitorsList extends StatelessWidget {
  const VisitorsList({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VISITORS LIST',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('visitors').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Display a loading indicator while data is being fetched
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // If we reach here, data has been successfully loaded
          var visitors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: visitors.length,
            itemBuilder: (context, index) {
              var visitorData = visitors[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text('Name: ${visitorData['full name'] ?? ''}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${visitorData['phone'] ?? ''}'),
                    Text('Email: ${visitorData['email'] ?? ''}'),
                    Text('Address: ${visitorData['adress'] ?? ''}'),
                    Text('Time: ${visitorData['time']?.toDate() ?? ''}'),
                    Text('Purpose: ${visitorData['purpose'] ?? ''}'),
                  ],
                ),
                // Add more fields as needed
              );
            },
          );
        },
      ),
    );
  }
}
