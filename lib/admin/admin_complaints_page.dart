import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminComplaintsPage extends StatelessWidget {
  const AdminComplaintsPage({super.key});

  Future<void> blockAccount(String role, String id) async {
    final collection = role == 'doctor' ? 'doctors' : 'users';

    await FirebaseFirestore.instance.collection(collection).doc(id).update({
      'isBlocked': true,
    });
  }

  Future<void> resolveComplaint(String complaintId) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({'status': 'resolved'});
  }

  Future<String> fetchName(String role, String id) async {
    final collection = role == 'doctor' ? 'doctors' : 'users';

    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .get();

    if (!doc.exists) return "Unknown";

    final data = doc.data() as Map<String, dynamic>;
    return data['name'] ?? data['email'] ?? "No Name";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

        return ListView.builder(
          padding: const EdgeInsets.all(30),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return FutureBuilder<List<String>>(
              future: Future.wait([
                fetchName(data['fromRole'], data['fromId']),
                fetchName(data['againstRole'], data['againstId']),
              ]),
              builder: (context, nameSnapshot) {
                if (!nameSnapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final fromName = nameSnapshot.data![0];
                final againstName = nameSnapshot.data![1];

                return Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        color: Colors.grey.withOpacity(0.08),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Complaint Case",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Pending",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// FROM SECTION
                      buildUserSection(
                        "Filed By",
                        fromName,
                        data['fromRole'],
                        data['fromId'],
                        Colors.blue,
                      ),

                      const SizedBox(height: 15),

                      /// AGAINST SECTION
                      buildUserSection(
                        "Against",
                        againstName,
                        data['againstRole'],
                        data['againstId'],
                        Colors.red,
                      ),

                      const SizedBox(height: 20),

                      /// REASON
                      const Text(
                        "Reason",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['reason'] ?? "",
                        style: const TextStyle(color: Colors.black87),
                      ),

                      const SizedBox(height: 25),

                      /// ACTIONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              await blockAccount(
                                data['againstRole'],
                                data['againstId'],
                              );
                              await resolveComplaint(doc.id);
                            },
                            child: const Text("Block"),
                          ),

                          const SizedBox(width: 15),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            onPressed: () => resolveComplaint(doc.id),
                            child: const Text("Ignore"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildUserSection(
    String title,
    String name,
    String role,
    String id,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$name ($role)\nID: $id",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
