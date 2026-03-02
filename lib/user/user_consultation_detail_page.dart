import 'dart:convert';
import 'package:care_connect/user/user_complaint_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserConsultationDetailPage extends StatelessWidget {
  final String appointmentId;

  const UserConsultationDetailPage({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Consultation Details"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .where('appointmentId', isEqualTo: appointmentId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Consultation not available yet"));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          final List medicines = data['medicines'] ?? [];

          final List activities = data['activities'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔵 Doctor Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Consulted By",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data['doctorName'] ?? "Doctor",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// 🔵 Diagnosis
                buildSection("Diagnosis", data['diagnosis'] ?? ""),

                /// 🔵 Medicines
                buildListSection(
                  "Prescribed Medicines",
                  medicines.cast<String>(),
                ),

                /// 🔵 Activities
                buildListSection(
                  "Assigned Activities",
                  activities.cast<String>(),
                ),

                /// 🔵 Notes
                buildSection("Doctor Notes", data['notes'] ?? ""),

                /// 🔵 Prescription Image
                if (data['prescriptionImageBase64'] != null)
                  buildImageSection(
                    "Prescription Image",
                    data['prescriptionImageBase64'],
                  ),

                /// 🔵 Signature
                if (data['doctorSignatureBase64'] != null)
                  buildImageSection(
                    "Doctor Signature",
                    data['doctorSignatureBase64'],
                    height: 80,
                  ),

                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserComplaintPage(
                          doctorId: data['doctorId'],
                          doctorName: data['doctorName'],
                          appointmentId: appointmentId,
                        ),
                      ),
                    );
                  },
                  child: const Text("Report Doctor"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.grey.withOpacity(0.1)),
              ],
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget buildListSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          if (items.isEmpty)
            const Text("None")
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(blurRadius: 6, color: Colors.grey.withOpacity(0.1)),
                ],
              ),
              child: Column(
                children: items
                    .map(
                      (item) => Row(
                        children: [
                          const Icon(Icons.circle, size: 6),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildImageSection(
    String title,
    String base64Image, {
    double height = 150,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.grey.withOpacity(0.1)),
              ],
            ),
            child: Image.memory(base64Decode(base64Image), height: height),
          ),
        ],
      ),
    );
  }
}
