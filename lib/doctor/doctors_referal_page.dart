import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorReferralsPage extends StatefulWidget {
  const DoctorReferralsPage({super.key});

  @override
  State<DoctorReferralsPage> createState() =>
      _DoctorReferralsPageState();
}

class _DoctorReferralsPageState
    extends State<DoctorReferralsPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final String doctorId =
      FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this);
  }

  /// ACCEPT REFERRAL
  Future<void> acceptReferral(
      String referralId,
      Map<String, dynamic> data) async {

    // 1️⃣ Update referral status
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(referralId)
        .update({'status': 'accepted'});

    // 2️⃣ Create new appointment for receiving doctor
    await FirebaseFirestore.instance
        .collection('appointments')
        .add({
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
      appBar: AppBar(
        title: const Text("Referrals"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Incoming"),
            Tab(text: "Outgoing"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildIncoming(),
          buildOutgoing(),
        ],
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
          return const Center(
              child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No incoming referrals"));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: snapshot.data!.docs.map((doc) {

            final data =
                doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      data['patientEmail'] ?? "",
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                        "From: ${data['fromDoctorName']}"),

                    const SizedBox(height: 6),

                    Text(
                        "Note: ${data['referralNote']}"),

                    const SizedBox(height: 12),

                    Text(
                      "Status: ${data['status']}",
                      style: TextStyle(
                        color: data['status'] ==
                                'pending'
                            ? Colors.orange
                            : data['status'] ==
                                    'accepted'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),

                    if (data['status'] ==
                        'pending')
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [

                          TextButton(
                            onPressed: () =>
                                rejectReferral(
                                    doc.id),
                            child:
                                const Text("Reject"),
                          ),

                          ElevatedButton(
                            onPressed: () =>
                                acceptReferral(
                                    doc.id, data),
                            child:
                                const Text("Accept"),
                          ),
                        ],
                      ),
                  ],
                ),
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
          .where('fromDoctorId',
              isEqualTo: doctorId)
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No outgoing referrals"));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: snapshot.data!.docs.map((doc) {

            final data =
                doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      data['patientEmail'] ?? "",
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                        "To: ${data['toDoctorName']}"),

                    const SizedBox(height: 6),

                    Text(
                        "Note: ${data['referralNote']}"),

                    const SizedBox(height: 12),

                    Text(
                      "Status: ${data['status']}",
                      style: TextStyle(
                        color: data['status'] ==
                                'pending'
                            ? Colors.orange
                            : data['status'] ==
                                    'accepted'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}