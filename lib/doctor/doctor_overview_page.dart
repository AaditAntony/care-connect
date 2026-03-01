import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorOverviewPage extends StatelessWidget {
  const DoctorOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String doctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ========= STAT CARDS =========
            Row(
              children: [
                Expanded(
                  child: buildLiveCard(
                    title: "Patients",
                    icon: Icons.people,
                    stream: FirebaseFirestore.instance
                        .collection('consultations')
                        .where('doctorId', isEqualTo: doctorId)
                        .snapshots(),
                    valueBuilder: (snapshot) {
                      final docs = snapshot.docs;

                      final unique = {for (var d in docs) d['userId']: true};

                      return unique.length.toString();
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildLiveCard(
                    title: "Booked",
                    icon: Icons.calendar_today,
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorId', isEqualTo: doctorId)
                        .where('status', isEqualTo: 'booked')
                        .snapshots(),
                    valueBuilder: (snapshot) => snapshot.docs.length.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: buildLiveCard(
                    title: "Completed",
                    icon: Icons.check_circle,
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorId', isEqualTo: doctorId)
                        .where('status', isEqualTo: 'completed')
                        .snapshots(),
                    valueBuilder: (snapshot) => snapshot.docs.length.toString(),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildLiveCard(
                    title: "Referrals",
                    icon: Icons.swap_horiz,
                    stream: FirebaseFirestore.instance
                        .collection('referrals')
                        .where('toDoctorId', isEqualTo: doctorId)
                        .snapshots(),
                    valueBuilder: (snapshot) => snapshot.docs.length.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// ========= RECENT ACTIVITY =========
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Recent Appointments",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('doctorId', isEqualTo: doctorId)
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text("No recent activity");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: data['status'] == 'completed'
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                              data['status'] == 'completed'
                                  ? Icons.check
                                  : Icons.access_time,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['patientEmail'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['timeSlot'] ?? "",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  /// ===== Reusable Live Card =====
  Widget buildLiveCard({
    required String title,
    required IconData icon,
    required Stream<QuerySnapshot> stream,
    required String Function(QuerySnapshot snapshot) valueBuilder,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return buildCardUI(title, icon, "--");
        }

        final value = valueBuilder(snapshot.data!);

        return buildCardUI(title, icon, value);
      },
    );
  }

  Widget buildCardUI(String title, IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 15, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: const Color(0xFF00897B)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
