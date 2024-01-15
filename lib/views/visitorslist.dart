import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitorsList extends StatefulWidget {
  const VisitorsList({Key? key}) : super(key: key);

  @override
  _VisitorsListState createState() => _VisitorsListState();
}

class _VisitorsListState extends State<VisitorsList> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late StreamController<void>
      updateController; // StreamController to trigger updates
  late Stream<void> updateStream; // Stream to listen for updates
  late StreamSubscription<void>
      updateSubscription; // Subscription to updateStream
  late Stream<QuerySnapshot> stream;

  Future<void> _deleteVisitor(String documentId) async {
    await FirebaseFirestore.instance
        .collection('visitors')
        .doc(documentId)
        .delete();
  }

  @override
  void initState() {
    super.initState();
    startDateController =
        TextEditingController(text: startDate.toLocal().toString());
    endDateController =
        TextEditingController(text: endDate.toLocal().toString());
    updateController = StreamController<void>.broadcast();
    updateStream = updateController.stream;
    stream = FirebaseFirestore.instance
        .collection('visitors')
        .orderBy('time', descending: true)
        .snapshots();

    // Subscribe to the updateStream and rebuild the widget on updates
    updateSubscription = updateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    updateController.close(); // Close the StreamController
    updateSubscription.cancel(); // Cancel the StreamSubscription
    super.dispose();
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
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text('Select Time Range'),
                        content: SingleChildScrollView(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Column(
                              children: [
                                Card(
                                  child: ListTile(
                                    title: Text('Start Date:'),
                                    subtitle: InkWell(
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: startDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (picked != null &&
                                            picked != startDate) {
                                          setState(() {
                                            startDate = picked;
                                            startDateController.text =
                                                "${startDate.day}-${startDate.month}-${startDate.year}";
                                          });
                                        }
                                      },
                                      child: Text(
                                        "${startDate.day}-${startDate.month}-${startDate.year}",
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  child: ListTile(
                                    title: Text('End Date:'),
                                    subtitle: InkWell(
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: endDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (picked != null &&
                                            picked != endDate) {
                                          setState(() {
                                            endDate = picked;
                                            endDateController.text =
                                                "${endDate.day}-${endDate.month}-${endDate.year}";
                                          });
                                        }
                                      },
                                      child: Text(
                                        "${endDate.day}-${endDate.month}-${endDate.year}",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Perform Firestore query with date range filter
                              var query = FirebaseFirestore.instance
                                  .collection('visitors')
                                  .where(
                                    'time',
                                    isGreaterThanOrEqualTo: Timestamp.fromDate(
                                      DateTime(
                                        startDate.year,
                                        startDate.month,
                                        startDate.day,
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                    ),
                                  )
                                  .where(
                                    'time',
                                    isLessThan: Timestamp.fromDate(
                                      DateTime(
                                        endDate.year,
                                        endDate.month,
                                        endDate.day + 1,
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                    ),
                                  )
                                  .orderBy('time', descending: true);

                              Navigator.of(context).pop(); // Close the dialog
                              // Trigger an update to the stream
                              updateController.add(null);
                              // Directly update the StreamBuilder with the new query
                              setState(() {
                                stream = query.snapshots();
                              });
                            },
                            child: Text('Apply'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(
              child: Text(
                'No visitors found in the selected date range.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var visitorData = documents[index].data() as Map<String, dynamic>;
              var documentId = documents[index].id;

              return Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Card(
                  shadowColor: Colors.deepPurple,
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
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
                                'Are you sure you want to delete this visitor?',
                              ),
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