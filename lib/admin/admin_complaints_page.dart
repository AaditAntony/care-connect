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
    return Container(
      color: const Color(0xFFF4F6FA), // soft background
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No pending complaints",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 25),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.grey.withOpacity(0.08),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ===== Header Section =====
                    Row(
                      children: [
                        const Icon(
                          Icons.report_problem,
                          color: Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Pending Complaint",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===== Complaint Info =====
                    buildInfoRow(
                      "From",
                      "${data['fromRole']} (${data['fromId']})",
                    ),

                    const SizedBox(height: 6),

                    buildInfoRow(
                      "Against",
                      "${data['againstRole']} (${data['againstId']})",
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Reason",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data['reason'] ?? "",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ===== Action Buttons =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade500,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.block),
                          onPressed: () async {
                            await blockAccount(
                              data['againstRole'],
                              data['againstId'],
                            );
                            await resolveComplaint(doc.id);
                          },
                          label: const Text("Block Account"),
                        ),

                        const SizedBox(width: 15),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.check),
                          onPressed: () => resolveComplaint(doc.id),
                          label: const Text("Ignore"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

}
