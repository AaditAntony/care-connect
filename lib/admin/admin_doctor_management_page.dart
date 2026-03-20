import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_connect/admin/admin_doctor_detail_page.dart';

class AdminDoctorManagementPage extends StatelessWidget {
  const AdminDoctorManagementPage({super.key});

  Future<void> revokeAccess(BuildContext context, String doctorId) async {
    // Show confirmation dialog before revoking access
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Revoke Access?"),
          content: const Text(
            "Are you sure you want to revoke this doctor's approved status? They will no longer be able to use the app as a verified doctor.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Revoke"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('doctors').doc(doctorId).update(
        {'verificationStatus': 'rejected', 'isVerified': false},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Doctor access revoked successfully."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Approved Doctors"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('verificationStatus', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No approved doctors found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.medical_services, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? "Doctor",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  data['email'] ?? "No email",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, size: 16, color: Colors.green),
                                SizedBox(width: 5),
                                ...[
                                  Text(
                                    "Verified",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Divider(),
                      const SizedBox(height: 5),
                      Text(
                        "Qualification: ${data['qualification'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Specialization: ${data['specialization'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Experience: ${data['experience'] ?? '0'} years",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminDoctorDetailPage(doctorId: doc.id),
                                ),
                              );
                            },
                            child: const Text("View Details"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                            ),
                            onPressed: () => revokeAccess(context, doc.id),
                            icon: const Icon(Icons.block, size: 18),
                            label: const Text("Revoke Access"),
                          ),
                        ],
                      ),
                    ],
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
