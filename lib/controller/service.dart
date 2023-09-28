import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:tier/core/constants.dart';
import 'package:tier/models/url_response_model.dart';

final serviceProvider = StateNotifierProvider<ServiceController, bool>(
  (ref) => ServiceController(ref: ref),
);

final urlResponseProvider = StateProvider<UrlResponseModel?>(
  (ref) => null, // Initialize with null or a default value
);

class ServiceController extends StateNotifier<bool> {
  final Ref _ref;
  ServiceController({
    required Ref ref,
  })  : _ref = ref,
        super(false);

  UrlResponseModel responseModel = UrlResponseModel(
    message: '',
    id: 0,
    error: '',
    type: '',
    code: '',
    service: '',
  );

  Future<void> fetchUrl(String rawUrl) async {
    try {
      state = true;

      final apiUrl = rawUrl.contains('instagram.com')
          ? "${Constants.apiUrl}/reel/$rawUrl"
          : "${Constants.apiUrl}/twitter/$rawUrl";

      final response = await http.get(Uri.parse(apiUrl));
      state = false;

      responseModel = UrlResponseModel.fromJson(response.body);

      // return responseModel;
      _ref.watch(urlResponseProvider.notifier).update((state) => responseModel);
    } catch (error) {
      debugPrint('Error fetching URL: $error');
      state = false;
      final errorResponseModel = UrlResponseModel(
        message: '',
        id: 0,
        error: 'An error occurred while fetching the URL.',
        type: '', // Fix the 'type' value as needed
        code: '',
        service: '',
      );

      // Update the urlResponseProvider with the error data
      _ref
          .watch(urlResponseProvider.notifier)
          .update((state) => errorResponseModel);
    }
  }

  Future<void> downloadVideo({
    required BuildContext context,
    required String url,
  }) async {
    if (Uri.parse(url).isAbsolute) {
      final status = await Permission.storage.request();

      if (status.isGranted) {
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final downloadDir = "${externalDir.path}/Downloads";
            final savedDir = Directory(downloadDir);
            bool hasExisted = await savedDir.exists();
            if (!hasExisted) {
              savedDir.create();
            }

            final taskId = await FlutterDownloader.enqueue(
              url: url,
              savedDir: downloadDir,
              fileName: DateTime.now().toString().trim().replaceAll(' ', '-'),
              showNotification: true,
              openFileFromNotification: true,
            );
            debugPrint('Download started with ID: $taskId');
          } else {
            debugPrint("Failed to get external storage directory.");
          }
        } catch (e) {
          debugPrint("Error downloading file: $e");
        }
      } else {
        debugPrint("Permission denied for storage access");
      }
    } else {
      debugPrint('Invalid URL: $url');
      // Handle invalid URL as needed
    }
  }
}
