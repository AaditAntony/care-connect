import 'package:flutter/material.dart';
import 'admin_doctor_approval_page.dart';
import 'admin_complaints_page.dart';

class AdminEntryPage extends StatefulWidget {
  const AdminEntryPage({super.key});

  @override
  State<AdminEntryPage> createState() => _AdminEntryPageState();
}

class _AdminEntryPageState extends State<AdminEntryPage> {
  int selectedTab = 0;

  final List<String> tabs = [
    "Overview",
    "Pending Doctors",
    "Complaints",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= HEADER =======
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Admin Dashboard",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ======= TAB BAR =======
            Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedTab == index;

                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = index;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                            color:
                            isSelected ? Colors.purple : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (isSelected)
                          Container(
                            height: 3,
                            width: 80,
                            color: Colors.purple,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // ======= BODY SECTION =======
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ],
                ),
                child: buildSelectedTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSelectedTab() {
    switch (selectedTab) {
      case 0:
        return buildOverview();
      case 1:
       // return const AdminVerifyDoctorsPage();
        return const AdminDoctorApprovalPage();
      case 2:
        return const AdminComplaintsPage();
      default:
        return const SizedBox();
    }
  }

  Widget buildOverview() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: const [
        StatCard(title: "Total Doctors", value: "0"),
        StatCard(title: "Total Users", value: "0"),
        StatCard(title: "Pending Approvals", value: "0"),
        StatCard(title: "Complaints", value: "0"),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
