import 'dart:convert';
import 'package:feature/feature/common_print/printlog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePayScreen extends StatefulWidget {
  const StripePayScreen({super.key});

  @override
  State<StripePayScreen> createState() => _StripePayScreenState();
}

class _StripePayScreenState extends State<StripePayScreen> {
  dynamic paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: TextButton(
          onPressed: () => makePayment(), child: const Text('Make Payment')),
    );
  }


// make payment with stripe
  Future<void> makePayment() async {
    try {
      Printlog.printLog('..............initiated payment....');
      //STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(amount: '10', currency: 'USD');

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance .initPaymentSheet( paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'], //Gotten from payment intent
                  style: ThemeMode.light,
                  merchantDisplayName: 'Ikay'))
          .then((value) {
             Printlog.printLog('..............payment return....');
          });

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }


// create payment intent
  createPaymentIntent({String? amount, String? currency}) async {
    try {
             Printlog.printLog('..............payment in process ....');

      //Request body
      Map<String, dynamic> body = {
        'amount': "100",
        'currency': currency ?? "USD",
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${"dotenv.env['STRIPE_SECRET']"}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
             Printlog.printLog('..............payment in process next ......${json.decode(response.body)}....');

      return json.decode(response.body);
    } catch (err) {
      Printlog.printLog('..............payment error .... $err');

      throw Exception(err.toString());
    }
  }


// display payment sheet
void  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0), 
                      Text("Payment Successful!"),
                    ],
                  ),
                ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      Printlog.printLog('Error is:---> $e');
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      Printlog.printLog('$e');
    }
  }

// Future<void> onGooglePayResult(paymentResult) async {
//     final response = await fetchPaymentIntentClientSecret();
//     final clientSecret = response['clientSecret'];
//     final token = paymentResult['paymentMethodData']['tokenizationData']['token'];
//     final tokenJson = Map.castFrom(json.decode(token));

//     final params = PaymentMethodParams.cardFromToken(
//       token: tokenJson['id'], paymentMethodData: null,
//     );
//     // Confirm Google pay payment method
//     await Stripe.instance.confirmPayment(
//       paymentIntentClientSecret:clientSecret,
//       data:params,
//     );
// }
// Future<PaymentMethod> createPaymentMethod();
// Future<PaymentIntent> handleNextAction();
// Future<PaymentIntent> confirmPayment();
// Future<void> configure3dSecure();
// Future<bool> isApplePaySupported();
// Future<void> presentApplePay();
// Future<void> confirmApplePayPayment();
// Future<SetupIntent> confirmSetupIntent();
// Future<PaymentIntent> retrievePaymentIntent();
// Future<String> createTokenForCVCUpdate();

// Future<void> initPaymentSheet();
// Future<void> presentPaymentSheet();
// Future<void> confirmPaymentSheetPayment()
}
