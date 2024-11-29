import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';
import 'package:nongnongan_mobile/requests.dart';// For formatting date and time

class CreateTransaction extends StatefulWidget {
  final int userId;
  final String complete_name;
  final String selected_document;
  final String phone;
  final VoidCallback onTransactionCreated; // Add this line

  CreateTransaction({
    required this.userId,
    required this.complete_name,
    required this.phone,
    required this.selected_document,
    required this.onTransactionCreated, // Add this line
  });

  @override
  _CreateTransactionState createState() => _CreateTransactionState();
}

class _CreateTransactionState extends State<CreateTransaction> {
  Map<String, dynamic>? userData;
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController bdayController = TextEditingController();
  final TextEditingController bplaceController = TextEditingController();
  final TextEditingController documentTypeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController transactionCodeController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController civilStatusController = TextEditingController();

  // Define the civil statuses
  final List<String> civilStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated'
  ];


Future<void> _create_transactions() async {
  try {
    final connectionSettings = ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12747600',
        db: 'sql12747600',
        password: 'IypDAxHngN',
    );

    final conn = await MySqlConnection.connect(connectionSettings);

    var result = await conn.query(
      'INSERT INTO transactions (transaction_code, user_id, document_type, name, address, bday, bplace, sex, civil_status, purpose, validity, or_no, status, ref_no, remarks, schedule, payable) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        transactionCodeController.text,
        idController.text,
        documentTypeController.text,
        nameController.text,
        addressController.text,
        bdayController.text,
        bplaceController.text,
        sexController.text,
        civilStatusController.text,
        purposeController.text,
        'N/A',
        'N/A',
        'Pending',
        'N/A',
        'No Remarks',
        'N/A',
        0.0,
      ],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaction created successfully')),
    );

    await conn.close();

    // Call the callback to refresh the data table
    widget.onTransactionCreated(); // Add this line

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  @override
  void initState() {
    super.initState();
    fetchData();
    initializeTransactionCode();
    // Set the default value for documentTypeController
    documentTypeController.text = widget.selected_document;
  }

  void initializeTransactionCode() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now); // Format: yyyyMMdd_HHmmss
    transactionCodeController.text = formattedDate;
  }

  Future<void> fetchData() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12747600',
        db: 'sql12747600',
        password: 'IypDAxHngN',
    ));

    try {
      // Execute the query
      var results = await conn.query('SELECT * FROM users WHERE id = ?', [widget.userId]);
      if (results.isNotEmpty) {
        setState(() {
          userData = results.first.fields;
          // Set the values in the controllers
          idController.text = userData!['id'].toString();
          nameController.text = userData!['complete_name'] ?? '';
          sexController.text = userData!['sex'] ?? '';
          bdayController.text = userData!['bday'] ?? '';
          bplaceController.text = userData!['place_of_birth'] ?? '';
          addressController.text = userData!['purok'] ?? '';
          phoneController.text = userData!['phone'] ?? '';
          civilStatusController.text = userData!['civil_status'] ?? '';
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      await conn.close();
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Create ' + widget.selected_document),
    ),
    body: Center(
      child: userData == null
          ? CircularProgressIndicator()
          : ListView( // Change to ListView
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: documentTypeController,
                  decoration: InputDecoration(
                    labelText: 'Document Type',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // This makes the field read-only
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Complete Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: sexController,
                  decoration: InputDecoration(
                    labelText: 'Sex',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: bdayController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: bplaceController,
                  decoration: InputDecoration(
                    labelText: 'Place of Birth',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: civilStatusController,
                  decoration: InputDecoration(
                    labelText: 'Purpose',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: purposeController,
                  decoration: InputDecoration(
                    labelText: 'Purpose',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: transactionCodeController,
                  decoration: InputDecoration(
                    labelText: 'Transaction Code',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Set to true if you don't want this field to be editable
                ),

                SizedBox(height: 10),


                 // Links for "Create Account" and "Forgot Password"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(onPressed: (){
                      _create_transactions();
                    }, child: Text("Submit Requests"))
                  ],
                ),
              ],
              
            ),
    ),
  );
}


  @override
  void dispose() {
    // Dispose of the controllers when not in use to free resources
    idController.dispose();
    nameController.dispose();
    sexController.dispose();
    bdayController.dispose();
    bplaceController.dispose();
    addressController.dispose();
    phoneController.dispose();
    transactionCodeController.dispose();
    documentTypeController.dispose();
    purposeController.dispose(); // Dispose the purpose controller
    super.dispose();
  }
}
