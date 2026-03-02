import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserComplaintPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String appointmentId;

  const UserComplaintPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
  });

  @override
  State<UserComplaintPage> createState() =>
      _UserComplaintPageState();
}

class _UserComplaintPageState
    extends State<UserComplaintPage> {

  final TextEditingController reasonController =
      TextEditingController();

  bool loading = false;

  Future<void> submitComplaint() async {

    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please describe your issue"),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final userId =
          FirebaseAuth.instance.currentUser!.uid;

      /// 🔥 Fetch user name
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userName =
          userDoc.data()?['name'] ?? "User";

      await FirebaseFirestore.instance
          .collection('complaints')
          .add({
        'fromId': userId,
        'fromName': userName,
        'fromRole': 'user',

        'againstId': widget.doctorId,
        'againstName': widget.doctorName,
        'againstRole': 'doctor',

        'appointmentId': widget.appointmentId,

        'reason': reasonController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Complaint submitted successfully"),
        ),
      );

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Report Doctor"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// Doctor Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning,
                      color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Reporting: ${widget.doctorName}",
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Describe the Issue",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: reasonController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    "Explain what happened during your consultation...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(
                          vertical: 14),
                ),
                onPressed:
                    loading ? null : submitComplaint,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text("Submit Complaint"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}