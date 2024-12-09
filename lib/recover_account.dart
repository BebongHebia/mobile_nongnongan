import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class RecoverAccountPage extends StatefulWidget {
  final String name;
  final int userId;

  RecoverAccountPage({required this.name, required this.userId});

  @override
  _RecoverAccountPageState createState() => _RecoverAccountPageState();
}

class _RecoverAccountPageState extends State<RecoverAccountPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _updatePassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

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

      // Update password in the database
      await conn.query(
        'UPDATE users SET user_password = ? WHERE id = ?',
        [password, widget.userId],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );

      // Close connection
      await conn.close();

      // Navigate back to login
      Navigator.pop(context);
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
        title: Text('Recover Account'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${widget.name}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),

              // Confirm Password TextField
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),

              // Update Password Button
              ElevatedButton(
                onPressed: _updatePassword,
                child: Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
