import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class CustomerDetailsPage extends StatefulWidget {
  final List<dynamic> cartItems;
  final int noOfPlates;
  final String email;

  const CustomerDetailsPage({
    super.key,
    required this.cartItems,
    required double totalAmount,
    required this.noOfPlates,
    required this.email,
  });

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  // Your existing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController employeeNameController = TextEditingController();
  final TextEditingController employeeEmailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController orderDateController = TextEditingController();
  final TextEditingController fssaiController = TextEditingController();
  final TextEditingController taxController = TextEditingController();

  double plates = 0;
  double total = 0;
  double subtotal = 0;
  double roundedPrice = 0;
  String date = '';

// Terms and Conditions template
  String? termsAndConditions;

  // Add function to fetch terms and conditions

  void calculateTotals() {
    subtotal =
        widget.cartItems.fold(0.0, (sum, item) => sum + (item['price'] ?? 0.0));
    total = subtotal * widget.noOfPlates;
    roundedPrice = (total).toDouble();
  }

  @override
  void initState() {
    super.initState();
    plates = widget.noOfPlates.toDouble();
    calculateTotals();
  }

  Future<String> fetchFssaiNumber(String email) async {
    try {
      // Trim and prepare the email for the query
      final trimmedEmail = email.trim();
      debugPrint('Fetching FSSAI No for email: $trimmedEmail');

      // Fetch the document snapshot from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(trimmedEmail)
          .get();

      // Check if the document exists
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        throw Exception('User document not found or no data available');
      }

      // Extract the FSSAI number
      final fssaiNo = docSnapshot.data()?['FSSAI'] ?? 'N/A'; // Default to 'N/A'
      debugPrint('Fetched FSSAI No: $fssaiNo');

      return fssaiNo;
    } catch (e) {
      debugPrint('Error fetching FSSAI No: $e');
      return 'Error fetching FSSAI No'; // Return a fallback message
    }
  }

  Future<String> fetchTermsAndConditions() async {
    try {
      final email = widget.email.trim();
      debugPrint('Fetching T&C for email: $email');

      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      debugPrint('Document exists: ${docSnapshot.exists}');

      if (!docSnapshot.exists) {
        return 'Terms and conditions not found for this user.';
      }

      final data = docSnapshot.data();
      debugPrint('Document data: $data');

      if (data == null || !data.containsKey('TermsAndConditions')) {
        return 'Terms and conditions section is empty.';
      }

      final terms = data['TermsAndConditions'] as String;
      if (terms.isEmpty) {
        return 'Terms and conditions are empty.';
      }

      debugPrint('Terms length: ${terms.length}');
      debugPrint(
          'First 100 chars of terms: ${terms.substring(0, terms.length > 100 ? 100 : terms.length)}');

      return terms;
    } catch (e) {
      debugPrint('Error fetching terms: $e');
      return 'Error loading terms and conditions: $e';
    }
  }

  Future<void> _generateAndShowPDF() async {
    //PDF
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    //feteching Terms
    final terms = await fetchTermsAndConditions();
    // Constants for pagination
    const int itemsPerPage = 10;
    final int totalPages = (widget.cartItems.length / itemsPerPage).ceil();
    final ByteData logoBytes =
        await rootBundle.load('assets/logos/costcaterlogo.png');
    final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoUint8List);

    // Helper function to build the header

    // Fetching FSSAI number before generating PDF
    final fssaiNo = await fetchFssaiNumber(widget.email); // Await FSSAI number
    //Date
    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    pw.Widget buildHeader() {
      return pw.Column(
        children: [
          // Logo row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Image(logoImage, width: 200), // Adjust width as needed
            ],
          ),
          pw.SizedBox(height: 20),
          // Invoice details row
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
                    'Invoice Date: $formattedDate',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  pw.Text(
                    'Order Date: ${orderDateController.text.contains('/') ? orderDateController.text.replaceAll('/', '-') : orderDateController.text}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'FSSAI No: $fssaiNo',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    // Helper function to build billing information
    pw.Widget buildBillingInfo() {
      return pw.Container(
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
                pw.Text(nameController.text, style: pw.TextStyle(font: font)),
                pw.Text(emailController.text, style: pw.TextStyle(font: font)),
                pw.Text(mobileController.text, style: pw.TextStyle(font: font)),
                pw.Text(addressController.text,
                    style: pw.TextStyle(font: font)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Venue:', style: pw.TextStyle(font: boldFont)),
                pw.Text(venueController.text, style: pw.TextStyle(font: font)),
                pw.Text('Employee Details:',
                    style: pw.TextStyle(font: boldFont)),
                pw.Text(employeeNameController.text,
                    style: pw.TextStyle(font: font)),
                pw.Text(employeeEmailController.text,
                    style: pw.TextStyle(font: font)),
              ],
            ),
          ],
        ),
      );
    }

    // Helper function to build table header
    pw.TableRow buildTableHeader(pw.Font boldFont) {
      return pw.TableRow(
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
      );
    }

    // Helper function to build table rows for items
    List<pw.TableRow> buildTableRows(List<dynamic> items, pw.Font font) {
      return items
          .map((item) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(item['item'] ?? '',
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                        '\$${(item['price'] ?? 0).toStringAsFixed(2)}',
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(plates.toString(),
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                        '\$${((item['price'] ?? 0) * plates).toStringAsFixed(2)}',
                        style: pw.TextStyle(font: font)),
                  ),
                ],
              ))
          .toList();
    }

    // Helper function to build footer
    pw.Widget buildFooter(pw.Context context) {
      return pw.Column(
        children: [
          pw.Container(
            alignment: pw.Alignment.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Page ${context.pageNumber} of ${totalPages + 1}',
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ],
      );
    }

    // Generate pages
    for (int pageNum = 0; pageNum < totalPages; pageNum++) {
      final startIndex = pageNum * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage <= widget.cartItems.length)
          ? startIndex + itemsPerPage
          : widget.cartItems.length;
      final pageItems = widget.cartItems.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header (only on first page)
                if (pageNum == 0) ...[
                  buildHeader(),
                  pw.SizedBox(height: 20),
                  buildBillingInfo(),
                  pw.SizedBox(height: 20),
                ],

                // Items table
                pw.Expanded(
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(4),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      buildTableHeader(boldFont),
                      ...buildTableRows(pageItems, font),
                    ],
                  ),
                ),

                // Summary (only on last page)
                if (pageNum == totalPages - 1) ...[
                  pw.SizedBox(height: 20),
                  pw.Container(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Subtotal: ',
                                style: pw.TextStyle(font: boldFont)),
                            pw.Text('\$${subtotal.toStringAsFixed(2)}',
                                style: pw.TextStyle(font: font)),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text(
                              'TOTAL : ',
                              style: pw.TextStyle(font: boldFont, fontSize: 16),
                            ),
                            pw.Text(
                              '\$${subtotal.toStringAsFixed(2)} X ${widget.noOfPlates} = \n',
                              style: pw.TextStyle(font: font),
                            ),
                            pw.Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: pw.TextStyle(font: boldFont, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Footer with page number
                pw.Spacer(),
                buildFooter(context),
              ],
            );
          },
        ),
      );
    }

    // Add Terms and Conditions page
    // Add Terms and Conditions page with enhanced formatting
    // Add Terms and Conditions page
    // Add Terms and Conditions page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40), // Add margin to ensure text fits
        build: (context) {
          // Debug print to verify terms content
          debugPrint('Terms content: $terms');

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Simple header
              pw.Center(
                child: pw.Text(
                  'Terms and Conditions',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Terms and Conditions content with proper wrapping
              pw.Expanded(
                child: pw.Container(
                  child: pw.Text(
                    terms ??
                        'No terms and conditions available', // Add null check
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                    ),
                    textAlign: pw.TextAlign.justify,
                    maxLines: null, // Allow multiple lines
                  ),
                ),
              ),

              // Footer
              pw.Spacer(),
              buildFooter(context),
            ],
          );
        },
      ),
    );
    // Show the PDF preview
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 800,
          height: 800,
          child: PdfPreview(
            build: (format) => pdf.save(),
            canChangeOrientation: false,
            canDebug: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Your existing build method remains the same until the ElevatedButton
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(nameController, 'Name'),
                    _buildTextField(mobileController, 'Mobile'),
                    _buildTextField(emailController, 'Email'),
                    _buildTextField(addressController, 'Address'),
                    _buildTextField(venueController, 'Venue'),
                    _buildTextField(employeeNameController, 'Employee Name'),
                    _buildTextField(employeeEmailController, 'Employee Email'),
                    _buildTextField(phoneNumberController, 'Phone Number'),
                    _buildTextField(orderDateController, 'Order Date'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Number of Plates:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            plates.toStringAsFixed(0),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _generateAndShowPDF,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFF52ed28),
                        ),
                        child: const Text(
                          'Generate Invoice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'SF Pro',
            color: Colors.black54,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 64, 243, 70)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }
}
