import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerateInvoicePage extends StatelessWidget {
  final Map<String, dynamic> customerDetails;
  final List<dynamic> cartItems;

  const GenerateInvoicePage({
    super.key,
    required this.customerDetails,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        backgroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => generateInvoice(format),
      ),
    );
  }

  Future<Uint8List> generateInvoice(PdfPageFormat format) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 40,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Invoice Date: ${customerDetails['orderDate']}',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FSSAI No: ${customerDetails['fssaino']}',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Billing Information
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Bill To:', style: pw.TextStyle(font: boldFont)),
                        pw.Text(customerDetails['name'], style: pw.TextStyle(font: font)),
                        pw.Text(customerDetails['email'], style: pw.TextStyle(font: font)),
                        pw.Text(customerDetails['mobile'], style: pw.TextStyle(font: font)),
                        pw.Text(customerDetails['address'], style: pw.TextStyle(font: font)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Venue:', style: pw.TextStyle(font: boldFont)),
                        pw.Text(customerDetails['venue'], style: pw.TextStyle(font: font)),
                        pw.Text('Employee Details:', style: pw.TextStyle(font: boldFont)),
                        pw.Text(customerDetails['employeeName'], style: pw.TextStyle(font: font)),
                        pw.Text(customerDetails['employeeEmail'], style: pw.TextStyle(font: font)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Item', style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Price', style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Plates', style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Total', style: pw.TextStyle(font: boldFont)),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...cartItems.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(item['name'] ?? '', style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('\$${(item['price'] ?? 0).toStringAsFixed(2)}', 
                          style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(customerDetails['plates'].toString(), 
                          style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '\$${((item['price'] ?? 0) * customerDetails['plates']).toStringAsFixed(2)}',
                          style: pw.TextStyle(font: font)),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: ', style: pw.TextStyle(font: boldFont)),
                        pw.Text('\$${customerDetails['subtotal'].toStringAsFixed(2)}',
                          style: pw.TextStyle(font: font)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text('Tax (${customerDetails['tax']}%): ', 
                          style: pw.TextStyle(font: boldFont)),
                        pw.Text('\$${(customerDetails['subtotal'] * 
                          (double.parse(customerDetails['tax']) / 100)).toStringAsFixed(2)}',
                          style: pw.TextStyle(font: font)),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text('Total: ', style: pw.TextStyle(font: boldFont)),
                        pw.Text('\$${customerDetails['roundedPrice'].toStringAsFixed(2)}',
                          style: pw.TextStyle(font: font, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    font: font,
                    color: PdfColors.grey700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
}