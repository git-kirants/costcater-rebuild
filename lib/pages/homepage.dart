import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart';
import 'create_tier_page.dart';
import 'user_profile.dart';

class HomePage extends StatefulWidget {
  final String email; // Accept email as a parameter

  const HomePage({super.key, required this.email});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String userId;
  late CollectionReference menuTiersRef;

  @override
  void initState() {
    super.initState();
    userId = widget.email; // Use the passed email as the userId
    menuTiersRef = FirebaseFirestore.instance.collection('menuTiers');
  }

  // Add the entire tier to the cart
  void _addTierToCart(Map<String, dynamic> tier) async {
    try {
      // Reference to the user's document in 'cartItems'
      final userCartRef =
          FirebaseFirestore.instance.collection('cartItems').doc(userId);

      // Add all items from the tier to the cart
      List<Map<String, dynamic>> tierItems =
          List<Map<String, dynamic>>.from(tier['items']);

      // Create a list of cart items from the tier items
      List<Map<String, dynamic>> cartItems = tierItems
          .map((item) => {
                'item': item['name'],
                'price': item['price'],
              })
          .toList();

      // Update Firestore document: Add all items to the 'items' array
      await userCartRef.set({
        'items': FieldValue.arrayUnion(cartItems),
      }, SetOptions(merge: true));

      // Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${tier['tierName']} tier added to cart!")),
      );
    } catch (e) {
      print("Error adding tier to cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to add ${tier['tierName']} tier to cart.")),
      );
    }
  }

// Add an individual item to the cart
  void _addItemToCart(String userId, Map<String, dynamic> newItem) async {
    try {
      // Reference to the user's document in 'cartItems'
      final userCartRef = FirebaseFirestore.instance
          .collection('cartItems')
          .doc(userId); // e.g., userId = 'kiran221031@gmail.com'

      // Update Firestore document: Add to the 'items' array
      await userCartRef.set({
        'items': FieldValue.arrayUnion([
          {
            'item': newItem['name'], // Item name
            'price': newItem['price'], // Item price
          }
        ]),
      }, SetOptions(merge: true)); // Merge with existing document

      // Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${newItem['name']} added to cart!")),
      );
    } catch (e) {
      print("Error adding item to cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add ${newItem['name']} to cart.")),
      );
    }
  }

  // Remove a tier from Firestore
  Future<void> _removeTierFromDatabase(
      Map<String, dynamic> tierToRemove) async {
    final docRef = menuTiersRef.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        List<dynamic> existingTiers = snapshot['tiers'] ?? [];
        existingTiers.removeWhere(
            (tier) => tier['tierName'] == tierToRemove['tierName']);
        transaction.update(docRef, {'tiers': existingTiers});
      }
    });
  }

  // Navigate to CreateTierPage
  void _navigateToCreateTier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTierPage(email: widget.email),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result['tier']} tier created!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.account_circle_outlined,
              color: Color(0xFF52ed28)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(email: userId),
              ),
            );
          },
        ),
        title: Center(
          child: SizedBox(
            height: 40, // Adjust this value to control logo height
            child: Image.asset(
              'assets/logos/costcaterlogo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Color(0xFF52ed28)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            menuTiersRef.doc(userId).snapshots(), // Real-time Firestore stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No menu tiers available."));
          }

          // Extract and parse tier data
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> tiers = data['tiers'] ?? [];

          // Convert Firestore tier data into a list of usable maps
          List<Map<String, dynamic>> parsedTiers = tiers.map((tier) {
            final items = tier['tierItems'] ?? [];
            return {
              'tierName': tier['tierName'] ?? 'Unnamed Tier',
              'tierPrice': tier['tierPrice'] ?? 0,
              'items': items.map((item) {
                return {
                  'name': item['itemName'] ?? 'Unnamed Item',
                  'price': item['itemPrice'] is String
                      ? double.tryParse(item['itemPrice']) ?? 0.0
                      : (item['itemPrice'] ?? 0).toDouble(),
                };
              }).toList(),
            };
          }).toList();

          return ListView.builder(
            itemCount: parsedTiers.length,
            itemBuilder: (context, index) {
              var tier = parsedTiers[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 3,
                child: Column(
                  children: [
                    ExpansionTile(
                      backgroundColor: Colors.white,
                      iconColor: const Color(0xFF52ed28),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tier Name
                          Text(
                            '${tier['tierName']}',
                            style: const TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // Buttons to the right
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add),
                                color: Color(0xFF52ed28),
                                onPressed: () => _addTierToCart(tier),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeTierFromDatabase(tier),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        ...tier['items'].map<Widget>((item) {
                          return ListTile(
                            title: Text(
                              item['name'] ?? 'Unnamed Item',
                              style: const TextStyle(
                                fontFamily: 'SFPro',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${item['price']}',
                                  style: const TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  color: Color(0xFF52ed28),
                                  onPressed: () => _addItemToCart(userId, item),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTier,
        backgroundColor: const Color(0xFF52ed28),
        tooltip: 'Add New Tier',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: Colors.white,
    );
  }
}
