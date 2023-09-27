import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandemic/controller/service.dart';
import 'package:pandemic/core/utils.dart';
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

  final ServiceController _controller = ServiceController();
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    // _videoController = VideoPlayerController.networkUrl(Uri.parse(''));
    // // _videoController!.initialize().then((_) {
    // //   setState(() {});
    // // });
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
    _videoController!.dispose();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        child: TextButton.icon(
                          onPressed: () {
                            ref.watch(serviceProvider.notifier).downloadVideo(
                                  context: context,
                                  url: _urlController.text.trim(),
                                );
                            _videoController = VideoPlayerController.networkUrl(
                                Uri.parse(ref.watch(urlStringProvider)));
                            _videoController!.initialize().then((_) {
                              setState(() {});
                            });
                            print(ref.watch(urlStringProvider));
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("fetch"),
                          style: ElevatedButton.styleFrom(
                            shape: const BeveledRectangleBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _videoController!.value.isInitialized,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Chewie(
                        controller: ChewieController(
                          videoPlayerController: _videoController!,
                          showControls: true,
                          autoPlay: true,
                          allowMuting: true,
                          looping: true,
                          aspectRatio: _videoController!.value.aspectRatio,
                          errorBuilder: (context, errorMessage) {
                            return Text(errorMessage);
                          },
                          placeholder: Text("Loading..."),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
