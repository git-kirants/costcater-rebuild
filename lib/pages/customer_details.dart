import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CustomerDetailsPage extends StatefulWidget {
  final List<dynamic> cartItems;
  final int noOfPlates;

  CustomerDetailsPage({
    required this.cartItems,
    required double totalAmount,
    required this.noOfPlates,
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
  final TextEditingController fssainoController = TextEditingController();
  final TextEditingController taxController = TextEditingController();

  double plates = 0;
  double total = 0;
  double subtotal = 0;
  double roundedPrice = 0;
  String date = '';

  void calculateTotals() {
    subtotal =
        widget.cartItems.fold(0.0, (sum, item) => sum + (item['price'] ?? 0.0));
    total = subtotal * widget.noOfPlates;
    roundedPrice = (total + 5).toDouble();
  }

  @override
  void initState() {
    super.initState();
    plates = widget.noOfPlates.toDouble();
    calculateTotals();
  }

  Future<void> _generateAndShowPDF() async {
    // Create the PDF document
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
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
                        'Invoice Date: ${orderDateController.text}',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FSSAI No: ${fssainoController.text}',
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
                        pw.Text('Bill To:',
                            style: pw.TextStyle(font: boldFont)),
                        pw.Text(nameController.text,
                            style: pw.TextStyle(font: font)),
                        pw.Text(emailController.text,
                            style: pw.TextStyle(font: font)),
                        pw.Text(mobileController.text,
                            style: pw.TextStyle(font: font)),
                        pw.Text(addressController.text,
                            style: pw.TextStyle(font: font)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Venue:', style: pw.TextStyle(font: boldFont)),
                        pw.Text(venueController.text,
                            style: pw.TextStyle(font: font)),
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
                        child: pw.Text('Item',
                            style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Price',
                            style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Plates',
                            style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Total',
                            style: pw.TextStyle(font: boldFont)),
                      ),
                    ],
                  ),
                  ...widget.cartItems
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
                      .toList(),
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
                        pw.Text('Subtotal: ',
                            style: pw.TextStyle(font: boldFont)),
                        pw.Text('\$${subtotal.toStringAsFixed(2)}',
                            style: pw.TextStyle(font: font)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text('Tax (${taxController.text}%): ',
                            style: pw.TextStyle(font: boldFont)),
                        pw.Text(
                            '\$${(subtotal * (double.tryParse(taxController.text) ?? 0) / 100).toStringAsFixed(2)}',
                            style: pw.TextStyle(font: font)),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text('Total: ', style: pw.TextStyle(font: boldFont)),
                        pw.Text('\$${roundedPrice.toStringAsFixed(2)}',
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
                    _buildTextField(fssainoController, 'FSSAI No'),
                    _buildTextField(taxController, 'Tax'),
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
                            '${plates.toStringAsFixed(0)}',
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
