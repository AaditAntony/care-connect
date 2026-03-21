import 'package:care_connect/user/payment_page.dart';
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
  String? selectedSlot;
  bool loading = false;

  List<String> allSlots = [];
  List<String> bookedSlots = [];
  bool isLoadingSlots = true;

  @override
  void initState() {
    super.initState();
    allSlots = _generateTimeSlots();
    _fetchBookedSlots();
  }

  String _formatTime(int hour, int minute) {
    String period = hour >= 12 ? 'PM' : 'AM';
    int h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  List<String> _generateTimeSlots() {
    List<String> generatedSlots = [];
    for (int h = 9; h < 17; h++) {
      generatedSlots.add('${_formatTime(h, 0)} - ${_formatTime(h, 30)}');
      generatedSlots.add('${_formatTime(h, 30)} - ${_formatTime(h + 1, 0)}');
    }
    return generatedSlots;
  }

  bool _isSlotInPast(String slot) {
    try {
      final now = DateTime.now();
      final startTimeStr = slot.split(' - ')[0]; // e.g. "9:00 AM"
      final parts = startTimeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (parts[1] == 'PM' && hour != 12)
        hour += 12;
      else if (parts[1] == 'AM' && hour == 12)
        hour = 0;

      DateTime slotTime = DateTime(now.year, now.month, now.day, hour, minute);
      return slotTime.isBefore(now) || slotTime.isAtSameMomentAs(now);
    } catch (e) {
      return false;
    }
  }

  Future<void> _fetchBookedSlots() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('status', isEqualTo: 'booked')
          .get();

      if (mounted) {
        setState(() {
          bookedSlots = snapshot.docs
              .map((doc) => doc['timeSlot'] as String)
              .toList();
          isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingSlots = false);
      }
      print("Error fetching slots: $e");
    }
  }

  Future<void> bookAppointment() async {
    if (problemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe your problem")),
      );
      return;
    }

    if (selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time slot")),
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
        'timeSlot': selectedSlot!,
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

  Future<void> handlePayment() async {
    bool? paid = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentPage()),
    );

    if (paid == true) {
      await bookAppointment();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful. Appointment booked."),
        ),
      );
    }
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

            isLoadingSlots
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: allSlots.map((slot) {
                      bool isPast = _isSlotInPast(slot);
                      bool isBooked = bookedSlots.contains(slot);
                      bool isOccupied = isPast || isBooked;
                      bool isSelected = selectedSlot == slot;

                      return GestureDetector(
                        onTap: isOccupied
                            ? null
                            : () {
                                setState(() {
                                  selectedSlot = slot;
                                });
                              },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 70) / 3,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOccupied
                                ? Colors.red.shade50
                                : isSelected
                                ? const Color(0xFF5C6BC0)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOccupied
                                  ? Colors.red.shade300
                                  : isSelected
                                  ? const Color(0xFF5C6BC0)
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: isSelected || !isOccupied
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            slot,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isOccupied
                                  ? Colors.red.shade400
                                  : isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              decoration: isOccupied
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                onPressed: loading ? null : handlePayment,
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
