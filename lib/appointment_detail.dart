import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDetailPage extends StatefulWidget {
  final String appointmentId;
  final String userId;
  final String doctorId;

  const AppointmentDetailPage({
    super.key,
    required this.appointmentId,
    required this.userId,
    required this.doctorId,
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
            // -------- MEDICINE SECTION --------
            const Text(
              "Prescribe Medicine",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: medicineController,
              decoration: const InputDecoration(
                labelText: "Medicine & dosage",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: addMedicine,
              child: const Text("Add Medicine"),
            ),

            const SizedBox(height: 20),

            // -------- ACTIVITY SECTION --------
            const Text(
              "Assign Activity / Exercise",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

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

            const SizedBox(height: 30),

            // -------- COMPLETE BUTTON --------
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
          ],
        ),
      ),
    );
  }
}
