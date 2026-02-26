import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDoctorDetailPage extends StatelessWidget {
  final String doctorId;

  const AdminDoctorDetailPage({super.key, required this.doctorId});

  Future<void> approveDoctor() async {
    await FirebaseFirestore.instance.collection('doctors').doc(doctorId).update(
      {'verificationStatus': 'approved', 'isVerified': true},
    );
  }

  Future<void> rejectDoctor() async {
    await FirebaseFirestore.instance.collection('doctors').doc(doctorId).update(
      {'verificationStatus': 'rejected', 'isVerified': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          "Doctor Verification",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String status = data['verificationStatus'] ?? "pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER =================
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.grey.withOpacity(0.08),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// Profile Image
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: data['profileImageBase64'] != null
                            ? MemoryImage(
                                base64Decode(data['profileImageBase64']),
                              )
                            : null,
                        child: data['profileImageBase64'] == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              )
                            : null,
                      ),

                      const SizedBox(width: 25),

                      /// Name + Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? "",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data['email'] ?? "",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Status Badge
                      buildStatusBadge(status),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// ================= PROFESSIONAL INFO =================
                buildSectionTitle("Professional Information"),
                const SizedBox(height: 15),
                buildInfoCard([
                  buildInfoRow("Qualification", data['qualification'] ?? ""),
                  buildInfoRow("Specialization", data['specialization'] ?? ""),
                  buildInfoRow(
                    "Experience",
                    "${data['experience'] ?? ""} years",
                  ),
                ]),

                const SizedBox(height: 40),

                /// ================= PROFILE IMAGE SECTION =================
                buildSectionTitle("Profile Image"),
                const SizedBox(height: 15),
                buildImageCard(data['profileImageBase64'], 220),

                const SizedBox(height: 40),

                /// ================= CERTIFICATE SECTION =================
                buildSectionTitle("Certificate / Proof"),
                const SizedBox(height: 15),
                buildImageCard(data['certificateBase64'], 300),

                const SizedBox(height: 50),

                /// ================= ACTION BUTTONS =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await rejectDoctor();
                        Navigator.pop(context);
                      },
                      child: const Text("Reject"),
                    ),

                    const SizedBox(width: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await approveDoctor();
                        Navigator.pop(context);
                      },
                      child: const Text("Approve"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= STATUS BADGE =================
  Widget buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "approved":
        bgColor = Colors.green.shade100;
        textColor = Colors.green;
        break;
      case "rejected":
        bgColor = Colors.red.shade100;
        textColor = Colors.red;
        break;
      default:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// ================= SECTION TITLE =================
  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// ================= INFO CARD =================
  Widget buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 15, color: Colors.grey.withOpacity(0.08)),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// ================= INFO ROW =================
  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  /// ================= IMAGE CARD =================
  Widget buildImageCard(String? base64String, double height) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 15, color: Colors.grey.withOpacity(0.08)),
        ],
      ),
      child: base64String == null
          ? SizedBox(
              height: height,
              child: const Center(child: Text("No Image Available")),
            )
          : Image.memory(
              base64Decode(base64String),
              height: height,
              fit: BoxFit.contain,
            ),
    );
  }
}
