import 'package:care_connect/admin/admin_doctor_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDoctorApprovalPage extends StatelessWidget {
  const AdminDoctorApprovalPage({super.key});

  Future<void> approveDoctor(String doctorId) async {
    await FirebaseFirestore.instance.collection('doctors').doc(doctorId).update(
      {'verificationStatus': 'approved', 'isVerified': true},
    );
  }

  Future<void> rejectDoctor(String doctorId) async {
    await FirebaseFirestore.instance.collection('doctors').doc(doctorId).update(
      {'verificationStatus': 'rejected', 'isVerified': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Doctor Approval Requests"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('verificationStatus', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending approval requests"));
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
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              data['name'] ?? "Doctor",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
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

                      const SizedBox(height: 15),

                      Text("Qualification: ${data['qualification'] ?? ''}"),
                      Text("Specialization: ${data['specialization'] ?? ''}"),
                      Text("Experience: ${data['experience'] ?? ''} years"),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminDoctorDetailPage(doctorId: doc.id),
                                ),
                              );
                            },
                            child: const Text("View Details"),
                          ),
                          const SizedBox(width: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => rejectDoctor(doc.id),
                            child: const Text("Reject"),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () => approveDoctor(doc.id),
                            child: const Text("Approve"),
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
