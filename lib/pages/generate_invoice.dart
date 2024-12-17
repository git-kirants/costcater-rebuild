import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:open_file/open_file.dart';

class GenerateInvoicePage extends StatelessWidget {
  final Map<String, dynamic> customerDetails;
  final List<dynamic> cartItems;

  GenerateInvoicePage({
    required this.customerDetails,
    required this.cartItems,
  }) {
    // Debugging cartItms
    debugPrint("Received cartItems: $cartItems");
  }

  // Existing calculation methods remain the same
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
    return subtotal * 0.10; // 10% tax
  }

  double calculateTotal(double subtotal, double tax, double plates) {
    return (subtotal + tax) * plates;
  }

  // PDF generation method remains the same
  Future<void> generatePDF(BuildContext context, double plates) async {
    final pdf = pw.Document();

    // Calculate totals
    double subtotal = calculateSubtotal();
    double tax = calculateTax(subtotal);
    double total = calculateTotal(subtotal, tax, plates);

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
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open the generated PDF
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    double plates = customerDetails['plates'] ?? 1;
    double subtotal = calculateSubtotal();
    double tax = calculateTax(subtotal);
    double total = calculateTotal(subtotal, tax, plates);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Invoice Details',
          style: TextStyle(
            fontFamily: '-apple-system',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            // Increased horizontal padding to 24 and added screen edge protection
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice Header
                Center(),
                const SizedBox(height: 24),

                // Customer Information Section
                _buildSectionHeader('Customer Information'),
                const SizedBox(height: 12),
                _buildDetailsCard(
                  children: [
                    _buildDetailRow('Name', customerDetails['name']),
                    _buildDetailRow('Mobile', customerDetails['mobile']),
                    _buildDetailRow('Email', customerDetails['email']),
                    _buildDetailRow('Address', customerDetails['address']),
                    _buildDetailRow('Venue', customerDetails['venue']),
                    _buildDetailRow('Order Date', customerDetails['orderDate']),
                  ],
                ),
                const SizedBox(height: 24),

                // Items Ordered Section
                _buildSectionHeader('Items Ordered'),
                const SizedBox(height: 12),
                _buildItemsCard(cartItems),
                const SizedBox(height: 24),

                // Invoice Summary Section
                _buildSectionHeader('Invoice Summary'),
                const SizedBox(height: 12),
                _buildSummaryCard(subtotal, tax, total),
                const SizedBox(height: 32),

                // Download Button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await generatePDF(context, plates);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF69F94F),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Download Invoice',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Added bottom padding to prevent content from being too close to the bottom
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'SF-Pro',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetailsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF-Pro',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontFamily: 'SF-Pro',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(List<dynamic> items) {
    // Debugging the cartItems list
    print('Cart Items: $items'); // Check if cartItems is passed correctly

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item',
                  style: TextStyle(
                    fontFamily: 'SF-Pro',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Price',
                  style: TextStyle(
                    fontFamily: 'SF-Pro',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          // Iterate through the cartItems to display each item
          ...items.map((item) {
            print('Item: $item'); // Debugging individual item data
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['item'] ??
                        'Unknown Item', // Ensure item['name'] is available
                    style: TextStyle(
                      fontFamily: 'SF-Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}', // Ensure item['price'] is available
                    style: TextStyle(
                      fontFamily: 'SF-Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double subtotal, double tax, double total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', subtotal),
          _buildSummaryRow('Tax (10%)', tax),
          _buildSummaryRow('Total', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF-Pro',
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.black54,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'SF-Pro',
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? const Color(0xFF69F94F) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
