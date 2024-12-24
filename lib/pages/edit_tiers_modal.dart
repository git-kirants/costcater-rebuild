import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:costcater/components/toast.dart';
import 'homepage.dart';

class EditTiersPage extends StatefulWidget {
  final String tierName;
  final String email;

  const EditTiersPage({
    Key? key,
    required this.tierName,
    required this.email,
  }) : super(key: key);

  @override
  _EditTiersPageState createState() => _EditTiersPageState();
}

class _EditTiersPageState extends State<EditTiersPage> {
  late List<Map<String, dynamic>> tierItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTierItems();
  }

  Future<void> fetchTierItems() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('menuTiers').doc(widget.email);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final tiers = snapshot.data()!['tiers'] ?? [];
        final tier = tiers.firstWhere(
          (tier) => tier['tierName'] == widget.tierName,
          orElse: () => null,
        );

        if (tier != null) {
          setState(() {
            tierItems =
                List<Map<String, dynamic>>.from(tier['tierItems'] ?? []);
          });
        }
      }
    } catch (e) {
      context.showToast('Error', type: ToastType.error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addItem(String itemName, double itemPrice) {
    setState(() {
      tierItems.add({'itemName': itemName, 'itemPrice': itemPrice});
    });
  }

  void removeItem(int index) {
    setState(() {
      tierItems.removeAt(index);
    });
  }

  Future<void> saveChanges() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('menuTiers').doc(widget.email);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        List tiers = snapshot.data()!['tiers'] ?? [];
        tiers = tiers.map((tier) {
          if (tier['tierName'] == widget.tierName) {
            return {
              ...tier,
              'tierItems': tierItems,
            };
          }
          return tier;
        }).toList();

        await docRef.update({'tiers': tiers});
        context.showToast('Saved');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              email: widget.email,
            ),
          ),
        );
      }
    } catch (e) {
      context.showToast('Failed to save changes: $e', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Tier: ${widget.tierName}',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: tierItems.length,
                      itemBuilder: (context, index) {
                        final item = tierItems[index];
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
                              item['itemName'] ?? 'Unnamed Item',
                              style: const TextStyle(
                                fontFamily: 'SFPro',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              '\$${(item['itemPrice'] ?? 0.0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'SFPro',
                                color: Colors.black54,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => removeItem(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AddItemDialog(
                          onAdd: addItem,
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Color(0xFF52ed28)),
                      label: const Text(
                        'Add Item',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          color: Color(0xFF52ed28),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFF52ed28), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.95,
                            50), // 90% width
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52ed28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.95,
                            50), // 90% width
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  final Function(String, double) onAdd;

  const AddItemDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: 400, // Adjust the width to make the dialog larger
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                labelStyle: TextStyle(color: Color.fromARGB(255, 40, 40, 40)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded border
                  borderSide: BorderSide(color: Color(0xFF52ed28), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF52ed28), width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Item Price',
                labelStyle: TextStyle(color: Color.fromARGB(255, 40, 40, 40)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded border
                  borderSide: BorderSide(color: Color(0xFF52ed28), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF52ed28), width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final itemName = nameController.text.trim();
            final itemPrice =
                double.tryParse(priceController.text.trim()) ?? 0.0;

            if (itemName.isNotEmpty && itemPrice > 0) {
              widget.onAdd(itemName, itemPrice);
              Navigator.pop(context);
            } else {
              context.showToast('Please enter valid item details.',
                  type: ToastType.info);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF52ed28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded button
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Add',
            style: TextStyle(
              fontFamily: 'SFPro',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
