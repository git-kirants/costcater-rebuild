import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_details.dart';

class CartPage extends StatefulWidget {
  final String userId;

  const CartPage({super.key, required this.userId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late String userId;
  late CollectionReference cartRef;
  TextEditingController noOfPlatesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    cartRef = FirebaseFirestore.instance.collection('cartItems');
  }

  void removeItemFromCart(Map<String, dynamic> item) async {
    final docRef = cartRef.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;

      List<dynamic> cartItems =
          (snapshot.data() as Map<String, dynamic>)?['items'] ?? [];

      cartItems.removeWhere((cartItem) =>
          cartItem['item'] == item['name'] &&
          cartItem['price'] == item['price']);

      transaction.update(docRef, {'items': cartItems});
    });
  }

  void clearCart() async {
    final docRef = cartRef.doc(userId);
    await docRef.update({'items': []});
  }

  double calculateTotalAmount(List<dynamic> cartItems) {
    double totalAmount = 0.0;
    for (var item in cartItems) {
      if (item is Map && item.containsKey('price')) {
        totalAmount += (item['price'] is double)
            ? item['price']
            : (item['price'] as num).toDouble();
      }
    }
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: const Color(0xFF52ed28),
              onPressed: clearCart,
            ),
          ),
        ],
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
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontFamily: 'SF Pro',
                ),
              ),
            );
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> cartItems = data['items'] ?? [];

          double totalAmount = calculateTotalAmount(cartItems);

          return cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // Your cart item list and other UI components
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var item = cartItems[index];
                          String itemName = item['item'] ?? 'Unknown Item';
                          double itemPrice = (item['price'] is double)
                              ? item['price']
                              : (item['price'] as num).toDouble();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              title: Text(
                                itemName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                              subtitle: Text(
                                'Price: \$${itemPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_shopping_cart,
                                  color: Color(0xFF52ed28),
                                ),
                                onPressed: () {
                                  removeItemFromCart(
                                      {'name': itemName, 'price': itemPrice});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 16.0,
                      left: 16.0,
                      right: 16.0,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6, // Reduced shadow blur
                              spreadRadius: 1, // Reduced spread
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Floating Widget for Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily: 'SF Pro',
                                  ),
                                ),
                                Text(
                                  '\$${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'SF Pro',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            // No of Plates Input Field
                            TextField(
                              controller: noOfPlatesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'No of Plates',
                                labelStyle: const TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'SF Pro',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF52ed28),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Improved Button Design
                            SizedBox(
                              width: double
                                  .infinity, // Makes the button take the full available width
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomerDetailsPage(
                                        cartItems: cartItems,
                                        totalAmount: totalAmount,
                                        noOfPlates: int.tryParse(
                                                noOfPlatesController.text) ??
                                            0,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF52ed28),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical:
                                        18, // Keeps the vertical padding consistent
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.green.withOpacity(0.5),
                                ),
                                child: const Text(
                                  'Proceed',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
