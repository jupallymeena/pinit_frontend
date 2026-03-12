import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'package:pinitui/apiservice.dart';
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
