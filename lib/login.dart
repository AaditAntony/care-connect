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

const Color kPrimary = Color(0xFF5C6BC0);
const Color kBackground = Color(0xFFF4F6FB);

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
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCred.user!.uid;

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

        if (!doctorDoc.data().toString().contains('verificationStatus')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorVerificationForm()),
          );
          return;
        }

        if (doctorDoc['verificationStatus'] == 'pending') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorPendingScreen()),
          );
          return;
        }

        if (doctorDoc['verificationStatus'] == 'approved') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorHomePage()),
          );
          return;
        }
      }

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
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              const Text(
                "Care Connect",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to your account",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 50),

              /// EMAIL
              const Text(
                "Email",
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
                    hintText: "Enter your email",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// PASSWORD
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
                    hintText: "Enter your password",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// 🔥 PREMIUM LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: loading ? null : login,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              const Center(
                child: Text(
                  "New here?",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 USER REGISTER CARD
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.person, color: Color(0xFF5C6BC0)),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "Create User Account",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// 🔥 DOCTOR REGISTER CARD
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorRegisterPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.local_hospital, color: Color(0xFF00897B)),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "Register as Doctor",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
