import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';

void main() async {
  Stripe.publishableKey =
      'pk_test_51PbKTGRpYSBpeIWzisnMemtNZ4Y13kpBMW6Pn2BppG5MnS507NlsSUNnZRXH4g9fMyORClONGnklJ24ULUXfe3Df00r6waPZTb';
  Stripe.merchantIdentifier = 'merchant.stripeExample';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StripeCardFormWeb(width: 300, height: 200),
    );
  }
}

class StripeCardFormWidget extends StatefulWidget {
  final Function(CardFieldInputDetails?) onCardChanged;
  final Function(String) onTokenCreated;

  const StripeCardFormWidget({
    super.key,
    required this.onCardChanged,
    required this.onTokenCreated,
  });

  @override
  _StripeCardFormWidgetState createState() => _StripeCardFormWidgetState();
}

class _StripeCardFormWidgetState extends State<StripeCardFormWidget> {
  CardFieldInputDetails? _card;
  bool _isLoading = false;
  String name = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CardField(
        //   onCardChanged: (card) {
        //     setState(() {
        //       _card = card;
        //     });
        //     widget.onCardChanged(card);
        //   },
        // ),

        Container(
          height: 50,
          width: 300,
          child: CardField(
            controller: CardEditController(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Card number',
            ),
            onCardChanged: (card) {
              setState(() {
                _card = card;
              });
              widget.onCardChanged(card);
            },
          ),
        ),
        // CardField(
        //   // controller: CardEditController(),
        //   // height: 50,
        //   // width: 300,
        //   onCardChanged: (card) {
        //     setState(() {
        //       _card = card;
        //     });
        //     widget.onCardChanged(card);
        //   },
        //   // style: CardStyle(
        //   //   backgroundColor: Color.fromARGB(255, 11, 11, 11),
        //   //   borderRadius: 8,
        //   //   borderWidth: 1,
        //   //   borderColor: const Color.fromARGB(255, 212, 34, 34),
        //   // ),
        // ),
        const SizedBox(height: 20),
        Container(
          height: 50,
          width: 300,
          child: Material(
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name on card',
              ),
              style: const TextStyle(
                color: Colors.black,
                backgroundColor: Colors.white,
              ),
              onChanged: (value) {
                // You can add custom logic here to handle expiry date changes
                setState(() {
                  name = value;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 40),
        Text(
          _card?.complete == true ? 'Valid card' : 'Invalid card',
          style: TextStyle(
            color: _card?.complete == true ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _card?.complete == true ? _createToken : null,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Add Card'),
        ),
      ],
    );
  }

  Future<void> _createToken() async {
    if (_card == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create token
      final tokenData = await Stripe.instance.createToken(
        CreateTokenParams.card(
            params: CardTokenParams(
          type: TokenType.Card,
          name: name,
        )),
      );

      // Call the callback with the token
      print(tokenData);

      widget.onTokenCreated(tokenData.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating token: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// FlutterFlow CustomWidget
class StripeCardFormWeb extends StatefulWidget {
  const StripeCardFormWeb({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  _StripeCardFormState createState() => _StripeCardFormState();
}

class _StripeCardFormState extends State<StripeCardFormWeb> {
  CardFieldInputDetails? _cardDetails;
  String? _token;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StripeCardFormWidget(
          onCardChanged: (CardFieldInputDetails? details) {
            setState(() {
              _cardDetails = details;
            });
            // You can add custom logic here to handle card changes
            print('Card Details: ${details?.complete}, ${details?.last4}');
          },
          onTokenCreated: (String token) {
            setState(() {
              _token = token;
            });
            // You can add custom logic here to handle the created token
            print('Card Token: $token');

            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Card added successfully!')),
            );
          },
        ),
        Text(_token ?? ''),
      ]),
    );
  }
}
