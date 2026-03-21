import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_consultation_detail_page.dart';

/// 🔷 File-level colors (Fixes scope issue)
const Color kPrimary = Color(0xFF5C6BC0);
const Color kBackground = Color(0xFFF4F6FB);

class UserAppointmentsPage extends StatelessWidget {
  const UserAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "My Appointments",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: kPrimary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kPrimary,
            indicatorWeight: 3,
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
      stream: status == "booked"
          ? FirebaseFirestore.instance
                .collection('appointments')
                .where('userId', isEqualTo: userId)
                .where('status', whereIn: ['booked', 'cancelled'])
                .snapshots()
          : FirebaseFirestore.instance
                .collection('appointments')
                .where('userId', isEqualTo: userId)
                .where('status', isEqualTo: status)
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

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
        final bool isCompleted = status == "completed";

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final bool isCancelled = data['status'] == 'cancelled';

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isCancelled ? Colors.red.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: isCancelled
                    ? Border.all(color: Colors.red.shade300)
                    : null,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: isCompleted && !isCancelled
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        /// 🔹 Icon Circle
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isCancelled
                              ? Colors.red.withOpacity(0.15)
                              : isCompleted
                              ? Colors.green.withOpacity(0.15)
                              : kPrimary.withOpacity(0.15),
                          child: Icon(
                            isCancelled
                                ? Icons.cancel
                                : isCompleted
                                ? Icons.check_circle
                                : Icons.calendar_today,
                            color: isCancelled
                                ? Colors.red
                                : isCompleted
                                ? Colors.green
                                : kPrimary,
                          ),
                        ),

                        const SizedBox(width: 16),

                        /// 🔹 Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['doctorName'] ?? "Doctor",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                data['timeSlot'] ?? "",
                                style: TextStyle(
                                  color: isCancelled
                                      ? Colors.red.shade400
                                      : Colors.grey,
                                  decoration: isCancelled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// 🔹 Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isCancelled
                                      ? Colors.red.withOpacity(0.15)
                                      : isCompleted
                                      ? Colors.green.withOpacity(0.15)
                                      : kPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data['status'].toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isCancelled
                                        ? Colors.red
                                        : isCompleted
                                        ? Colors.green
                                        : kPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (isCompleted && !isCancelled)
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                    if (isCancelled)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "The doctor is not available, the meeting that is scheduled has been cancelled and you will get back the payment in the next 42 hours.",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(Icons.swap_horiz, color: Colors.orange),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "You have been referred to another doctor",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
