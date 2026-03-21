import 'package:care_connect/doctor/consultation_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Appointments",
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Color(0xFF00897B),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF00897B),
            tabs: [
              Tab(text: "Booked"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [BookedAppointmentsTab(), CompletedAppointmentsTab()],
        ),
      ),
    );
  }
}

class BookedAppointmentsTab extends StatelessWidget {
  const BookedAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final String doctorId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'booked')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyState(
            icon: Icons.calendar_today_outlined,
            message: "No booked appointments",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _AppointmentCard(
              appointmentId: doc.id, // Passed for cancellation
              patientEmail: data['patientEmail'] ?? "Patient",
              timeSlot: data['timeSlot'] ?? "",
              status: "Booked",
              statusColor: const Color(0xFF00897B),
              icon: Icons.schedule,
              showCancelButton: true, // Show Cancel Button
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConsultationPage(
                      appointmentId: doc.id,
                      userId: data['userId'],
                      patientEmail: data['patientEmail'],
                    ),
                  ),
                );
              },
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
    final String doctorId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyState(
            icon: Icons.check_circle_outline,
            message: "No completed consultations",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _AppointmentCard(
              appointmentId: doc.id,
              patientEmail: data['patientEmail'] ?? "Patient",
              timeSlot: data['timeSlot'] ?? "",
              status: "Completed",
              statusColor: Colors.green,
              icon: Icons.check_circle,
              showCancelButton: false, // No cancellation for completed
              onTap: null,
            );
          },
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String appointmentId;
  final String patientEmail;
  final String timeSlot;
  final String status;
  final Color statusColor;
  final IconData icon;
  final bool showCancelButton;
  final VoidCallback? onTap;

  const _AppointmentCard({
    required this.appointmentId,
    required this.patientEmail,
    required this.timeSlot,
    required this.status,
    required this.statusColor,
    required this.icon,
    this.showCancelButton = false,
    required this.onTap,
  });

  Future<void> _cancelAppointment(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Appointment"),
        content: const Text(
          "Are you sure you want to cancel this appointment because you are unavailable?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': 'cancelled'});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment cancelled successfully")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: statusColor.withOpacity(0.15),
              child: Icon(icon, color: statusColor),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Time: $timeSlot",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (showCancelButton)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                tooltip: "Cancel Appointment",
                onPressed: () => _cancelAppointment(context),
              )
            else if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
