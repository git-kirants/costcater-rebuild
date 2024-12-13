import 'package:flutter/material.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> cartItems = [];

  void addToCart(String item) {
    setState(() {
      cartItems.add(item);
    });
  }

  void addEntireTierToCart(List<String> items) {
    setState(() {
      cartItems.addAll(items);
    });
  }

  void removeItemFromCart(String item) {
    setState(() {
      cartItems.remove(item);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cartItems: cartItems,
                    removeItemFromCart: removeItemFromCart, // Pass the callback
                  ),
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
              title: Text(tier['tier']),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      addEntireTierToCart(List<String>.from(tier['items']));
                    },
                    child: const Text('Add Entire Tier to Cart'),
                  ),
                ),
                ...tier['items'].map<Widget>((item) {
                  return ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        addToCart(item);
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
