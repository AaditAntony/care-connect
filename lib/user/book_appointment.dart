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

  final List<String> slots = [
    "10:00 AM - 10:30 AM",
    "11:00 AM - 11:30 AM",
    "2:00 PM - 2:30 PM",
  ];

  Future<void> bookAppointment() async {
    if (problemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe your problem")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      if (user.email == null) {
        throw "User email not available";
      }

      /// 🔍 CHECK IF SLOT ALREADY BOOKED
      final existing = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('timeSlot', isEqualTo: selectedSlot)
          .where('status', isEqualTo: 'booked')
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This time slot is already booked. Please choose another.",
            ),
          ),
        );
        return;
      }

      /// ✅ CREATE APPOINTMENT
      await FirebaseFirestore.instance.collection('appointments').add({
        'doctorId': widget.doctorId,
        'doctorName': widget.doctorName, // ✅ IMPORTANT FIX
        'userId': user.uid,
        'patientEmail': user.email,
        'problem': problemController.text.trim(),
        'timeSlot': selectedSlot,
        'status': 'booked',
        'isReferred': false,
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            /// 🔷 HEADER
            const Text(
              "Book Appointment",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// 🔷 DOCTOR CARD
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF5C6BC0),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔷 PROBLEM SECTION
            const Text(
              "Describe Your Concern",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: TextField(
                controller: problemController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Enter your symptoms or issue...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 🔷 SLOT SECTION
            const Text(
              "Choose Time Slot",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: selectedSlot,
                icon: const Icon(Icons.keyboard_arrow_down),
                decoration: const InputDecoration(border: InputBorder.none),
                items: slots
                    .map(
                      (slot) =>
                          DropdownMenuItem(value: slot, child: Text(slot)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSlot = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 40),

            /// 🔷 BOOK BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6BC0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                onPressed: loading ? null : bookAppointment,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Confirm Appointment",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
