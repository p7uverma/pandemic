import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandemic/core/constants.dart';
import 'package:pandemic/core/utils.dart';
import 'package:pandemic/models/url_response_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final serviceProvider = StateNotifierProvider<ServiceController, bool>((ref) {
  return ServiceController();
});

final urlStringProvider =
    Provider((ref) => ref.watch(serviceProvider.notifier).vidUrl);

class ServiceController extends StateNotifier<bool> {
  ServiceController() : super(false);

  String vidUrl = "";

  Future<UrlResponseModel> fetchUrl(String rawUrl) async {
    state = true;
    final res = await http.get(
      Uri.parse("${Constants.apiUrl}/reel/$rawUrl"),
    );
    state = false;
    hideKeyboard();

    // vidUrl = UrlResponseModel.fromJson(res.body).message;
    return UrlResponseModel.fromJson(res.body);
  }

  Future<void> downloadVideo({
    required BuildContext context,
    required String url,
  }) async {
    if (!url.contains('instagram.com')) {
      showSnackBar(context, "Invaild Url (Should be from Instagram)");
      return;
    }
    final url_model = await fetchUrl(url);
    vidUrl = url_model.message;
    return;

    if (Uri.parse(url_model.message).isAbsolute) {
      // final status = await FlutterDownloader.initialize();
      // if (status == DownloadTaskStatus.undefined) {
      //   print('Could not initialize Flutter Downloader');
      //   return;
      // }

      final appDocumentsDirectory = await getApplicationDocumentsDirectory();
      final savedDir = appDocumentsDirectory.path;

      final taskId = await FlutterDownloader.enqueue(
        url: url_model.message,
        savedDir: savedDir,
        showNotification: true,
        openFileFromNotification: true,
        fileName:
            '${url_model.id}/${url_model.message[60]}', // Specify the desired file name
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
    } else {}
  }
}
