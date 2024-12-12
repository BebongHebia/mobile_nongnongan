import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:easy_send_sms/easy_sms.dart';
import 'package:intl/intl.dart';

class AdminBoard extends StatefulWidget {
  final int userId;
  final String complete_name;

  const AdminBoard(
      {Key? key, required this.userId, required this.complete_name})
      : super(key: key);

  @override
  _AdminBoardState createState() => _AdminBoardState();
}

class _AdminBoardState extends State<AdminBoard> {
  late Future<List<Map<String, dynamic>>> _transactionsFuture;
  Timer? _smsCheckerTimer;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
    _startSmsChecker(); // Start the periodic check
  }

  @override
  void dispose() {
    _smsCheckerTimer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    try {
      final connectionSettings = ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12751398',
        db: 'sql12751398',
        password: 'T8m87TYNGK',
      );

      final conn = await MySqlConnection.connect(connectionSettings);
      final results = await conn
          .query('SELECT * FROM transactions ORDER BY created_at DESC');
      await conn.close();

      return results
          .map((row) => {
                'id': row['id'],
                'name': row['name'],
                'document_type': row['document_type'],
                'status': row['status'],
                'sms_status': row['sms_status'],
                'contact': row['contact'],
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  void _startSmsChecker() {
    _smsCheckerTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _checkAndSendSms();
    });
  }

  Future<void> _checkAndSendSms() async {
    try {
      final connectionSettings = ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12751398',
        db: 'sql12751398',
        password: 'T8m87TYNGK',
      );

      final conn = await MySqlConnection.connect(connectionSettings);

      // Fetch pending SMS records
      final results = await conn.query(
        'SELECT * FROM transactions WHERE sms_status = "Pending" order by created_at desc limit 1',
      );

      for (var row in results) {
        final id = row['id'];
        final contact = row['contact'];

        final name = row['name'];
        final transaction_code = row['transaction_code'];
        final document_type = row['document_type'];
        final schedule = row['schedule'];
        final status = row['status'];
        final payable = row['payable'];

        String message = "Good Day/Evening " +
            name +
            " your requested document " +
            document_type +
            " is now " +
            status +
            " Please claim, " +
            schedule +
            " Transaction Code : " +
            transaction_code +
            " your payable is " +
            payable;

        // Send SMS logic
        final isSmsSent = await sendSms(contact, message);

        if (isSmsSent) {
          // Update the sms_status to "Sent"
          await conn.query(
              'UPDATE transactions SET sms_status = "Sent" WHERE id = ?', [id]);
        }
      }

      await conn.close();
    } catch (e) {
      debugPrint('Error while checking or sending SMS: $e');
    }
  }

  final _easySmsPlugin = EasySms();

  Future<bool> sendSms(String contact, String message) async {
    try {
      await _easySmsPlugin.requestSmsPermission();
      await _easySmsPlugin.sendSms(phone: contact, msg: message);
      return true; // Indicate success
    } catch (err) {
      if (kDebugMode) {
        print('Failed to send SMS to $contact: ${err.toString()}');
      }
      return false; // Indicate failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.complete_name}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'User ID: ${widget.userId}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No transactions found.'));
                  }

                  final transactions = snapshot.data!;
                  return PaginatedDataTable(
                    header: Text('Transactions'),
                    columns: [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Document')),
                      DataColumn(label: Text('Status')),
                    ],
                    source: TransactionsDataSource(transactions),
                    rowsPerPage: 5,
                    showCheckboxColumn: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> transactions;

  TransactionsDataSource(this.transactions);

  Color _getRowColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.yellow.withOpacity(0.3);
      case 'received':
        return Colors.blue.withOpacity(0.3);
      case 'declined':
        return Colors.red.withOpacity(0.3);
      case 'completed':
        return Colors.green.withOpacity(0.3);
      default:
        return Colors.transparent;
    }
  }

  @override
  DataRow getRow(int index) {
    if (index >= transactions.length) return null as DataRow;
    final transaction = transactions[index];

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>((states) {
        return _getRowColor(transaction['status']);
      }),
      cells: [
        DataCell(Text(transaction['id'].toString())),
        DataCell(Text(transaction['name'].toString())),
        DataCell(Text(transaction['document_type'].toString())),
        DataCell(Text(transaction['status'] ?? '')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => transactions.length;

  @override
  int get selectedRowCount => 0;
}
