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
  Future<void> addToCart(String name, double price) async {
    final docRef = cartRef.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // If the cart doesn't exist, create it with the item
        transaction.set(docRef, {
          'cartItems': [
            {'name': name, 'price': price}
          ],
        });
      } else {
        // If the cart exists, update the array
        List<dynamic> cartItems = snapshot['cartItems'];
        if (!cartItems.any((element) => element['name'] == name)) {
          cartItems.add({'name': name, 'price': price});
          transaction.update(docRef, {'cartItems': cartItems});
        }
      }
    });
  }

  // Function to add an entire tier to Firestore cart
  Future<void> addTierToCart(List<Map<String, dynamic>> items) async {
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
          if (!cartItems.any((element) => element['name'] == item['name'])) {
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
      'price': 100.0,
      'items': [
        {'name': 'Steak', 'price': 40.0},
        {'name': 'Lobster', 'price': 30.0},
        {'name': 'Caviar', 'price': 30.0}
      ]
    },
    {
      'tier': 'Silver',
      'price': 50.0,
      'items': [
        {'name': 'Chicken', 'price': 15.0},
        {'name': 'Fish', 'price': 15.0},
        {'name': 'Salad', 'price': 20.0}
      ]
    },
    {
      'tier': 'Bronze',
      'price': 25.0,
      'items': [
        {'name': 'Pizza', 'price': 10.0},
        {'name': 'Burger', 'price': 8.0},
        {'name': 'Fries', 'price': 7.0}
      ]
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
                      await addTierToCart(
                          List<Map<String, dynamic>>.from(tier['items']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${tier['tier']} tier added to cart!')),
                      );
                    },
                    child: Text(
                        'Add Entire ${tier['tier']} Tier (\$${tier['price']}) to Cart'),
                  ),
                ),
                ...tier['items'].map<Widget>((item) {
                  return ListTile(
                    title: Text(
                      item['name'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${item['price']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart,
                              color: Colors.green),
                          onPressed: () async {
                            await addToCart(item['name'], item['price']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('${item['name']} added to cart!')),
                            );
                          },
                        ),
                      ],
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
