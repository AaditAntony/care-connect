import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kDoctorPrimary = Color(0xFF00897B);
const Color kBackground = Color(0xFFF4F7F9);

class DoctorRegisterPage extends StatefulWidget {
  const DoctorRegisterPage({super.key});

  @override
  State<DoctorRegisterPage> createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends State<DoctorRegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> registerDoctor() async {
    setState(() => loading = true);

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.user!.uid)
          .set({
            'email': emailController.text.trim(),
            'role': 'doctor',
            'isVerified': false,
            'isBlocked': false,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Registration successful. Please complete verification.",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Doctor Registration",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔷 Header Section
            const Text(
              "Join as a Doctor",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Create your doctor account to access the dashboard and begin verification.",
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),

            const SizedBox(height: 40),

            /// 🔷 Email Field
            const Text(
              "Professional Email",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "Enter your professional email",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// 🔷 Password Field
            const Text(
              "Password",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Create a secure password",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// 🔷 Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDoctorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                onPressed: loading ? null : registerDoctor,
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
                        "Register as Doctor",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
