import 'package:care_connect/admin/admin_overview_page.dart';
import 'package:flutter/material.dart';
import 'admin_doctor_approval_page.dart';
import 'admin_complaints_page.dart';
import 'admin_user_management_page.dart';
import 'admin_doctor_management_page.dart';
import 'admin_appointments_page.dart';

class AdminEntryPage extends StatefulWidget {
  const AdminEntryPage({super.key});

  @override
  State<AdminEntryPage> createState() => _AdminEntryPageState();
}

class _AdminEntryPageState extends State<AdminEntryPage> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    "Overview",
    "User Management",
    "Doctor Approvals",
    "Doctor Management",
    "Appointments",
    "Complaints"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Row(
        children: [
          /// ================= SIDEBAR =================
          Container(
            width: 250,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const Icon(Icons.local_hospital, color: Colors.white, size: 40),

                const SizedBox(height: 15),

                const Text(
                  "CareConnect",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                ...List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconForIndex(index),
                            color: isSelected ? Colors.blue : Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            menuItems[index],
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          /// ================= MAIN CONTENT =================
          Expanded(
            child: Column(
              children: [
                /// HEADER
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(blurRadius: 6, color: Colors.black12),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        menuItems[selectedIndex],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                /// BODY
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: buildSelectedPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return AdminOverviewPage();
      case 1:
        return const AdminUserManagementPage();
      case 2:
        return const AdminDoctorApprovalPage();
      case 3:
        return const AdminDoctorManagementPage();
      case 4:
        return const AdminAppointmentsPage();
      case 5:
        return const AdminComplaintsPage();
      default:
        return AdminOverviewPage();
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.people;
      case 2:
        return Icons.verified;
      case 3:
        return Icons.medical_services;
      case 4:
        return Icons.calendar_today;
      case 5:
        return Icons.report;
      default:
        return Icons.dashboard;
    }
  }

  /// OVERVIEW UI (Simple for now — we improve later)
  Widget buildOverview() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 25,
      mainAxisSpacing: 25,
      children: const [
        StatCard(
          title: "Total Doctors",
          value: "0",
          icon: Icons.medical_services,
        ),
        StatCard(title: "Total Users", value: "0", icon: Icons.people),
        StatCard(title: "Pending Approvals", value: "0", icon: Icons.pending),
        StatCard(title: "Complaints", value: "0", icon: Icons.report_problem),
      ],
    );
  }
}

/// ================= STAT CARD =================
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 15, color: Colors.grey.withOpacity(0.08)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
