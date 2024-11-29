import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:nongnongan_mobile/announcement.dart';
import 'package:nongnongan_mobile/kap_calendar.dart';
import 'package:nongnongan_mobile/requests.dart';
import 'package:nongnongan_mobile/login.dart'; // Import the login page
import 'package:nongnongan_mobile/profile_pic.dart'; // Import the profile picture page

class HomePage extends StatefulWidget {
  final int userId;
  final String complete_name;
  final String phone;

  HomePage(
      {required this.userId, required this.complete_name, required this.phone});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? profilePicture;
  String? latestTransactionStatus; // To store the latest transaction status
  String? pick_up_sched; // To store the latest transaction status
  List<Map<String, dynamic>> latestTransactions =
      []; // List to store latest 5 transactions

  final List<String> _slideshowImages = [
    'assets/images/slideshow/image_1.jpg',
    'assets/images/slideshow/image_2.jpg',
    'assets/images/slideshow/image_3.jpg',
    'assets/images/slideshow/image_4.jpg',
    'assets/images/slideshow/image_5.jpg',
  ];

  late final PageController _pageController;
  late Timer _slideshowTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _fetchProfilePicture();
    _fetchLatestTransactionStatus(); // Fetch the latest transaction status
    _fetchLatestTransactions(); // Fetch the 5 latest transactions

    _slideshowTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = (_currentPage + 1) % _slideshowImages.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideshowTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchProfilePicture() async {
    var settings = ConnectionSettings(
      host: 'sql12.freesqldatabase.com',
      port: 3306,
      user: 'sql12747600',
      db: 'sql12747600',
      password: 'IypDAxHngN',
    );

    try {
      final conn = await MySqlConnection.connect(settings);
      final results = await conn
          .query('SELECT profile FROM users WHERE id = ?', [widget.userId]);

      if (results.isNotEmpty && results.first['profile'] != null) {
        final blob = results.first['profile'];
        if (blob is Blob) {
          final imageData = await blob.toBytes();
          if (imageData.isNotEmpty && imageData.length < 1000000) {
            setState(() {
              profilePicture = Uint8List.fromList(imageData);
            });
          } else {
            setState(() {
              profilePicture = null;
            });
          }
        } else {
          setState(() {
            profilePicture = null;
          });
        }
      } else {
        setState(() {
          profilePicture = null;
        });
      }

      await conn.close();
    } catch (e) {
      setState(() {
        profilePicture = null;
      });
    }
  }

  Future<void> _fetchLatestTransactionStatus() async {
    var settings = ConnectionSettings(
      host: 'sql12.freesqldatabase.com',
      port: 3306,
      user: 'sql12747600',
      db: 'sql12747600',
      password: 'IypDAxHngN',
    );

    try {
      final conn = await MySqlConnection.connect(settings);

      // Query to get the latest transaction
      final results = await conn.query(
        'SELECT status, schedule FROM transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT 1',
        [widget.userId],
      );

      if (results.isNotEmpty) {
        final row = results.first;
        setState(() {
          latestTransactionStatus = row['status'] ?? 'No status available';
          pick_up_sched = row['schedule'] ?? 'No schedule available';
        });
      } else {
        setState(() {
          latestTransactionStatus = 'No transactions found';
          pick_up_sched = 'No schedule available';
        });
      }

      await conn.close();
    } catch (e) {
      setState(() {
        latestTransactionStatus = 'Error fetching status';
        pick_up_sched = 'Error fetching schedule';
      });
    }
  }

  Future<void> _fetchLatestTransactions() async {
    var settings = ConnectionSettings(
      host: 'sql12.freesqldatabase.com',
      port: 3306,
      user: 'sql12747600',
      db: 'sql12747600',
      password: 'IypDAxHngN',
    );

    try {
      final conn = await MySqlConnection.connect(settings);

      // Query to get the latest 5 transactions
      final results = await conn.query(
        'SELECT status, schedule, created_at FROM transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT 5',
        [widget.userId],
      );

      List<Map<String, dynamic>> transactions = [];
      for (var row in results) {
        transactions.add({
          'status': row['status'] ?? 'No status available',
          'schedule': row['schedule'] ?? 'No schedule available',
          'created_at': row['created_at'],
        });
      }

      setState(() {
        latestTransactions = transactions;
      });

      await conn.close();
    } catch (e) {
      setState(() {
        latestTransactions = [];
      });
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
                    _fetchProfilePicture();
                  });
                },
                child: profilePicture != null
                    ? CircleAvatar(
                        radius: 70,
                        backgroundImage: MemoryImage(profilePicture!),
                      )
                    : CircleAvatar(
                        radius: 70,
                        child: Text(
                          widget.complete_name.isNotEmpty
                              ? widget.complete_name[0]
                              : 'A',
                          style: TextStyle(fontSize: 40),
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
              onTap: () {},
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
      body: SingleChildScrollView(
        // Add this to make the body scrollable
        child: Column(
          children: [
            // Slideshow
            SizedBox(
              height: 200,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 6.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slideshowImages.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _slideshowImages[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            // Latest Transaction Status
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                border: Border.all(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Transaction Status:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    latestTransactionStatus ?? 'Loading...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    "Schedule : " + (pick_up_sched ?? 'Loading...'),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Divider(),
            Text(
              '5 Latest Transactions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            latestTransactions.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          Colors.blue), // Header background color
                      columns: [
                        DataColumn(
                          label: Text('Status',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Schedule',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Date',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: latestTransactions.map((transaction) {
                        return DataRow(cells: [
                          DataCell(
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Text(transaction['status'] ?? 'N/A'),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Text(transaction['schedule'] ?? 'N/A'),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Text(transaction['created_at']
                                  .toString()
                                  .substring(0, 10)),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
            Column(
              children: [
                Divider(
                  color: Colors.grey.shade300, // Border color between rows
                  thickness: 1, // Border thickness
                ),
                // You can repeat the above row of the DataTable with the Divider for each row
              ],
            ),
            
            ElevatedButton(
              onPressed: () => {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Requests(
                      userId: widget.userId,
                      complete_name: widget.complete_name,
                      phone: widget.phone,
                    ),
                  ),
                )
              },
              child: Text('View all my transactions'),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
