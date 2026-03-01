import 'package:care_connect/user/user_details_form_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORT YOUR SCREENS
import 'doctor/doctor_home.dart';
import 'doctor/doctor_pending.dart';
import 'doctor/doctor_register_page.dart';
import 'doctor/doctor_verification_form.dart';
import 'user/register.dart';
import 'user/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      // 1️⃣ Firebase Authentication
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCred.user!.uid;

      // 2️⃣ CHECK USER COLLECTION
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        if (userDoc['isBlocked'] == true) {
          await FirebaseAuth.instance.signOut();
          showMessage("Your account is blocked by admin");
          setState(() => loading = false);
          return;
        }

        // 🔵 CHECK PROFILE COMPLETION
        if (userDoc.data().toString().contains('profileCompleted') &&
            userDoc['profileCompleted'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserDetailsFormPage()),
          );
        }

        return;
      }

      // DOCTOR COLLECTION CHECK
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .get();

      if (doctorDoc.exists) {
        if (doctorDoc['isBlocked'] == true) {
          await FirebaseAuth.instance.signOut();
          showMessage("Your account is blocked by admin");
          return;
        }

        // 🔹 CASE 1: Verification form NOT submitted
        if (!doctorDoc.data().toString().contains('verificationStatus')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorVerificationForm()),
          );
          return;
        }

        // 🔹 CASE 2: Submitted, waiting for admin
        if (doctorDoc['verificationStatus'] == 'pending') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorPendingScreen()),
          );
          return;
        }

        // 🔹 CASE 3: Approved doctor
        if (doctorDoc['verificationStatus'] == 'approved') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorHomePage()),
          );
          return;
        }
      }

      // 4️⃣ NO ROLE FOUND
      await FirebaseAuth.instance.signOut();
      showMessage("No role assigned to this account");
    } catch (e) {
      showMessage(e.toString());
    }

    setState(() => loading = false);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // LOGIN BUTTON
            ElevatedButton(
              onPressed: loading ? null : login,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),

            const SizedBox(height: 10),

            // USER REGISTER
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("Create User Account"),
            ),

            // DOCTOR REGISTER
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DoctorRegisterPage()),
                );
              },
              child: const Text("Register as Doctor"),
            ),
          ],
        ),
      ),
    );
  }
}
//done