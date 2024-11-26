import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class ViewTransaction extends StatefulWidget {
  final int transaction_id;

  ViewTransaction({
    required this.transaction_id,
  });

  @override
  _ViewTransactionState createState() => _ViewTransactionState();
}

class _ViewTransactionState extends State<ViewTransaction> {
  late int id;
  late int userId;
  late String name;
  late String address;
  late String bday;
  late String bplace;
  late String sex;
  late String civil_status;
  late String purpose;
  late String validity;
  late String or_no;
  late String ref_no;
  late String remarks;
  late String schedule;
  late double payable; // Change from String to double
  late String transactionCode;
  late String documentType;
  late String status;
  late String date; // You can store the date as a string

  bool isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    fetchTransactionDetails(); // Fetch the transaction details when the widget initializes
  }

  Future<void> fetchTransactionDetails() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12745725',
        db: 'sql12745725',
        password: 'dexel9dQ9R',
    ));

    try {
      var results = await conn.query(
          'SELECT * FROM transactions WHERE id = ?', [widget.transaction_id]);

      if (results.isNotEmpty) {
        var row = results.first; // Get the first row of the result
        setState(() {
          userId = row['user_id'];
          name = row['name'] ?? 'Unknown';
          address = row['address'] ?? 'Unknown';
          bday = row['bday'] ?? 'Unknown';
          bplace = row['bplace'] ?? 'Unknown';
          sex = row['sex'] ?? 'Unknown';
          civil_status = row['civil_status'] ?? 'Unknown';
          purpose = row['purpose'] ?? 'Unknown';
          validity = row['validity'] ?? 'Unknown';
          or_no = row['or_no'] ?? 'Unknown';
          ref_no = row['ref_no'] ?? 'Unknown';
          remarks = row['remarks'] ?? 'Unknown';
          schedule = row['schedule'] ?? 'Unknown';
          payable = row['payable'] ?? 0.0; // Assign double directly
          transactionCode = row['transaction_code'] ?? 'Unknown';
          documentType = row['document_type'] ?? 'N/A';
          status = row['status'] ?? 'Unknown';
          date = DateFormat('yyyy-MM-dd').format(row['created_at']); // Format the date
          isLoading = false; // Update loading state
        });
      } else {
        // Handle the case where no results are found
        setState(() {
          isLoading = false; // Update loading state
        });
      }
    } catch (e) {
      print('Error fetching transaction details: ${e.toString()}');
      setState(() {
        isLoading = false; // Update loading state on error
      });
    } finally {
      await conn.close(); // Ensure the connection is closed
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('View My Transaction'),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
        : SingleChildScrollView( // Enable scrolling
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Panel Card
                  Card(
                    color: getStatusColor(status), // Get the color based on the status
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0), // Add some spacing below the card

                  // Transaction Details
                  TextFormField(
                    decoration: InputDecoration(labelText: 'User ID'),
                    initialValue: userId.toString(),
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Complete Name'),
                    initialValue: name,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Date of Birth'),
                    initialValue: bday,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Sex'),
                    initialValue: sex,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Place of Birth'),
                    initialValue: bplace,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Civil Status'),
                    initialValue: civil_status,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Address'),
                    initialValue: address,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Purpose'),
                    initialValue: purpose,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Validity'),
                    initialValue: validity,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'O.R No.#'),
                    initialValue: or_no,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Ref No.#'),
                    initialValue: ref_no,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Remarks'),
                    initialValue: remarks,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Schedule'),
                    initialValue: schedule,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Payable'),
                    initialValue: payable.toString(), // Convert to string for display
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Transaction Code'),
                    initialValue: transactionCode,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Document Type'),
                    initialValue: documentType,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Date'),
                    initialValue: date,
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),
  );
}

// Method to get the status color based on the status
Color getStatusColor(String status) {
  switch (status) {
    case 'Pending':
      return Colors.orange; // Orange for Pending
    case 'Received':
      return Colors.blue; // Blue for Received
    case 'Decline':
      return Colors.red;
    case 'Completed':
      return Colors.green; // Red for Decline
    default:
      return Colors.grey; // Default color if status doesn't match
  }
}


}
