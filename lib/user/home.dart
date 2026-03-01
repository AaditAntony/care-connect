import 'package:care_connect/user/user_appointments_page.dart';
import 'package:care_connect/user/user_dashboard_page.dart';
import 'package:care_connect/user_profile_page.dart';
import 'package:flutter/material.dart';

// USER SCREENS
import 'doctor_list.dart';

// USER HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  // 🔹 Pages MUST match bottom nav items count
  final List<Widget> pages = const [
    UserDashboardPage(), // 🔥 NEW DASHBOARD
    UserAppointmentsPage(),
    UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Home")),
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
            icon: Icon(Icons.local_hospital),
            label: "Doctors",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
