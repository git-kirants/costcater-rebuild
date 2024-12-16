import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:open_file/open_file.dart';

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

  // Function to generate the PDF
  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    // Calculate totals
    double subtotal = calculateSubtotal();
    double tax = calculateTax(subtotal);
    double total = calculateTotal(subtotal, tax);

    // Create PDF content
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          // Title
          pw.Center(
            child: pw.Text(
              'Invoice',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // Customer Information
          pw.Text('Customer Information',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            data: [
              ['Name', customerDetails['name']],
              ['Mobile', customerDetails['mobile']],
              ['Email', customerDetails['email']],
              ['Address', customerDetails['address']],
              ['Venue', customerDetails['venue']],
              ['Order Date', customerDetails['orderDate']],
            ],
          ),
          pw.SizedBox(height: 20),

          // Items Ordered
          pw.Text('Items Ordered',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Item', 'Price'],
            data: cartItems.map((item) {
              return [item['name'] ?? 'Unknown Item', '\$${item['price']}'];
            }).toList(),
          ),
          pw.SizedBox(height: 20),

          // Invoice Summary
          pw.Text('Invoice Summary',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            data: [
              ['Subtotal', '\$${subtotal.toStringAsFixed(2)}'],
              ['Tax (10%)', '\$${tax.toStringAsFixed(2)}'],
              ['Total', '\$${total.toStringAsFixed(2)}'],
            ],
          ),
        ],
      ),
    );

    // Save the PDF in a temporary location
    final directory = Directory.systemTemp; // Use system temporary directory
    final file = File('${directory.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open the generated PDF
    OpenFile.open(file.path);
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
                onPressed: () async {
                  await generatePDF(context);
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
