import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_details.dart'; // Import the new page

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late String userId; // Stores logged-in user's ID
  late CollectionReference cartRef; // Firestore reference
  TextEditingController noOfPlatesController =
      TextEditingController(); // Controller for No of Plates field

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    cartRef = FirebaseFirestore.instance.collection('carts');
  }

  // Function to add item to the cart
  void addItemToCart(String item) async {
    final docRef = cartRef.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // If the cart document does not exist, create it with the item.
        transaction.set(docRef, {
          'cartItems': [item]
        });
      } else {
        // If the cart document exists, add the item to the existing list.
        List<dynamic> cartItems =
            (snapshot.data() as Map<String, dynamic>)['cartItems'] ?? [];
        cartItems.add(item); // Add the item to the cart list.
        transaction.update(docRef, {'cartItems': cartItems});
      }
    });
  }

  // Function to remove an item from the cart
  void removeItemFromCart(Map<String, dynamic> item) async {
    final docRef = cartRef.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;

      List<dynamic> cartItems =
          (snapshot.data() as Map<String, dynamic>?)?['cartItems'] ?? [];
      cartItems.removeWhere((cartItem) => cartItem['name'] == item['name']);

      transaction.update(docRef, {'cartItems': cartItems});
    });
  }

  // Function to clear the entire cart
  void clearCart() async {
    final docRef = cartRef.doc(userId);
    await docRef.update({'cartItems': []});
  }

  // Function to calculate the total amount
  double calculateTotalAmount(List<dynamic> cartItems) {
    double totalAmount = 0.0;
    // Example calculation, assuming each item has a price field
    for (var item in cartItems) {
      if (item is Map && item.containsKey('price')) {
        totalAmount += item['price'] ?? 0.0;
      }
    }
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cartRef.doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Safely access cartItems in this scope with proper casting
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> cartItems = data['cartItems'] ?? [];

          // Calculate the total amount dynamically
          double totalAmount = calculateTotalAmount(cartItems);

          return cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var item = cartItems[index];
                          String itemName =
                              item is Map ? item['name'] : 'Unknown Item';
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                itemName,
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_shopping_cart,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  removeItemFromCart(
                                      item); // Pass the entire item to the remove function
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total: \$${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    // Add No of Plates TextField here
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: noOfPlatesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'No of Plates',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to customer details page and pass cartItems, total, and No of Plates
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailsPage(
                                cartItems: cartItems,
                                totalAmount:
                                    totalAmount, // Pass total to the next page
                                noOfPlates:
                                    int.tryParse(noOfPlatesController.text) ??
                                        0, // Pass No of Plates
                              ),
                            ),
                          );
                        },
                        child: const Text('Proceed to Customer Details'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: clearCart, // Clear the cart
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Red color for the button
                        ),
                        child: const Text('Clear Cart'),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
