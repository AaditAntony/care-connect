import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔵 Welcome
            const Text(
              "Welcome Back 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// 🔵 Stats Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {

                final stats = [
                  _StatData(
                    title: "Doctors",
                    color: Colors.blue,
                    stream: FirebaseFirestore.instance
                        .collection('doctors')
                        .where('verificationStatus',
                            isEqualTo: 'approved')
                        .where('isBlocked', isEqualTo: false)
                        .snapshots(),
                  ),
                  _StatData(
                    title: "Upcoming",
                    color: Colors.orange,
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('userId', isEqualTo: userId)
                        .where('status', isEqualTo: 'booked')
                        .snapshots(),
                  ),
                  _StatData(
                    title: "Completed",
                    color: Colors.green,
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('userId', isEqualTo: userId)
                        .where('status', isEqualTo: 'completed')
                        .snapshots(),
                  ),
                  _StatData(
                    title: "Referred",
                    color: Colors.purple,
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('userId', isEqualTo: userId)
                        .where('isReferred', isEqualTo: true)
                        .snapshots(),
                  ),
                ];

                return _StatCard(data: stats[index]);
              },
            ),

            const SizedBox(height: 30),

            /// 🔵 Quick Actions
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _QuickActionButton(
              icon: Icons.local_hospital,
              title: "Find Doctors",
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _QuickActionButton(
              icon: Icons.calendar_today,
              title: "My Appointments",
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _QuickActionButton(
              icon: Icons.person,
              title: "My Profile",
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  final String title;
  final Color color;
  final Stream<QuerySnapshot> stream;

  _StatData({
    required this.title,
    required this.color,
    required this.stream,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            data.color.withOpacity(0.9),
            data.color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: data.stream,
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final count =
              snapshot.data?.docs.length ?? 0;

          return Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.grey.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}