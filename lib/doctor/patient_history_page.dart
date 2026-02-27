import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientHistoryPage extends StatelessWidget {
  final String userId;

  const PatientHistoryPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient History"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No previous consultations"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {

              final doc = snapshot.data!.docs[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              final timestamp =
                  data['createdAt'] as Timestamp;
              final date =
                  timestamp.toDate();

              return Container(
                margin:
                    const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.grey
                          .withOpacity(0.1),
                    )
                  ],
                ),
                child: ExpansionTile(
                  title: Text(
                    data['doctorName'] ??
                        "Doctor",
                    style: const TextStyle(
                        fontWeight:
                            FontWeight.bold),
                  ),
                  subtitle: Text(
                      "${date.day}/${date.month}/${date.year}"),
                  children: [

                    /// Diagnosis
                    buildSection(
                        "Diagnosis",
                        data['diagnosis'] ?? ""),

                    /// Medicines
                    buildListSection(
                        "Medicines",
                        List<String>.from(
                            data['medicines'] ??
                                [])),

                    /// Activities
                    buildListSection(
                        "Activities",
                        List<String>.from(
                            data['activities'] ??
                                [])),

                    /// Notes
                    buildSection(
                        "Notes",
                        data['notes'] ?? ""),

                    /// Prescription Image
                    if (data[
                            'prescriptionImageBase64'] !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              "Prescription Image",
                              style: TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold),
                            ),
                            const SizedBox(
                                height: 8),
                            Image.memory(
                              base64Decode(data[
                                  'prescriptionImageBase64']),
                              height: 150,
                            ),
                          ],
                        ),
                      ),

                    /// Signature
                    if (data[
                            'doctorSignatureBase64'] !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              "Doctor Signature",
                              style: TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold),
                            ),
                            const SizedBox(
                                height: 8),
                            Image.memory(
                              base64Decode(data[
                                  'doctorSignatureBase64']),
                              height: 80,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(value),
        ],
      ),
    );
  }

  Widget buildListSection(
      String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Row(
              children: [
                const Icon(Icons.circle,
                    size: 6),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}