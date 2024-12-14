import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late String userId; // Stores logged-in user's ID
  late CollectionReference cartRef; // Firestore reference

  @override
  void initState() {
    super.initState();
    // Get current user's ID
    userId = FirebaseAuth.instance.currentUser!.uid;

    // Reference to Firestore collection
    cartRef = FirebaseFirestore.instance.collection('carts');
  }

  // Function to remove an item from the cart
  void removeItemFromCart(String item) async {
    final docRef = cartRef.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;

      List<dynamic> cartItems = snapshot['cartItems'];
      cartItems.remove(item);

      transaction.update(docRef, {'cartItems': cartItems});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cartRef.doc(userId).snapshots(), // Listen for real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If no data exists, display empty cart message
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Extract cart items from Firestore document
          List<dynamic> cartItems = snapshot.data!['cartItems'];

          return cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          cartItems[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_shopping_cart,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            removeItemFromCart(cartItems[index]);
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
