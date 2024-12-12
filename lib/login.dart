import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:nongnongan_mobile/admin_board.dart';
import 'package:nongnongan_mobile/forgot_password.dart';
import 'package:nongnongan_mobile/home_page.dart';
import 'create_account.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      // Define the connection settings
      final connectionSettings = ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12751398',
        db: 'sql12751398',
        password: 'T8m87TYNGK',
      );

      // Establish a connection
      final conn = await MySqlConnection.connect(connectionSettings);

      // Query the database to check if the user exists
      var results = await conn.query(
        'SELECT * FROM users WHERE username = ? AND user_password = ?',
        [username, password], // Ensure you hash passwords in a real application
      );

      if (results.isNotEmpty) {
        var userRow = results.first;
        String role = userRow['role'];

        if (role == 'User') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userId: userRow['id'],
                complete_name: userRow['complete_name'],
                phone: userRow['phone'],
              ),
            ),
          );
        } else if (role == 'Admin' || role == 'Staff-Secretary') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminBoard(
                userId: userRow['id'],
                complete_name: userRow['complete_name'],
              ),
            ),
          );
        }

        // Login successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
        // Navigate to the home page or dashboard
      } else {
        // Login failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }

      // Close the connection
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
      body: Container(
        color: Color(0xFF3A6C7C), // Background color #3A6C7C
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png', // Replace with your actual logo path
                  height: 200, // Adjust the size of the logo
                ),
                SizedBox(height: 30),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),

                // Username TextField
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle:
                        TextStyle(color: Colors.white), // White label text
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[800], // Dark background color
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white), // White border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue), // Blue border on focus
                    ),
                  ),
                  style: TextStyle(color: Colors.white), // White text
                ),
                SizedBox(height: 20),

                // Password TextField
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle:
                        TextStyle(color: Colors.white), // White label text
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[800], // Dark background color
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white), // White border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue), // Blue border on focus
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Colors.white), // White text
                ),

                // Stretched Login Button with Adjustments
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 5), // Padding for height
                      elevation: 2, // Elevation for a raised look
                    ),
                    onPressed: _login,
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold), // Text style
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Links for "Create Account" and "Forgot Password"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAccountPage()),
                        );
                      },
                      child: Text('Create Account',
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: Text('Forgot Password?',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
