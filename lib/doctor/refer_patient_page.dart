import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReferPatientPage extends StatefulWidget {
  final String appointmentId;
  final String patientId;
  final String patientEmail;
  final String fromDoctorId;

  const ReferPatientPage({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.patientEmail,
    required this.fromDoctorId,
  });

  @override
  State<ReferPatientPage> createState() => _ReferPatientPageState();
}

class _ReferPatientPageState extends State<ReferPatientPage> {
  String? selectedDoctorId;
  final noteController = TextEditingController();

  Future<void> submitReferral() async {
    if (selectedDoctorId == null || noteController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('referrals').add({
      'originalAppointmentId': widget.appointmentId,
      'patientId': widget.patientId,
      'patientEmail': widget.patientEmail,
      'fromDoctorId': widget.fromDoctorId,
      'toDoctorId': selectedDoctorId,
      'referralNote': noteController.text.trim(),
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Refer Patient")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Doctor list
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .where('verificationStatus', isEqualTo: 'approved')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField(
                  hint: const Text("Select Doctor"),
                  items: snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Row(
                        children: [Text(doc['name']),SizedBox(width: 20,), Text(doc['experience']+" years")],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDoctorId = value as String;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Referral Note",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: submitReferral,
              child: const Text("Send Referral"),
            ),
          ],
        ),
      ),
    );
  }
}
