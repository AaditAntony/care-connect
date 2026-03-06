import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "System Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                statCard(
                  "Total Users",
                  Icons.people,
                  Colors.blue,
                  FirebaseFirestore.instance.collection('users').snapshots(),
                ),

                statCard(
                  "Approved Doctors",
                  Icons.medical_services,
                  Colors.green,
                  FirebaseFirestore.instance
                      .collection('doctors')
                      .where('verificationStatus', isEqualTo: 'approved')
                      .snapshots(),
                ),

                statCard(
                  "Pending Doctors",
                  Icons.pending_actions,
                  Colors.orange,
                  FirebaseFirestore.instance
                      .collection('doctors')
                      .where('verificationStatus', isEqualTo: 'pending')
                      .snapshots(),
                ),

                statCard(
                  "Pending Complaints",
                  Icons.report_problem,
                  Colors.red,
                  FirebaseFirestore.instance
                      .collection('complaints')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                ),

                statCard(
                  "Appointments",
                  Icons.calendar_today,
                  Colors.purple,
                  FirebaseFirestore.instance
                      .collection('appointments')
                      .snapshots(),
                ),

                statCard(
                  "Referred Cases",
                  Icons.swap_horiz,
                  Colors.teal,
                  FirebaseFirestore.instance
                      .collection('appointments')
                      .where('isReferred', isEqualTo: true)
                      .snapshots(),
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "Recent Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error loading appointments");
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text("No appointments yet");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    String status = data['status'] ?? "";

                    Color statusColor = Colors.grey;

                    if (status == "completed") statusColor = Colors.green;
                    if (status == "booked") statusColor = Colors.orange;
                    if (data['isReferred'] == true) statusColor = Colors.blue;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          "Patient: ${data['patientEmail'] ?? "Unknown"}",
                        ),
                        subtitle: Text(
                          "Doctor: ${data['doctorName'] ?? "Unknown"}",
                        ),
                        trailing: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(
    String title,
    IconData icon,
    Color color,
    Stream<QuerySnapshot> stream,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingCard(title, icon, color);
        }

        int count = snapshot.data!.docs.length;

        return Container(
          width: 170,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.grey.withOpacity(0.1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),

              const SizedBox(height: 15),

              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(title, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        );
      },
    );
  }

  Widget loadingCard(String title, IconData icon, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          const CircularProgressIndicator(),
          const SizedBox(height: 5),
          Text(title),
        ],
      ),
    );
  }
}
