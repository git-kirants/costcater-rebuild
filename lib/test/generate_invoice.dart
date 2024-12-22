import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

class GenerateInvoicePage extends StatelessWidget {
  final Map<String, dynamic> customerDetails;
  final List<dynamic> cartItems;

  GenerateInvoicePage({super.key, 
    required this.customerDetails,
    required this.cartItems,
  }) {
    debugPrint("Received cartItems: $cartItems");
  }

  // Calculation methods
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

  Future<void> generateInvoice(BuildContext context, double plates) async {
    try {
      final pdf = pw.Document();

      // Load custom fonts
      final fontRegular = pw.Font.ttf(
          await rootBundle.load('assets/fonts/SF-Pro-Display-Regular.otf'));
      final fontBold = pw.Font.ttf(
          await rootBundle.load('assets/fonts/SF-Pro-Display-Bold.otf'));

      // Calculate financial details
      double subtotal = calculateSubtotal();
      double tax = calculateTax(subtotal);
      double total = calculateTotal(subtotal, tax, plates);

      // Create PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            pw.Center(
              child: pw.Text(
                'Invoice',
                style: pw.TextStyle(fontSize: 28, font: fontBold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Customer Information',
                style: pw.TextStyle(fontSize: 18, font: fontBold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              cellAlignment: pw.Alignment.centerLeft,
              data: [
                ['Name', customerDetails['name'] ?? 'N/A'],
                ['Mobile', customerDetails['mobile'] ?? 'N/A'],
                ['Email', customerDetails['email'] ?? 'N/A'],
                ['Address', customerDetails['address'] ?? 'N/A'],
                ['Venue', customerDetails['venue'] ?? 'N/A'],
                ['Order Date', customerDetails['orderDate'] ?? 'N/A'],
              ],
              headerStyle: pw.TextStyle(font: fontBold),
              cellStyle: pw.TextStyle(font: fontRegular),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Items Ordered',
                style: pw.TextStyle(fontSize: 18, font: fontBold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Item', 'Price'],
              columnWidths: {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(1),
              },
              headerStyle: pw.TextStyle(font: fontBold),
              cellStyle: pw.TextStyle(font: fontRegular),
              data: cartItems
                  .map((item) => [
                        item['item'] ?? 'Unknown Item',
                        '\$${(item['price'] ?? 0.0).toStringAsFixed(2)}'
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Invoice Summary',
                style: pw.TextStyle(fontSize: 18, font: fontBold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
              },
              headerStyle: pw.TextStyle(font: fontBold),
              cellStyle: pw.TextStyle(font: fontRegular),
              cellAlignment: pw.Alignment.centerRight,
              data: [
                ['Subtotal', '\$${subtotal.toStringAsFixed(2)}'],
                ['Tax (10%)', '\$${tax.toStringAsFixed(2)}'],
                ['Total', '\$${total.toStringAsFixed(2)}'],
              ],
            ),
          ],
        ),
      );

      // Open PDF directly without saving
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      debugPrint("Error generating PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate invoice: $e')),
      );
    }
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
        title: Text('Invoice Details',
            style: TextStyle(
                fontFamily: '-apple-system',
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Customer Information'),
                const SizedBox(height: 12),
                _buildDetailsCard([
                  _buildDetailRow('Name', customerDetails['name']),
                  _buildDetailRow('Mobile', customerDetails['mobile']),
                  _buildDetailRow('Email', customerDetails['email']),
                  _buildDetailRow('Address', customerDetails['address']),
                  _buildDetailRow('Venue', customerDetails['venue']),
                  _buildDetailRow('Order Date', customerDetails['orderDate']),
                ]),
                const SizedBox(height: 24),
                _buildSectionHeader('Items Ordered'),
                const SizedBox(height: 12),
                _buildItemsCard(cartItems),
                const SizedBox(height: 24),
                _buildSectionHeader('Invoice Summary'),
                const SizedBox(height: 12),
                _buildSummaryCard(subtotal, tax, total),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () => generateInvoice(context, plates),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF69F94F),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Download Invoice',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  Widget _buildDetailsCard(List<Widget> children) {
    return _buildContainer(children);
  }

  Widget _buildItemsCard(List<dynamic> items) {
    return _buildContainer(items.map((item) {
      return _buildDetailRow(item['item'] ?? 'Unknown Item',
          '\$${(item['price'] ?? 0.0).toStringAsFixed(2)}');
    }).toList());
  }

  Widget _buildSummaryCard(double subtotal, double tax, double total) {
    return _buildContainer([
      _buildDetailRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
      _buildDetailRow('Tax (10%)', '\$${tax.toStringAsFixed(2)}'),
      _buildDetailRow('Total', '\$${total.toStringAsFixed(2)}'),
    ]);
  }

  Widget _buildContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value ?? 'N/A',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
