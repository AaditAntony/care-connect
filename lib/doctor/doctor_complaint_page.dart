import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorComplaintPage extends StatefulWidget {
  final String userId;
  final String patientEmail;
  final String appointmentId;

  const DoctorComplaintPage({
    super.key,
    required this.userId,
    required this.patientEmail,
    required this.appointmentId,
  });

  @override
  State<DoctorComplaintPage> createState() => _DoctorComplaintPageState();
}

class _DoctorComplaintPageState extends State<DoctorComplaintPage> {
  final TextEditingController reasonController = TextEditingController();

  bool loading = false;

  Future<void> submitComplaint() async {
    if (reasonController.text.trim().isEmpty) return;

    setState(() => loading = true);

    try {
      final doctorId = FirebaseAuth.instance.currentUser!.uid;

      /// 🔥 Fetch doctor name
      final doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      final doctorName = doctorDoc.data()?['name'] ?? "Doctor";

      await FirebaseFirestore.instance.collection('complaints').add({
        'fromId': doctorId,
        'fromName': doctorName,
        'fromRole': 'doctor',

        'againstId': widget.userId,
        'againstName': widget.patientEmail,
        'againstRole': 'user',

        'appointmentId': widget.appointmentId,

        'reason': reasonController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint submitted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report User")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Reporting: ${widget.patientEmail}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: reasonController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Describe the issue",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: loading ? null : submitComplaint,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Complaint"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
