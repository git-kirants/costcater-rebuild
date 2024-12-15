import 'package:flutter/material.dart';

class GenerateInvoicePage extends StatelessWidget {
  final Map<String, dynamic> customerDetails;
  final List<dynamic> cartItems;

  GenerateInvoicePage({required this.customerDetails, required this.cartItems});

  // Function to calculate subtotal, tax, and total from cart items
  double calculateSubtotal() {
    double subtotal = 0.0;
    for (var item in cartItems) {
      if (item is Map && item.containsKey('price')) {
        subtotal += item['price'] ?? 0.0;
      }
    }
    return subtotal;
  }

  double calculateTax(double subtotal) {
    // Example: 10% tax
    return subtotal * 0.10;
  }

  double calculateTotal(double subtotal, double tax) {
    return subtotal + tax;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    double subtotal = calculateSubtotal();
    double tax = calculateTax(subtotal);
    double total = calculateTotal(subtotal, tax);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Invoice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Title
            Center(
              child: Text(
                'Invoice',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Customer Information
            Text('Customer Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Table(
              columnWidths: {0: FixedColumnWidth(150.0)},
              children: [
                TableRow(children: [
                  Text('Name:', style: TextStyle(fontSize: 16)),
                  Text(customerDetails['name'], style: TextStyle(fontSize: 16)),
                ]),
                TableRow(children: [
                  Text('Mobile:', style: TextStyle(fontSize: 16)),
                  Text(customerDetails['mobile'],
                      style: TextStyle(fontSize: 16)),
                ]),
                TableRow(children: [
                  Text('Email:', style: TextStyle(fontSize: 16)),
                  Text(customerDetails['email'],
                      style: TextStyle(fontSize: 16)),
                ]),
                TableRow(children: [
                  Text('Address:', style: TextStyle(fontSize: 16)),
                  Text(customerDetails['address'],
                      style: TextStyle(fontSize: 16)),
                ]),
                TableRow(children: [
                  Text('Venue:', style: TextStyle(fontSize: 16)),
                  Text(customerDetails['venue'],
                      style: TextStyle(fontSize: 16)),
                ]),
                TableRow(children: [
                  Text('Order Date:', style: TextStyle(fontSize: 16)),
                  Text(customerDetails['orderDate'],
                      style: TextStyle(fontSize: 16)),
                ]),
              ],
            ),
            const SizedBox(height: 20),

            // Invoice Items
            Text('Items Ordered',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Table(
              columnWidths: {
                0: FixedColumnWidth(200.0),
                1: FixedColumnWidth(100.0),
                2: FixedColumnWidth(100.0),
              },
              children: [
                TableRow(children: [
                  Text('Item',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Price',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
                for (var item in cartItems)
                  TableRow(children: [
                    Text(item['name'] ?? 'Unknown Item',
                        style: TextStyle(fontSize: 16)),
                    Text('\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(fontSize: 16)),
                  ]),
              ],
            ),
            const SizedBox(height: 20),

            // Invoice Summary
            Table(
              columnWidths: {
                0: FixedColumnWidth(200.0),
                1: FixedColumnWidth(100.0)
              },
              children: [
                TableRow(children: [
                  Text('Subtotal:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\$${subtotal.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16)),
                ]),
                TableRow(children: [
                  Text('Tax (10%):',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\$${tax.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16)),
                ]),
                TableRow(children: [
                  Text('Total:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\$${total.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16)),
                ]),
              ],
            ),
            const SizedBox(height: 20),

            // Download Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement PDF generation logic here
                },
                child: const Text('Download Invoice',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
