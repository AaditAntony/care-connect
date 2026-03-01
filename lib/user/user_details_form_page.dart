import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class UserDetailsFormPage extends StatefulWidget {
  const UserDetailsFormPage({super.key});

  @override
  State<UserDetailsFormPage> createState() => _UserDetailsFormPageState();
}

class _UserDetailsFormPageState extends State<UserDetailsFormPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();

  String selectedGender = "Male";
  bool loading = false;

  Future<void> saveDetails() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        ageController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': selectedGender,
        'address': addressController.text.trim(),
        'profileCompleted': true,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            _buildField("Full Name", nameController),
            const SizedBox(height: 15),

            _buildField("Phone Number", phoneController,
                keyboard: TextInputType.phone),
            const SizedBox(height: 15),

            _buildField("Age", ageController,
                keyboard: TextInputType.number),
            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: selectedGender,
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                setState(() => selectedGender = value!);
              },
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            _buildField("Address", addressController, maxLines: 3),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveDetails,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save & Continue"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}