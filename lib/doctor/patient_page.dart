import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_history_page.dart';

class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

 @override
Widget build(BuildContext context) {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;

  return Scaffold(
    backgroundColor: const Color(0xFFF4F7F9),
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        "My Patients",
        style: TextStyle(color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consultations')
          .where('doctorId', isEqualTo: doctorId)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.people_outline,
                    size: 70, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "No patients found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        /// 🔥 Extract unique patients
        final Map<String, Map<String, dynamic>> uniquePatients = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final userId = data['userId'];
          final email = data['patientEmail'];

          if (!uniquePatients.containsKey(userId)) {
            uniquePatients[userId] = {'email': email};
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: uniquePatients.length,
          itemBuilder: (context, index) {

            final userId =
                uniquePatients.keys.elementAt(index);
            final email =
                uniquePatients[userId]!['email'];

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PatientHistoryPage(userId: userId),
                    ),
                  );
                },
                child: Row(
                  children: [

                    /// Avatar
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFF00897B),
                      child: Icon(Icons.person,
                          color: Colors.white),
                    ),

                    const SizedBox(width: 16),

                    /// Patient Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            email ?? "Patient",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Tap to view consultation history",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey),
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
