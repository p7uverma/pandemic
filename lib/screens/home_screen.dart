import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tier/controller/service.dart';
import 'package:tier/core/utils.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:video_player/video_player.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final TextEditingController _urlController = TextEditingController();
  late StreamSubscription _intentDataStreamSubscription;

  int progress = 0;

  final ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");
    sendPort?.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");
    _receivePort.listen((message) {
      setState(() {
        progress = message[2];
      });

      print(progress);
    });

    FlutterDownloader.registerCallback(downloadingCallback);

    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen(
      (String? value) {
        if (value != null) {
          setState(() {
            _urlController.text = value;
          });
        }
      },
      cancelOnError: true,
    );

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value != null) {
        setState(() {
          _urlController.text = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(serviceProvider);
    return GestureDetector(
      onTap: hideKeyboard,
      child: SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Tier",
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.grey.shade200,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.settings, size: 34),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                keyboardType: TextInputType.url,
                                decoration: const InputDecoration(
                                  hintText: 'Enter url..',
                                  contentPadding: EdgeInsets.all(4),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: IconButton(
                                onPressed: () async {
                                  await ref
                                      .watch(serviceProvider.notifier)
                                      .fetchUrl(
                                        _urlController.text.trim(),
                                      );

                                  log(ref.watch(urlResponseProvider)?.message ??
                                      "");
                                },
                                icon: const Icon(Icons.play_arrow_rounded),
                                style: ElevatedButton.styleFrom(
                                  shape: const BeveledRectangleBorder(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: IconButton(
                                onPressed: ref.watch(urlResponseProvider) ==
                                            null ||
                                        ref.watch(urlResponseProvider)?.error !=
                                            ""
                                    ? null
                                    : () async {
                                        await ref
                                            .watch(serviceProvider.notifier)
                                            .downloadVideo(
                                                context: context,
                                                url: ref
                                                    .watch(urlResponseProvider)!
                                                    .message);
                                        log(ref
                                            .watch(urlResponseProvider)!
                                            .message);
                                      },
                                icon: const Icon(Icons.download_rounded),
                                style: ElevatedButton.styleFrom(
                                  shape: const BeveledRectangleBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: LinearProgressIndicator(),
                            )
                          : Container(),
                      _buildBody(context, isLoading, ref),
                    ]))),
      ),
    );
  }
}

Widget _buildBody(BuildContext context, bool isLoading, WidgetRef ref) {
  final responseModel = ref.watch(urlResponseProvider);

  // Check if the response model is not null and has a message and type
  if (responseModel != null &&
      responseModel.message.isNotEmpty &&
      responseModel.type.isNotEmpty) {
    // Depending on the type, render either a video or an image
    if (responseModel.type == 'video') {
      return _buildVideoOrImage(
        responseModel.message,
        isVideo: true,
      );
    } else if (responseModel.type == 'image' ||
        responseModel.type == 'custom') {
      return _buildVideoOrImage(
        responseModel.message,
        isVideo: false,
      );
    }
  }

  // Default UI when no valid response is available
  return Container();
}

Widget _buildVideoOrImage(String url, {required bool isVideo}) {
  if (isVideo) {
    return _buildVideo(url);
  } else {
    return _buildImage(url);
  }
}

Widget _buildVideo(String videoUrl) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Chewie(
        // Set up Chewie for video playback
        controller: ChewieController(
          videoPlayerController: VideoPlayerController.network(videoUrl)
            ..setVolume(0),
          showControls: true,
          autoPlay: true,
          allowMuting: true,
          looping: true,
          // autoInitialize: true,
          aspectRatio: 16 / 9,
          errorBuilder: (context, errorMessage) {
            // Handle video playback error here, e.g., show an error message
            return Center(
              child: Text("Video playback error: $errorMessage"),
            );
          },
          // You can set other properties here
        ),
      ),
    ),
  );
}

Widget _buildImage(String imageUrl) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(imageUrl),
    ),
  );
}
