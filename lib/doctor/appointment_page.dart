import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Appointments"),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: "Booked"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BookedAppointmentsTab(),
            CompletedAppointmentsTab(),
          ],
        ),
      ),
    );
  }
}

class BookedAppointmentsTab extends StatelessWidget {
  const BookedAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final String doctorId =
        FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'booked')
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
              child: Text("No booked appointments"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {

            final doc = snapshot.data!.docs[index];
            final data =
                doc.data() as Map<String, dynamic>;

            return Container(
              margin:
                  const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.all(16),
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
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person,
                      color: Colors.white),
                ),
                title: Text(
                  data['patientEmail'] ??
                      "Patient",
                  style: const TextStyle(
                      fontWeight:
                          FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                        "Time: ${data['timeSlot']}"),
                    const SizedBox(height: 4),
                    const Text(
                      "Status: Booked",
                      style: TextStyle(
                          color: Colors.blue),
                    ),
                  ],
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios,
                        size: 16),
                onTap: () {
                  // 🔥 Later we connect to ConsultationPage
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Open Consultation Page")),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class CompletedAppointmentsTab extends StatelessWidget {
  const CompletedAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final String doctorId =
        FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status',
              isEqualTo: 'completed')
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
              child: Text(
                  "No completed consultations"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {

            final doc = snapshot.data!.docs[index];
            final data =
                doc.data() as Map<String, dynamic>;

            return Container(
              margin:
                  const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.all(16),
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
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor:
                      Colors.green,
                  child: Icon(Icons.check,
                      color: Colors.white),
                ),
                title: Text(
                  data['patientEmail'] ??
                      "Patient",
                  style: const TextStyle(
                      fontWeight:
                          FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                        "Time: ${data['timeSlot']}"),
                    const SizedBox(height: 4),
                    const Text(
                      "Status: Completed",
                      style: TextStyle(
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}