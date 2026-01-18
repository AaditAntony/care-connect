import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorPendingScreen extends StatelessWidget {
  const DoctorPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification Pending"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Disable back button
        actions: [
          // Logout button for doctor
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              // Pending icon
              Icon(
                Icons.hourglass_top,
                size: 80,
                color: Colors.orange,
              ),
              SizedBox(height: 20),

              // Main message
              Text(
                "Your account is under verification",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10),

              // Sub message
              Text(
                "Your details have been submitted successfully.\n"
                    "Admin verification may take up to 7 days.\n\n"
                    "You will be able to access your dashboard once approved.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
