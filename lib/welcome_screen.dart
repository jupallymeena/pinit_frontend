// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:pinitui/api_service.dart';
// import 'package:pinitui/gallery.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'main.dart';

// class WelcomeScreen extends StatefulWidget {
//   final String uniqueId;

//   const WelcomeScreen({super.key, required this.uniqueId});

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final ImagePicker _picker = ImagePicker();
//   bool _loading = false;

//   // 📷 CAMERA
//   Future<void> _openCamera() async {
//     final image = await _picker.pickImage(source: ImageSource.camera);

//     if (image != null) {
//       await _uploadImage(image);
//     }
//   }

//   Future<void> _uploadImage(XFile image) async {
//     setState(() => _loading = true);

//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse("${ApiService.baseUrl}/upload-image/"),
//       );

//       request.fields['unique_id'] = widget.uniqueId;
//       request.files.add(await http.MultipartFile.fromPath('file', image.path));

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Uploaded to DB ✅")));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Upload failed: ${response.statusCode} ❌")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Upload error: $e ❌")));
//     }

//     setState(() => _loading = false);
//   }

//   // 📂 OPEN GALLERY
//   void _openGallery() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => GalleryScreen(uniqueId: widget.uniqueId),
//       ),
//     );
//   }

//   // 🗑 DELETE USER API
//   Future<void> _deleteUser() async {
//     try {
//       final response = await http.delete(
//         Uri.parse("${ApiService.baseUrl}/delete-user/${widget.uniqueId}"),
//       );

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("User Deleted Successfully")),
//         );

//         Navigator.popUntil(context, (route) => route.isFirst);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Delete Failed: ${response.statusCode}")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   // CONFIRM DELETE
//   void _confirmDelete() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete User"),
//         content: const Text(
//           "Are you sure you want to delete this user and all images?",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteUser();
//             },
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//   }

//   // PROFILE MENU
//   void _showProfileMenu() {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => SafeArea(
//         child: Wrap(
//           children: [
//             // children: [
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: Text("User ID: ${widget.uniqueId}"),
//             ),

//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text("Logout"),
//               onTap: () async {
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 await prefs.remove("unique_id");

//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => const FingerPrintScreen()),
//                   (route) => false,
//                 );
//               },
//             ),

//             ListTile(
//               leading: const Icon(Icons.delete, color: Colors.red),
//               title: const Text("Delete User"),
//               onTap: () {
//                 Navigator.pop(context);
//                 _confirmDelete();
//               },
//             ),
//           ],
//           // ListTile(
//           //   leading: const Icon(Icons.person),
//           //   title: Text("User ID: ${widget.uniqueId}"),
//           // ),
//           // ListTile(
//           //   leading: const Icon(Icons.delete, color: Colors.red),
//           //   title: const Text("Delete User"),
//           //   onTap: () {
//           //     Navigator.pop(context);
//           //     _confirmDelete();
//           //   },
//           // ),
//           // ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Welcome"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: _showProfileMenu,
//           ),
//         ],
//       ),

//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 40),

//             const Text(
//               "Your Unique ID",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               widget.uniqueId,
//               style: const TextStyle(fontSize: 18, color: Colors.grey),
//             ),

//             const Spacer(),

//             if (_loading) const CircularProgressIndicator(),

//             const SizedBox(height: 20),

//             Padding(
//               padding: const EdgeInsets.only(bottom: 30),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   BottomIcon(icon: Icons.image, onTap: _openGallery),
//                   BottomIcon(icon: Icons.camera_alt, onTap: _openCamera),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BottomIcon extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const BottomIcon({super.key, required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 65,
//         height: 65,
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.black,
//         ),
//         child: Icon(icon, color: Colors.white),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pinitui/api_service.dart';
import 'package:pinitui/gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class WelcomeScreen extends StatefulWidget {
  final String uniqueId;

  const WelcomeScreen({super.key, required this.uniqueId});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final android = await deviceInfo.androidInfo;

    return {"device_id": android.id, "device_model": android.model};
  }

  Future<void> _openCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await _uploadImage(image);
    }
  }

  Future<void> _uploadImage(XFile image) async {
    setState(() => _loading = true);

    try {
      final device = await getDeviceInfo();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiService.baseUrl}/upload-image/"),
      );

      request.fields['unique_id'] = widget.uniqueId;
      request.fields['device_id'] = device["device_id"]!;
      request.fields['device_model'] = device["device_model"]!;

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Uploaded successfully")));
      }
    } catch (e) {
      print(e);
    }

    setState(() => _loading = false);
  }

  void _openGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GalleryScreen(uniqueId: widget.uniqueId),
      ),
    );
  }

  Future<void> _deleteUser() async {
    final response = await http.delete(
      Uri.parse("${ApiService.baseUrl}/delete-user/${widget.uniqueId}"),
    );

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("unique_id");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FingerPrintScreen()),
        (route) => false,
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Delete user and all images?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text("User ID: ${widget.uniqueId}"),
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove("unique_id");

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const FingerPrintScreen()),
                (route) => false,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete User"),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showProfileMenu,
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 40),

          const Text(
            "Your Unique ID",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(widget.uniqueId),

          const Spacer(),

          if (_loading) const CircularProgressIndicator(),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BottomIcon(icon: Icons.image, onTap: _openGallery),

              BottomIcon(icon: Icons.camera_alt, onTap: _openCamera),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class BottomIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const BottomIcon({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 65,
        height: 65,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
