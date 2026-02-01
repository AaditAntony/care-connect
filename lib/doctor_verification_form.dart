import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORT PENDING SCREEN
import 'doctor_pending.dart';

class DoctorVerificationForm extends StatefulWidget {
  const DoctorVerificationForm({super.key});

  @override
  State<DoctorVerificationForm> createState() =>
      _DoctorVerificationFormState();
}

class _DoctorVerificationFormState extends State<DoctorVerificationForm> {
  // Controllers for doctor details
  final nameController = TextEditingController();
  final qualificationController = TextEditingController();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();

  // Base64 strings for images
  String? profileImageBase64;
  String? certificateImageBase64;

  // base 64 for the  docotor signature
  File? signatureImage;
  String? signatureBase64;

  bool loading = false;

  /// Pick PROFILE image
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    XFile? image =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);

    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    setState(() {
      profileImageBase64 = base64Encode(bytes);
    });
  }

  /// Pick CERTIFICATE image
  Future<void> pickCertificateImage() async {
    final picker = ImagePicker();
    XFile? image =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);

    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    setState(() {
      certificateImageBase64 = base64Encode(bytes);
    });
  }

  // pic signature image
  Future<void> pickSignature() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        signatureImage = File(picked.path);
        signatureBase64 = base64Encode(bytes);
      });
    }
  }

  /// Submit verification details
  Future<void> submitVerification() async {
    // Basic validation
    if (profileImageBase64 == null) {
      showMessage("Please upload profile image");
      return;
    }
    if (certificateImageBase64 == null) {
      showMessage("Please upload certificate image");
      return;
    }

    setState(() => loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Save verification details
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .update({
        'name': nameController.text.trim(),
        'qualification': qualificationController.text.trim(),
        'specialization': specializationController.text.trim(),
        'experience': experienceController.text.trim(),
        'profileImageBase64': profileImageBase64,
        'certificateBase64': certificateImageBase64,
        'verificationStatus': 'pending',
        'isVerified': false,
        'submittedAt': Timestamp.now(),
      });

      // 🔥 IMPORTANT: Redirect to Pending Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DoctorPendingScreen(),
        ),
      );
    } catch (e) {
      showMessage(e.toString());
    }

    setState(() => loading = false);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Verification"),
        automaticallyImplyLeading: false, // prevent going back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: qualificationController,
              decoration: const InputDecoration(
                labelText: "Qualification",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: specializationController,
              decoration: const InputDecoration(
                labelText: "Specialization",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: experienceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Years of Experience",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: pickProfileImage,
              icon: const Icon(Icons.person),
              label: const Text("Upload Profile Image"),
            ),
            if (profileImageBase64 != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  MemoryImage(base64Decode(profileImageBase64!)),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: pickCertificateImage,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Certificate"),
            ),
            if (certificateImageBase64 != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Image.memory(
                  base64Decode(certificateImageBase64!),
                  height: 120,
                ),
              ),

            const SizedBox(height: 25),

            // signature
            const SizedBox(height: 20),

            const Text(
              "Doctor Signature",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            signatureImage == null
                ? OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Upload Signature"),
              onPressed: pickSignature,
            )
                : Column(
              children: [
                Image.file(signatureImage!, height: 80),
                TextButton(
                  onPressed: pickSignature,
                  child: const Text("Change Signature"),
                ),
              ],
            ),


            ElevatedButton(
              onPressed: loading ? null : submitVerification,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit for Verification"),
            ),
          ],
        ),
      ),
    );
  }
}
