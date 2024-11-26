import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:nongnongan_mobile/announcement.dart';
import 'package:nongnongan_mobile/kap_calendar.dart';
import 'package:nongnongan_mobile/org_chart.dart';
import 'package:nongnongan_mobile/requests.dart';
import 'package:nongnongan_mobile/login.dart'; // Import the login page
import 'package:nongnongan_mobile/profile_pic.dart'; // Import the profile picture page

class HomePage extends StatefulWidget {
  final int userId;
  final String complete_name;
  final String phone;

  HomePage({required this.userId, required this.complete_name, required this.phone});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? profilePicture;

  @override
  void initState() {
    super.initState();
    _fetchProfilePicture();
  }

  Future<void> _fetchProfilePicture() async {
    var settings = ConnectionSettings(
      host: 'sql12.freesqldatabase.com',
      port: 3306,
      user: 'sql12745725',
      db: 'sql12745725',
      password: 'dexel9dQ9R',
    );

    try {
      final conn = await MySqlConnection.connect(settings);
      final results = await conn.query(
        'SELECT profile FROM users WHERE id = ?',
        [widget.userId],
      );

      if (results.isNotEmpty) {
        setState(() {
          profilePicture = results.first['profile'] as Uint8List?;
        });
      }

      await conn.close();
    } catch (e) {
      print("Error fetching profile picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.complete_name),
              accountEmail: Text(widget.phone),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePic(
                        userId: widget.userId,
                        complete_name: widget.complete_name,
                        phone: widget.phone,
                      ),
                    ),
                  ).then((_) {
                    // Refresh profile picture after returning from ProfilePic page
                    _fetchProfilePicture();
                  });
                },
                child: profilePicture != null
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(profilePicture!),
                      )
                    : CircleAvatar(
                        child: Text(
                          widget.complete_name[0],
                          style: TextStyle(fontSize: 40.0),
                        ),
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
                      phone: widget.phone,
                    ),
                  ),
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
                      phone: widget.phone,
                    ),
                  ),
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
                      phone: widget.phone,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Kap Calendar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KapCalendar(
                      userId: widget.userId,
                      complete_name: widget.complete_name,
                      phone: widget.phone,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Organizational Chart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrgChart(
                      userId: widget.userId,
                      complete_name: widget.complete_name,
                      phone: widget.phone,
                    ),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome, ${widget.complete_name}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
