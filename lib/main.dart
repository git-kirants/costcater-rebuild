import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/cart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/cart': (context) {
          // Ensure cartItems is a List<String>
          final List<String> cartItems = []; // Initialize as List<String>

          return CartPage(
            cartItems: cartItems,
            removeItemFromCart: (String item) {
              // Implement your logic to remove an item from the cart
            },
          );
        },
      },
    );
  }
}
