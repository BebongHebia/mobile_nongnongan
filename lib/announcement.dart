import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:nongnongan_mobile/home_page.dart';
import 'package:nongnongan_mobile/kap_calendar.dart';
import 'package:nongnongan_mobile/login.dart';
import 'package:nongnongan_mobile/requests.dart';
import 'package:nongnongan_mobile/view_announcement.dart'; // Import the view screen for announcements

class Announcements extends StatefulWidget {
  final int userId;
  final String complete_name;
  final String phone;

  Announcements({
    required this.userId,
    required this.complete_name,
    required this.phone,
  });

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  late Future<List<Map<String, dynamic>>> _announcementsFuture;

  Future<List<Map<String, dynamic>>> _fetchAnnouncements() async {
    try {
      final conn = await MySqlConnection.connect(ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12747600',
        db: 'sql12747600',
        password: 'IypDAxHngN',
      ));

      var results = await conn.query('SELECT * FROM announcements ORDER BY created_at DESC');

      List<Map<String, dynamic>> announcements = [];
      for (var row in results) {
        announcements.add({
          'id': row['id'],
          'added_by': row['added_by'],
          'title': row['title'],
          'details': row['details']?.toString() ?? 'No details available', // Convert BLOB to String
        });
      }

      await conn.close();
      return announcements;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _announcementsFuture = _fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
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
              onTap: () {},  // Don't navigate anywhere here as we're already on the Announcements page
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
                          phone: widget.phone)),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No announcements found.'));
          }

          final announcements = snapshot.data!;
          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              String truncatedDetails = announcement['details']
                      .toString()
                      .length > 50
                  ? '${announcement['details'].toString().substring(0, 50)}...'
                  : announcement['details'].toString();

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(Icons.announcement, color: Colors.blue), // Add announcement icon
                  title: Text(announcement['title']),
                  subtitle: Text(truncatedDetails),
                  trailing: Text('By: ${announcement['added_by']}'),
                  onTap: () {
                    // Navigate to the detail page, passing the announcement data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAnnouncement(
                          announcementId: announcement['id'],
                          title: announcement['title'],
                          details: announcement['details'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
