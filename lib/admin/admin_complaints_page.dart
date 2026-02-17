import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminComplaintsPage extends StatelessWidget {
  const AdminComplaintsPage({super.key});

  Future<void> blockAccount(String role, String id) async {
    final collection = role == 'doctor' ? 'doctors' : 'users';

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .update({'isBlocked': true});
  }

  Future<void> resolveComplaint(String complaintId) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({'status': 'resolved'});
  }

  @override
  Widget build(BuildContext context) {
    return

       StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending complaints"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From: ${data['fromRole']} (${data['fromId']})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Against: ${data['againstRole']} (${data['againstId']})",
                      ),
                      const SizedBox(height: 8),
                      Text("Reason: ${data['reason']}"),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () async {
                              await blockAccount(
                                data['againstRole'],
                                data['againstId'],
                              );
                              await resolveComplaint(doc.id);
                            },
                            child: const Text("Block"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => resolveComplaint(doc.id),
                            child: const Text("Ignore"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      );

  }
}
