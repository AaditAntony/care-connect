import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_consultation_detail_page.dart';

class UserAppointmentsPage extends StatelessWidget {
  const UserAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          title: const Text("My Appointments"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Referred"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AppointmentsTab(status: "booked"),
            _AppointmentsTab(status: "completed"),
            _ReferredTab(),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  final String status;

  const _AppointmentsTab({required this.status});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        // 🔴 Error state
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // 🔵 Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 🟡 Empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              status == "booked"
                  ? "No upcoming appointments"
                  : "No completed appointments",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(blurRadius: 8, color: Colors.grey.withOpacity(0.1)),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: status == "completed"
                      ? Colors.green
                      : Colors.blue,
                  child: Icon(
                    status == "completed" ? Icons.check : Icons.calendar_today,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  data['doctorName'] ?? "Doctor",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Time: ${data['timeSlot']}"),
                    const SizedBox(height: 4),
                    Text(
                      "Status: ${data['status']}",
                      style: TextStyle(
                        color: status == "completed"
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                  ],
                ),
                trailing: status == "completed"
                    ? const Icon(Icons.arrow_forward_ios, size: 16)
                    : null,
                onTap: status == "completed"
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserConsultationDetailPage(
                              appointmentId: doc.id,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _ReferredTab extends StatelessWidget {
  const _ReferredTab();

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('isReferred', isEqualTo: true)
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
              "No referred cases",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.orange),
                title: Text(data['doctorName'] ?? "Doctor"),
                subtitle: const Text("You have been referred"),
              ),
            );
          },
        );
      },
    );
  }
}
