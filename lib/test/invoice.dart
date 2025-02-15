import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class GenerateInvoicePage extends StatelessWidget {
  final Map<String, dynamic> customerDetails;
  final List<dynamic> cartItems;

  const GenerateInvoicePage({
    super.key,
    required this.customerDetails,
    required this.cartItems,
  });

  Future<Uint8List?> _getImageFromFirebase(String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final url = await ref.getDownloadURL();
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('Error loading image from Firebase: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 800 : screenSize.width,
                    minHeight: constraints.maxHeight,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20.0 : 10.0,
                    vertical: 10.0,
                  ),
                  child: PdfPreview(
                    build: (format) => generateInvoice(format, isTablet),
                    allowPrinting: true,
                    allowSharing: true,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    maxPageWidth: isTablet ? 700 : screenSize.width - 40,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Uint8List> generateInvoice(PdfPageFormat format, bool isTablet) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    
    // Load logos from Firebase Storage
    final headerLogoBytes = await _getImageFromFirebase('logos/royal_logo.png');
    final footerLogoBytes = await _getImageFromFirebase('logos/costcater_logo.png');
    
    // Calculate responsive dimensions
    final logoSize = isTablet ? 80.0 : 60.0;
    final headerFontSize = isTablet ? 20.0 : 16.0;
    final contentFontSize = isTablet ? 12.0 : 10.0;
    final footerFontSize = isTablet ? 10.0 : 8.0;
    
    pw.Image? headerLogo;
    pw.Image? footerLogo;
    
    if (headerLogoBytes != null) {
      headerLogo = pw.Image(pw.MemoryImage(headerLogoBytes), 
        width: logoSize, height: logoSize);
    }
    
    if (footerLogoBytes != null) {
      footerLogo = pw.Image(pw.MemoryImage(footerLogoBytes), 
        width: logoSize * 0.75, height: logoSize * 0.25);
    }
    
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(isTablet ? 40.0 : 20.0),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo and Company Details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (headerLogo != null) headerLogo,
                  pw.SizedBox(width: 10),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Ottapalam',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: headerFontSize,
                        ),
                      ),
                      pw.Text(
                        '+91 8943100500',
                        style: pw.TextStyle(font: font, fontSize: contentFontSize),
                      ),
                      pw.Text(
                        '+91 7034100500',
                        style: pw.TextStyle(font: font, fontSize: contentFontSize),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 10),
              pw.Text(
                'FSSAI No: ${customerDetails['fssaino']}',
                style: pw.TextStyle(font: font, fontSize: contentFontSize),
              ),
              pw.Divider(),

              // Billing Information
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed to:', style: pw.TextStyle(font: boldFont, fontSize: contentFontSize)),
                      pw.Text(customerDetails['name'], style: pw.TextStyle(font: font, fontSize: contentFontSize)),
                      pw.Text(customerDetails['mobile'], style: pw.TextStyle(font: font, fontSize: contentFontSize)),
                      pw.Text(customerDetails['address'], style: pw.TextStyle(font: font, fontSize: contentFontSize)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('From:', style: pw.TextStyle(font: boldFont, fontSize: contentFontSize)),
                      pw.Text('${customerDetails['employeeName']}', style: pw.TextStyle(font: font, fontSize: contentFontSize)),
                      pw.Text('${customerDetails['employeeEmail']}', style: pw.TextStyle(font: font, fontSize: contentFontSize)),
                      pw.Text('${customerDetails['mobile']}', style: pw.TextStyle(font: font, fontSize: contentFontSize)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Venue: ${customerDetails['venue']}'),
                  pw.Text('Date: ${customerDetails['orderDate']}'),
                  pw.Text('Order Date: ${customerDetails['orderDate']}'),
                ],
              ),
              pw.SizedBox(height: 20),

              // Menu Items Table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(4),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(isTablet ? 8.0 : 5.0),
                        child: pw.Text('S.No', 
                          style: pw.TextStyle(font: boldFont, fontSize: contentFontSize)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(isTablet ? 8.0 : 5.0),
                        child: pw.Text('MENU', 
                          style: pw.TextStyle(font: boldFont, fontSize: contentFontSize)),
                      ),
                    ],
                  ),
                  ...generateMenuItems(cartItems, font, boldFont, contentFontSize),
                ],
              ),
              
              pw.SizedBox(height: 20),

              // Pricing Summary
              pw.Text(
                'Plates: ${customerDetails['plates']} x ${customerDetails['pricePerPlate']} Rs.',
                style: pw.TextStyle(font: font, fontSize: contentFontSize),
              ),
              pw.Text(
                'Total: ${customerDetails['subtotal']} Rs.',
                style: pw.TextStyle(font: boldFont, fontSize: contentFontSize),
              ),
              pw.Text(
                'Discounted Price: ${customerDetails['roundedPrice']} Rs.',
                style: pw.TextStyle(font: boldFont, fontSize: contentFontSize),
              ),

              pw.SizedBox(height: 20),

              // Terms and Conditions
              pw.Text(
                'Terms and Conditions',
                style: pw.TextStyle(font: boldFont, fontSize: contentFontSize),
              ),
              pw.SizedBox(height: 5),
              ...generateTermsAndConditions(font, footerFontSize),

              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Royal Catering',
                      style: pw.TextStyle(font: boldFont, fontSize: contentFontSize),
                    ),
                    pw.Text(
                      'Royal Group of Companies',
                      style: pw.TextStyle(font: font, fontSize: contentFontSize),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (footerLogo != null) footerLogo,
                        pw.SizedBox(width: 5),
                        pw.Text(
                          'Created by CostCater and developed by Cygnus IT Solutions.',
                          style: pw.TextStyle(font: font, fontSize: footerFontSize),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Page 1 of 3',
                      style: pw.TextStyle(font: font, fontSize: footerFontSize),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  List<pw.TableRow> generateMenuItems(
    List<dynamic> items, 
    pw.Font font, 
    pw.Font boldFont,
    double fontSize,
  ) {
    Map<String, List<Map<String, dynamic>>> categorizedItems = {
      'Beef': [],
      'Bread': [],
      'Chicken': [],
      'Dessert': [],
    };

    // Categorize items
    for (var item in items) {
      String category = item['category'] ?? 'Other';
      if (categorizedItems.containsKey(category)) {
        categorizedItems[category]!.add(item);
      }
    }

    List<pw.TableRow> rows = [];
    int serialNo = 1;

    // Generate rows for each category
    categorizedItems.forEach((category, categoryItems) {
      if (categoryItems.isNotEmpty) {
        // Add category header
        rows.add(
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(''),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  category, 
                  style: pw.TextStyle(font: boldFont, fontSize: fontSize)
                ),
              ),
            ],
          ),
        );

        // Add items in category
        for (var item in categoryItems) {
          rows.add(
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    '$serialNo',
                    style: pw.TextStyle(font: font, fontSize: fontSize)
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    item['name'] ?? '',
                    style: pw.TextStyle(font: font, fontSize: fontSize)
                  ),
                ),
              ],
            ),
          );
          serialNo++;
        }
      }
    });

    return rows;
  }

  List<pw.Widget> generateTermsAndConditions(pw.Font font, double fontSize) {
    List<String> terms = [
      '1. Payment terms: 50% advance payment required',
      '2. Cancellation policy: 24 hours notice required',
      '3. Minimum order quantity applies',
      '4. Prices are subject to change',
      '5. Service charges and taxes extra',
    ];

    return terms.map((term) => pw.Text(
      term,
      style: pw.TextStyle(font: font, fontSize: fontSize),
    )).toList();
  }
}