import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'recover_account.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _verifyCredentials() async {
    final phone = _phoneController.text;
    final username = _usernameController.text;

    try {
      // MySQL Connection Settings
      final connectionSettings = ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12749646',
        db: 'sql12749646',
        password: 'ybCUYliBya',
      );

      // Establish connection
      final conn = await MySqlConnection.connect(connectionSettings);

      // Query database to check for the record
      var results = await conn.query(
        'SELECT * FROM users WHERE phone = ? AND username = ?',
        [phone, username],
      );

      if (results.isNotEmpty) {
        // Navigate to recover_account.dart with the retrieved data
        var userRow = results.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecoverAccountPage(
              name: userRow['complete_name'],
              userId: userRow['id'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid phone or username')),
        );
      }

      // Close connection
      await conn.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Reset Your Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Phone TextField
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),

              // Verify Button
              ElevatedButton(
                onPressed: _verifyCredentials,
                child: Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
