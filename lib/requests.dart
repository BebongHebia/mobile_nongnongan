import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:nongnongan_mobile/announcement.dart';
import 'package:nongnongan_mobile/create_transaction.dart';
import 'package:nongnongan_mobile/home_page.dart';
import 'package:nongnongan_mobile/kap_calendar.dart';
import 'package:nongnongan_mobile/login.dart';
import 'package:nongnongan_mobile/view_transactions.dart';

class Transaction {
  final int id;
  final String userId; // Ensure that userId is correctly mapped and not null
  final String transactionCode; // This field might be null
  final String? documentType; // Make this field nullable if needed
  final String status; // Ensure this field is correctly mapped

  Transaction({
    required this.id,
    required this.userId,
    required this.transactionCode,
    this.documentType, // Mark as nullable
    required this.status,
  });
}

class Requests extends StatefulWidget {
  final int userId;
  final String complete_name;
  final String phone;

  Requests({
    required this.userId,
    required this.complete_name,
    required this.phone,
  });

  @override
  _RequestsState createState() => _RequestsState();

  static void fetchTransactions() {}
}

class _RequestsState extends State<Requests> {
  // List of document types
  final List<String> documentTypes = [
    'Certificate of Indigency',
    'Barangay Clearance',
    'Barangay Certification',
    'Barangay Cert - First-time Job Seeker',
    'Incident Reports'
  ];

  // Selected document type
  String? selectedDocument;

  // Transaction management
  List<Transaction> transactions = [];
  String searchQuery = ""; // Query for search
  int _rowsPerPage = 5; // Number of rows per page
  int _currentPage = 0; // Current page index

  @override
  void initState() {
    super.initState();
    fetchTransactions(); // Fetch transactions when the widget initializes
  }

  Future<void> fetchTransactions() async {
    print('Fetching transactions for userId: ${widget.userId}'); // Log userId
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'sql12.freesqldatabase.com',
      port: 3306,
      user: 'sql12751398',
      db: 'sql12751398',
      password: 'T8m87TYNGK',
    ));

    try {
      var results = await conn.query(
          'SELECT * FROM transactions WHERE user_id = ?', [widget.userId]);

      print('Transactions fetched: ${results.length}'); // Debugging line
      if (results.isEmpty) {
        print('No transactions found for userId: ${widget.userId}');
      } else {
        print(results); // Log the actual results for inspection
      }

      setState(() {
        transactions = results.map((row) {
          return Transaction(
            id: row['id'],
            userId: row['user_id'].toString(), // Convert to String if needed
            transactionCode:
                row['transaction_code'] ?? 'Unknown', // Default value if null
            documentType: row['document_type'], // This can be null
            status: row['status'] ?? 'Unknown', // Default value if null
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching transactions: ${e.toString()}');
    } finally {
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.complete_name),
              accountEmail: Text(widget.phone),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  widget.complete_name[0],
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(
                          userId: widget.userId,
                          complete_name: widget.complete_name,
                          phone: widget.phone)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.request_page),
              title: Text('My Request'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Requests(
                          userId: widget.userId,
                          complete_name: widget.complete_name,
                          phone: widget.phone)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Announcements'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Announcements(
                          userId: widget.userId,
                          complete_name: widget.complete_name,
                          phone: widget.phone)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Calendar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KapCalendar(
                            userId: widget.userId,
                            complete_name: widget.complete_name,
                            phone: widget.phone,
                          )),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Perform logout action and navigate to the login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // Navigate to the login page
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Document Button at the top
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    // Local variable for dialog's dropdown selection
                    String? dialogSelectedDocument = selectedDocument;

                    return StatefulBuilder(builder: (context, setDialogState) {
                      return AlertDialog(
                        title: Text('Request Document'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'Please select the type of document you wish to request.'),
                            SizedBox(height: 16.0),
                            DropdownButton<String>(
                              isExpanded: true,
                              value: dialogSelectedDocument,
                              hint: Text('Select Document'),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  dialogSelectedDocument = newValue;
                                });
                              },
                              items: documentTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (dialogSelectedDocument != null) {
                                setState(() {
                                  selectedDocument = dialogSelectedDocument;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'Request for "$selectedDocument" has been submitted.')));

                                var selectedDoc = selectedDocument;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateTransaction(
                                            userId: widget.userId,
                                            complete_name: widget.complete_name,
                                            phone: widget.phone,
                                            selected_document: selectedDoc!,
                                            onTransactionCreated: () {
                                              // Call your refresh function here to reload the data table
                                              fetchTransactions(); // This should be your function to refresh the data
                                            },
                                          )),
                                );
                              }
                            },
                            child: Text('Submit'),
                          ),
                        ],
                      );
                    });
                  },
                );
              },
              child: Text('Request Document'),
            ),
            SizedBox(height: 16.0), // Add spacing between button and search box

            // Search Box
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Transactions',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update search query
                });
              },
            ),
            SizedBox(
                height: 16.0), // Add spacing between search box and data table

            // Transactions Data Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: transactions.isEmpty
                    ? Center(child: Text('No transactions found.'))
                    : DataTable(
                        columns: [
                          DataColumn(label: Text('Transaction Code')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Document Type')),
                        ],
                        rows: transactions
                            .where((transaction) => transaction.transactionCode
                                .toLowerCase()
                                .contains(searchQuery
                                    .toLowerCase())) // Filter transactions
                            .skip(_currentPage * _rowsPerPage) // Paginate
                            .take(_rowsPerPage)
                            .map((transaction) => DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      // Apply background color based on status
                                      switch (
                                          transaction.status.toLowerCase()) {
                                        case 'pending':
                                          return Colors.orange[100];
                                        case 'received':
                                          return Colors.blue[100];
                                        case 'completed':
                                          return Colors.green[100];
                                        case 'decline':
                                          return Colors.red[100];
                                        default:
                                          return Colors
                                              .grey[100]; // Default color
                                      }
                                    },
                                  ),
                                  cells: [
                                    DataCell(
                                      InkWell(
                                        onTap: () {
                                          // Define what happens when the row is clicked
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewTransaction(
                                                      transaction_id:
                                                          transaction.id),
                                            ),
                                          );
                                        },
                                        child:
                                            Text(transaction.transactionCode),
                                      ),
                                    ),
                                    DataCell(Text(transaction.status)),
                                    DataCell(Text(
                                        transaction.documentType ?? 'N/A')),
                                  ],
                                ))
                            .toList(),
                      ),
              ),
            ),

            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rows per page:'),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  onChanged: (value) {
                    setState(() {
                      _rowsPerPage = value ?? 5;
                      _currentPage = 0; // Reset to first page
                    });
                  },
                  items: [5, 10, 15].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_currentPage > 0) {
                        _currentPage--; // Go to previous page
                      }
                    });
                  },
                  child: Text('Previous'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_currentPage <
                          (transactions.length / _rowsPerPage).ceil() - 1) {
                        _currentPage++; // Go to next page
                      }
                    });
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
