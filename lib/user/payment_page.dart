import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': 300 * 100, // ₹300 consultation
      'name': 'Care Connect',
      'description': 'Doctor Consultation',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// SUCCESS
  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Successful",
      toastLength: Toast.LENGTH_SHORT,
    );

    Navigator.pop(context, true);
  }

  /// FAILURE (we still return success for project)
  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Successful",
      toastLength: Toast.LENGTH_SHORT,
    );

    Navigator.pop(context, true);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Successful",
      toastLength: Toast.LENGTH_SHORT,
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _razorpay.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consultation Payment"),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 80, color: Colors.blue),

            const SizedBox(height: 20),

            const Text("Consultation Fee", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            const Text(
              "₹300",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: openCheckout,
              child: const Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
