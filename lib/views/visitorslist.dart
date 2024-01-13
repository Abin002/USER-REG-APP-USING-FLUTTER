import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitorsList extends StatelessWidget {
  const VisitorsList({Key? key});

  Future<void> _deleteVisitor(String documentId) async {
    await FirebaseFirestore.instance
        .collection('visitors')
        .doc(documentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'VISITORS LIST',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('visitors')
            .orderBy('time', descending: true)
            .snapshots(),
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
              var documentId = visitors[index].id;

              return Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Card(
                  shadowColor: Colors.deepPurple,
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'), // Display the item number
                    ),
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.white,
                              title: Text('Delete Visitor'),
                              content: Text(
                                  'Are you sure you want to delete this visitor?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteVisitor(documentId);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    // Add more fields as needed
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
