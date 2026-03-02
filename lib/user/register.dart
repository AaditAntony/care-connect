import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimary = Color(0xFF5C6BC0);
const Color kBackground = Color(0xFFF4F6FB);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  register() async {
    setState(() => loading = true);

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .set({
            'email': emailController.text.trim(),
            'role': 'user',
            'isBlocked': false,
          });

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
          "Create Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            /// 🔷 Header Section
            const Text(
              "Welcome 👋",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create your account to start booking consultations.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            /// 🔷 Email Field
            const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  hintText: "Enter your email",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// 🔷 Password Field
            const Text(
              "Password",
              style: TextStyle(fontWeight: FontWeight.bold),
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
                  hintText: "Create a password",
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
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                onPressed: loading ? null : register,
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
                        "Create Account",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
