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
  State<ReferPatientPage> createState() => _ReferPatientPageState();
}

class _ReferPatientPageState extends State<ReferPatientPage> {
  String? selectedDoctorId;
  String? selectedDoctorName;

  final noteController = TextEditingController();
  bool loading = false;

  Future<void> sendReferral() async {
    if (selectedDoctorId == null) return;

    setState(() => loading = true);

    try {
      final currentDoctorId = FirebaseAuth.instance.currentUser!.uid;

      final currentDoctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(currentDoctorId)
          .get();

      final currentDoctorName = currentDoctorDoc.data()?['name'];

      /// 1️⃣ Create referral document
      await FirebaseFirestore.instance.collection('referrals').add({
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
          .update({'status': 'completed', 'isReferred': true});

      Navigator.pop(context); // close referral page
      Navigator.pop(context); // close consultation page
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentDoctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Refer Patient",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            const Text(
              "Select Receiving Doctor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Choose a verified doctor to transfer this case.",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 20),

            /// Doctor List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .where('isVerified', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final doctors = snapshot.data!.docs
                      .where((doc) => doc.id != currentDoctorId)
                      .toList();

                  if (doctors.isEmpty) {
                    return const Center(
                      child: Text("No other doctors available"),
                    );
                  }

                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doc = doctors[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final isSelected = selectedDoctorId == doc.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDoctorId = doc.id;
                            selectedDoctorName = data['name'];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00897B)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12,
                                color: Colors.black.withOpacity(0.05),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              /// Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isSelected
                                    ? const Color(0xFF00897B)
                                    : Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(width: 14),

                              /// Doctor Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? "Doctor",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['specialization'] ?? "",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF00897B),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// Referral Note Section
            const Text(
              "Referral Note",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Add additional notes for the receiving doctor...",
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: loading ? null : sendReferral,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Send Referral",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
