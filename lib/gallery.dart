import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pinitui/api_service.dart';
import 'package:share_plus/share_plus.dart';

class GalleryScreen extends StatefulWidget {
  final String uniqueId;

  const GalleryScreen({super.key, required this.uniqueId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> images = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  // ---------------- SHARE IMAGE FILE ----------------
  Future<void> shareImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.png');

      await file.writeAsBytes(response.bodyBytes);

      await Share.shareXFiles([XFile(file.path)], text: "Check out this image");
    } catch (e) {
      print("SHARE ERROR: $e");
    }
  }

  // ---------------- FETCH IMAGES ----------------
  Future<void> fetchImages() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/get-images/${widget.uniqueId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          images = List<Map<String, dynamic>>.from(data["images"]);
          loading = false;
        });
      } else {
        loading = false;
        setState(() {});
      }
    } catch (e) {
      print("FETCH ERROR: $e");
      loading = false;
      setState(() {});
    }
  }

  // ---------------- DELETE IMAGE ----------------
  Future<void> deleteImage(String imageUrl) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiService.baseUrl}/delete-image"),
        body: {"image_url": imageUrl},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image Deleted")));

        fetchImages();
        Navigator.pop(context);
      }
    } catch (e) {
      print("DELETE ERROR: $e");
    }
  }

  // // ---------------- SHOW INFO ----------------
  // void showInfo(String createdAt) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Image Info"),
  //       content: Text("Uploaded on:\n$createdAt"),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void showInfo(String createdAt, String deviceId, String deviceModel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Image Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Uploaded on:\n$createdAt"),
            const SizedBox(height: 10),
            Text("Device Model:\n$deviceModel"),
            const SizedBox(height: 10),
            Text("Device ID:\n$deviceId"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ---------------- FULL IMAGE VIEW ----------------
  //void openFullImage(String url, String createdAt)
  void openFullImage(
    String url,
    String createdAt,
    String deviceId,
    String deviceModel,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // DELETE
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        deleteImage(url);
                      },
                    ),

                    // SHARE IMAGE FILE
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        shareImage(url);
                      },
                    ),

                    // INFO
                    IconButton(
                      icon: const Icon(Icons.info, color: Colors.white),
                      onPressed: () {
                        showInfo(createdAt, deviceId, deviceModel);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- BUILD URL SAFELY ----------------
  String buildImageUrl(String imagePath) {
    if (imagePath.startsWith("http")) {
      return imagePath;
    } else {
      return "${ApiService.baseUrl}/$imagePath";
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gallery")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
          ? const Center(child: Text("No Images Found"))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final imagePath = images[index]["image_url"] ?? "";
                final createdAt = images[index]["created_at"] ?? "";
                final deviceId = images[index]["device_id"] ?? "";
                final deviceModel = images[index]["device_model"] ?? "";

                final url = buildImageUrl(imagePath);

                print("IMAGE URL -> $url");

                return GestureDetector(
                  // onTap: () => openFullImage(url, createdAt),
                  onTap: () =>
                      openFullImage(url, createdAt, deviceId, deviceModel),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print("IMAGE LOAD ERROR -> $url");
                        return const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
