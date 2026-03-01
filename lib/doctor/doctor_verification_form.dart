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
  State<DoctorVerificationForm> createState() => _DoctorVerificationFormState();
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

  // base 64 for the  doctor signature
  File? signatureImage;
  String? signatureBase64;

  bool loading = false;

  /// Pick PROFILE image
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    setState(() {
      profileImageBase64 = base64Encode(bytes);
    });
  }

  /// Pick CERTIFICATE image
  Future<void> pickCertificateImage() async {
    final picker = ImagePicker();
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

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
    if (signatureBase64 == null) {
      showMessage("Please upload your signature");
      return;
    }

    setState(() => loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Save verification details
      await FirebaseFirestore.instance.collection('doctors').doc(uid).update({
        'name': nameController.text.trim(),
        'qualification': qualificationController.text.trim(),
        'specialization': specializationController.text.trim(),
        'experience': experienceController.text.trim(),
        'profileImageBase64': profileImageBase64,
        'certificateBase64': certificateImageBase64,
        'signatureBase64': signatureBase64,
        'verificationStatus': 'pending',
        'isVerified': false,
        'submittedAt': Timestamp.now(),
      });

      // 🔥 IMPORTANT: Redirect to Pending Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorPendingScreen()),
      );
    } catch (e) {
      showMessage(e.toString());
    }

    setState(() => loading = false);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Doctor Verification",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔷 Header Section
            const Text(
              "Professional Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Please provide accurate details for admin verification.",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 30),

            /// 🔷 Information Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                children: [
                  buildInputField("Full Name", nameController),
                  const SizedBox(height: 16),

                  buildInputField("Qualification", qualificationController),
                  const SizedBox(height: 16),

                  buildInputField("Specialization", specializationController),
                  const SizedBox(height: 16),

                  buildInputField(
                    "Years of Experience",
                    experienceController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔷 Documents Section
            const Text(
              "Upload Documents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            buildUploadCard(
              title: "Profile Image",
              icon: Icons.person,
              onTap: pickProfileImage,
              preview: profileImageBase64 != null
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: MemoryImage(
                        base64Decode(profileImageBase64!),
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            buildUploadCard(
              title: "Medical Certificate",
              icon: Icons.description,
              onTap: pickCertificateImage,
              preview: certificateImageBase64 != null
                  ? Image.memory(
                      base64Decode(certificateImageBase64!),
                      height: 120,
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            buildUploadCard(
              title: "Digital Signature",
              icon: Icons.edit,
              onTap: pickSignature,
              preview: signatureImage != null
                  ? Image.file(signatureImage!, height: 80)
                  : null,
            ),

            const SizedBox(height: 40),

            /// 🔷 Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: loading ? null : submitVerification,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit for Verification",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F9FC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUploadCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? preview,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00897B)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: onTap, child: const Text("Upload")),
            ],
          ),
          if (preview != null) ...[
            const SizedBox(height: 10),
            Center(child: preview),
          ],
        ],
      ),
    );
  }
}
