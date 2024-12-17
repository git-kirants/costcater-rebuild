import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTierPage extends StatefulWidget {
  final String email; // Accept the user's email as a parameter

  const CreateTierPage({super.key, required this.email});

  @override
  _CreateTierPageState createState() => _CreateTierPageState();
}

class _CreateTierPageState extends State<CreateTierPage> {
  final TextEditingController _tierController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _items = [];

  // Add a new item to the list
  void _addItem() {
    final itemName = _itemController.text.trim();
    final itemPriceText = _priceController.text.trim();
    final itemPrice = double.tryParse(itemPriceText);

    if (itemName.isEmpty) {
      _showSnackBar('Item name cannot be empty');
      return;
    }
    if (itemPrice == null || itemPrice <= 0) {
      _showSnackBar('Please enter a valid price greater than zero');
      return;
    }

    setState(() {
      _items.add({'itemName': itemName, 'itemPrice': itemPrice});
      _itemController.clear();
      _priceController.clear();
    });
  }

  // Remove an item from the list
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  // Save the tier data to Firestore under the user's email
  Future<void> _saveTierToFirestore(String tierName, double tierPrice) async {
    try {
      final docRef = _firestore.collection('menuTiers').doc(widget.email);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // Create a new document if it doesn't exist
          transaction.set(docRef, {
            'tiers': [
              {
                'tierName': tierName,
                'tierPrice': tierPrice,
                'tierItems': _items,
              }
            ],
          });
        } else {
          // Update the existing document
          List<dynamic> existingTiers = snapshot.data()?['tiers'] ?? [];
          existingTiers.add({
            'tierName': tierName,
            'tierPrice': tierPrice,
            'tierItems': _items,
          });
          transaction.update(docRef, {'tiers': existingTiers});
        }
      });

      _showSnackBar('Tier "$tierName" added successfully!', isSuccess: true);
      Navigator.pop(context, {
        'tier': tierName,
        'items': _items,
      });
    } catch (e) {
      _showSnackBar('Error saving tier: $e');
    }
  }

  // Create the tier and save it to Firestore
  void _createTier() {
    final tierName = _tierController.text.trim();

    if (tierName.isEmpty) {
      _showSnackBar('Please provide a tier name');
      return;
    }
    if (_items.isEmpty) {
      _showSnackBar('Add at least one item to create a tier');
      return;
    }

    // Calculate total tier price
    final double tierPrice =
        _items.fold(0.0, (sum, item) => sum + (item['itemPrice'] as double));

    // Save to Firestore
    _saveTierToFirestore(tierName, tierPrice);
  }

  // Show a SnackBar with a message
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Tier',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Tier Name',
              controller: _tierController,
              placeholder: 'Enter tier name',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Item Name',
                    controller: _itemController,
                    placeholder: 'Enter item name',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    label: 'Price',
                    controller: _priceController,
                    placeholder: 'Enter price',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: _buildButton(
                label: 'Add Item',
                icon: Icons.add,
                onPressed: _addItem,
              ),
            ),
            const SizedBox(height: 20),
            if (_items.isNotEmpty)
              const Text(
                'Items:',
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        item['itemName'],
                        style: const TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '\$${item['itemPrice'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'SFPro',
                          color: Colors.black54,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: _buildButton(
                label: 'Create Tier',
                onPressed: _createTier,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // Input field widget
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? placeholder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF52ed28), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'SFPro',
            fontSize: 16,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            hintText: placeholder ?? '',
            labelStyle: const TextStyle(color: Colors.black54),
            hintStyle: const TextStyle(color: Colors.black38),
          ),
        ),
      ),
    );
  }

  // Button widget
  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF52ed28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: icon != null
          ? Icon(icon, color: Colors.white)
          : const SizedBox.shrink(),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'SFPro',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tierController.dispose();
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
