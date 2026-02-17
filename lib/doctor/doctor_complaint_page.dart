import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorComplaintPage extends StatefulWidget {
  final String userId;

  const DoctorComplaintPage({super.key, required this.userId});

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
      await FirebaseFirestore.instance.collection('complaints').add({
        'fromId': FirebaseAuth.instance.currentUser!.uid,
        'fromRole': 'doctor',
        'againstId': widget.userId,
        'againstRole': 'user',
        'reason': reasonController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint submitted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report User")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: reasonController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Describe your complaint",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // button
            ElevatedButton(
              onPressed: loading ? null : submitComplaint,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Complaint"),
            ),
          ],
        ),
      ),
    );
  }
}
