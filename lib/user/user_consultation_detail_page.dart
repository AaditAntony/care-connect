import 'dart:convert';
import 'package:care_connect/user/user_complaint_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimary = Color(0xFF5C6BC0);
const Color kBackground = Color(0xFFF4F6FB);

class UserConsultationDetailPage extends StatelessWidget {
  final String appointmentId;

  const UserConsultationDetailPage({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Consultation Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                /// 🔷 Doctor Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, Color(0xFF3949AB)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: kPrimary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Consulted By",
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['doctorName'] ?? "Doctor",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                buildSection("Diagnosis", data['diagnosis'] ?? ""),
                buildListSection(
                  "Prescribed Medicines",
                  medicines.cast<String>(),
                ),
                buildListSection(
                  "Assigned Activities",
                  activities.cast<String>(),
                ),
                buildSection("Doctor Notes", data['notes'] ?? ""),

                if (data['prescriptionImageBase64'] != null)
                  buildImageSection(
                    "Prescription Image",
                    data['prescriptionImageBase64'],
                  ),

                if (data['doctorSignatureBase64'] != null)
                  buildImageSection(
                    "Doctor Signature",
                    data['doctorSignatureBase64'],
                    height: 90,
                  ),

                const SizedBox(height: 30),

                /// 🔴 Report Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
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
                    child: const Text(
                      "Report Doctor",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black.withOpacity(0.05),
                ),
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: items.isEmpty
                ? const Text("None")
                : Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: kPrimary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(item)),
                              ],
                            ),
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(base64Image),
                height: height,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
