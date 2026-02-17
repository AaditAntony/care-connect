import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'appointment_detail.dart';
import '../login.dart';

class DoctorAppointmentsPage extends StatefulWidget {
  const DoctorAppointmentsPage({super.key});

  @override
  State<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;

  // Logout function
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      // 🔐 Filter appointments by doctorId
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // No appointments
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No appointments yet"),
            );
          }

          // Appointment list
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Patient ID: ${data['userId']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient email: ${data['patientEmail']}"),
                      Text("Time Slot: ${data['timeSlot']}"),
                      Text("Status: ${data['status']}"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),

                  // 👉 OPEN APPOINTMENT DETAIL
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentDetailPage(
                            appointmentId: doc.id,
                            userId: data['userId'],
                            doctorId: doctorId,
                            patientEmail: data['patientEmail']

                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );

  }
}
