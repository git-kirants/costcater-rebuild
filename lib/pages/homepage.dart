import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String userId; // Current user's ID
  late CollectionReference cartRef; // Firestore cart reference

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      cartRef = FirebaseFirestore.instance.collection('carts');
    }
  }

  // Function to add a single item to Firestore cart
  Future<void> addToCart(String item) async {
    final docRef = cartRef.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // If the cart doesn't exist, create it with the item
        transaction.set(docRef, {
          'cartItems': [item],
        });
      } else {
        // If the cart exists, update the array
        List<dynamic> cartItems = snapshot['cartItems'];
        if (!cartItems.contains(item)) {
          cartItems.add(item);
          transaction.update(docRef, {'cartItems': cartItems});
        }
      }
    });
  }

  // Function to add an entire tier to Firestore cart
  Future<void> addTierToCart(List<String> items) async {
    final docRef = cartRef.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // If the cart doesn't exist, add all tier items
        transaction.set(docRef, {
          'cartItems': items,
        });
      } else {
        // If the cart exists, update the array
        List<dynamic> cartItems = snapshot['cartItems'];
        for (var item in items) {
          if (!cartItems.contains(item)) {
            cartItems.add(item);
          }
        }
        transaction.update(docRef, {'cartItems': cartItems});
      }
    });
  }

  final List<Map<String, dynamic>> menuTiers = [
    {
      'tier': 'Gold',
      'items': ['Steak', 'Lobster', 'Caviar']
    },
    {
      'tier': 'Silver',
      'items': ['Chicken', 'Fish', 'Salad']
    },
    {
      'tier': 'Bronze',
      'items': ['Pizza', 'Burger', 'Fries']
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: menuTiers.length,
        itemBuilder: (context, index) {
          var tier = menuTiers[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: Text(
                tier['tier'],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await addTierToCart(List<String>.from(tier['items']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${tier['tier']} tier added to cart!')),
                      );
                    },
                    child: const Text('Add Entire Tier to Cart'),
                  ),
                ),
                ...tier['items'].map<Widget>((item) {
                  return ListTile(
                    title: Text(
                      item,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart,
                          color: Colors.green),
                      onPressed: () async {
                        await addToCart(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$item added to cart!')),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
