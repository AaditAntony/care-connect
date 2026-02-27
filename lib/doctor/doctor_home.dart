import 'package:flutter/material.dart';
import 'doctor_appointments_page.dart';
import 'doctors_referal_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DoctorAppointmentsPage(), // Index 0
    DoctorReferralsPage(),    // Index 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        automaticallyImplyLeading: false,
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.transfer_within_a_station),
            label: "Referrals",
          ),
        ],
      ),
    );
  }
}
// change need