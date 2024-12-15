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
    total = subtotal; // You can modify this to add tax or other fees
    roundedPrice = (total + 5).toDouble(); // Example of rounding up
  }

  @override
  void initState() {
    super.initState();
    plates = widget.noOfPlates.toDouble(); // Set the number of plates
    calculateTotals(); // Calculate totals when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Input fields for customer details
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
              ),
              TextField(
                controller: employeeNameController,
                decoration: const InputDecoration(labelText: 'Employee Name'),
              ),
              TextField(
                controller: employeeEmailController,
                decoration: const InputDecoration(labelText: 'Employee Email'),
              ),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: orderDateController,
                decoration: const InputDecoration(labelText: 'Order Date'),
              ),
              TextField(
                controller: fssainoController,
                decoration: const InputDecoration(labelText: 'FSSAI No'),
              ),
              TextField(
                controller: taxController,
                decoration: const InputDecoration(labelText: 'Tax'),
              ),
              // Display number of plates
              Text(
                'Number of Plates: ${plates.toStringAsFixed(0)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Cart summary
              ListTile(
                title: Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
              ),
              // Button to navigate to generate invoice page
              ElevatedButton(
                onPressed: () {
                  // Implement logic to navigate to generate invoice page
                  // Pass necessary data (like customer details and cart items)
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
                child: const Text('Generate Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
