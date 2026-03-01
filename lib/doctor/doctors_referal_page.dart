import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorReferralsPage extends StatefulWidget {
  const DoctorReferralsPage({super.key});

  @override
  State<DoctorReferralsPage> createState() => _DoctorReferralsPageState();
}

class _DoctorReferralsPageState extends State<DoctorReferralsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final String doctorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// ACCEPT REFERRAL
  Future<void> acceptReferral(
    String referralId,
    Map<String, dynamic> data,
  ) async {
    // 1️⃣ Update referral status
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(referralId)
        .update({'status': 'accepted'});

    // 2️⃣ Create new appointment for receiving doctor
    await FirebaseFirestore.instance.collection('appointments').add({
      'doctorId': doctorId,
      'userId': data['userId'],
      'patientEmail': data['patientEmail'],
      'timeSlot': "Referred Case",
      'status': 'booked',
      'createdAt': Timestamp.now(),
    });

    // 3️⃣ Mark original appointment as referred (optional safety)
    if (data['appointmentId'] != null) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(data['appointmentId'])
          .update({'isReferred': true});
    }
  }

  /// REJECT REFERRAL
  Future<void> rejectReferral(String referralId) async {
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(referralId)
        .update({'status': 'rejected'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Referrals", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00897B),
          labelColor: const Color(0xFF00897B),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Incoming"),
            Tab(text: "Outgoing"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildIncoming(), buildOutgoing()],
      ),
    );
  }

  /// INCOMING REFERRALS
  Widget buildIncoming() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('referrals')
          .where('toDoctorId', isEqualTo: doctorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No incoming referrals"));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Patient Email
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF00897B),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data['patientEmail'] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      buildStatusBadge(data['status']),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// From / To Doctor
                  Text(
                    data.containsKey('fromDoctorName')
                        ? "From: ${data['fromDoctorName']}"
                        : "To: ${data['toDoctorName']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  /// Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data['referralNote'] ?? "",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),

                  if (data['status'] == 'pending')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => rejectReferral(doc.id),
                            child: const Text(
                              "Reject",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),

                          const SizedBox(width: 8),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => acceptReferral(doc.id, data),
                            child: const Text("Accept"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// OUTGOING REFERRALS
  Widget buildOutgoing() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('referrals')
          .where('fromDoctorId', isEqualTo: doctorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No outgoing referrals"));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Patient Email
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF00897B),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data['patientEmail'] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      buildStatusBadge(data['status']),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// From / To Doctor
                  Text(
                    data.containsKey('fromDoctorName')
                        ? "From: ${data['fromDoctorName']}"
                        : "To: ${data['toDoctorName']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  /// Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data['referralNote'] ?? "",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),

                  if (data['status'] == 'pending')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => rejectReferral(doc.id),
                            child: const Text(
                              "Reject",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),

                          const SizedBox(width: 8),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => acceptReferral(doc.id, data),
                            child: const Text("Accept"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildStatusBadge(String status) {
    Color color;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
//