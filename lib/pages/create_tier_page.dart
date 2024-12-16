import 'package:flutter/material.dart';

class CreateTierPage extends StatefulWidget {
  const CreateTierPage({super.key});

  @override
  _CreateTierPageState createState() => _CreateTierPageState();
}

class _CreateTierPageState extends State<CreateTierPage> {
  final TextEditingController _tierController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  void _addItem() {
    final itemName = _itemController.text.trim();
    final itemPriceText = _priceController.text.trim();
    final itemPrice = double.tryParse(itemPriceText);

    if (itemName.isEmpty || itemPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid item name and price')),
      );
      return;
    }

    setState(() {
      _items.add({'name': itemName, 'price': itemPrice});
      _itemController.clear();
      _priceController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _createTier() {
    if (_tierController.text.trim().isNotEmpty && _items.isNotEmpty) {
      Navigator.pop(context, {
        'tier': _tierController.text.trim(),
        'items': _items,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a tier name and add at least one item'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tierController,
              decoration: const InputDecoration(labelText: 'Tier Name'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Item Price'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addItem,
                child: const Text('Add Item'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('\$${item['price'].toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(index),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _createTier,
                child: const Text('Create Tier'),
              ),
            ),
          ],
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
