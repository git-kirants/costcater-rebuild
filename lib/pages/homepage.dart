import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart';
import 'create_tier_page.dart';
import 'user_profile.dart';
import 'package:costcater/components/toast.dart';

class HomePage extends StatefulWidget {
  final String email;

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

  // Add your existing initState and other methods here...
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
      context.showToast('${tier['tierName']} added to cart successfully');
    } catch (e) {
      print("Error adding tier to cart: $e");
      context.showToast('Failed to add ${tier['tierName']} to cart',
          type: ToastType.error);
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
      context.showToast('${newItem['name']} added to cart successfully');
    } catch (e) {
      print("Error adding item to cart: $e");
      context.showToast('Failed to add ${newItem['name']} to cart',
          type: ToastType.error);
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
      context.showToast('${result['tier']} added to cart successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    // Calculate responsive values
    final double maxWidth =
        screenSize.width > 1200 ? 1200 : screenSize.width * 1;
    final double cardPadding = screenSize.width > 600 ? 16.0 : 8.0;
    final double fontSize = screenSize.width > 600 ? 18.0 : 16.0;
    final double iconSize = screenSize.width > 600 ? 28.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 1.0,
        toolbarHeight: screenSize.height * 0.08, // Responsive app bar height
        leading: Padding(
          padding:
              const EdgeInsets.only(left: 12.0), // Padding for the leading icon
          child: IconButton(
            icon: Icon(
              Icons.account_circle_outlined,
              color: const Color(0xFF52ed28),
              size: iconSize + 7,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(email: userId),
                ),
              );
            },
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0), // Padding for the title
          child: Center(
            child: SizedBox(
              height: screenSize.height * 0.04, // Responsive logo height
              child: Image.asset(
                'assets/logos/costcaterlogo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 12.0), // Padding for the action icon
            child: Transform.translate(
              offset: Offset(0, 0), // Move up by 10 pixels
              child: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: const Color(0xFF52ed28),
                  size: iconSize + 3,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(userId: userId),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: StreamBuilder<DocumentSnapshot>(
            stream: menuTiersRef.doc(userId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logos/empty-menu.png',
                        width: 500,
                        height: 500,
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final List<dynamic> tiers = data['tiers'] ?? [];

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
                padding: EdgeInsets.all(cardPadding),
                itemCount: parsedTiers.length,
                itemBuilder: (context, index) {
                  var tier = parsedTiers[index];
                  return Container(
                    margin: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 0.1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          12.0), // Match the card border radius
                      child: ExpansionTile(
                        collapsedBackgroundColor: const Color(0xFFF7F7F9),
                        backgroundColor: Colors.white,
                        iconColor: const Color(0xFF52ed28),
                        collapsedIconColor: Colors.black54,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${tier['tierName']}',
                                style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    size: iconSize,
                                  ),
                                  color: const Color(0xFF52ed28),
                                  onPressed: () => _addTierToCart(tier),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    size: iconSize,
                                  ),
                                  color: Colors.red,
                                  onPressed: () =>
                                      _removeTierFromDatabase(tier),
                                ),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          Divider(
                            thickness: 1,
                            height: 1,
                            color: Colors.white,
                          ),
                          ...tier['items'].map<Widget>((item) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: cardPadding * 1.5,
                                  vertical: cardPadding / 2,
                                ),
                                title: Text(
                                  item['name'] ?? 'Unnamed Item',
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: fontSize,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$${item['price']}',
                                      style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_shopping_cart_outlined,
                                        size: iconSize,
                                      ),
                                      color: const Color(0xFF52ed28),
                                      onPressed: () =>
                                          _addItemToCart(userId, item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: screenSize.width > 600 ? 64.0 : 56.0,
        width: screenSize.width > 600 ? 64.0 : 56.0,
        child: FloatingActionButton(
          onPressed: _navigateToCreateTier,
          backgroundColor: const Color(0xFF52ed28),
          tooltip: 'Add New Tier',
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
