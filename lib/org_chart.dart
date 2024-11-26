import 'package:flutter/material.dart';
import 'package:nongnongan_mobile/announcement.dart';
import 'package:nongnongan_mobile/home_page.dart';
import 'package:nongnongan_mobile/kap_calendar.dart';
import 'package:nongnongan_mobile/login.dart';
import 'package:nongnongan_mobile/requests.dart';

class OrgChart extends StatelessWidget {
  final int userId; // Add userId field
  final String complete_name;
  final String phone;

  OrgChart({required this.userId, required this.complete_name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizational Chart'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // User Account Header
            UserAccountsDrawerHeader(
              accountName: Text(complete_name),
              accountEmail: Text(phone), // You can replace with user email if available
              currentAccountPicture: CircleAvatar(
                child: Text(
                  complete_name[0], // Display first letter of the name
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            // Sidebar options
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  HomePage(userId: userId, complete_name: complete_name, phone: phone,)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.request_page),
              title: Text('My Request'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  Requests(userId: userId, complete_name: complete_name, phone: phone,)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Announcements'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  Announcements(userId: userId, complete_name: complete_name, phone: phone,)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Kap Calendar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  KapCalendar(userId: userId, complete_name: complete_name, phone: phone,)),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Organizational Chart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  OrgChart(userId: userId, complete_name: complete_name, phone: phone,)),
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
                  MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to the login page
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // You can add additional content here if needed
          ],
        ),
      ),
    );
  }
}
