import 'dart:convert';
import 'dart:io';

import 'package:care_connect/doctor/doctor_complaint_page.dart';
import 'package:care_connect/doctor/patient_history_page.dart';
import 'package:care_connect/doctor/refer_patient_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsultationPage extends StatefulWidget {
  final String appointmentId;
  final String userId;
  final String patientEmail;

  const ConsultationPage({
    super.key,
    required this.appointmentId,
    required this.userId,
    required this.patientEmail,
  });

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final diagnosisController = TextEditingController();
  final notesController = TextEditingController();

  final List<String> medicinesList = [];
  final List<String> activitiesList = [];

  final medicineController = TextEditingController();
  final activityController = TextEditingController();

  String? prescriptionImageBase64;
  bool loading = false;

  Future<void> sendMeetingLink() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: widget.patientEmail,
      queryParameters: {
        'subject': 'Online Consultation – Google Meet',
        'body':
            'Hello,\n\nPlease join the consultation using the Google Meet link below:\n\n',
      },
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open email app")));
    }
  }

  /// Pick prescription image
  Future<void> pickPrescriptionImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      setState(() {
        prescriptionImageBase64 = base64Encode(bytes);
      });
    }
  }

  /// Submit Consultation
  Future<void> submitConsultation() async {
    if (diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Diagnosis is required")));
      return;
    }

    setState(() => loading = true);

    try {
      final doctorId = FirebaseAuth.instance.currentUser!.uid;

      /// 🔥 Fetch doctor details
      final doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      final doctorData = doctorDoc.data() as Map<String, dynamic>;

      final doctorName = doctorData['name'];
      final doctorSignature = doctorData['signatureBase64'];

      /// 🔥 Save consultation
      await FirebaseFirestore.instance.collection('consultations').add({
        'appointmentId': widget.appointmentId,
        'doctorId': doctorId,
        'doctorName': doctorName, // ✅ IMPORTANT
        'userId': widget.userId,
        'patientEmail': widget.patientEmail,
        'diagnosis': diagnosisController.text.trim(),
        'medicines': medicinesList,
        'activities': activitiesList,
        'notes': notesController.text.trim(),
        'prescriptionImageBase64': prescriptionImageBase64,
        'doctorSignatureBase64': doctorSignature,
        'createdAt': Timestamp.now(),
      });

      /// 🔥 Mark appointment completed
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({'status': 'completed'});

      Navigator.pop(context);
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
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Consultation",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔷 Patient Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF00897B),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.patientEmail,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.email, color: Color(0xFF00897B)),
                        onPressed: sendMeetingLink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PatientHistoryPage(userId: widget.userId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("View Previous History"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 🔷 Diagnosis Section
            _buildSectionCard(
              title: "Diagnosis",
              child: TextField(
                controller: diagnosisController,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔷 Medicines Section
            _buildSectionCard(
              title: "Medicines",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: medicineController,
                          decoration: const InputDecoration(
                            hintText: "Add medicine",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF00897B)),
                        onPressed: () {
                          if (medicineController.text.trim().isNotEmpty) {
                            setState(() {
                              medicinesList.add(medicineController.text.trim());
                              medicineController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  ...medicinesList.map(
                    (med) => ListTile(
                      leading: const Icon(
                        Icons.medication,
                        color: Color(0xFF00897B),
                      ),
                      title: Text(med),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔷 Activities Section
            _buildSectionCard(
              title: "Activities",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: activityController,
                          decoration: const InputDecoration(
                            hintText: "Add activity",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF00897B)),
                        onPressed: () {
                          if (activityController.text.trim().isNotEmpty) {
                            setState(() {
                              activitiesList.add(
                                activityController.text.trim(),
                              );
                              activityController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  ...activitiesList.map(
                    (act) => ListTile(
                      leading: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFF00897B),
                      ),
                      title: Text(act),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔷 Notes Section
            _buildSectionCard(
              title: "Additional Notes",
              child: TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔷 Prescription Upload
            _buildSectionCard(
              title: "Prescription Image",
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                    ),
                    onPressed: pickPrescriptionImage,
                    child: const Text("Upload Prescription Image"),
                  ),
                  if (prescriptionImageBase64 != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.memory(
                        base64Decode(prescriptionImageBase64!),
                        height: 120,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔷 Complete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: loading ? null : submitConsultation,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Complete Consultation"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00897B)),
                ),
                onPressed: () {
                  if (diagnosisController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter diagnosis before referring",
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReferPatientPage(
                        appointmentId: widget.appointmentId,
                        userId: widget.userId,
                        patientEmail: widget.patientEmail,
                        diagnosis: diagnosisController.text.trim(),
                      ),
                    ),
                  );
                },
                child: const Text("Refer to Another Doctor"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorComplaintPage(
                        userId: widget.userId,
                        patientEmail: widget.patientEmail,
                        appointmentId: widget.appointmentId,
                      ),
                    ),
                  );
                },
                child: const Text("Report Patient"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
