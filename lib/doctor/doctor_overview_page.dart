import 'package:flutter/material.dart';

class DoctorOverviewPage extends StatelessWidget {
  const DoctorOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: const [
            OverviewCard(
              title: "Total Patients",
              value: "0",
              icon: Icons.people,
            ),
            OverviewCard(
              title: "Booked Appointments",
              value: "0",
              icon: Icons.calendar_today,
            ),
            OverviewCard(
              title: "Completed",
              value: "0",
              icon: Icons.check_circle,
            ),
            OverviewCard(
              title: "Pending Referrals",
              value: "0",
              icon: Icons.swap_horiz,
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.grey.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}