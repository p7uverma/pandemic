import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  final TextEditingController _urlController = TextEditingController();
  bool _isValidUrl = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(''));
    _controller!.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player App'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Video URL',
                errorText: _isValidUrl ? null : 'Invalid URL',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _playVideo();
              },
              child: const Text('Play Video'),
            ),
            ElevatedButton(
              onPressed: () {
                _downloadVideo();
              },
              child: Text('Download Video'),
            ),
            const SizedBox(height: 20),
            _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _downloadVideo() async {
    final url = _urlController.text.trim();
    if (Uri.parse(url).isAbsolute) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        try {
          final appDocumentsDirectory =
              await getApplicationDocumentsDirectory();
          final savedDir = appDocumentsDirectory.path;

          final taskId = await FlutterDownloader.enqueue(
            url: url,
            savedDir: savedDir,
            showNotification: true,
            openFileFromNotification: true,
            saveInPublicStorage: true,
            allowCellular: true,
            fileName: '12${url[1]}',
          );

          // Handle the taskId, if needed
          FlutterDownloader.registerCallback((id, status, progress) {
            if (status == DownloadTaskStatus.failed.index) {
              print('Download $id failed');
              // You can display an error message to the user here
            } else if (status == DownloadTaskStatus.complete.index) {
              print('Download $id complete');
              // Handle the completed download here if needed
            }
          });

          print('Task ID: $taskId');
        } catch (error) {
          print('Download Error: $error');
        }
      } else {
        print('Permission denied');
      }
    } else {
      setState(() {
        _isValidUrl = false;
      });
    }
  }

  void _playVideo() {
    final String url = _urlController.text.trim();
    if (Uri.parse(url).isAbsolute) {
      setState(() {
        _isValidUrl = true;
      });
      _controller!.pause();
      _controller!.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller!.initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
    } else {
      setState(() {
        _isValidUrl = false;
      });
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    _urlController.dispose();
    super.dispose();
  }
}
