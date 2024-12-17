import 'package:flutter/material.dart';
import 'generate_invoice.dart';

class CustomerDetailsPage extends StatefulWidget {
  final List<dynamic> cartItems; // Cart items passed from CartPage
  final int noOfPlates; // Number of plates passed from CartPage

  CustomerDetailsPage({
    required this.cartItems,
    required double totalAmount,
    required this.noOfPlates, // Receiving noOfPlates
  });

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  // Declare the fields for customer details
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

  // Calculate totals based on the cartItems passed
  void calculateTotals() {
    subtotal =
        widget.cartItems.fold(0.0, (sum, item) => sum + (item['price'] ?? 0.0));
    total = subtotal *
        widget.noOfPlates; // You can modify this to add tax or other fees
    roundedPrice = (total + 5).toDouble(); // Example of rounding up
  }

  @override
  void initState() {
    super.initState();
    plates = widget.noOfPlates.toDouble(); // Set the number of plates
    print(widget.cartItems); // Debugging cartItems
    calculateTotals(); // Calculate totals when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SafeArea(
        // To prevent the content from being hidden behind device notches or gestures
        child: Column(
          children: [
            // Main content section (now scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Customer Details Section
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

            // Floating summary section at the bottom
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
                      // Number of Plates
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Number of Plates:',
                            style: const TextStyle(
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

                      // Cart Summary Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:',
                              style: const TextStyle(
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
                          Text('Total:',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Generate Invoice Button
                      ElevatedButton(
                        onPressed: () {
                          // Ensure totals are calculated before navigating
                          calculateTotals();

                          // Pass the calculated subtotal and total to the GenerateInvoicePage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenerateInvoicePage(
                                customerDetails: {
                                  'name': nameController.text,
                                  'mobile': mobileController.text,
                                  'email': emailController.text,
                                  'address': addressController.text,
                                  'venue': venueController.text,
                                  'employeeName': employeeNameController.text,
                                  'employeeEmail': employeeEmailController.text,
                                  'plates': plates,
                                  'total': total,
                                  'subtotal': subtotal,
                                  'date': date,
                                  'phoneNumber': phoneNumberController.text,
                                  'roundedPrice': roundedPrice,
                                  'orderDate': orderDateController.text,
                                  'fssaino': fssainoController.text,
                                  'tax': taxController.text,
                                },
                                cartItems: widget.cartItems,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
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

  // Helper method to build text fields with consistent styling
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
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 64, 243, 70)), // Active border color
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }
}
