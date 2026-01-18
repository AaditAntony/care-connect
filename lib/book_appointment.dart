import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookAppointmentPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const BookAppointmentPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final problemController = TextEditingController();
  String selectedSlot = "10:00 AM - 10:30 AM";
  bool loading = false;

  final slots = [
    "10:00 AM - 10:30 AM",
    "11:00 AM - 11:30 AM",
    "2:00 PM - 2:30 PM",
  ];

  Future<void> bookAppointment() async {
    setState(() => loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('appointments').add({
        'doctorId': widget.doctorId,
        'userId': userId,
        'problem': problemController.text.trim(),
        'timeSlot': selectedSlot,
        'status': 'booked',
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consult ${widget.doctorName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: problemController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Describe your problem",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedSlot,
              items: slots
                  .map(
                    (slot) => DropdownMenuItem(
                  value: slot,
                  child: Text(slot),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSlot = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Time Slot",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : bookAppointment,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Book Appointment"),
            ),
          ],
        ),
      ),
    );
  }
}
