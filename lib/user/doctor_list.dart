import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_appointment.dart';

class DoctorListPage extends StatelessWidget {
  const DoctorListPage({super.key});

  static const Color primary = Color(0xFF5C6BC0);
  static const Color primaryLight = Color(0xFFE8EAF6);
  static const Color background = Color(0xFFF4F6FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          /// 🔷 HEADER SECTION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [primary, Color(0xFF3949AB)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find Your Doctor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Consult verified specialists",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// 🔷 DOCTOR LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .where('verificationStatus', isEqualTo: 'approved')
                  .where('isBlocked', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No doctors available at the moment",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final doctors = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doc = doctors[index];
                    final data = doc.data() as Map<String, dynamic>;

                    /// 🔹 Profile Image
                    Widget profileImageWidget = const CircleAvatar(
                      radius: 38,
                      backgroundColor: primaryLight,
                      child: Icon(Icons.person, size: 38, color: primary),
                    );

                    if (data['profileImageBase64'] != null &&
                        data['profileImageBase64'].toString().isNotEmpty) {
                      try {
                        profileImageWidget = CircleAvatar(
                          radius: 38,
                          backgroundImage: MemoryImage(
                            base64Decode(data['profileImageBase64']),
                          ),
                        );
                      } catch (_) {}
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 22),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 Top Row
                          Row(
                            children: [
                              profileImageWidget,
                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Name + Verified
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['name'] ?? "Doctor",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      data['qualification'] ?? "",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          /// Specialization Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data['specialization'] ?? "",
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// Experience Row
                          Row(
                            children: [
                              const Icon(
                                Icons.work_outline,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${data['experience'] ?? "0"} Years Experience",
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          /// Consult Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5C6BC0),
                                    foregroundColor:
                                        Colors.white, // 🔥 Important
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                  ).copyWith(
                                    overlayColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_month, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Book Consultation",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookAppointmentPage(
                                      doctorId: doc.id,
                                      doctorName: data['name'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
