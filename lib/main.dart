// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:pinitui/api_service.dart';
// import 'package:pinitui/welcome_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // <-- Make sure this exists after flutterfire configure

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PINIT',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const FingerPrintScreen(),
//     );
//   }
// }

// class FingerPrintScreen extends StatefulWidget {
//   const FingerPrintScreen({super.key});

//   @override
//   State<FingerPrintScreen> createState() => _FingerPrintScreenState();
// }

// class _FingerPrintScreenState extends State<FingerPrintScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> scaleAnimation;

//   final LocalAuthentication auth = LocalAuthentication();
//   //final String baseUrl = "http://192.168.1.7:8000";

//   bool isLoading = false;
//   bool isAuthenticated = false;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 120),
//     );

//     scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
//   }

//   // 🔥 CALL FASTAPI
//   Future<String?> registerUser() async {
//     try {
//       print("CALLING REGISTER API...");

//       final response = await http.post(
//         Uri.parse("${ApiService.baseUrl}/register"),
//       );

//       print("STATUS: ${response.statusCode}");
//       print("BODY: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data["unique_id"];
//       } else {
//         print("API Error: ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("REGISTER ERROR: $e");
//       return null;
//     }
//   }

//   Future<String?> loginUser(String uniqueId) async {
//     try {
//       print("CALLING LOGIN API...");

//       // final response = await http.post(
//       //   Uri.parse("http://192.168.1.18:8000/login"),
//       //   headers: {"Content-Type": "application/json"},
//       //   body: jsonEncode({"unique_id": uniqueId}),
//       // );
//       final response = await http.post(
//         Uri.parse("${ApiService.baseUrl}/login"),
//         body: {"unique_id": uniqueId},
//       );
//       print("LOGIN STATUS: ${response.statusCode}");
//       print("LOGIN BODY: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data["unique_id"];
//       } else {
//         print("Login API Error: ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("LOGIN ERROR: $e");
//       return null;
//     }
//   }

//   Future<void> authenticate() async {
//     try {
//       setState(() => isLoading = true);

//       bool didAuthenticate = await auth.authenticate(
//         localizedReason: 'Use fingerprint to login',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//         ),
//       );

//       if (didAuthenticate) {
//         setState(() => isAuthenticated = true);

//         // 🔥 CALL API HERE
//         String? uniqueId = await registerUser();

//         await Future.delayed(const Duration(seconds: 1));

//         if (!mounted) return;

//         if (uniqueId != null) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => WelcomeScreen(uniqueId: uniqueId),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Failed to generate ID")),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Authentication failed")));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void _showManualLoginDialog() {
//     final TextEditingController idController = TextEditingController();

//     final parentContext = context; // ✅ SAVE THIS

//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text("Enter Unique ID"),
//         content: TextField(
//           controller: idController,
//           keyboardType: TextInputType.text,
//           maxLength: 8,
//           decoration: const InputDecoration(
//             hintText: "Enter Your Unique-ID",
//             counterText: "",
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               String inputId = idController.text.trim();

//               if (inputId.length == 8) {
//                 Navigator.pop(dialogContext); // ✅ close dialog safely

//                 setState(() => isLoading = true);

//                 String? result = await loginUser(inputId);

//                 setState(() => isLoading = false);

//                 if (!mounted) return;

//                 if (result != null) {
//                   Navigator.of(parentContext).pushReplacement(
//                     // ✅ FIXED
//                     MaterialPageRoute(
//                       builder: (_) => WelcomeScreen(uniqueId: result),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(parentContext).showSnackBar(
//                     const SnackBar(content: Text("Invalid Unique ID")),
//                   );
//                 }
//               }
//             },
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               String inputId = idController.text.trim();

//               if (inputId.length == 8) {
//                 Navigator.pop(context); // close dialog

//                 setState(() => isLoading = true);

//                 String? result = await loginUser(inputId);

//                 setState(() => isLoading = false);

//                 if (!mounted) return; // ✅ IMPORTANT FIX

//                 if (result != null) {
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(
//                       builder: (_) => WelcomeScreen(uniqueId: result),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Invalid Unique ID")),
//                   );
//                 }
//               }
//             },
//             child: const Text("Login"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, size: 30, color: Colors.black87),
//             onSelected: (value) {
//               if (value == 'manual_login') {
//                 _showManualLoginDialog();
//               }
//             },
//             itemBuilder: (BuildContext context) {
//               return [
//                 const PopupMenuItem(
//                   value: 'manual_login',
//                   child: Text("Login with ID"),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: GestureDetector(
//           onTap: () async {
//             await _controller.forward();
//             await authenticate();
//             await _controller.reverse();
//           },
//           child: ScaleTransition(
//             scale: scaleAnimation,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   child: Icon(
//                     Icons.fingerprint,
//                     size: 90,
//                     color: isAuthenticated ? Colors.green : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   isAuthenticated
//                       ? "Authentication Successful"
//                       : "Touch Fingerprint to Register",
//                   style: const TextStyle(color: Colors.black54, fontSize: 18),
//                 ),
//                 const SizedBox(height: 20),
//                 if (isLoading) const CircularProgressIndicator(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'package:pinitui/api_service.dart';
import 'package:pinitui/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedId = prefs.getString("unique_id");

  runApp(MyApp(savedId));
}

class MyApp extends StatelessWidget {
  final String? savedId;

  const MyApp(this.savedId, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PINIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: savedId == null
          ? const FingerPrintScreen()
          : WelcomeScreen(uniqueId: savedId!),
    );
  }
}

class FingerPrintScreen extends StatefulWidget {
  const FingerPrintScreen({super.key});

  @override
  State<FingerPrintScreen> createState() => _FingerPrintScreenState();
}

class _FingerPrintScreenState extends State<FingerPrintScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scaleAnimation;

  final LocalAuthentication auth = LocalAuthentication();

  bool isLoading = false;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  Future<String?> registerUser() async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/register"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["unique_id"];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> loginUser(String uniqueId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/login"),
        body: {"unique_id": uniqueId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["unique_id"];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLogin(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("unique_id", id);
  }

  Future<void> authenticate() async {
    try {
      setState(() => isLoading = true);

      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Use fingerprint to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        String? uniqueId = await registerUser();

        if (uniqueId != null) {
          await saveLogin(uniqueId);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => WelcomeScreen(uniqueId: uniqueId),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Authentication failed")));
    }

    setState(() => isLoading = false);
  }

  void _showManualLoginDialog() {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Enter Unique ID"),
        content: TextField(
          controller: idController,
          maxLength: 8,
          decoration: const InputDecoration(
            hintText: "Enter Unique ID",
            counterText: "",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          ElevatedButton(
            child: const Text("Login"),
            onPressed: () async {
              String inputId = idController.text.trim();

              if (inputId.length == 8) {
                Navigator.pop(dialogContext);

                setState(() => isLoading = true);

                String? result = await loginUser(inputId);

                setState(() => isLoading = false);

                if (result != null) {
                  await saveLogin(result);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WelcomeScreen(uniqueId: result),
                    ),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid Unique ID")),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'manual_login') {
                _showManualLoginDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'manual_login',
                child: Text("Login with ID"),
              ),
            ],
          ),
        ],
      ),

      body: Center(
        child: GestureDetector(
          onTap: () async {
            await _controller.forward();
            await authenticate();
            await _controller.reverse();
          },
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 90,
                  color: isAuthenticated ? Colors.green : Colors.black87,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Touch Fingerprint to Login",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                if (isLoading) const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
