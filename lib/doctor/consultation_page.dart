import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final List<String> medicinesList = [];
  final List<String> activitiesList = [];

  final medicineController = TextEditingController();
  final activityController = TextEditingController();

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
      appBar: AppBar(title: const Text("Consultation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Patient Email
            Text(
              "Patient: ${widget.patientEmail}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

            /// Medicines
            const Text(
              "Medicines",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: medicineController,
                    decoration: const InputDecoration(hintText: "Add medicine"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
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

            ...medicinesList.map((med) => ListTile(title: Text(med))),

            const SizedBox(height: 20),

            /// Activities
            const Text(
              "Activities",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: activityController,
                    decoration: const InputDecoration(hintText: "Add activity"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (activityController.text.trim().isNotEmpty) {
                      setState(() {
                        activitiesList.add(activityController.text.trim());
                        activityController.clear();
                      });
                    }
                  },
                ),
              ],
            ),

            ...activitiesList.map((act) => ListTile(title: Text(act))),

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
            ElevatedButton(
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

            const SizedBox(height: 30),

            /// Submit
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
