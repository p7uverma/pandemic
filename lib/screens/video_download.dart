import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class VideoDownloadPage extends StatefulWidget {
  const VideoDownloadPage({Key? key}) : super(key: key); // Fix the constructor

  @override
  State<VideoDownloadPage> createState() => _VideoDownloadPageState();
}

class _VideoDownloadPageState extends State<VideoDownloadPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isValidUrl = true;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _downloadVideo() async {
    final url = _urlController.text.trim();
    if (Uri.parse(url).isAbsolute) {
      // final status = await FlutterDownloader.initialize();
      // if (status == DownloadTaskStatus.undefined) {
      //   print('Could not initialize Flutter Downloader');
      //   return;
      // }

      final appDocumentsDirectory = await getApplicationDocumentsDirectory();
      final savedDir = appDocumentsDirectory.path;

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        showNotification: true,
        openFileFromNotification: true,
        fileName: 'video.mp4', // Specify the desired file name
        allowCellular: true,
        saveInPublicStorage: true,
      );

      FlutterDownloader.registerCallback((id, status, progress) {
        if (status == DownloadTaskStatus.failed.index) {
          print('Download $id failed');
          // You can display an error message to the user here
        } else if (status == DownloadTaskStatus.complete.index) {
          print('Download $id complete');
          // Handle the completed download here if needed
        }
      });

      // Handle the taskId if needed
      print('Task ID: $taskId');
    } else {
      setState(() {
        _isValidUrl = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Enter Video URL',
                errorText: !_isValidUrl ? 'Invalid URL' : null,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _downloadVideo,
              child: const Text('Download Video'),
            ),
          ],
        ),
      ),
    );
  }
}
