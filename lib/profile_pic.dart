import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart';
import 'package:image/image.dart' as img;

class ProfilePic extends StatefulWidget {
  final int userId;
  final String complete_name;
  final String phone;

  ProfilePic({required this.userId, required this.complete_name, required this.phone});

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  Uint8List? profilePicture;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
  var settings = ConnectionSettings(
    host: 'sql12.freesqldatabase.com',
    port: 3306,
    user: 'sql12745725',
    db: 'sql12745725',
    password: 'dexel9dQ9R',
  );

  try {
    final conn = await MySqlConnection.connect(settings);
    final results = await conn.query('SELECT profile FROM users WHERE id = ?', [widget.userId]);

    if (results.isNotEmpty && results.first['profile'] != null) {
      final blob = results.first['profile'];

      // Check if the blob is actually of type Blob
      if (blob is Blob) {
        final imageData = await blob.toBytes(); // Convert Blob to byte array
        print("Image size: ${imageData.length} bytes");

        // Check if the byte data length is reasonable
        if (imageData.isNotEmpty && imageData.length < 1000000) {
          // Proceed to set the state with the valid image data
          setState(() {
            profilePicture = Uint8List.fromList(imageData); // Convert List<int> to Uint8List
          });
        } else {
          print("Image data is empty or too large.");
          setState(() {
            profilePicture = null;
          });
        }
      } else {
        print("Unexpected blob type: ${blob.runtimeType}");
        setState(() {
          profilePicture = null;
        });
      }
    } else {
      print("No profile picture found for userId: ${widget.userId}");
      setState(() {
        profilePicture = null;
      });
    }

    await conn.close();
  } catch (e) {
    print("Error fetching profile picture: $e");
    setState(() {
      profilePicture = null;
    });
  }
}




  Future<void> _updateProfilePicture(Uint8List imageBytes) async {
    var settings = ConnectionSettings(
      host: 'sql12.freesqldatabase.com',
      port: 3306,
      user: 'sql12745725',
      db: 'sql12745725',
      password: 'dexel9dQ9R',
    );

    try {
      // Decode the image based on its type (JPEG, PNG, etc.)
      img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        // Convert to PNG to ensure consistent format
        Uint8List pngImage = Uint8List.fromList(img.encodePng(image));

        final conn = await MySqlConnection.connect(settings);

        // Update the profile picture in the database
        final result = await conn.query(
          'UPDATE users SET profile = ? WHERE id = ?',
          [pngImage, widget.userId],
        );

        // Check if the update was successful
        if (result.affectedRows != null && result.affectedRows! > 0) {
          setState(() {
            profilePicture = pngImage;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile picture updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No changes made to profile picture.')),
          );
        }

        await conn.close();
      } else {
        print("Failed to decode image.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image.')),
        );
      }
    } catch (e) {
      print("Error updating profile picture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            profilePicture != null
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
            SizedBox(height: 20),
            Text(
              widget.complete_name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              widget.phone,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);

                if (image != null) {
                  final imageBytes = await image.readAsBytes();
                  await _updateProfilePicture(imageBytes);
                }
              },
              child: Text('Update Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
