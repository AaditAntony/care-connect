import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorReferralsPage extends StatelessWidget {
  const DoctorReferralsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Patient Referrals")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('referrals')
            .where('toDoctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No referrals"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text("Patient: ${data['patientEmail']}"),
                  subtitle: Text(data['referralNote']),
                  trailing: ElevatedButton(
                    child: const Text("Accept"),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('referrals')
                          .doc(doc.id)
                          .update({'status': 'accepted'});
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
