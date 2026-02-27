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
      appBar: AppBar(title: const Text("My Patients"), centerTitle: true),
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
            return const Center(child: Text("No patients found"));
          }

          final docs = snapshot.data!.docs;

          // 🔥 Extract unique patients
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
            padding: const EdgeInsets.all(16),
            itemCount: uniquePatients.length,
            itemBuilder: (context, index) {
              final userId = uniquePatients.keys.elementAt(index);

              final email = uniquePatients[userId]!['email'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    email ?? "Patient",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Tap to view history"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // ✅ CONNECTING TO HISTORY PAGE
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientHistoryPage(userId: userId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
