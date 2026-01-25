import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'admin/admin_entry_page.dart';
import 'firebase_options.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔐 ENTRY DECISION BASED ON SCREEN WIDTH
      home: LayoutBuilder(
        builder: (context, constraints) {
          // constraints.maxWidth works even before MediaQuery
          if (constraints.maxWidth >= 600) {
            // 💻 Desktop / Web → Admin
            return const AdminEntryPage();
          } else {
            // 📱 Mobile → Login
            return const LoginPage();
          }
        },
      ),
    );
  }
}




