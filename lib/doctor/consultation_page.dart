import 'dart:convert';
import 'dart:io';

import 'package:care_connect/doctor/patient_history_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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

  final medicineController = TextEditingController();
  final activityController = TextEditingController();

  List<String> medicines = [];
  List<String> activities = [];

  String? prescriptionImageBase64;
  bool loading = false;

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

  /// Add medicine dynamically
  void addMedicine() {
    if (medicineController.text.trim().isEmpty) return;

    setState(() {
      medicines.add(medicineController.text.trim());
      medicineController.clear();
    });
  }

  /// Add activity dynamically
  void addActivity() {
    if (activityController.text.trim().isEmpty) return;

    setState(() {
      activities.add(activityController.text.trim());
      activityController.clear();
    });
  }

  /// Submit consultation
  Future<void> submitConsultation() async {
    if (diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Diagnosis required")));
      return;
    }

    setState(() => loading = true);

    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    // 🔥 Fetch doctor signature
    final doctorDoc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .get();

    final doctorData = doctorDoc.data() as Map<String, dynamic>;

    final doctorSignature = doctorData['signatureBase64'];

    // 🔥 Create consultation document
    await FirebaseFirestore.instance.collection('consultations').add({
      'appointmentId': widget.appointmentId,
      'doctorId': doctorId,
      'userId': widget.userId,
      'patientEmail': widget.patientEmail,
      'diagnosis': diagnosisController.text.trim(),
      'medicines': medicines,
      'activities': activities,
      'notes': notesController.text.trim(),
      'prescriptionImageBase64': prescriptionImageBase64,
      'doctorSignatureBase64': doctorSignature,
      'createdAt': Timestamp.now(),
    });

    // 🔥 Update appointment status
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentId)
        .update({'status': 'completed'});

    setState(() => loading = false);

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Consultation Completed")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Consultation Form")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Patient info
            Text(
              "Patient: ${widget.patientEmail}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientHistoryPage(userId: widget.userId),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text("View Previous History"),
              ),
            ),

            const SizedBox(height: 20),

            /// Diagnosis
            const Text(
              "Diagnosis",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: diagnosisController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            /// Medicines Section
            const Text(
              "Medicines",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: medicineController,
                    decoration: const InputDecoration(
                      hintText: "Enter medicine",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addMedicine,
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...medicines.map(
              (med) => ListTile(
                leading: const Icon(Icons.medical_services),
                title: Text(med),
              ),
            ),

            const SizedBox(height: 20),

            /// Activities Section
            const Text(
              "Activities",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: activityController,
                    decoration: const InputDecoration(
                      hintText: "Enter activity",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addActivity,
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...activities.map(
              (act) => ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(act),
              ),
            ),

            const SizedBox(height: 20),

            /// Notes
            const Text(
              "Additional Notes",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            /// Prescription Image
            ElevatedButton.icon(
              onPressed: pickPrescriptionImage,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Prescription Image"),
            ),

            if (prescriptionImageBase64 != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Image.memory(
                  base64Decode(prescriptionImageBase64!),
                  height: 120,
                ),
              ),

            const SizedBox(height: 30),

            /// Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submitConsultation,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Complete Consultation"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
