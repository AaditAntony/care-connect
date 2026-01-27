import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'doctor_complaint_page.dart';

class AppointmentDetailPage extends StatefulWidget {
  final String appointmentId;
  final String userId;
  final String doctorId;
  final String patientEmail;
  const AppointmentDetailPage({
    super.key,
    required this.appointmentId,
    required this.userId,
    required this.doctorId, required this.patientEmail,
  });

  @override
  State<AppointmentDetailPage> createState() =>
      _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final TextEditingController medicineController = TextEditingController();
  final TextEditingController activityController = TextEditingController();

  bool loading = false;

  /// Add medicine for this appointment
  Future<void> addMedicine() async {
    if (medicineController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('prescriptions').add({
      'appointmentId': widget.appointmentId,
      'userId': widget.userId,
      'doctorId': widget.doctorId,
      'medicine': medicineController.text.trim(),
      'createdAt': Timestamp.now(),
    });

    medicineController.clear();
  }

  /// Add activity/exercise
  Future<void> addActivity() async {
    if (activityController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('activities').add({
      'appointmentId': widget.appointmentId,
      'userId': widget.userId,
      'doctorId': widget.doctorId,
      'activity': activityController.text.trim(),
      'isCompleted': false,
      'createdAt': Timestamp.now(),
    });

    activityController.clear();
  }

  /// Mark appointment completed
  Future<void> completeAppointment() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentId)
        .update({
      'status': 'completed',
    });

    setState(() => loading = false);
    Navigator.pop(context);
  }
  Future<void> openGmailForMeet(String patientEmail) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: patientEmail,
      queryParameters: {
        'subject': 'Online Consultation – Google Meet',
        'body':
        'Hello,\n\nPlease join the consultation using the Google Meet link below:\n\n',
      },
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open email app")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment Detail"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= MEDICINE SECTION =================
            const Text(
              "Prescribed Medicines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🔥 SHOW MEDICINES (IMPORTANT FIX)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prescriptions')
                  .where('appointmentId',
                  isEqualTo: widget.appointmentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text("No medicines added yet");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: Text(doc['medicine']),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: medicineController,
              decoration: const InputDecoration(
                labelText: "Medicine name & dosage",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: addMedicine,
              child: const Text("Add Medicine"),
            ),

            const SizedBox(height: 30),

            // ================= ACTIVITY SECTION =================
            const Text(
              "Assigned Activities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🔥 SHOW ACTIVITIES
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activities')
                  .where('appointmentId',
                  isEqualTo: widget.appointmentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text("No activities assigned yet");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(doc['activity']),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: activityController,
              decoration: const InputDecoration(
                labelText: "Activity description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: addActivity,
              child: const Text("Add Activity"),
            ),

            // ================= SEND GMAIL =================
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.video_call),
              label: const Text("Send Google Meet Link"),
              onPressed: () {
                openGmailForMeet(widget.patientEmail);
              },
            ),


            // ================= COMPLETE =================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: loading ? null : completeAppointment,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Mark Appointment as Completed"),


            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorComplaintPage(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              child: const Text("Report User"),
            ),

          ],
        ),
      ),
    );
  }
}
