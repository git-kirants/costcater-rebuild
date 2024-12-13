import 'package:flutter/material.dart';

class CreateTierPage extends StatefulWidget {
  const CreateTierPage({super.key});

  @override
  _CreateTierPageState createState() => _CreateTierPageState();
}

class _CreateTierPageState extends State<CreateTierPage> {
  final TextEditingController _tierController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  List<String> _items = [];

  void _addItem() {
    if (_itemController.text.isNotEmpty) {
      setState(() {
        _items.add(_itemController.text);
        _itemController.clear();
      });
    }
  }

  void _createTier() {
    if (_tierController.text.isNotEmpty && _items.isNotEmpty) {
      Navigator.pop(context, {
        'tier': _tierController.text,
        'items': _items,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide a tier name and at least one item')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Tier')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tierController,
              decoration: const InputDecoration(labelText: 'Tier Name'),
            ),
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Add Item'),
            ),
            const SizedBox(height: 20),
            Text('Items:'),
            ..._items.map((item) => Text(item)).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createTier,
              child: const Text('Create Tier'),
            ),
          ],
        ),
      ),
    );
  }
}
