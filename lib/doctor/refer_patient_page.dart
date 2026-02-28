import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferPatientPage extends StatefulWidget {
  final String appointmentId;
  final String userId;
  final String patientEmail;
  final String diagnosis;

  const ReferPatientPage({
    super.key,
    required this.appointmentId,
    required this.userId,
    required this.patientEmail,
    required this.diagnosis,
  });

  @override
  State<ReferPatientPage> createState() =>
      _ReferPatientPageState();
}

class _ReferPatientPageState
    extends State<ReferPatientPage> {

  String? selectedDoctorId;
  String? selectedDoctorName;

  final noteController = TextEditingController();
  bool loading = false;

  Future<void> sendReferral() async {
    if (selectedDoctorId == null) return;

    setState(() => loading = true);

    try {
      final currentDoctorId =
          FirebaseAuth.instance.currentUser!.uid;

      final currentDoctorDoc =
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(currentDoctorId)
              .get();

      final currentDoctorName =
          currentDoctorDoc.data()?['name'];

      /// 1️⃣ Create referral document
      await FirebaseFirestore.instance
          .collection('referrals')
          .add({
        'appointmentId': widget.appointmentId,
        'userId': widget.userId,
        'patientEmail': widget.patientEmail,
        'fromDoctorId': currentDoctorId,
        'fromDoctorName': currentDoctorName,
        'toDoctorId': selectedDoctorId,
        'toDoctorName': selectedDoctorName,
        'referralNote': noteController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      /// 2️⃣ Mark appointment completed + referred
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
        'status': 'completed',
        'isReferred': true,
      });

      Navigator.pop(context); // close referral page
      Navigator.pop(context); // close consultation page

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {

    final currentDoctorId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Refer Patient"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Doctor List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .where('isVerified', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final doctors = snapshot.data!.docs
                      .where((doc) =>
                          doc.id != currentDoctorId)
                      .toList();

                  if (doctors.isEmpty) {
                    return const Center(
                        child: Text("No other doctors available"));
                  }

                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {

                      final doc = doctors[index];
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return RadioListTile(
                        title: Text(data['name'] ?? "Doctor"),
                        subtitle: Text(data['specialization'] ?? ""),
                        value: doc.id,
                        groupValue: selectedDoctorId,
                        onChanged: (value) {
                          setState(() {
                            selectedDoctorId = value;
                            selectedDoctorName = data['name'];
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Referral Note",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : sendReferral,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send Referral"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}