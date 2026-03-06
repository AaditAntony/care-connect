import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool loading = false;

  Future<void> processPayment() async {
    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    /// Always return success (for project demo)
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consultation Payment"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 40),

            const Icon(Icons.payment, size: 80, color: Colors.blue),

            const SizedBox(height: 20),

            const Text("Consultation Fee", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            const Text(
              "₹300",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: loading ? null : processPayment,

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Pay Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
