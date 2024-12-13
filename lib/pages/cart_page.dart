import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final List<String> cartItems;
  final Function(String) removeItemFromCart;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.removeItemFromCart,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty!'))
          : ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(widget.cartItems[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_shopping_cart),
                      onPressed: () {
                        setState(() {
                          // Remove item from the cart
                          widget.removeItemFromCart(widget.cartItems[index]);
                        });

                        // Show the snack bar for item removed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.cartItems[index]} removed'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
