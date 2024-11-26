import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'login.dart'; // Import your Login page

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bdayController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final List<int> _purokOptions = List<int>.generate(19, (index) => index + 1);
  int? _selectedPurok;
  String _selectedSex = 'Male';
  DateTime? _selectedDate;

  Future<void> _registerAccount() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      final connectionSettings = ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12745725',
        db: 'sql12745725',
        password: 'dexel9dQ9R',
      );

      final conn = await MySqlConnection.connect(connectionSettings);

      var result = await conn.query(
        'INSERT INTO users (complete_name, purok, sex, bday, phone, role, status, username, user_password, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          _nameController.text,
          _selectedPurok,
          _selectedSex,
          _bdayController.text,
          _phoneController.text,
          'User',
          'Active',
          _usernameController.text,
          _passwordController.text,
          '00000000',
        ],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully')),
      );

      await conn.close();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _bdayController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Complete Name TextField
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Complete Name',
                  ),
                ),

                // Purok Dropdown
                SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: _selectedPurok,
                  items: _purokOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('Purok $value'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPurok = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Purok',
                  ),
                ),

                // Sex Dropdown
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  items: <String>['Male', 'Female', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSex = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sex',
                  ),
                ),

                // Birthday Date Picker
                SizedBox(height: 20),
                TextFormField(
                  controller: _bdayController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Birthday',
                    hintText: _selectedDate == null
                        ? 'Select your birthday'
                        : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
                  ),
                  onTap: () => _selectDate(context),
                ),

                // Phone Number TextField
                SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Phone Number',
                  ),
                ),

                // Username TextField
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Username',
                  ),
                ),

                // Password TextField
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Password',
                  ),
                ),

                // Confirm Password TextField
                SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                ),

                // Create Account Button
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _registerAccount,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Create Account',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
