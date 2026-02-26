import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Admin Overview"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [

                buildStatCard(
                  title: "Total Users",
                  icon: Icons.people,
                  color: Colors.blue,
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                ),

                buildStatCard(
                  title: "Verified Doctors",
                  icon: Icons.medical_services,
                  color: Colors.green,
                  stream: FirebaseFirestore.instance
                      .collection('doctors')
                      .where('isVerified', isEqualTo: true)
                      .snapshots(),
                ),

                buildStatCard(
                  title: "Pending Verifications",
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  stream: FirebaseFirestore.instance
                      .collection('doctors')
                      .where('verificationStatus', isEqualTo: 'pending')
                      .snapshots(),
                ),

                buildStatCard(
                  title: "Pending Complaints",
                  icon: Icons.report_problem,
                  color: Colors.red,
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "Recent Appointments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No recent appointments");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {

                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          "Patient: ${data['patientName'] ?? 'Unknown'}",
                        ),
                        subtitle: Text(
                          "Doctor: ${data['doctorName'] ?? 'Unknown'}",
                        ),
                        trailing: Text(
                          data['status'] ?? "",
                          style: TextStyle(
                            color: data['status'] == 'approved'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// REAL-TIME STAT CARD
  Widget buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<QuerySnapshot> stream,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingCard(title, icon, color);
        }

        int count = snapshot.data?.docs.length ?? 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 260,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.grey.withOpacity(0.1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),

              const SizedBox(height: 20),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  count.toString(),
                  key: ValueKey(count),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Loading card
  Widget loadingCard(String title, IconData icon, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}
