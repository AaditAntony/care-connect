import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  static const Color userPrimary = Color(0xFF5C6BC0);
  static const Color userPrimaryDark = Color(0xFF3949AB);
  static const Color userBackground = Color(0xFFF4F6FB);

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: userBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔵 Welcome Section
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// 🔵 Stats Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final stats = [
                  _StatData(
                    title: "Doctors",
                    color: userPrimary,
                    stream: FirebaseFirestore.instance
                        .collection('doctors')
                        .where('verificationStatus', isEqualTo: 'approved')
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

            /// 🔵 Upcoming Appointment Preview
            const Text(
              "Next Appointment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('userId', isEqualTo: userId)
                  .where('status', isEqualTo: 'booked')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _EmptyCard(message: "No upcoming appointments");
                }

                final data =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return _InfoCard(
                  icon: Icons.calendar_today,
                  title: data['doctorName'] ?? "Doctor",
                  subtitle: data['timeSlot'] ?? "",
                );
              },
            ),

            const SizedBox(height: 25),

            /// 🔵 Recent Activity
            const Text(
              "Recent Consultation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('consultations')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _EmptyCard(message: "No consultations yet");
                }

                final data =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return _InfoCard(
                  icon: Icons.description,
                  title: data['doctorName'] ?? "Doctor",
                  subtitle: data['diagnosis'] ?? "",
                );
              },
            ),

            const SizedBox(height: 30),

            /// 🔵 Support Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [userPrimary, userPrimaryDark],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: const [
                  Icon(Icons.support_agent, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Need Help? Contact Support",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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

  _StatData({required this.title, required this.color, required this.stream});
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.color.withOpacity(0.9), data.color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: data.stream,
        builder: (context, snapshot) {
          final count = snapshot.data?.docs.length ?? 0;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(data.title, style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.grey.withOpacity(0.1)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.2),
            child: Icon(icon, color: const Color(0xFF5C6BC0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.grey.withOpacity(0.1)),
        ],
      ),
      child: Text(message, style: const TextStyle(color: Colors.grey)),
    );
  }
}
