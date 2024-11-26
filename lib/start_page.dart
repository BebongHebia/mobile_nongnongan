import 'package:flutter/material.dart';
import 'package:nongnongan_mobile/login.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo
              Image.asset(
                'assets/images/undraw_login.png',  // Replace with your actual logo path
                height: 150,  // Adjust the size of the logo
              ),
              SizedBox(height: 30),  // Add space between the logo and text

              // Main Title
              Text(
                'Old Nongnongan Daily Transaction System',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',  // Optional: Use your desired font
                ),
                textAlign: TextAlign.center,
              ),

              // Subtitle
              SizedBox(height: 10),
              Text(
                'Seamless Transactions, Every Day.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),  // Add space between text and button

              // Continue Button
              ElevatedButton(
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), backgroundColor: Colors.blue, // Button background color
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
