import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:nongnongan_mobile/announcement.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nongnongan_mobile/home_page.dart';
import 'package:nongnongan_mobile/login.dart';
import 'package:nongnongan_mobile/org_chart.dart';
import 'package:nongnongan_mobile/requests.dart';

class KapCalendar extends StatefulWidget {
  final int userId;
  final String complete_name;
  final String phone;

  KapCalendar({required this.userId, required this.complete_name, required this.phone});

  @override
  _KapCalendarState createState() => _KapCalendarState();
}

class _KapCalendarState extends State<KapCalendar> {
  late Future<List<Map<String, dynamic>>> _calendarActsFuture;

  // Map to store events by date (only day part)
  Map<DateTime, List<Map<String, String>>> _events = {};
  List<Map<String, String>> _selectedDayEvents = [];

  // Fetch the calendar data from the database
  Future<List<Map<String, dynamic>>> _fetchCalendarActs() async {
    try {
      final conn = await MySqlConnection.connect(ConnectionSettings(
        host: 'sql12.freesqldatabase.com',
        port: 3306,
        user: 'sql12745725',
        db: 'sql12745725',
        password: 'dexel9dQ9R',
      ));

      var results = await conn.query('SELECT * FROM calendar_acts ORDER BY date ASC');

      List<Map<String, dynamic>> calendarActs = [];
      for (var row in results) {
        DateTime date = DateTime.parse(row['date']);
        String activity = row['activity'];

        // Strip time part to ensure we only compare dates
        DateTime eventDate = DateTime(date.year, date.month, date.day);

        // Organize events by date (only the date part)
        if (_events[eventDate] == null) {
          _events[eventDate] = [];
        }

        // Add activity with date to the map
        _events[eventDate]?.add({
          'activity': activity,
          'date': date.toString(),
        });

        calendarActs.add({
          'id': row['id'],
          'activity': row['activity'],
          'date': row['date'],
          'status': row['status'],
        });
      }

      await conn.close();
      return calendarActs;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _calendarActsFuture = _fetchCalendarActs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kapitan Calendar'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // User Account Header
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
            // Sidebar options
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(
                    userId: widget.userId,
                    complete_name: widget.complete_name,
                    phone: widget.phone,
                  )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.request_page),
              title: Text('My Request'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Requests(
                    userId: widget.userId,
                    complete_name: widget.complete_name,
                    phone: widget.phone,
                  )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Announcements'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Announcements(
                    userId: widget.userId,
                    complete_name: widget.complete_name,
                    phone: widget.phone,
                  )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Kap Calendar'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Organizational Chart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrgChart(
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
        future: _calendarActsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No calendar events found.'));
          }

          return Column(
            children: [
              // Calendar widget
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),
                eventLoader: (day) {
                  // Return events for the specific day
                  DateTime eventDate = DateTime(day.year, day.month, day.day);
                  return _events[eventDate]?.map((event) => event['activity'] ?? '')?.toList() ?? [];
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  // Change event dot color to red
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red, // Change to red
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    // Update the list of events for the selected day
                    DateTime eventDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    _selectedDayEvents = _events[eventDate] ?? [];
                  });
                },
              ),
              // Display events for selected day with activity and date
              _selectedDayEvents.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _selectedDayEvents.length,
                        itemBuilder: (context, index) {
                          var event = _selectedDayEvents[index];
                          return ListTile(
                            title: Text(event['activity'] ?? 'No activity'),
                            subtitle: Text(event['date'] ?? 'No date'),
                          );
                        },
                      ),
                    )
                  : Center(child: Text('No events for selected day.')),
            ],
          );
        },
      ),
    );
  }
}
