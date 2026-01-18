import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPrescriptionPage extends StatelessWidget {
  final String appointmentId;

  const UserPrescriptionPage({
    super.key,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescription"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= MEDICINE SECTION =================
            const Text(
              "Prescribed Medicines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🔥 Show medicines for THIS USER & THIS APPOINTMENT
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prescriptions')
                  .where('appointmentId', isEqualTo: appointmentId)
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text("No medicines prescribed yet");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: Text(doc['medicine']),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            // ================= ACTIVITY SECTION =================
            const Text(
              "Assigned Activities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🔥 Show activities for THIS USER & THIS APPOINTMENT
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activities')
                  .where('appointmentId', isEqualTo: appointmentId)
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text("No activities assigned yet");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return CheckboxListTile(
                      title: Text(data['activity']),
                      value: data['isCompleted'],
                      onChanged: (value) {
                        FirebaseFirestore.instance
                            .collection('activities')
                            .doc(doc.id)
                            .update({
                          'isCompleted': value,
                        });
                      },
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
}
