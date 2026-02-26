import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDoctorDetailPage extends StatelessWidget {
  final String doctorId;

  const AdminDoctorDetailPage({
    super.key,
    required this.doctorId,
  });

  Future<void> approveDoctor() async {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .update({
      'verificationStatus': 'approved',
      'isVerified': true,
    });
  }

  Future<void> rejectDoctor() async {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .update({
      'verificationStatus': 'rejected',
      'isVerified': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Doctor Details"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctorId)
            .get(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      data['name'] ?? "",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text("Email: ${data['email'] ?? ''}"),
                    Text("Qualification: ${data['qualification'] ?? ''}"),
                    Text("Specialization: ${data['specialization'] ?? ''}"),
                    Text("Experience: ${data['experience'] ?? ''} years"),

                    const SizedBox(height: 25),

                    const Text(
                      "Profile Image",
                      style:
                      TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (data['profileImageBase64'] != null)
                      Image.memory(
                        base64Decode(
                            data['profileImageBase64']),
                        height: 150,
                      ),

                    const SizedBox(height: 25),

                    const Text(
                      "Certificate",
                      style:
                      TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (data['certificateBase64'] != null)
                      Image.memory(
                        base64Decode(
                            data['certificateBase64']),
                        height: 200,
                      ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await rejectDoctor();
                            Navigator.pop(context);
                          },
                          child: const Text("Reject"),
                        ),

                        const SizedBox(width: 15),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            await approveDoctor();
                            Navigator.pop(context);
                          },
                          child: const Text("Approve"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}